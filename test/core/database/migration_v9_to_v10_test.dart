import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finio/core/database/app_database.dart';

/// Opens a real v9 database file and lets the app migrate it, so the v10
/// credit-limit column is added to a table that already holds cards.
void main() {
  late Directory tempDir;
  late File dbFile;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('finio_migration');
    dbFile = File('${tempDir.path}/v9.sqlite');
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  // Schema as it stood at v9.
  const v9Schema = '''
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
      account TEXT NULL,
      to_account TEXT NULL
    );
    CREATE TABLE accounts (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      icon TEXT NOT NULL,
      color TEXT NOT NULL,
      is_default INTEGER NOT NULL DEFAULT 0 CHECK ("is_default" IN (0, 1)),
      type TEXT NOT NULL DEFAULT 'savings',
      opening_balance REAL NOT NULL DEFAULT 0
    );
    CREATE UNIQUE INDEX idx_accounts_name ON accounts(name);
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
      period TEXT NOT NULL DEFAULT 'month',
      month INTEGER NOT NULL,
      year INTEGER NOT NULL,
      override_amount REAL NULL,
      created_at INTEGER NOT NULL DEFAULT 0
    );
  ''';

  AppDatabase openAsV9() => AppDatabase.forTesting(
    NativeDatabase(
      dbFile,
      setup: (raw) {
        raw.execute(v9Schema);
        raw.execute('''
            INSERT INTO accounts (name, icon, color, type, opening_balance)
            VALUES ('Visa', 'credit_card', '#42A5F5', 'creditCard', -300);
          ''');
        // Income filed to a card before refunds existed.
        raw.execute('''
            INSERT INTO transactions (title, amount, type, category, date, account)
            VALUES ('cashback', 20, 'income', 'catOtherIncome', 1714521600, 'Visa');
          ''');
        raw.execute('PRAGMA user_version = 9');
      },
    ),
  );

  test('an existing card gets no credit limit, and keeps its debt', () async {
    final db = openAsV9();
    addTearDown(db.close);

    final card = (await db.accountDao.getAllAccounts()).single;
    expect(card.type, 'creditCard');
    expect(card.openingBalance, -300);
    expect(card.creditLimit, isNull);
  });

  test('income already on a card stays income', () async {
    final db = openAsV9();
    addTearDown(db.close);

    final tx = (await db.transactionDao.searchTransactions('')).single;
    expect(tx.type, 'income');
    expect(tx.account, 'Visa');
  });

  test('a limit can be stored after the upgrade', () async {
    final db = openAsV9();
    addTearDown(db.close);

    final card = (await db.accountDao.getAllAccounts()).single;
    await db.accountDao.updateAccount(
      card.copyWith(creditLimit: const Value(5000)),
    );
    expect((await db.accountDao.getAllAccounts()).single.creditLimit, 5000);
  });
}
