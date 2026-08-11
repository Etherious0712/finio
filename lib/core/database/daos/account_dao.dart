import 'package:drift/drift.dart';

import '../app_database.dart';

part 'account_dao.g.dart';

@DriftAccessor(tables: [Accounts, Transactions])
class AccountDao extends DatabaseAccessor<AppDatabase> with _$AccountDaoMixin {
  AccountDao(super.db);

  Stream<List<Account>> watchAllAccounts() => select(accounts).watch();

  Future<List<Account>> getAllAccounts() => select(accounts).get();

  Future<Account?> getDefaultAccount() =>
      (select(accounts)..where((a) => a.isDefault.equals(true)))
          .getSingleOrNull();

  Future<int> insertAccount(AccountsCompanion entry) =>
      into(accounts).insert(entry);

  Future<bool> updateAccount(Account entry) =>
      update(accounts).replace(entry);

  Future<int> deleteAccount(int id) =>
      (delete(accounts)..where((a) => a.id.equals(id))).go();

  Future<int> deleteAllAccounts() => delete(accounts).go();

  /// Makes [id] the only default jar.
  Future<void> setDefault(int id) => transaction(() async {
        await update(accounts)
            .write(const AccountsCompanion(isDefault: Value(false)));
        await (update(accounts)..where((a) => a.id.equals(id)))
            .write(const AccountsCompanion(isDefault: Value(true)));
      });

  /// Renames a jar and re-points every transaction filed under the old name.
  ///
  /// Transactions reference jars by name (see [Transactions.account]), so the
  /// cascade lives here — doing it in the caller would leave records orphaned
  /// whenever a new call site forgets.
  Future<void> renameAccount({
    required int id,
    required String oldName,
    required String newName,
  }) =>
      transaction(() async {
        await (update(accounts)..where((a) => a.id.equals(id)))
            .write(AccountsCompanion(name: Value(newName)));
        if (oldName == newName) return;
        await (update(transactions)..where((t) => t.account.equals(oldName)))
            .write(TransactionsCompanion(
          account: Value(newName),
          isSynced: const Value(false),
          updatedAt: Value(DateTime.now()),
        ));
      });

  /// Finds a jar by name, creating it when absent. Used when pulling cloud
  /// records whose jar doesn't exist on this device yet.
  Future<Account> findOrCreateByName(
    String name, {
    String icon = 'savings',
    String color = '#4ECDC4',
  }) async {
    final existing = await (select(accounts)..where((a) => a.name.equals(name)))
        .getSingleOrNull();
    if (existing != null) return existing;
    final id = await into(accounts).insert(
      AccountsCompanion.insert(name: name, icon: icon, color: color),
    );
    return (select(accounts)..where((a) => a.id.equals(id))).getSingle();
  }
}
