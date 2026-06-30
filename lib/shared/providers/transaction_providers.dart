import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finio/core/database/app_database.dart';
import 'package:finio/shared/providers/database_provider.dart';

/// Currently selected month (defaults to this month). Drives month navigation.
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
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

/// All-time net balance (total income − total expense). Powers the dashboard
/// headline.
final totalBalanceProvider = Provider<double>((ref) {
  final txs = ref.watch(allTransactionsProvider).valueOrNull ?? [];
  return txs.fold(
      0.0, (sum, t) => sum + (t.type == 'income' ? t.amount : -t.amount));
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
