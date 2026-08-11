import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:finio/core/database/app_database.dart';
import 'package:finio/shared/providers/auth_provider.dart';
import 'package:finio/shared/providers/database_provider.dart';

class SyncService {
  SyncService(this._db, this._supabase);

  final AppDatabase _db;
  final SupabaseClient _supabase;

  Future<void> syncOnLogin() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _pushLocalChanges(userId);
    await _pullCloudChanges(userId);
  }

  // ── Push local changes to the cloud ──────────────────────────────────────

  Future<void> _pushLocalChanges(String userId) async {
    final unsynced = await _db.transactionDao.getUnsyncedTransactions();

    for (final t in unsynced) {
      if (t.isDeleted) {
        // DELETE: remove from Supabase, then hard-delete locally
        if (t.syncId != null) {
          await _supabase
              .from('transactions')
              .delete()
              .eq('id', t.syncId!);
        }
        await _db.transactionDao.hardDeleteTransaction(t.id);
      } else if (t.syncId == null) {
        // CREATE: insert new record and capture its cloud ID
        final response = await _supabase
            .from('transactions')
            .insert({
              'user_id': userId,
              'title': t.title,
              'amount': t.amount,
              'type': t.type,
              'category': t.category,
              'note': t.note,
              'date': t.date.toUtc().toIso8601String(),
              'currency_code': t.currencyCode,
              'account': t.account,
              'updated_at': t.updatedAt.toUtc().toIso8601String(),
            })
            .select('id')
            .single();

        await _db.transactionDao.updateSyncId(t.id, response['id'] as String);
        await _db.transactionDao.markSynced(t.id);
      } else {
        // MODIFY: update the existing cloud record
        await _supabase
            .from('transactions')
            .update({
              'title': t.title,
              'amount': t.amount,
              'type': t.type,
              'category': t.category,
              'note': t.note,
              'date': t.date.toUtc().toIso8601String(),
              'currency_code': t.currencyCode,
              'account': t.account,
              'updated_at': t.updatedAt.toUtc().toIso8601String(),
            })
            .eq('id', t.syncId!);

        await _db.transactionDao.markSynced(t.id);
      }
    }
  }

  // ── Pull cloud records that don't exist locally ───────────────────────────

  Future<void> _pullCloudChanges(String userId) async {
    final cloudData = await _supabase
        .from('transactions')
        .select()
        .eq('user_id', userId);

    for (final row in cloudData) {
      final syncId = row['id'] as String;
      final existing = await _db.transactionDao.getTransactionBySyncId(syncId);
      if (existing != null) continue;

      // Savings jars are referenced by name and are local-only, so a record
      // arriving from another device needs its jar materialised here. Icon and
      // color don't sync in v1 — a recreated jar gets the DAO's defaults and
      // the user can restyle it.
      final account = row['account'] as String?;
      if (account != null && account.isNotEmpty) {
        await _db.accountDao.findOrCreateByName(account);
      }

      // Cloud record not found locally → download it
      await _db.transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          title: row['title'] as String,
          amount: (row['amount'] as num).toDouble(),
          type: row['type'] as String,
          category: row['category'] as String,
          note: Value(row['note'] as String?),
          date: DateTime.parse(row['date'] as String).toLocal(),
          createdAt: Value(DateTime.parse(row['created_at'] as String).toLocal()),
          updatedAt: Value(DateTime.parse(row['updated_at'] as String).toLocal()),
          currencyCode: Value(row['currency_code'] as String? ?? 'USD'),
          account: Value(account),
          syncId: Value(syncId),
          isSynced: const Value(true),
        ),
      );
    }
  }

  // Alias kept so existing callers (app.dart, settings_screen.dart) don't break.
  Future<void> syncAll() => syncOnLogin();
}

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.read(appDatabaseProvider);
  final supabase = ref.read(supabaseClientProvider);
  return SyncService(db, supabase);
});
