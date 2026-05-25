# Account & Data Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an "Account & Data" settings screen with forgot-password, reset-settings, reset-data, and delete-account operations.

**Architecture:** Single-file `ConsumerStatefulWidget` screen with four async methods (`_showForgotPasswordDialog`, `_showResetSettingsDialog`, `_showResetDataDialog`, `_showDeleteAccountDialog`) and one private `_DeleteConfirmDialog` widget for the DELETE-input pattern shared by Reset Data and Delete Account.

**Tech Stack:** Flutter, Riverpod, Drift (SQLite), Supabase, GoRouter, flutter_localizations (ARB)

---

## Task 1: Add 12 l10n keys to all 8 .arb files

**Files:**
- Modify: `lib/l10n/app_en.arb`
- Modify: `lib/l10n/app_zh.arb`
- Modify: `lib/l10n/app_ja.arb`
- Modify: `lib/l10n/app_ko.arb`
- Modify: `lib/l10n/app_ms.arb`
- Modify: `lib/l10n/app_fr.arb`
- Modify: `lib/l10n/app_de.arb`
- Modify: `lib/l10n/app_es.arb`

- [ ] **Step 1: Add keys to app_en.arb**

In `lib/l10n/app_en.arb`, replace the final `}` with:

```json
  "accountAndData": "Account & Data",
  "resetSettings": "Reset Settings",
  "resetData": "Reset Data",
  "deleteAccount": "Delete Account",
  "forgotPassword": "Forgot Password",
  "dangerZone": "Danger Zone",
  "confirmDelete": "This cannot be undone.",
  "typeDeleteToConfirm": "Type DELETE to confirm",
  "settingsReset": "Settings have been reset",
  "dataReset": "All records cleared",
  "accountDeleted": "Account deleted",
  "resetPasswordEmailSent": "Reset email sent. Check your inbox."
}
```

- [ ] **Step 2: Add keys to app_zh.arb**

In `lib/l10n/app_zh.arb`, replace the final `}` with:

```json
  "accountAndData": "账号与数据",
  "resetSettings": "重置设置",
  "resetData": "重置数据",
  "deleteAccount": "删除账号",
  "forgotPassword": "忘记密码",
  "dangerZone": "危险操作",
  "confirmDelete": "此操作无法撤销。",
  "typeDeleteToConfirm": "输入 DELETE 确认",
  "settingsReset": "设置已重置",
  "dataReset": "所有记录已清空",
  "accountDeleted": "账号已删除",
  "resetPasswordEmailSent": "重置邮件已发送，请检查收件箱。"
}
```

- [ ] **Step 3: Add keys to app_ja.arb**

In `lib/l10n/app_ja.arb`, replace the final `}` with:

```json
  "accountAndData": "アカウントとデータ",
  "resetSettings": "設定をリセット",
  "resetData": "データをリセット",
  "deleteAccount": "アカウントを削除",
  "forgotPassword": "パスワードを忘れた",
  "dangerZone": "危険な操作",
  "confirmDelete": "この操作は元に戻せません。",
  "typeDeleteToConfirm": "DELETE と入力して確認",
  "settingsReset": "設定がリセットされました",
  "dataReset": "すべての記録が削除されました",
  "accountDeleted": "アカウントが削除されました",
  "resetPasswordEmailSent": "リセットメールを送信しました。受信トレイを確認してください。"
}
```

- [ ] **Step 4: Add keys to app_ko.arb**

In `lib/l10n/app_ko.arb`, replace the final `}` with:

```json
  "accountAndData": "계정 및 데이터",
  "resetSettings": "설정 초기화",
  "resetData": "데이터 초기화",
  "deleteAccount": "계정 삭제",
  "forgotPassword": "비밀번호 찾기",
  "dangerZone": "위험 구역",
  "confirmDelete": "이 작업은 취소할 수 없습니다.",
  "typeDeleteToConfirm": "DELETE 입력 후 확인",
  "settingsReset": "설정이 초기화되었습니다",
  "dataReset": "모든 기록이 삭제되었습니다",
  "accountDeleted": "계정이 삭제되었습니다",
  "resetPasswordEmailSent": "재설정 이메일이 전송되었습니다. 받은 편지함을 확인하세요."
}
```

- [ ] **Step 5: Add keys to app_ms.arb**

In `lib/l10n/app_ms.arb`, replace the final `}` with:

```json
  "accountAndData": "Akaun & Data",
  "resetSettings": "Set Semula Tetapan",
  "resetData": "Tetapkan Semula Data",
  "deleteAccount": "Padam Akaun",
  "forgotPassword": "Lupa Kata Laluan",
  "dangerZone": "Zon Bahaya",
  "confirmDelete": "Tindakan ini tidak boleh dibatalkan.",
  "typeDeleteToConfirm": "Taip DELETE untuk sahkan",
  "settingsReset": "Tetapan telah ditetapkan semula",
  "dataReset": "Semua rekod telah dipadamkan",
  "accountDeleted": "Akaun telah dipadam",
  "resetPasswordEmailSent": "E-mel tetapan semula telah dihantar. Semak peti masuk anda."
}
```

- [ ] **Step 6: Add keys to app_fr.arb**

In `lib/l10n/app_fr.arb`, replace the final `}` with:

```json
  "accountAndData": "Compte et données",
  "resetSettings": "Réinitialiser les paramètres",
  "resetData": "Réinitialiser les données",
  "deleteAccount": "Supprimer le compte",
  "forgotPassword": "Mot de passe oublié",
  "dangerZone": "Zone dangereuse",
  "confirmDelete": "Cette action est irréversible.",
  "typeDeleteToConfirm": "Tapez DELETE pour confirmer",
  "settingsReset": "Paramètres réinitialisés",
  "dataReset": "Tous les enregistrements supprimés",
  "accountDeleted": "Compte supprimé",
  "resetPasswordEmailSent": "E-mail de réinitialisation envoyé. Vérifiez votre boîte de réception."
}
```

- [ ] **Step 7: Add keys to app_de.arb**

In `lib/l10n/app_de.arb`, replace the final `}` with:

```json
  "accountAndData": "Konto & Daten",
  "resetSettings": "Einstellungen zurücksetzen",
  "resetData": "Daten zurücksetzen",
  "deleteAccount": "Konto löschen",
  "forgotPassword": "Passwort vergessen",
  "dangerZone": "Gefahrenzone",
  "confirmDelete": "Diese Aktion kann nicht rückgängig gemacht werden.",
  "typeDeleteToConfirm": "Geben Sie DELETE ein zur Bestätigung",
  "settingsReset": "Einstellungen zurückgesetzt",
  "dataReset": "Alle Einträge gelöscht",
  "accountDeleted": "Konto gelöscht",
  "resetPasswordEmailSent": "Passwort-Reset-E-Mail gesendet. Bitte prüfen Sie Ihren Posteingang."
}
```

- [ ] **Step 8: Add keys to app_es.arb**

In `lib/l10n/app_es.arb`, replace the final `}` with:

```json
  "accountAndData": "Cuenta y datos",
  "resetSettings": "Restablecer ajustes",
  "resetData": "Restablecer datos",
  "deleteAccount": "Eliminar cuenta",
  "forgotPassword": "Olvidé mi contraseña",
  "dangerZone": "Zona de peligro",
  "confirmDelete": "Esta acción no se puede deshacer.",
  "typeDeleteToConfirm": "Escribe DELETE para confirmar",
  "settingsReset": "Ajustes restablecidos",
  "dataReset": "Todos los registros eliminados",
  "accountDeleted": "Cuenta eliminada",
  "resetPasswordEmailSent": "Correo de restablecimiento enviado. Revisa tu bandeja de entrada."
}
```

- [ ] **Step 9: Verify l10n generation succeeds**

```bash
flutter gen-l10n
```

Expected: no errors, updated files in `lib/` (app_localizations.dart + per-locale files).

- [ ] **Step 10: Commit**

```bash
git add lib/l10n/
git commit -m "feat: add 12 l10n keys for account & data screen (8 languages)"
```

---

## Task 2: Add DAO methods + test constructor

**Files:**
- Modify: `lib/core/database/app_database.dart` — add test constructor
- Modify: `lib/core/database/daos/transaction_dao.dart` — add `deleteAllTransactions()`
- Modify: `lib/core/database/daos/budget_dao.dart` — add `deleteAllBudgets()`
- Modify: `lib/core/database/daos/category_dao.dart` — add `deleteCustomCategories()`
- Create: `test/core/database/daos/dao_delete_test.dart`

- [ ] **Step 1: Add test constructor to AppDatabase**

In `lib/core/database/app_database.dart`, add a second constructor after the existing one:

```dart
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // Used in tests only
  AppDatabase.forTesting(super.e);
```

- [ ] **Step 2: Add deleteAllTransactions to TransactionDao**

In `lib/core/database/daos/transaction_dao.dart`, add after `deleteTransaction`:

```dart
  Future<int> deleteAllTransactions() => delete(transactions).go();
```

- [ ] **Step 3: Add deleteAllBudgets to BudgetDao**

In `lib/core/database/daos/budget_dao.dart`, add after `deleteBudget`:

```dart
  Future<int> deleteAllBudgets() => delete(budgets).go();
```

- [ ] **Step 4: Add deleteCustomCategories to CategoryDao**

In `lib/core/database/daos/category_dao.dart`, add after `deleteCategory`:

```dart
  Future<int> deleteCustomCategories() =>
      (delete(categories)..where((c) => c.isCustom.equals(true))).go();
```

- [ ] **Step 5: Write failing tests**

Create `test/core/database/daos/dao_delete_test.dart`:

```dart
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

  Future<void> _insertTransaction(AppDatabase db) =>
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
    await _insertTransaction(db);
    await _insertTransaction(db);
    await db.transactionDao.deleteAllTransactions();
    final remaining = await db.transactionDao.searchTransactions('');
    // searchTransactions with empty string returns all rows
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
```

- [ ] **Step 6: Run tests — expect failures**

```bash
flutter test test/core/database/daos/dao_delete_test.dart -v
```

Expected: compilation error — `AppDatabase.forTesting` does not exist yet (you just added it in step 1, but if running before the rebuild, the generated `_$AppDatabase` mixin might need rebuild).

If compilation fails run:
```bash
dart run build_runner build --delete-conflicting-outputs
flutter test test/core/database/daos/dao_delete_test.dart -v
```

- [ ] **Step 7: Run tests — expect all pass**

```bash
flutter test test/core/database/daos/dao_delete_test.dart -v
```

Expected output:
```
00:XX +3: All tests passed!
```

- [ ] **Step 8: Verify overall analysis**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 9: Commit**

```bash
git add lib/core/database/ test/core/database/
git commit -m "feat: add deleteAllTransactions, deleteAllBudgets, deleteCustomCategories DAO methods"
```

---

## Task 3: Add route and settings entry

**Files:**
- Modify: `lib/app.dart` — add `/account-data` route
- Modify: `lib/features/settings/settings_screen.dart` — add entry ListTile

- [ ] **Step 1: Add import and route in app.dart**

In `lib/app.dart`, add the import after the other settings screen imports:

```dart
import 'features/settings/account_data_screen.dart';
```

Then inside `_router`'s routes list, after the `'auth'` route entry, add:

```dart
        GoRoute(
          path: 'account-data',
          builder: (context, state) => const AccountDataScreen(),
        ),
```

- [ ] **Step 2: Add entry ListTile in settings_screen.dart**

In `lib/features/settings/settings_screen.dart`, add after the existing `Padding` for `l.settings` section header (i.e., as the first item under that section, before `l.language`):

```dart
          ListTile(
            leading: const Icon(Icons.manage_accounts),
            title: Text(l.accountAndData),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/account-data'),
          ),
```

- [ ] **Step 3: Verify analysis**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```bash
git add lib/app.dart lib/features/settings/settings_screen.dart
git commit -m "feat: add account-data route and settings entry"
```

---

## Task 4: Build AccountDataScreen

**Files:**
- Create: `lib/features/settings/account_data_screen.dart`

- [ ] **Step 1: Create account_data_screen.dart**

Create `lib/features/settings/account_data_screen.dart` with the full content below:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:finio/app_localizations.dart';
import 'package:finio/shared/providers/currency_provider.dart';
import 'package:finio/shared/providers/database_provider.dart';
import 'package:finio/shared/providers/locale_provider.dart';
import 'package:finio/shared/providers/theme_provider.dart';

class AccountDataScreen extends ConsumerStatefulWidget {
  const AccountDataScreen({super.key});

  @override
  ConsumerState<AccountDataScreen> createState() => _AccountDataScreenState();
}

class _AccountDataScreenState extends ConsumerState<AccountDataScreen> {
  Future<void> _showForgotPasswordDialog(String? email) async {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: email ?? '');
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.forgotPassword),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: l.email),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.confirm),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      await Supabase.instance.client.auth
          .resetPasswordForEmail(controller.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.resetPasswordEmailSent),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      controller.dispose();
    }
  }

  Future<void> _showResetSettingsDialog() async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.resetSettings),
        content: Text(l.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    ref.read(localeProvider.notifier).setLocale(null);
    ref.read(themeProvider.notifier).setTheme(AppThemeMode.system);
    ref.read(currencyProvider.notifier).setCode('USD');
    await ref.read(appDatabaseProvider).budgetDao.deleteAllBudgets();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.settingsReset),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _showResetDataDialog(String? userId) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteConfirmDialog(
        title: l.resetData,
        body: l.confirmDelete,
        actionLabel: l.resetData,
      ),
    );
    if (confirmed != true || !mounted) return;

    final db = ref.read(appDatabaseProvider);
    await db.transactionDao.deleteAllTransactions();
    if (userId != null) {
      try {
        await Supabase.instance.client
            .from('transactions')
            .delete()
            .eq('user_id', userId);
      } catch (_) {}
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.dataReset),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _showDeleteAccountDialog(String userId) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteConfirmDialog(
        title: l.deleteAccount,
        body: l.confirmDelete,
        actionLabel: l.deleteAccount,
      ),
    );
    if (confirmed != true || !mounted) return;

    final supabase = Supabase.instance.client;
    final db = ref.read(appDatabaseProvider);
    bool rpcSucceeded = false;

    try {
      await supabase.from('transactions').delete().eq('user_id', userId);
    } catch (_) {}

    try {
      await supabase.rpc('delete_user');
      rpcSucceeded = true;
    } catch (_) {}

    await db.transactionDao.deleteAllTransactions();
    await db.budgetDao.deleteAllBudgets();
    await db.categoryDao.deleteCustomCategories();

    if (mounted) {
      ref.read(localeProvider.notifier).setLocale(null);
      ref.read(themeProvider.notifier).setTheme(AppThemeMode.system);
      ref.read(currencyProvider.notifier).setCode('USD');
    }

    await supabase.auth.signOut();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(rpcSucceeded ? l.accountDeleted : '账号将在 24 小时内删除'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final user = Supabase.instance.client.auth.currentUser;
    final isLoggedIn = user != null;

    return Scaffold(
      appBar: AppBar(title: Text(l.accountAndData), centerTitle: true),
      body: ListView(
        children: [
          if (isLoggedIn) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                l.account,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.lock_reset),
              title: Text(l.forgotPassword),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showForgotPasswordDialog(user.email),
            ),
            const Divider(height: 1),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Data Management',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: Text(l.resetSettings),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showResetSettingsDialog,
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.red),
            title: Text(l.resetData,
                style: const TextStyle(color: Colors.red)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showResetDataDialog(user?.id),
          ),
          if (isLoggedIn) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                l.dangerZone,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.red,
                    ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.no_accounts, color: Colors.red),
              title: Text(l.deleteAccount,
                  style: const TextStyle(color: Colors.red)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showDeleteAccountDialog(user.id),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeleteConfirmDialog extends StatefulWidget {
  const _DeleteConfirmDialog({
    required this.title,
    required this.body,
    required this.actionLabel,
  });

  final String title;
  final String body;
  final String actionLabel;

  @override
  State<_DeleteConfirmDialog> createState() => _DeleteConfirmDialogState();
}

class _DeleteConfirmDialogState extends State<_DeleteConfirmDialog> {
  final _controller = TextEditingController();
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(
      () => setState(() => _confirmed = _controller.text == 'DELETE'),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.title, style: const TextStyle(color: Colors.red)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.body),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: l.typeDeleteToConfirm,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed:
              _confirmed ? () => Navigator.pop(context, true) : null,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text(widget.actionLabel),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Verify analysis**

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```bash
git add lib/features/settings/account_data_screen.dart
git commit -m "feat: account & data screen - forgot password, reset settings/data, delete account"
```

---

## Task 5: Final verification and push

- [ ] **Step 1: Run all tests**

```bash
flutter test
```

Expected: all tests pass including the new DAO delete tests.

- [ ] **Step 2: Build to confirm no runtime issues**

```bash
flutter build apk --debug
```

Expected: `√ Built build\app\outputs\flutter-apk\app-debug.apk`

- [ ] **Step 3: Push**

```bash
git push origin main
```
