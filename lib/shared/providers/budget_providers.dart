import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import 'database_provider.dart';

/// Reactive overall budget (category IS NULL, month=0, year=0). Null when not set.
final overallBudgetProvider = StreamProvider<Budget?>((ref) {
  return ref.watch(appDatabaseProvider).budgetDao.watchOverallBudget();
});

/// Reactive list of all category budgets (category IS NOT NULL, month=0, year=0).
final categoryBudgetsProvider = StreamProvider<List<Budget>>((ref) {
  return ref.watch(appDatabaseProvider).budgetDao.watchCategoryBudgets();
});
