import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finio/core/database/app_database.dart';
import 'package:finio/shared/providers/database_provider.dart';

/// Currently selected month (defaults to this month). Drives month navigation.
/// In [RecordScope.year] the `.year` component is the selected year; the month
/// component is preserved across scope switches.
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

/// The time granularity Records + Statistics are viewed at.
enum RecordScope { month, year, allTime }

/// Active scope, shared by Records + Statistics (like [selectedMonthProvider]).
final recordScopeProvider =
    StateProvider<RecordScope>((ref) => RecordScope.month);

/// Transactions for the active scope. Month → the selected month's live stream;
/// Year → all-time stream filtered to the selected year; All-time → everything.
final scopedTransactionsProvider =
    Provider.autoDispose<AsyncValue<List<Transaction>>>((ref) {
  switch (ref.watch(recordScopeProvider)) {
    case RecordScope.month:
      return ref.watch(monthlyTransactionsProvider);
    case RecordScope.year:
      final year = ref.watch(selectedMonthProvider).year;
      // ponytail: in-memory year filter; add a DAO query if the table grows large.
      return ref
          .watch(allTransactionsProvider)
          .whenData((txs) => txs.where((t) => t.date.year == year).toList());
    case RecordScope.allTime:
      return ref.watch(allTransactionsProvider);
  }
});

/// All non-deleted transactions (all time). Used for category usage counts.
final allTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  return ref.watch(appDatabaseProvider).transactionDao.watchAllTransactions();
});

/// How many transactions reference each category key. Drives the usage badge
/// in category management.
final categoryUsageProvider = Provider<Map<String, int>>((ref) {
  final txs = ref.watch(allTransactionsProvider).valueOrNull ?? [];
  final counts = <String, int>{};
  for (final t in txs) {
    counts[t.category] = (counts[t.category] ?? 0) + 1;
  }
  return counts;
});

/// This month's transactions (live stream; updates on write).
final monthlyTransactionsProvider =
    StreamProvider.autoDispose<List<Transaction>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final month = ref.watch(selectedMonthProvider);
  return db.transactionDao.watchTransactionsByMonth(month.year, month.month);
});

/// This month's total income (derived from the stream).
final monthlyIncomeProvider = Provider.autoDispose<double>((ref) {
  final txs = ref.watch(monthlyTransactionsProvider).valueOrNull ?? [];
  return txs
      .where((t) => t.type == 'income')
      .fold(0.0, (sum, t) => sum + t.amount);
});

/// This month's total expense.
final monthlyExpenseProvider = Provider.autoDispose<double>((ref) {
  final txs = ref.watch(monthlyTransactionsProvider).valueOrNull ?? [];
  return txs
      .where((t) => t.type == 'expense')
      .fold(0.0, (sum, t) => sum + t.amount);
});

/// Today's income (filtered from this month's stream).
final todayIncomeProvider = Provider.autoDispose<double>((ref) {
  final txs = ref.watch(monthlyTransactionsProvider).valueOrNull ?? [];
  final today = DateTime.now();
  return txs
      .where((t) =>
          t.type == 'income' &&
          t.date.year == today.year &&
          t.date.month == today.month &&
          t.date.day == today.day)
      .fold(0.0, (sum, t) => sum + t.amount);
});

/// Today's expense.
final todayExpenseProvider = Provider.autoDispose<double>((ref) {
  final txs = ref.watch(monthlyTransactionsProvider).valueOrNull ?? [];
  final today = DateTime.now();
  return txs
      .where((t) =>
          t.type == 'expense' &&
          t.date.year == today.year &&
          t.date.month == today.month &&
          t.date.day == today.day)
      .fold(0.0, (sum, t) => sum + t.amount);
});
