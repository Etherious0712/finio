import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:finio/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Future<void> insertTransaction(AppDatabase db) =>
      db.transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          title: 'test',
          amount: 10.0,
          type: 'expense',
          category: 'catFood',
          date: DateTime(2024, 1, 1),
        ),
      );

  test('deleteAllTransactions removes every row', () async {
    await insertTransaction(db);
    await insertTransaction(db);
    await db.transactionDao.deleteAllTransactions();
    final remaining = await db.transactionDao.searchTransactions('');
    expect(remaining, isEmpty);
  });

  test('deleteAllBudgets removes every budget row', () async {
    await db.budgetDao.upsertBudget(category: null, amount: 500.0);
    await db.budgetDao.upsertBudget(category: 'catFood', amount: 100.0);
    await db.budgetDao.deleteAllBudgets();
    final remaining = await db.budgetDao.getBudgets();
    expect(remaining, isEmpty);
  });

  test('deleteCustomCategories only removes isCustom=true rows', () async {
    // Default categories seeded by onCreate are isCustom=false — count them
    final before = await db.categoryDao.getAllCategories();
    final defaultCount = before.where((c) => !c.isCustom).length;

    // Add a custom category
    await db.categoryDao.insertCategory(
      CategoriesCompanion.insert(
        name: 'MyCustom',
        type: 'expense',
        icon: 'star',
        color: '#FF0000',
        isCustom: const Value(true),
      ),
    );

    await db.categoryDao.deleteCustomCategories();

    final after = await db.categoryDao.getAllCategories();
    expect(after.length, defaultCount);
    expect(after.every((c) => !c.isCustom), isTrue);
  });
}
