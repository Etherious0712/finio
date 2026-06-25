import 'package:drift/drift.dart';

import '../app_database.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  Stream<List<Transaction>> watchAllTransactions() =>
      (select(transactions)
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .watch();

  Stream<List<Transaction>> watchTransactionsByMonth(int year, int month) {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);
    return (select(transactions)
          ..where(
            (t) =>
                t.isDeleted.equals(false) &
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerThanValue(end),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<Map<String, double>> getTodayTotals() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return _sumByType(start, end);
  }

  Future<Map<String, double>> getMonthlyTotals(int year, int month) async {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1);
    return _sumByType(start, end);
  }

  Future<Map<String, double>> _sumByType(DateTime start, DateTime end) async {
    final rows = await (select(transactions)
          ..where(
            (t) =>
                t.isDeleted.equals(false) &
                t.date.isBiggerOrEqualValue(start) &
                t.date.isSmallerThanValue(end),
          ))
        .get();

    double income = 0;
    double expense = 0;
    for (final row in rows) {
      if (row.type == 'income') {
        income += row.amount;
      } else {
        expense += row.amount;
      }
    }
    return {'income': income, 'expense': expense};
  }

  Future<int> insertTransaction(TransactionsCompanion entry) =>
      into(transactions).insert(entry);

  Future<bool> updateTransaction(Transaction entry) =>
      update(transactions).replace(entry);

  // Soft-delete: marks the record as deleted and flags for sync.
  // The sync service will push the deletion to Supabase, then hard-delete locally.
  Future<void> deleteTransaction(int id) =>
      (update(transactions)..where((t) => t.id.equals(id))).write(
        TransactionsCompanion(
          isDeleted: const Value(true),
          isSynced: const Value(false),
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

  // Hard-delete used after the cloud deletion is confirmed during sync.
  Future<void> hardDeleteTransaction(int id) =>
      (delete(transactions)..where((t) => t.id.equals(id))).go();

  Future<int> deleteAllTransactions() => delete(transactions).go();

  Future<List<Transaction>> searchTransactions(String keyword) {
    final lower = keyword.toLowerCase();
    return (select(transactions)
          ..where(
            (t) =>
                t.isDeleted.equals(false) &
                (t.title.lower().like('%$lower%') |
                    t.category.lower().like('%$lower%') |
                    t.note.lower().like('%$lower%')),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  /// Multiplies every non-deleted transaction's amount by [rate].
  /// Returns the number of records updated.
  Future<int> updateAllAmounts(double rate) async {
    final all = await (select(transactions)
          ..where((t) => t.isDeleted.equals(false)))
        .get();
    final now = DateTime.now();
    for (final t in all) {
      await update(transactions).replace(
        t.copyWith(amount: t.amount * rate, isSynced: false, updatedAt: now),
      );
    }
    return all.length;
  }

  // Returns all unsynced records, including soft-deleted ones awaiting cloud deletion.
  Future<List<Transaction>> getUnsyncedTransactions() =>
      (select(transactions)..where((t) => t.isSynced.equals(false))).get();

  Future<void> updateSyncId(int id, String syncId) =>
      (update(transactions)..where((t) => t.id.equals(id))).write(
        TransactionsCompanion(syncId: Value(syncId)),
      );

  Future<void> markSynced(int id) =>
      (update(transactions)..where((t) => t.id.equals(id))).write(
        const TransactionsCompanion(isSynced: Value(true)),
      );

  Future<Transaction?> getTransactionBySyncId(String syncId) =>
      (select(transactions)..where((t) => t.syncId.equals(syncId)))
          .getSingleOrNull();
}
