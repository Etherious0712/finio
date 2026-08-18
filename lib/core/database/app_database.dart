import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/account_dao.dart';
import 'daos/budget_dao.dart';
import 'daos/category_dao.dart';
import 'daos/transaction_dao.dart';

part 'app_database.g.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(max: 100)();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // 'income' | 'expense' | 'transfer'
  TextColumn get category => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncId => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get currencyCode =>
      text().withDefault(const Constant('USD'))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  // Account this record belongs to, referenced by name (same convention as
  // [category] above). null = unassigned. Renames cascade via
  // AccountDao.renameAccount.
  TextColumn get account => text().nullable()();
  // Transfer destination, by name. Non-null only when type = 'transfer', where
  // [account] is the source. Renames cascade the same way.
  TextColumn get toAccount => text().nullable()();
}

/// A pot of money — cash, a bank account, a credit card, an e-wallet.
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 50)();
  TextColumn get icon => text()(); // Material icon name
  TextColumn get color => text()(); // Hex color string
  // Preselected when adding a transaction. At most one row is true — enforced
  // by AccountDao.setDefault.
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  // 'cash' | 'bank' | 'creditCard' | 'eWallet' | 'savings'. Display name via
  // localizeAccountType.
  TextColumn get type => text().withDefault(const Constant('savings'))();
  // Balance before tracking started. Negative on a credit card = money owed.
  RealColumn get openingBalance => real().withDefault(const Constant(0))();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 50)();
  TextColumn get type => text()(); // 'income' | 'expense'
  TextColumn get icon => text()(); // Material icon name
  TextColumn get color => text()(); // Hex color string
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  // null = main (top-level) category; set = sub-category under this parent id.
  IntColumn get parentId => integer().nullable()();
}

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text().nullable()(); // null = overall budget
  RealColumn get amount => real()();
  IntColumn get month => integer()(); // 1-12, 0 = monthly repeat
  IntColumn get year => integer()(); // 0 = monthly repeat
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Transactions, Categories, Budgets, Accounts])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Used in tests only
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 8;

  late final transactionDao = TransactionDao(this);
  late final categoryDao = CategoryDao(this);
  late final budgetDao = BudgetDao(this);
  late final accountDao = AccountDao(this);

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _uniqueAccountNameIndex();
          await _seedDefaultCategories();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(budgets);
          }
          if (from < 3) {
            await customStatement(
              "ALTER TABLE transactions ADD COLUMN currency_code TEXT NOT NULL DEFAULT 'USD'",
            );
          }
          if (from < 4) {
            await _migrateCategoriesToKeys();
          }
          if (from < 5) {
            await customStatement(
              'ALTER TABLE transactions ADD COLUMN is_deleted INTEGER NOT NULL DEFAULT 0',
            );
            await customStatement(
              'ALTER TABLE transactions ADD COLUMN deleted_at INTEGER',
            );
          }
          if (from < 6) {
            // Two-level categories: existing rows all become mains (parent NULL).
            await customStatement(
              'ALTER TABLE categories ADD COLUMN parent_id INTEGER',
            );
          }
          if (from < 7) {
            // Savings jars. Existing transactions stay NULL = unassigned.
            await m.createTable(accounts);
            await customStatement(
              'ALTER TABLE transactions ADD COLUMN account TEXT',
            );
          }
          if (from < 8) {
            // Account types, opening balances and transfers. SQLite backfills
            // existing rows from the DEFAULT, so every jar becomes a savings
            // account at 0 without an UPDATE.
            if (from >= 7) {
              // Only a table that already existed needs the columns added: the
              // createTable above builds `accounts` from today's definition,
              // which already has them.
              await customStatement(
                "ALTER TABLE accounts ADD COLUMN type TEXT NOT NULL DEFAULT 'savings'",
              );
              await customStatement(
                'ALTER TABLE accounts ADD COLUMN opening_balance REAL NOT NULL DEFAULT 0',
              );
            }
            await customStatement(
              'ALTER TABLE transactions ADD COLUMN to_account TEXT',
            );
            // Transactions reference accounts by name, so duplicates are
            // ambiguous (and make findOrCreateByName throw). Collapse them
            // before the index, or CREATE would abort the whole migration for
            // exactly the users who have the problem. Transactions keep
            // pointing at the name and lose nothing but a duplicate's styling.
            await customStatement(
              'DELETE FROM accounts WHERE id NOT IN '
              '(SELECT MIN(id) FROM accounts GROUP BY name)',
            );
            await _uniqueAccountNameIndex();
          }
        },
      );

  Future<void> _uniqueAccountNameIndex() => customStatement(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_accounts_name ON accounts(name)',
      );

  /// Renames built-in Chinese category names to language-neutral ARB keys so
  /// that all locales display the correct translated name.
  Future<void> _migrateCategoriesToKeys() async {
    const categoryRenames = {
      '餐饮': ('catFood', 'expense'),
      '交通': ('catTransport', 'expense'),
      '购物': ('catShopping', 'expense'),
      '娱乐': ('catEntertainment', 'expense'),
      '医疗': ('catHealth', 'expense'),
      '账单': ('catBills', 'expense'),
      '薪资': ('catSalary', 'income'),
      '兼职': ('catFreelance', 'income'),
      '投资': ('catInvestment', 'income'),
    };

    for (final entry in categoryRenames.entries) {
      final (key, type) = entry.value;
      await customStatement(
        "UPDATE categories SET name = ? WHERE name = ? AND type = ? AND is_custom = 0",
        [key, entry.key, type],
      );
      await customStatement(
        "UPDATE transactions SET category = ? WHERE category = ?",
        [key, entry.key],
      );
    }

    // The old "Other" category ('其他') exists for both expense and income —
    // rename to distinct keys

    await customStatement(
      "UPDATE categories SET name = 'catOtherExpense' WHERE name = '其他' AND type = 'expense' AND is_custom = 0",
    );
    await customStatement(
      "UPDATE categories SET name = 'catOtherIncome' WHERE name = '其他' AND type = 'income' AND is_custom = 0",
    );
    await customStatement(
      "UPDATE transactions SET category = 'catOtherExpense' WHERE category = '其他' AND type = 'expense'",
    );
    await customStatement(
      "UPDATE transactions SET category = 'catOtherIncome' WHERE category = '其他' AND type = 'income'",
    );
    await customStatement(
      "UPDATE budgets SET category = 'catOtherExpense' WHERE category = '其他'",
    );

    // Migrate budget table for named categories
    for (final entry in categoryRenames.entries) {
      final (key, _) = entry.value;
      await customStatement(
        "UPDATE budgets SET category = ? WHERE category = ?",
        [key, entry.key],
      );
    }
  }

  Future<void> _seedDefaultCategories() async {
    await batch((b) {
      b.insertAll(categories, [
        // Expense categories — stored as ARB keys
        CategoriesCompanion.insert(name: 'catFood', type: 'expense', icon: 'restaurant', color: '#FF6B6B'),
        CategoriesCompanion.insert(name: 'catTransport', type: 'expense', icon: 'directions_transit', color: '#4ECDC4'),
        CategoriesCompanion.insert(name: 'catShopping', type: 'expense', icon: 'shopping_bag', color: '#45B7D1'),
        CategoriesCompanion.insert(name: 'catEntertainment', type: 'expense', icon: 'sports_esports', color: '#96CEB4'),
        CategoriesCompanion.insert(name: 'catHealth', type: 'expense', icon: 'local_hospital', color: '#FFEAA7'),
        CategoriesCompanion.insert(name: 'catBills', type: 'expense', icon: 'receipt_long', color: '#DDA0DD'),
        CategoriesCompanion.insert(name: 'catOtherExpense', type: 'expense', icon: 'more_horiz', color: '#B0B0B0'),
        // Income categories
        CategoriesCompanion.insert(name: 'catSalary', type: 'income', icon: 'work', color: '#2ECC71'),
        CategoriesCompanion.insert(name: 'catFreelance', type: 'income', icon: 'laptop_mac', color: '#27AE60'),
        CategoriesCompanion.insert(name: 'catInvestment', type: 'income', icon: 'trending_up', color: '#F39C12'),
        CategoriesCompanion.insert(name: 'catOtherIncome', type: 'income', icon: 'more_horiz', color: '#95A5A6'),
      ]);
    });
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'finio_db');
}
