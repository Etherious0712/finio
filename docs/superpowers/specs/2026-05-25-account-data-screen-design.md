# Account & Data Screen — Design Spec
**Date:** 2026-05-25  
**Feature:** Settings → Account & Data management page  
**Approach:** Single-file screen (方案一), C-variant Delete Account (local-first, upgradeable via Supabase RPC)

---

## 1. Files Changed

### New
- `lib/features/settings/account_data_screen.dart` — main screen

### Modified
- `lib/features/settings/settings_screen.dart` — add entry ListTile (icon: `manage_accounts`, route: `/account-data`)
- `lib/app.dart` — register GoRouter route `/account-data`
- `lib/core/database/daos/transaction_dao.dart` — add `deleteAllTransactions()`
- `lib/core/database/daos/budget_dao.dart` — add `deleteAllBudgets()`
- `lib/core/database/daos/category_dao.dart` — add `deleteCustomCategories()`
- `lib/l10n/app_en.arb` + 7 other language files — add 12 new keys

### Not changed
- `lib/core/database/app_database.dart` — no schema changes needed
- `lib/core/sync/sync_service.dart` — not involved

---

## 2. Screen Layout

`AccountDataScreen` is a `ConsumerWidget` with a `Scaffold` + `ListView`.

Auth state is read once via `Supabase.instance.client.auth.currentUser` (not a stream — the page is opened after the user is known to be logged in or not). The `isLoggedIn` flag controls visibility of Area 1 and Area 3.

```
AccountDataScreen
├── AppBar: l.accountAndData, centerTitle: true
│
├── [Area 1 — Account Settings, visible only when isLoggedIn]
│   Section header: l.account  (labelMedium, primary color — same style as settings_screen)
│   └── ListTile
│       icon: Icons.lock_reset
│       title: l.forgotPassword
│       trailing: Icons.chevron_right
│       onTap: _showForgotPasswordDialog()
│
├── Divider(height: 1)
│
├── [Area 2 — Data Management, always visible]
│   Section header: "Data Management"  (same style)
│   ├── ListTile
│   │   icon: Icons.restore
│   │   title: l.resetSettings
│   │   trailing: Icons.chevron_right
│   │   onTap: _showResetSettingsDialog()
│   │
│   └── ListTile
│       icon: Icons.delete_sweep  (color: Colors.red)
│       title: l.resetData        (color: Colors.red)
│       trailing: Icons.chevron_right
│       onTap: _showResetDataDialog()
│
├── Divider(height: 1)
│
└── [Area 3 — Danger Zone, visible only when isLoggedIn]
    Section header: l.dangerZone  (labelMedium, Colors.red)
    └── ListTile
        icon: Icons.no_accounts  (color: Colors.red)
        title: l.deleteAccount   (color: Colors.red)
        trailing: Icons.chevron_right
        onTap: _showDeleteAccountDialog()
```

---

## 3. Operation Details

### 3.1 Forgot Password (`_showForgotPasswordDialog`)

- **Dialog**: `AlertDialog` with a `TextField` pre-filled with `currentUser?.email ?? ''`
- **On confirm**:
  ```dart
  await Supabase.instance.client.auth.resetPasswordForEmail(email);
  ```
- **Success**: `SnackBar(content: Text(l.resetPasswordEmailSent))`
- **Error**: `SnackBar(content: Text(e.toString()))`
- No `ConsumerStatefulWidget` needed — dialog manages its own `TextEditingController`.

### 3.2 Reset Settings (`_showResetSettingsDialog`)

- **Dialog**: Simple `AlertDialog` with `l.confirmDelete` message. No DELETE input required (settings reset is reversible).
- **On confirm**, call in order:
  1. `ref.read(localeProvider.notifier).setLocale(null)` — resets language to system
  2. `ref.read(themeProvider.notifier).setTheme(AppThemeMode.system)` — resets theme
  3. `ref.read(currencyProvider.notifier).setCode('USD')` — resets currency
  4. `await db.budgetDao.deleteAllBudgets()` — clears all budget records from SQLite
- **After**: `SnackBar(content: Text(l.settingsReset))`
- UI reflects language/theme/currency changes immediately (Riverpod reactivity).
- Custom categories and transaction records are **not** affected.

### 3.3 Reset Data (`_showResetDataDialog`)

- **Dialog**: `AlertDialog` with red warning text (`l.confirmDelete`), a `TextField` labelled `l.typeDeleteToConfirm`.
- **Confirm button**: `enabled` only when `controller.text == 'DELETE'` (case-sensitive, real-time via `setState` listener).
- **On confirm**:
  1. `await db.transactionDao.deleteAllTransactions()` — clears local SQLite
  2. If `isLoggedIn`: `await supabase.from('transactions').delete().eq('user_id', user.id)`
- **After**: `SnackBar(content: Text(l.dataReset))`
- Settings, budgets, categories remain untouched.

### 3.4 Delete Account (`_showDeleteAccountDialog`)

- **Dialog**: `AlertDialog` with red warning. Requires `'DELETE'` input same as Reset Data.
- **On confirm**, execute in order (each step wrapped in try/catch to avoid partial failure):
  1. `await supabase.from('transactions').delete().eq('user_id', user.id)` — delete cloud data
  2. `await supabase.rpc('delete_user')` — attempt real account deletion; **catch and ignore** if function not found (PostgrestException)
  3. `await db.transactionDao.deleteAllTransactions()`
  4. `await db.budgetDao.deleteAllBudgets()`
  5. `await db.categoryDao.deleteCustomCategories()`
  6. Clear SharedPreferences: call each notifier's reset method (locale → null, theme → system, currency → USD)
  7. `await Supabase.instance.client.auth.signOut()`
- **SnackBar**:
  - RPC succeeded → `l.accountDeleted` ("账号已删除")
  - RPC failed → `"账号将在 24 小时内删除"` (hardcoded for now, add l10n key later)
- After sign out, the `StreamBuilder<AuthState>` in `SettingsScreen` automatically updates the UI — no manual navigation needed.

---

## 4. New DAO Methods

```dart
// TransactionDao
Future<int> deleteAllTransactions() => delete(transactions).go();

// BudgetDao
Future<int> deleteAllBudgets() => delete(budgets).go();

// CategoryDao
Future<int> deleteCustomCategories() =>
    (delete(categories)..where((c) => c.isCustom.equals(true))).go();
```

---

## 5. New l10n Keys (12)

| Key | EN | ZH |
|-----|----|----|
| `accountAndData` | Account & Data | 账号与数据 |
| `resetSettings` | Reset Settings | 重置设置 |
| `resetData` | Reset Data | 重置数据 |
| `deleteAccount` | Delete Account | 删除账号 |
| `forgotPassword` | Forgot Password | 忘记密码 |
| `dangerZone` | Danger Zone | 危险操作 |
| `confirmDelete` | This cannot be undone. | 此操作无法撤销。 |
| `typeDeleteToConfirm` | Type DELETE to confirm | 输入 DELETE 确认 |
| `settingsReset` | Settings have been reset | 设置已重置 |
| `dataReset` | All records cleared | 所有记录已清空 |
| `accountDeleted` | Account deleted | 账号已删除 |
| `resetPasswordEmailSent` | Reset email sent. Check your inbox. | 重置邮件已发送，请检查收件箱。 |

Full translations for all 8 languages (EN/ZH/JA/KO/MS/FR/DE/ES) are defined in the design conversation and will be applied during implementation.

---

## 6. Supabase RPC SQL (C-variant upgrade path)

Paste into **Supabase SQL Editor** to enable true account deletion:

```sql
create or replace function delete_user()
returns void language plpgsql security definer as $$
begin
  delete from auth.users where id = auth.uid();
end;
$$;
```

Once deployed, `supabase.rpc('delete_user')` succeeds and shows "账号已删除". Before deployment, the RPC throws a `PostgrestException` which is caught and ignored — app proceeds with local cleanup and shows "账号将在 24 小时内删除".

---

## 7. What is NOT in scope

- Custom categories are only deleted during **Delete Account**, not during Reset Data or Reset Settings.
- Budget settings (SQLite) are reset during **Reset Settings** (cleared via `deleteAllBudgets()`), not during Reset Data.
- No new Supabase tables or schema changes.
- No Edge Function deployment.
- No statistics or category data synced to cloud (local-only, no cloud cleanup needed for those).
