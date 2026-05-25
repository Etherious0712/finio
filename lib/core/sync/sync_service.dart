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

  Future<int> syncPending() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 0;

    final unsynced = await _db.transactionDao.getUnsyncedTransactions();
    int count = 0;

    for (final tx in unsynced) {
      final row = await _supabase
          .from('transactions')
          .upsert({
            'user_id': user.id,
            'title': tx.title,
            'amount': tx.amount,
            'type': tx.type,
            'category': tx.category,
            'note': tx.note,
            'date': tx.date.toUtc().toIso8601String(),
            'updated_at': tx.updatedAt.toUtc().toIso8601String(),
            'currency_code': tx.currencyCode,
          })
          .select('id')
          .single();

      final remoteId = row['id'] as String;
      await _db.transactionDao.markSynced(tx.id, remoteId);
      count++;
    }

    return count;
  }

  Future<int> downloadAll() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 0;

    final rows = await _supabase
        .from('transactions')
        .select()
        .eq('user_id', user.id);

    int count = 0;

    for (final row in rows) {
      final remoteId = row['id'] as String;
      final existing = await _db.transactionDao.getTransactionBySyncId(remoteId);
      if (existing != null) continue;

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
          syncId: Value(remoteId),
          isSynced: const Value(true),
          currencyCode: Value(row['currency_code'] as String? ?? 'USD'),
        ),
      );
      count++;
    }

    return count;
  }

  Future<void> syncAll() async {
    await syncPending();
    await downloadAll();
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.read(appDatabaseProvider);
  final supabase = ref.read(supabaseClientProvider);
  return SyncService(db, supabase);
});
