import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/stats_models.dart';
import 'category_providers.dart';
import 'database_provider.dart';
import 'transaction_providers.dart';

/// Per-type category breakdown for the currently selected month.
/// Watches monthlyTransactionsProvider so it reacts to month changes + new entries.
final categoryStatsProvider =
    Provider.autoDispose.family<List<CategoryStat>, String>((ref, type) {
  final txs = ref.watch(monthlyTransactionsProvider).valueOrNull ?? [];
  final cats = ref.watch(categoriesByTypeProvider(type)).valueOrNull ?? [];

  final catMap = {for (final c in cats) c.name: c};

  final totals = <String, double>{};
  for (final tx in txs.where((t) => t.type == type)) {
    totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
  }

  final grandTotal = totals.values.fold(0.0, (a, b) => a + b);
  if (grandTotal == 0) return [];

  final result = totals.entries.map((e) {
    final cat = catMap[e.key];
    return CategoryStat(
      category: e.key,
      icon: cat?.icon ?? 'more_horiz',
      color: cat?.color ?? '#B0B0B0',
      amount: e.value,
      percentage: e.value / grandTotal * 100,
    );
  }).toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));

  return result;
});

/// Last 6 months income + expense totals. Refreshes when any transaction changes
/// (watches monthlyTransactionsProvider as a reactive trigger).
final last6MonthsProvider =
    FutureProvider.autoDispose<List<MonthSummary>>((ref) async {
  ref.watch(monthlyTransactionsProvider); // reactive refresh trigger
  final db = ref.watch(appDatabaseProvider);
  final now = DateTime.now();

  final result = <MonthSummary>[];
  for (int i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i);
    final totals =
        await db.transactionDao.getMonthlyTotals(month.year, month.month);
    result.add(MonthSummary(
      month: month,
      income: totals['income']!,
      expense: totals['expense']!,
    ));
  }
  return result;
});
