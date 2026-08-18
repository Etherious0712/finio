import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finio/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Future<int> addJar(String name) => db.accountDao.insertAccount(
        AccountsCompanion.insert(name: name, icon: 'savings', color: '#4ECDC4'),
      );

  Future<void> addTx({
    required String type,
    required double amount,
    String? account,
  }) =>
      db.transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          title: 'test',
          amount: amount,
          type: type,
          category: type == 'income' ? 'catSalary' : 'catFood',
          date: DateTime(2024, 1, 1),
          account: Value(account),
        ),
      );

  test('setDefault leaves exactly one default jar', () async {
    final bank = await addJar('Maybank');
    final wallet = await addJar('TNG eWallet');

    await db.accountDao.setDefault(bank);
    expect((await db.accountDao.getDefaultAccount())?.id, bank);

    // Switching must clear the previous default, not add a second one.
    await db.accountDao.setDefault(wallet);
    final all = await db.accountDao.getAllAccounts();
    expect(all.where((a) => a.isDefault).map((a) => a.id), [wallet]);
    expect((await db.accountDao.getDefaultAccount())?.id, wallet);
  });

  test('renameAccount re-points the jar and its transactions', () async {
    final id = await addJar('Maybank');
    await addTx(type: 'expense', amount: 10, account: 'Maybank');
    await addTx(type: 'income', amount: 50, account: 'Maybank');
    // A record in a different jar must be left alone.
    await addJar('TNG eWallet');
    await addTx(type: 'expense', amount: 5, account: 'TNG eWallet');

    await db.accountDao.renameAccount(
      id: id,
      oldName: 'Maybank',
      newName: 'Maybank Savings',
    );

    final jars = await db.accountDao.getAllAccounts();
    expect(jars.firstWhere((a) => a.id == id).name, 'Maybank Savings');

    final txs = await db.transactionDao.searchTransactions('');
    expect(txs.where((t) => t.account == 'Maybank Savings').length, 2);
    expect(txs.where((t) => t.account == 'Maybank'), isEmpty);
    expect(txs.where((t) => t.account == 'TNG eWallet').length, 1);
  });

  test('renameAccount also re-points transfers arriving at the account',
      () async {
    await addJar('Cash');
    final id = await addJar('Maybank');
    await db.transactionDao.insertTransaction(
      TransactionsCompanion.insert(
        title: 'top up',
        amount: 200,
        type: 'transfer',
        category: 'catTransfer',
        date: DateTime(2024, 1, 1),
        account: const Value('Cash'),
        toAccount: const Value('Maybank'),
      ),
    );

    await db.accountDao
        .renameAccount(id: id, oldName: 'Maybank', newName: 'MB');

    final tx = (await db.transactionDao.searchTransactions('')).single;
    expect(tx.account, 'Cash');
    expect(tx.toAccount, 'MB');
  });

  test('renamed transactions are re-flagged for sync', () async {
    final id = await addJar('Maybank');
    await addTx(type: 'expense', amount: 10, account: 'Maybank');
    // Pretend the record already reached the cloud.
    final tx = (await db.transactionDao.searchTransactions('')).single;
    await db.transactionDao.markSynced(tx.id);

    await db.accountDao
        .renameAccount(id: id, oldName: 'Maybank', newName: 'MB');

    final unsynced = await db.transactionDao.getUnsyncedTransactions();
    expect(unsynced.map((t) => t.account), ['MB']);
  });

  test('findOrCreateByName is idempotent', () async {
    final first = await db.accountDao.findOrCreateByName('Cash');
    final second = await db.accountDao.findOrCreateByName('Cash');
    expect(second.id, first.id);
    expect((await db.accountDao.getAllAccounts()).length, 1);
  });

  test('deleteAllAccounts clears every jar', () async {
    await addJar('Maybank');
    await addJar('TNG eWallet');
    await db.accountDao.deleteAllAccounts();
    expect(await db.accountDao.getAllAccounts(), isEmpty);
  });
}
