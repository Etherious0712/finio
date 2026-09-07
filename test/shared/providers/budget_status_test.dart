import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finio/core/database/app_database.dart';
import 'package:finio/shared/providers/budget_providers.dart';
import 'package:finio/shared/providers/category_providers.dart';
import 'package:finio/shared/providers/database_provider.dart';
import 'package:finio/shared/providers/transaction_providers.dart';

/// Budget spend: the window, the sub-category rollup, and the month override.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() {
    container.dispose();
    return db.close();
  });

  Future<void> addBudget({
    String? category,
    double amount = 500,
    String period = 'month',
    int month = 0,
    int year = 0,
    double? override,
  }) =>
      db.budgetDao.insertBudget(BudgetsCompanion.insert(
        category: Value(category),
        amount: amount,
        period: Value(period),
        month: month,
        year: year,
        overrideAmount: Value(override),
      ));

  Future<void> addExpense(double amount, String category, DateTime date) =>
      db.transactionDao.insertTransaction(TransactionsCompanion.insert(
        title: '',
        amount: amount,
        type: 'expense',
        category: category,
        date: date,
      ));

  /// Subscribe after seeding so the first stream emission already carries it.
  Future<void> settle() async {
    container.listen(budgetStatusesProvider, (_, _) {});
    await container.read(allTransactionsProvider.future);
    await container.read(budgetsProvider.future);
    await container.read(allCategoriesProvider.future);
  }

  test('spend inside the window counts, outside does not', () async {
    final now = DateTime.now();
    await addBudget(category: 'catFood');
    await addExpense(30, 'catFood', DateTime(now.year, now.month, 1));
    // Last month — same category, outside the window.
    await addExpense(999, 'catFood', DateTime(now.year, now.month - 1, 15));
    await settle();

    final s = container.read(budgetStatusesProvider).single;
    expect(s.spent, 30);
    expect(s.limit, 500);
    expect(s.overridden, isFalse);
  });

  test('sub-category spend counts toward its parent budget', () async {
    final now = DateTime.now();
    final parentId = await db.categoryDao.getAllCategories().then(
        (cats) => cats.firstWhere((c) => c.name == 'catFood').id);
    await db.categoryDao.findOrCreateSub(
      parentId: parentId,
      name: 'kopitiam',
      type: 'expense',
      icon: 'restaurant',
      color: '#FF6B6B',
    );
    await addBudget(category: 'catFood');
    await addExpense(20, 'kopitiam', DateTime(now.year, now.month, 2));
    await settle();

    expect(container.read(budgetStatusesProvider).single.spent, 20);
  });

  test('a transfer never counts toward a budget', () async {
    final now = DateTime.now();
    await addBudget(); // overall
    await db.transactionDao.insertTransaction(TransactionsCompanion.insert(
      title: 'move',
      amount: 200,
      type: 'transfer',
      category: 'catTransfer',
      date: DateTime(now.year, now.month, 3),
      account: const Value('Cash'),
      toAccount: const Value('Bank'),
    ));
    await settle();

    expect(container.read(budgetStatusesProvider).single.spent, 0);
  });

  test('the override applies inside the month it names', () async {
    final now = DateTime.now();
    await addBudget(
      category: 'catFood',
      month: now.month,
      year: now.year,
      override: 1500,
    );
    await settle();

    final s = container.read(budgetStatusesProvider).single;
    expect(s.limit, 1500);
    expect(s.overridden, isTrue);
  });

  test('an overall budget counts every expense category', () async {
    final now = DateTime.now();
    await addBudget();
    await addExpense(30, 'catFood', DateTime(now.year, now.month, 4));
    await addExpense(70, 'catTransport', DateTime(now.year, now.month, 5));
    await settle();

    expect(container.read(budgetStatusesProvider).single.spent, 100);
  });
}
