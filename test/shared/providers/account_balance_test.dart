import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finio/core/database/app_database.dart';
import 'package:finio/shared/models/stats_models.dart';
import 'package:finio/shared/providers/account_providers.dart';
import 'package:finio/shared/providers/database_provider.dart';
import 'package:finio/shared/providers/statistics_providers.dart';
import 'package:finio/shared/providers/transaction_providers.dart';

/// Balance math: opening balances, transfers, and credit-card debt in the
/// net-worth total.
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

  Future<void> addAccount(
    String name, {
    String type = 'savings',
    double opening = 0,
    double? limit,
  }) =>
      db.accountDao.insertAccount(AccountsCompanion.insert(
        name: name,
        icon: 'savings',
        color: '#4ECDC4',
        type: Value(type),
        openingBalance: Value(opening),
        creditLimit: Value(limit),
      ));

  Future<void> addTx({
    required String type,
    required double amount,
    String? account,
    String? toAccount,
    DateTime? date,
  }) =>
      db.transactionDao.insertTransaction(TransactionsCompanion.insert(
        title: 'test',
        amount: amount,
        type: type,
        category: switch (type) {
          'income' => 'catSalary',
          'transfer' => 'catTransfer',
          _ => 'catFood',
        },
        date: date ?? DateTime(2024, 1, 15),
        account: Value(account),
        toAccount: Value(toAccount),
      ));

  /// Subscribes and waits for the drift streams to deliver. Called *after* the
  /// rows are seeded so the first emission already carries them — subscribing
  /// in setUp would resolve `.future` against an empty database.
  Future<void> settle() async {
    container.listen(accountBalancesProvider, (_, _) {});
    await container.read(allTransactionsProvider.future);
    await container.read(accountsProvider.future);
  }

  AccountBalance accountOf(String name) => container
      .read(accountBalancesProvider)
      .firstWhere((b) => b.name == name);

  double balanceOf(String name) => accountOf(name).balance;

  test('opening balance seeds the account with no transactions', () async {
    await addAccount('Cash', type: 'cash', opening: 500);
    await settle();

    expect(balanceOf('Cash'), 500);
    expect(container.read(totalBalanceProvider), 500);
  });

  test('a transfer moves money and leaves net worth unchanged', () async {
    await addAccount('Cash', type: 'cash', opening: 500);
    await addAccount('Maybank', type: 'bank');
    await addTx(
        type: 'transfer', amount: 200, account: 'Cash', toAccount: 'Maybank');
    await settle();

    expect(balanceOf('Cash'), 300);
    expect(balanceOf('Maybank'), 200);
    expect(container.read(totalBalanceProvider), 500);
  });

  test('credit-card debt subtracts from net worth', () async {
    await addAccount('Maybank', type: 'bank', opening: 1000);
    await addAccount('Visa', type: 'creditCard', opening: -500);
    // A charge on the card is an expense filed to it, deepening the debt.
    await addTx(type: 'expense', amount: 100, account: 'Visa');
    await settle();

    expect(balanceOf('Maybank'), 1000);
    expect(balanceOf('Visa'), -600);
    expect(container.read(totalBalanceProvider), 400);
  });

  test('paying the card off with a transfer shifts the debt, not net worth',
      () async {
    await addAccount('Maybank', type: 'bank', opening: 1000);
    await addAccount('Visa', type: 'creditCard', opening: -500);
    await addTx(
        type: 'transfer', amount: 500, account: 'Maybank', toAccount: 'Visa');
    await settle();

    expect(balanceOf('Maybank'), 500);
    expect(balanceOf('Visa'), 0);
    expect(container.read(totalBalanceProvider), 500);
  });

  test('a transfer counts as neither income nor expense', () async {
    final now = DateTime.now();
    await addAccount('Cash', type: 'cash');
    await addAccount('Maybank', type: 'bank');
    await addTx(
      type: 'transfer',
      amount: 200,
      account: 'Cash',
      toAccount: 'Maybank',
      date: now,
    );
    await settle();
    container.listen(monthlyTransactionsProvider, (_, _) {});
    await container.read(monthlyTransactionsProvider.future);

    expect(container.read(monthlyIncomeProvider), 0);
    expect(container.read(monthlyExpenseProvider), 0);

    final totals =
        await db.transactionDao.getMonthlyTotals(now.year, now.month);
    expect(totals['income'], 0);
    expect(totals['expense'], 0);
  });

  test('records whose account was deleted fall into unassigned', () async {
    await addAccount('Cash', type: 'cash');
    await addTx(type: 'expense', amount: 30, account: 'Ghost');
    await settle();

    final balances = container.read(accountBalancesProvider);
    expect(balances.map((b) => b.name), containsAll(['Cash', '']));
    expect(balances.firstWhere((b) => b.isUnassigned).balance, -30);
  });

  group('credit cards', () {
    test('owed and available credit follow the balance', () async {
      await addAccount('Visa', type: 'creditCard', opening: -500, limit: 2000);
      await addTx(type: 'expense', amount: 100, account: 'Visa');
      await settle();

      final card = accountOf('Visa');
      expect(card.isCreditCard, isTrue);
      expect(card.owed, 600);
      expect(card.overpaid, 0);
      expect(card.available, 1400);
    });

    test('a card with no limit has no available credit', () async {
      await addAccount('Visa', type: 'creditCard', opening: -50);
      await settle();

      expect(accountOf('Visa').available, isNull);
    });

    test('paying past zero is an overpayment that adds to available',
        () async {
      await addAccount('Maybank', type: 'bank', opening: 1000);
      await addAccount('Visa', type: 'creditCard', opening: -100, limit: 2000);
      await addTx(
          type: 'transfer', amount: 150, account: 'Maybank', toAccount: 'Visa');
      await settle();

      final card = accountOf('Visa');
      expect(card.owed, 0);
      expect(card.overpaid, 50);
      expect(card.available, 2050);
      expect(container.read(totalBalanceProvider), 900);
    });

    test('a refund lowers the debt and takes back spending, not income',
        () async {
      final now = DateTime.now();
      await addAccount('Visa', type: 'creditCard', limit: 1000);
      await addTx(type: 'expense', amount: 80, account: 'Visa', date: now);
      await addTx(type: 'refund', amount: 30, account: 'Visa', date: now);
      await settle();
      container.listen(monthlyTransactionsProvider, (_, _) {});
      await container.read(monthlyTransactionsProvider.future);

      expect(accountOf('Visa').owed, 50);
      expect(container.read(monthlyIncomeProvider), 0);
      expect(container.read(monthlyExpenseProvider), 50);

      final totals =
          await db.transactionDao.getMonthlyTotals(now.year, now.month);
      expect(totals['income'], 0);
      expect(totals['expense'], 50);
    });

    test('a refund offsets its expense category in statistics', () async {
      final now = DateTime.now();
      await addAccount('Visa', type: 'creditCard', limit: 1000);
      await addTx(type: 'expense', amount: 80, account: 'Visa', date: now);
      await addTx(type: 'refund', amount: 30, account: 'Visa', date: now);
      await settle();
      container.listen(categoryStatsProvider('expense'), (_, _) {});
      await container.read(monthlyTransactionsProvider.future);

      final food = container
          .read(categoryStatsProvider('expense'))
          .singleWhere((s) => s.category == 'catFood');
      expect(food.amount, 50);
      // Never shows up on the income side.
      expect(container.read(categoryStatsProvider('income')), isEmpty);
    });
  });
}
