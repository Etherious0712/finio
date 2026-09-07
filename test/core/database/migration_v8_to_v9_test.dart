import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finio/core/database/app_database.dart';

/// Opens a real v8 database file and lets the app migrate it, so the v9 data
/// fix (clearing titles that hold the raw category key) runs against rows that
/// actually have the bug rather than a freshly created schema.
void main() {
  late Directory tempDir;
  late File dbFile;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('finio_migration');
    dbFile = File('${tempDir.path}/v8.sqlite');
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  // Schema as it stood at v8.
  const v8Schema = '''
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
      month INTEGER NOT NULL,
      year INTEGER NOT NULL,
      created_at INTEGER NOT NULL DEFAULT 0
    );
  ''';

  AppDatabase openAsV8() => AppDatabase.forTesting(
        NativeDatabase(dbFile, setup: (raw) {
          raw.execute(v8Schema);
          // The bug: no note typed, so the category key landed in `title`.
          raw.execute('''
            INSERT INTO transactions (title, amount, type, category, date, is_synced)
            VALUES ('catOtherIncome', 500, 'income', 'catOtherIncome', 1714521600, 1);
          ''');
          // A real note must survive untouched, sync flag included.
          raw.execute('''
            INSERT INTO transactions (title, amount, type, category, date, is_synced)
            VALUES ('lunch', 12.5, 'expense', 'catFood', 1714521600, 1);
          ''');
          raw.execute('''
            INSERT INTO budgets (category, amount, month, year)
            VALUES ('catFood', 500, 0, 0);
          ''');
          raw.execute('PRAGMA user_version = 8');
        }),
      );

  test('a title holding its own category key is cleared and re-flagged',
      () async {
    final db = openAsV8();
    addTearDown(db.close);

    final txs = await db.transactionDao.searchTransactions('');
    final fixed = txs.firstWhere((t) => t.category == 'catOtherIncome');
    expect(fixed.title, '');
    // Re-flagged so the next sync overwrites the bad cloud copy too.
    expect(fixed.isSynced, isFalse);
    expect(fixed.amount, 500);
  });

  test('an existing budget becomes a recurring monthly one', () async {
    final db = openAsV8();
    addTearDown(db.close);

    final budget = (await db.budgetDao.getBudgets()).single;
    expect(budget.category, 'catFood');
    expect(budget.amount, 500);
    expect(budget.period, 'month');
    expect(budget.overrideAmount, isNull);
  });

  test('a real note is left alone', () async {
    final db = openAsV8();
    addTearDown(db.close);

    final txs = await db.transactionDao.searchTransactions('');
    final kept = txs.firstWhere((t) => t.category == 'catFood');
    expect(kept.title, 'lunch');
    expect(kept.isSynced, isTrue);
  });

  test('schema version matches the current app schema after upgrade', () async {
    final db = openAsV8();
    await db.transactionDao.searchTransactions('');
    await db.close();

    final reopened = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(reopened.close);
    final row = await reopened.customSelect('PRAGMA user_version').getSingle();
    expect(row.data.values.first, reopened.schemaVersion);
  });
}
