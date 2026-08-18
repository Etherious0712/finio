import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finio/core/database/app_database.dart';

/// Opens a real v7 database file and lets the app migrate it, so the v8 step
/// (account types, opening balances, transfers, unique account names) runs
/// against pre-existing data rather than a freshly created schema.
void main() {
  late Directory tempDir;
  late File dbFile;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('finio_migration');
    dbFile = File('${tempDir.path}/v7.sqlite');
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  // Schema as it stood at v7: accounts without type/opening_balance, and
  // transactions without to_account.
  const v7Schema = '''
    CREATE TABLE transactions (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      amount REAL NOT NULL,
      type TEXT NOT NULL,
      category TEXT NOT NULL,
      note TEXT NULL,
      date INTEGER NOT NULL,
      created_at INTEGER NOT NULL DEFAULT 0,
      updated_at INTEGER NOT NULL DEFAULT 0,
      sync_id TEXT NULL,
      is_synced INTEGER NOT NULL DEFAULT 0,
      currency_code TEXT NOT NULL DEFAULT 'USD',
      is_deleted INTEGER NOT NULL DEFAULT 0,
      deleted_at INTEGER NULL,
      account TEXT NULL
    );
    CREATE TABLE accounts (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      icon TEXT NOT NULL,
      color TEXT NOT NULL,
      is_default INTEGER NOT NULL DEFAULT 0 CHECK ("is_default" IN (0, 1))
    );
    CREATE TABLE categories (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      type TEXT NOT NULL,
      icon TEXT NOT NULL,
      color TEXT NOT NULL,
      is_custom INTEGER NOT NULL DEFAULT 0,
      parent_id INTEGER NULL
    );
    CREATE TABLE budgets (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      category TEXT NULL,
      amount REAL NOT NULL,
      month INTEGER NOT NULL,
      year INTEGER NOT NULL,
      created_at INTEGER NOT NULL DEFAULT 0
    );
  ''';

  /// [extraSetup] runs after the seed data, before the version pragma.
  AppDatabase openAsV7({String extraSetup = ''}) => AppDatabase.forTesting(
        // `setup` runs on the raw handle before drift inspects the schema, so
        // the app sees a genuine v7 file and takes the onUpgrade path.
        NativeDatabase(dbFile, setup: (raw) {
          raw.execute(v7Schema);
          raw.execute('''
            INSERT INTO transactions (title, amount, type, category, date, account)
            VALUES ('old lunch', 12.5, 'expense', 'catFood', 1714521600, 'Maybank');
          ''');
          raw.execute("INSERT INTO accounts (name, icon, color) "
              "VALUES ('Maybank', 'savings', '#42A5F5');");
          if (extraSetup.isNotEmpty) raw.execute(extraSetup);
          raw.execute('PRAGMA user_version = 7');
        }),
      );

  test('existing jars become savings accounts with a zero opening balance',
      () async {
    final db = openAsV7();
    addTearDown(db.close);

    final accounts = await db.accountDao.getAllAccounts();
    expect(accounts.length, 1);
    expect(accounts.single.name, 'Maybank');
    expect(accounts.single.type, 'savings');
    expect(accounts.single.openingBalance, 0);
  });

  test('v7 transactions survive with no transfer destination', () async {
    final db = openAsV7();
    addTearDown(db.close);

    final txs = await db.transactionDao.searchTransactions('');
    expect(txs.length, 1);
    expect(txs.single.title, 'old lunch');
    expect(txs.single.account, 'Maybank');
    expect(txs.single.toAccount, isNull);
  });

  test('duplicate account names collapse and the name becomes unique',
      () async {
    final db = openAsV7(
      extraSetup: "INSERT INTO accounts (name, icon, color) "
          "VALUES ('Maybank', 'account_balance', '#000000');",
    );
    addTearDown(db.close);

    final accounts = await db.accountDao.getAllAccounts();
    expect(accounts.length, 1);
    // The lowest id wins, so the original styling is what survives.
    expect(accounts.single.icon, 'savings');

    await expectLater(
      db.accountDao.insertAccount(AccountsCompanion.insert(
          name: 'Maybank', icon: 'savings', color: '#42A5F5')),
      throwsA(anything),
    );
  });

  test('schema version matches the current app schema after upgrade', () async {
    final db = openAsV7();
    // Force the migration to run before reading the version back.
    await db.accountDao.getAllAccounts();
    await db.close();

    final reopened = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(reopened.close);
    final row = await reopened.customSelect('PRAGMA user_version').getSingle();
    expect(row.data.values.first, reopened.schemaVersion);
  });
}
