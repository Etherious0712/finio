import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finio/core/database/app_database.dart';
import 'package:finio/shared/providers/database_provider.dart';

/// 当前选中月份，默认本月。用于月份切换导航。
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

/// 本月交易列表（实时 Stream，数据写入后自动推送）
final monthlyTransactionsProvider =
    StreamProvider.autoDispose<List<Transaction>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final month = ref.watch(selectedMonthProvider);
  return db.transactionDao.watchTransactionsByMonth(month.year, month.month);
});

/// 本月收入总额（从 Stream 派生，与列表同步）
final monthlyIncomeProvider = Provider.autoDispose<double>((ref) {
  final txs = ref.watch(monthlyTransactionsProvider).valueOrNull ?? [];
  return txs
      .where((t) => t.type == 'income')
      .fold(0.0, (sum, t) => sum + t.amount);
});

/// 本月支出总额
final monthlyExpenseProvider = Provider.autoDispose<double>((ref) {
  final txs = ref.watch(monthlyTransactionsProvider).valueOrNull ?? [];
  return txs
      .where((t) => t.type == 'expense')
      .fold(0.0, (sum, t) => sum + t.amount);
});

/// 今日收入（从本月 Stream 中过滤当天数据）
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

/// 今日支出
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
