import 'package:drift/drift.dart';

import '../app_database.dart';

part 'budget_dao.g.dart';

@DriftAccessor(tables: [Budgets])
class BudgetDao extends DatabaseAccessor<AppDatabase> with _$BudgetDaoMixin {
  BudgetDao(super.db);

  // Streams (reactive UI)

  Stream<Budget?> watchOverallBudget() =>
      (select(budgets)
            ..where((b) =>
                b.category.isNull() & b.month.equals(0) & b.year.equals(0)))
          .watchSingleOrNull();

  Stream<List<Budget>> watchCategoryBudgets() =>
      (select(budgets)
            ..where((b) =>
                b.category.isNotNull() &
                b.month.equals(0) &
                b.year.equals(0)))
          .watch();

  // One-shot reads

  Future<List<Budget>> getBudgets() => select(budgets).get();

  Future<Budget?> getOverallBudget() =>
      (select(budgets)
            ..where((b) =>
                b.category.isNull() & b.month.equals(0) & b.year.equals(0)))
          .getSingleOrNull();

  Future<List<Budget>> getCategoryBudgets() =>
      (select(budgets)
            ..where((b) =>
                b.category.isNotNull() &
                b.month.equals(0) &
                b.year.equals(0)))
          .get();

  // Upsert: insert if not exists, update amount if exists (month=0, year=0 = monthly repeat)
  Future<void> upsertBudget({String? category, required double amount}) async {
    final existing = category == null
        ? await (select(budgets)
              ..where((b) =>
                  b.category.isNull() &
                  b.month.equals(0) &
                  b.year.equals(0)))
            .getSingleOrNull()
        : await (select(budgets)
              ..where((b) =>
                  b.category.equals(category) &
                  b.month.equals(0) &
                  b.year.equals(0)))
            .getSingleOrNull();

    if (existing != null) {
      await (update(budgets)..where((b) => b.id.equals(existing.id)))
          .write(BudgetsCompanion(amount: Value(amount)));
    } else {
      await into(budgets).insert(BudgetsCompanion.insert(
        category: Value<String?>(category),
        amount: amount,
        month: 0,
        year: 0,
      ));
    }
  }

  Future<int> deleteBudget(int id) =>
      (delete(budgets)..where((b) => b.id.equals(id))).go();

  Future<int> deleteAllBudgets() => delete(budgets).go();
}
