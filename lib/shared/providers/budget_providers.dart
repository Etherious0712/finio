import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finio/core/database/app_database.dart';
import '../utils/budget_period.dart';
import 'category_providers.dart';
import 'database_provider.dart';
import 'transaction_providers.dart';

/// Every budget the user created.
final budgetsProvider = StreamProvider<List<Budget>>(
    (ref) => ref.watch(appDatabaseProvider).budgetDao.watchBudgets());

/// A budget plus the spend for the window it is in right now.
class BudgetStatus {
  const BudgetStatus({
    required this.budget,
    required this.spent,
    required this.limit,
    required this.overridden,
  });

  final Budget budget;
  final double spent;

  /// The override amount when this window is overridden, else `budget.amount`.
  final double limit;
  final bool overridden;
}

/// Budgets with their spend.
///
/// Anchored on `now()`, deliberately **not** on [selectedMonthProvider] or
/// [recordScopeProvider]: a budget answers "am I over right now", and the old
/// screen compared a monthly budget against a whole year of spending whenever
/// Records was set to Year. It is also the only anchor that means anything for
/// a weekly or yearly window.
final budgetStatusesProvider = Provider<List<BudgetStatus>>((ref) {
  final budgets = ref.watch(budgetsProvider).valueOrNull ?? const [];
  final txs = ref.watch(allTransactionsProvider).valueOrNull ?? const [];
  final mainKey = ref.watch(categoryMainKeyProvider);
  final now = DateTime.now();

  // ponytail: O(budgets × transactions) scan. Bucket by category if it drags.
  final out = <BudgetStatus>[];
  for (final b in budgets) {
    final (start, end) = budgetWindow(b.period, now);
    final limit = effectiveBudget(b, start);
    var spent = 0.0;
    for (final t in txs) {
      if (t.type != 'expense') continue; // transfers are neither
      if (t.date.isBefore(start) || !t.date.isBefore(end)) continue;
      // Sub-category spend counts toward its parent, same as categoryStats.
      if (b.category != null &&
          (mainKey['expense:${t.category}'] ?? t.category) != b.category) {
        continue;
      }
      spent += t.amount;
    }
    out.add(BudgetStatus(
      budget: b,
      spent: spent,
      limit: limit,
      overridden: limit != b.amount,
    ));
  }
  return out;
});
