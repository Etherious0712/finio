import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finio/core/database/app_database.dart';

/// Opens a real v6 database file and lets the app migrate it, so the additive
/// v7 step (savings jars) is exercised against pre-existing data rather than a
/// freshly created schema.
void main() {
  late Directory tempDir;
  late File dbFile;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('finio_migration');
    dbFile = File('${tempDir.path}/v6.sqlite');
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  // Schema as it stood at v6: no `accounts` table, no `transactions.account`.
  const v6Schema = '''
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
      deleted_at INTEGER NULL
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

  AppDatabase openAsV6() => AppDatabase.forTesting(
        // `setup` runs on the raw handle before drift inspects the schema, so
        // the app sees a genuine v6 file and takes the onUpgrade path.
        NativeDatabase(dbFile, setup: (raw) {
          raw.execute(v6Schema);
          raw.execute('''
            INSERT INTO transactions (title, amount, type, category, date)
            VALUES ('old lunch', 12.5, 'expense', 'catFood', 1714521600);
          ''');
          raw.execute("INSERT INTO categories (name, type, icon, color) "
              "VALUES ('catFood', 'expense', 'restaurant', '#FF6B6B');");
          raw.execute('PRAGMA user_version = 6');
        }),
      );

  test('v6 data survives the upgrade and lands unassigned', () async {
    final db = openAsV6();
    addTearDown(db.close);

    final txs = await db.transactionDao.searchTransactions('');
    expect(txs.length, 1);
    expect(txs.single.title, 'old lunch');
    expect(txs.single.amount, 12.5);
    // The new column exists and defaults to "no jar".
    expect(txs.single.account, isNull);
  });

  test('the accounts table is created and usable after upgrade', () async {
    final db = openAsV6();
    addTearDown(db.close);

    // Would throw if v7's createTable hadn't run.
    expect(await db.accountDao.getAllAccounts(), isEmpty);

    final id = await db.accountDao.insertAccount(
      AccountsCompanion.insert(name: 'Maybank', icon: 'savings', color: '#42A5F5'),
    );
    await db.accountDao.setDefault(id);
    expect((await db.accountDao.getDefaultAccount())?.name, 'Maybank');
  });

  test('schema version matches the current app schema after upgrade', () async {
    final db = openAsV6();
    // Force the migration to run before reading the version back.
    await db.accountDao.getAllAccounts();
    await db.close();

    final reopened = AppDatabase.forTesting(NativeDatabase(dbFile));
    addTearDown(reopened.close);
    final row = await reopened
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(row.data.values.first, reopened.schemaVersion);
  });
}
