import 'package:drift/drift.dart';

import '../app_database.dart';

part 'budget_dao.g.dart';

@DriftAccessor(tables: [Budgets])
class BudgetDao extends DatabaseAccessor<AppDatabase> with _$BudgetDaoMixin {
  BudgetDao(super.db);

  /// Every budget the user created — the overall one (null category) first.
  Stream<List<Budget>> watchBudgets() => (select(budgets)
        ..orderBy([
          (b) => OrderingTerm(expression: b.category.isNull(), mode: OrderingMode.desc),
          (b) => OrderingTerm(expression: b.category),
        ]))
      .watch();

  Future<List<Budget>> getBudgets() => select(budgets).get();

  /// The overall budget, for the startup alert. Uses `get().firstOrNull` rather
  /// than `getSingleOrNull` so a stray duplicate can't throw before any UI has
  /// rendered — the picker is what keeps the category unique.
  Future<Budget?> getOverallBudget() async =>
      (await (select(budgets)..where((b) => b.category.isNull())).get())
          .firstOrNull;

  Future<int> insertBudget(BudgetsCompanion entry) =>
      into(budgets).insert(entry);

  Future<bool> updateBudget(Budget entry) => update(budgets).replace(entry);

  Future<int> deleteBudget(int id) =>
      (delete(budgets)..where((b) => b.id.equals(id))).go();

  Future<int> deleteAllBudgets() => delete(budgets).go();
}
