# Budget Feature Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add monthly budget tracking — set overall and per-category budgets, view progress bars on the dashboard, and receive local push notifications when spending hits 80 % or 100 % of the budget.

**Architecture:** A new `Budgets` table (schema v2) stores budgets; `BudgetDao` exposes stream and future accessors; two `StreamProvider`s feed the budget screen and dashboard. Notification init + startup budget check live in `BudgetNotifier` called from an async `main()`. Dashboard gains `_BudgetSection` / `_BudgetProgressRow` widgets inserted between the summary card and the transaction list.

**Tech Stack:** Drift 2.18 (SQLite), Riverpod, flutter_local_notifications ^17.2.2, Flutter Material 3

---

## File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Modify | `pubspec.yaml` | add flutter_local_notifications |
| Modify | `lib/core/database/app_database.dart` | Budgets table, budgetDao, schema v2, migration |
| Create | `lib/core/database/daos/budget_dao.dart` | BudgetDao with stream + future accessors and upsert |
| *(run)* | `dart run build_runner build` | regenerate app_database.g.dart + budget_dao.g.dart |
| Modify | `android/app/src/main/AndroidManifest.xml` | POST_NOTIFICATIONS permission |
| Create | `lib/shared/providers/budget_providers.dart` | overallBudgetProvider, categoryBudgetsProvider |
| Create | `lib/features/budget/budget_screen.dart` | budget settings UI |
| Modify | `lib/features/settings/settings_screen.dart` | add "预算设置" entry |
| Modify | `lib/app.dart` | add /budget route |
| Modify | `lib/features/dashboard/dashboard_screen.dart` | _BudgetSection + _BudgetProgressRow |
| Create | `lib/core/notifications/budget_notifier.dart` | init + startup check + notify |
| Modify | `lib/main.dart` | async main, init notifications, startup check |

---

## Task 1: Add flutter_local_notifications Dependency

**Files:** `pubspec.yaml`

- [ ] **Step 1: Add the package**

In `pubspec.yaml`, under the `# Utilities` comment block, add:

```yaml
  # Notifications
  flutter_local_notifications: ^17.2.2
```

Full dependencies section (relevant excerpt):
```yaml
  # Color picker
  flutter_colorpicker: ^1.1.0

  # Notifications
  flutter_local_notifications: ^17.2.2

  # Utilities
  intl: ^0.19.0
```

- [ ] **Step 2: Install**

```
flutter pub get
```

Expected: output contains `+ flutter_local_notifications 17.2.2`

- [ ] **Step 3: Commit**

```
git add pubspec.yaml pubspec.lock
git commit -m "feat: add flutter_local_notifications dependency"
```

---

## Task 2: Budgets Table + BudgetDao + Schema Migration

**Files:**
- Modify: `lib/core/database/app_database.dart`
- Create: `lib/core/database/daos/budget_dao.dart`
- Modify: `android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1: Add Budgets table and bump schema in app_database.dart**

Replace the entire file content:

```dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/budget_dao.dart';
import 'daos/category_dao.dart';
import 'daos/transaction_dao.dart';

part 'app_database.g.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(max: 100)();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // 'income' | 'expense'
  TextColumn get category => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncId => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 50)();
  TextColumn get type => text()(); // 'income' | 'expense'
  TextColumn get icon => text()(); // Material icon name
  TextColumn get color => text()(); // Hex color string
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
}

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get category => text().nullable()(); // null = 整体预算
  RealColumn get amount => real()();
  IntColumn get month => integer()(); // 1-12, 0 = 每月重复
  IntColumn get year => integer()(); // 0 = 每月重复
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Transactions, Categories, Budgets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  late final transactionDao = TransactionDao(this);
  late final categoryDao = CategoryDao(this);
  late final budgetDao = BudgetDao(this);

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedDefaultCategories();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(budgets);
          }
        },
      );

  Future<void> _seedDefaultCategories() async {
    await batch((b) {
      b.insertAll(categories, [
        CategoriesCompanion.insert(name: '餐饮', type: 'expense', icon: 'restaurant', color: '#FF6B6B'),
        CategoriesCompanion.insert(name: '交通', type: 'expense', icon: 'directions_transit', color: '#4ECDC4'),
        CategoriesCompanion.insert(name: '购物', type: 'expense', icon: 'shopping_bag', color: '#45B7D1'),
        CategoriesCompanion.insert(name: '娱乐', type: 'expense', icon: 'sports_esports', color: '#96CEB4'),
        CategoriesCompanion.insert(name: '医疗', type: 'expense', icon: 'local_hospital', color: '#FFEAA7'),
        CategoriesCompanion.insert(name: '账单', type: 'expense', icon: 'receipt_long', color: '#DDA0DD'),
        CategoriesCompanion.insert(name: '其他', type: 'expense', icon: 'more_horiz', color: '#B0B0B0'),
        CategoriesCompanion.insert(name: '薪资', type: 'income', icon: 'work', color: '#2ECC71'),
        CategoriesCompanion.insert(name: '兼职', type: 'income', icon: 'laptop_mac', color: '#27AE60'),
        CategoriesCompanion.insert(name: '投资', type: 'income', icon: 'trending_up', color: '#F39C12'),
        CategoriesCompanion.insert(name: '其他', type: 'income', icon: 'more_horiz', color: '#95A5A6'),
      ]);
    });
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'finio_db');
}
```

- [ ] **Step 2: Create lib/core/database/daos/budget_dao.dart**

```dart
import 'package:drift/drift.dart';

import '../app_database.dart';

part 'budget_dao.g.dart';

@DriftAccessor(tables: [Budgets])
class BudgetDao extends DatabaseAccessor<AppDatabase>
    with _$BudgetDaoMixin {
  BudgetDao(super.db);

  Stream<List<Budget>> watchBudgets() => select(budgets).watch();

  Future<List<Budget>> getBudgets() => select(budgets).get();

  Future<Budget?> getOverallBudget() =>
      (select(budgets)..where((b) => b.category.isNull()))
          .getSingleOrNull();

  Future<List<Budget>> getCategoryBudgets() =>
      (select(budgets)..where((b) => b.category.isNotNull())).get();

  /// Inserts or updates the budget for the given category (null = overall).
  /// Matches by category value in the DB, then writes only the amount.
  Future<void> upsertBudget(BudgetsCompanion entry) async {
    final String? category =
        entry.category.present ? entry.category.value : null;

    final Budget? existing = category == null
        ? await (select(budgets)..where((b) => b.category.isNull()))
            .getSingleOrNull()
        : await (select(budgets)
              ..where((b) => b.category.equals(category)))
            .getSingleOrNull();

    if (existing != null) {
      await (update(budgets)..where((b) => b.id.equals(existing.id)))
          .write(BudgetsCompanion(amount: entry.amount));
    } else {
      await into(budgets).insert(entry);
    }
  }

  Future<int> deleteBudget(int id) =>
      (delete(budgets)..where((b) => b.id.equals(id))).go();
}
```

- [ ] **Step 3: Run build_runner to regenerate code**

```
dart run build_runner build --delete-conflicting-outputs
```

Expected: generates `lib/core/database/daos/budget_dao.g.dart` and updates `lib/core/database/app_database.g.dart`. No errors.

- [ ] **Step 4: Add POST_NOTIFICATIONS permission to Android manifest**

Open `android/app/src/main/AndroidManifest.xml`. Add this line inside `<manifest>`, before the `<application>` tag:

```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

- [ ] **Step 5: Verify**

```
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 6: Commit**

```
git add lib/core/database/app_database.dart lib/core/database/daos/budget_dao.dart lib/core/database/daos/budget_dao.g.dart lib/core/database/app_database.g.dart android/app/src/main/AndroidManifest.xml
git commit -m "feat: add Budgets table, BudgetDao, schema migration v2"
```

---

## Task 3: Budget Providers

**Files:** Create `lib/shared/providers/budget_providers.dart`

- [ ] **Step 1: Create the providers file**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import 'database_provider.dart';

/// Stream of the overall (category == null) budget, or null if not set.
final overallBudgetProvider = StreamProvider.autoDispose<Budget?>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.budgetDao.watchBudgets().map(
    (list) => list.where((b) => b.category == null).firstOrNull,
  );
});

/// Stream of all category-specific budgets (category != null).
final categoryBudgetsProvider =
    StreamProvider.autoDispose<List<Budget>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.budgetDao.watchBudgets().map(
    (list) => list.where((b) => b.category != null).toList(),
  );
});
```

- [ ] **Step 2: Verify**

```
flutter analyze lib/shared/providers/budget_providers.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```
git add lib/shared/providers/budget_providers.dart
git commit -m "feat: add overallBudget and categoryBudgets Riverpod providers"
```

---

## Task 4: Budget Screen

**Files:** Create `lib/features/budget/budget_screen.dart`

**Context:**
- `overallBudgetProvider` → `AsyncValue<Budget?>` — watch for overall budget
- `categoryBudgetsProvider` → `AsyncValue<List<Budget>>` — watch for category budgets
- `expenseCategoriesProvider` → `AsyncValue<List<Category>>` — existing provider in `category_providers.dart`
- `appDatabaseProvider` → `AppDatabase` — read for mutations
- `parseCategoryColor(String hex) → Color`, `categoryIconData(String name) → IconData` — from `category_icon.dart`
- `BudgetsCompanion.insert(category: Value(String?), amount: double, month: int, year: int)` — always use `month: 0, year: 0` (monthly repeat)

- [ ] **Step 1: Create the budget screen**

```dart
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/app_database.dart';
import '../../shared/providers/budget_providers.dart';
import '../../shared/providers/category_providers.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/utils/category_icon.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overallBudget = ref.watch(overallBudgetProvider).valueOrNull;
    final categoryBudgets =
        ref.watch(categoryBudgetsProvider).valueOrNull ?? [];
    final expenseCats =
        ref.watch(expenseCategoriesProvider).valueOrNull ?? [];

    final budgetMap = {
      for (final b in categoryBudgets) b.category!: b,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('预算设置'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOverallCard(context, ref, overallBudget),
          const SizedBox(height: 24),
          Text(
            '分类预算',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          ...expenseCats.map(
            (cat) =>
                _buildCategoryTile(context, ref, cat, budgetMap[cat.name]),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallCard(
      BuildContext context, WidgetRef ref, Budget? budget) {
    final fmt = NumberFormat('#,##0.00');
    return Card(
      child: ListTile(
        leading: const Icon(Icons.account_balance_wallet_outlined),
        title: const Text('整体月预算'),
        subtitle: Text(
          budget != null ? '¥ ${fmt.format(budget.amount)}' : '未设置',
          style: TextStyle(
            color: budget != null
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showBudgetDialog(
          context,
          ref,
          title: '整体月预算',
          current: budget,
          category: null,
        ),
      ),
    );
  }

  Widget _buildCategoryTile(
    BuildContext context,
    WidgetRef ref,
    Category cat,
    Budget? budget,
  ) {
    final fmt = NumberFormat('#,##0.00');
    final color = parseCategoryColor(cat.color);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(categoryIconData(cat.icon), size: 20, color: color),
      ),
      title: Text(cat.name),
      trailing: Text(
        budget != null ? '¥ ${fmt.format(budget.amount)}' : '未设置',
        style: TextStyle(
          color: budget != null
              ? Theme.of(context).colorScheme.onSurface
              : Theme.of(context).colorScheme.outline,
        ),
      ),
      onTap: () => _showBudgetDialog(
        context,
        ref,
        title: '${cat.name}预算',
        current: budget,
        category: cat.name,
      ),
    );
  }

  Future<void> _showBudgetDialog(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required Budget? current,
    required String? category,
  }) async {
    final controller = TextEditingController(
      text: current != null ? current.amount.toStringAsFixed(2) : '',
    );
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: const InputDecoration(
            labelText: '预算金额（清空则删除）',
            prefixText: '¥ ',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = controller.text.trim();
              final db = ref.read(appDatabaseProvider);
              if (text.isEmpty && current != null) {
                await db.budgetDao.deleteBudget(current.id);
              } else {
                final amount = double.tryParse(text);
                if (amount != null && amount > 0) {
                  await db.budgetDao.upsertBudget(
                    BudgetsCompanion.insert(
                      category: Value(category),
                      amount: amount,
                      month: 0,
                      year: 0,
                    ),
                  );
                }
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
    controller.dispose();
  }
}
```

- [ ] **Step 2: Verify**

```
flutter analyze lib/features/budget/budget_screen.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```
git add lib/features/budget/budget_screen.dart
git commit -m "feat: add budget screen with overall and category budget editing"
```

---

## Task 5: Settings Entry + app.dart Route

**Files:**
- Modify: `lib/features/settings/settings_screen.dart`
- Modify: `lib/app.dart`

- [ ] **Step 1: Add budget settings entry to settings_screen.dart**

Replace the entire file:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置'), centerTitle: true),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.savings_outlined),
            title: const Text('预算设置'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/budget'),
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('分类管理'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/categories'),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Add import and /budget route to app.dart**

In `lib/app.dart`, add the import after the existing feature imports:

```dart
import 'features/budget/budget_screen.dart';
```

In `_router`, add the `/budget` route alongside the existing child routes:

```dart
GoRoute(
  path: 'budget',
  builder: (context, state) => const BudgetScreen(),
),
```

The full routes list becomes:
```dart
final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainShell(),
      routes: [
        GoRoute(
          path: 'transactions/add',
          builder: (context, state) => const AddTransactionScreen(),
        ),
        GoRoute(
          path: 'categories',
          builder: (context, state) => const CategoryManagementScreen(),
        ),
        GoRoute(
          path: 'budget',
          builder: (context, state) => const BudgetScreen(),
        ),
      ],
    ),
  ],
);
```

- [ ] **Step 3: Verify**

```
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```
git add lib/features/settings/settings_screen.dart lib/app.dart
git commit -m "feat: add budget settings entry and /budget route"
```

---

## Task 6: Dashboard Budget Progress Bars

**Files:** Modify `lib/features/dashboard/dashboard_screen.dart`

**Context:**
- `overallBudgetProvider` → `AsyncValue<Budget?>` — from `budget_providers.dart`
- `categoryBudgetsProvider` → `AsyncValue<List<Budget>>` — from `budget_providers.dart`
- `monthlyExpenseProvider` → `double` — already watched in `DashboardScreen.build`
- `monthlyTransactionsProvider` → `AsyncValue<List<Transaction>>` — already watched

The dashboard body is a `Column`. `_BudgetSection` is inserted between `_SummaryCard` and the "最近交易" label. When no budgets are set, `_BudgetSection` returns `SizedBox.shrink()`.

- [ ] **Step 1: Add budget imports to dashboard_screen.dart**

At the top of `lib/features/dashboard/dashboard_screen.dart`, add:

```dart
import '../../core/database/app_database.dart';
import '../../shared/providers/budget_providers.dart';
```

The `app_database.dart` import is already present (for `Transaction`, `Category`). Only `budget_providers.dart` is new.

- [ ] **Step 2: Update DashboardScreen.build to watch budget providers and compute category expenses**

Replace the `build` method of `DashboardScreen`:

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final monthlyIncome = ref.watch(monthlyIncomeProvider);
  final monthlyExpense = ref.watch(monthlyExpenseProvider);
  final todayIncome = ref.watch(todayIncomeProvider);
  final todayExpense = ref.watch(todayExpenseProvider);
  final transactionsAsync = ref.watch(monthlyTransactionsProvider);
  final categoryMap = {
    for (final c in ref.watch(allCategoriesProvider).valueOrNull ?? [])
      '${c.type}:${c.name}': c,
  };

  // Budget data
  final overallBudget = ref.watch(overallBudgetProvider).valueOrNull;
  final categoryBudgets =
      ref.watch(categoryBudgetsProvider).valueOrNull ?? [];
  final txs = ref.watch(monthlyTransactionsProvider).valueOrNull ?? [];
  final categoryExpenses = <String, double>{};
  for (final tx in txs.where((t) => t.type == 'expense')) {
    categoryExpenses[tx.category] =
        (categoryExpenses[tx.category] ?? 0) + tx.amount;
  }

  return Scaffold(
    appBar: AppBar(title: const Text('Finio'), centerTitle: true),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MonthNav(),
        _SummaryCard(
          monthlyIncome: monthlyIncome,
          monthlyExpense: monthlyExpense,
          todayIncome: todayIncome,
          todayExpense: todayExpense,
        ),
        _BudgetSection(
          overallBudget: overallBudget,
          monthlyExpense: monthlyExpense,
          categoryBudgets: categoryBudgets,
          categoryExpenses: categoryExpenses,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Text(
            '最近交易',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ),
        Expanded(
          child: transactionsAsync.when(
            data: (txs) => txs.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    itemCount: txs.length,
                    itemBuilder: (ctx, i) => _TransactionTile(
                      tx: txs[i],
                      category: categoryMap[
                          '${txs[i].type}:${txs[i].category}'],
                    ),
                  ),
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('加载失败: $e')),
          ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () => context.push('/transactions/add'),
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      child: const Icon(Icons.add),
    ),
  );
}
```

- [ ] **Step 3: Add _BudgetSection and _BudgetProgressRow widgets at the bottom of dashboard_screen.dart**

Append these two classes after the existing `_TransactionTile` class:

```dart
class _BudgetSection extends StatelessWidget {
  const _BudgetSection({
    required this.overallBudget,
    required this.monthlyExpense,
    required this.categoryBudgets,
    required this.categoryExpenses,
  });

  final Budget? overallBudget;
  final double monthlyExpense;
  final List<Budget> categoryBudgets;
  final Map<String, double> categoryExpenses;

  @override
  Widget build(BuildContext context) {
    if (overallBudget == null && categoryBudgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (overallBudget != null)
            _BudgetProgressRow(
              label: '整体预算',
              expense: monthlyExpense,
              budget: overallBudget!.amount,
            ),
          ...categoryBudgets.map(
            (b) => _BudgetProgressRow(
              label: b.category!,
              expense: categoryExpenses[b.category!] ?? 0,
              budget: b.amount,
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetProgressRow extends StatelessWidget {
  const _BudgetProgressRow({
    required this.label,
    required this.expense,
    required this.budget,
  });

  final String label;
  final double expense;
  final double budget;

  @override
  Widget build(BuildContext context) {
    final ratio = budget > 0 ? expense / budget : 0.0;
    final clampedRatio = ratio.clamp(0.0, 1.0);
    final fmt = NumberFormat('#,##0.00');

    final Color progressColor;
    final String? warningText;
    if (ratio > 1.0) {
      progressColor = Colors.red;
      warningText = '❌ 已超支';
    } else if (ratio >= 0.8) {
      progressColor = Colors.orange;
      warningText = '⚠️ 即将超支';
    } else {
      progressColor = Colors.green;
      warningText = null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              Text(
                '${fmt.format(expense)} / ${fmt.format(budget)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              if (warningText != null) ...[
                const SizedBox(width: 6),
                Text(
                  warningText,
                  style: TextStyle(fontSize: 11, color: progressColor),
                ),
              ],
            ],
          ),
          const SizedBox(height: 3),
          LinearProgressIndicator(
            value: clampedRatio,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            color: progressColor,
            minHeight: 5,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Verify**

```
flutter analyze lib/features/dashboard/dashboard_screen.dart
```

Expected: `No issues found!`

- [ ] **Step 5: Commit**

```
git add lib/features/dashboard/dashboard_screen.dart
git commit -m "feat: add budget progress bars to dashboard"
```

---

## Task 7: BudgetNotifier + Async main

**Files:**
- Create: `lib/core/notifications/budget_notifier.dart`
- Modify: `lib/main.dart`

**Context:**
- `flutter_local_notifications` v17: `FlutterLocalNotificationsPlugin`, `AndroidInitializationSettings('@mipmap/ic_launcher')`, `AndroidFlutterLocalNotificationsPlugin.requestNotificationsPermission()`, `AndroidNotificationDetails`, `Importance.high`, `Priority.high`
- `AppDatabase()` — creates a temporary DB connection (safe before ProviderScope starts)
- `db.budgetDao.getOverallBudget()` → `Future<Budget?>`
- `db.transactionDao.getMonthlyTotals(year, month)` → `Future<Map<String, double>>` with keys `'income'` and `'expense'`

- [ ] **Step 1: Create lib/core/notifications/budget_notifier.dart**

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../database/app_database.dart';

class BudgetNotifier {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  /// Opens a temporary DB connection, checks this month's expense vs overall
  /// budget, and fires a local notification if the threshold is crossed.
  static Future<void> checkStartupNotification() async {
    final db = AppDatabase();
    try {
      final overallBudget = await db.budgetDao.getOverallBudget();
      if (overallBudget == null) return;

      final now = DateTime.now();
      final totals =
          await db.transactionDao.getMonthlyTotals(now.year, now.month);
      final expense = totals['expense'] ?? 0.0;

      await _checkAndNotify(expense: expense, budget: overallBudget.amount);
    } finally {
      await db.close();
    }
  }

  static Future<void> _checkAndNotify({
    required double expense,
    required double budget,
  }) async {
    if (budget <= 0) return;
    final ratio = expense / budget;

    final String? message;
    if (ratio > 1.0) {
      message = '本月支出已超出预算！';
    } else if (ratio >= 0.8) {
      message = '本月支出已达预算的 80%，请注意控制开支';
    } else {
      message = null;
    }
    if (message == null) return;

    const androidDetails = AndroidNotificationDetails(
      'budget_channel',
      '预算提醒',
      channelDescription: '预算超支通知',
      importance: Importance.high,
      priority: Priority.high,
    );
    await _plugin.show(
      0,
      'Finio 预算提醒',
      message,
      const NotificationDetails(android: androidDetails),
    );
  }
}
```

- [ ] **Step 2: Update lib/main.dart**

Replace the entire file:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/notifications/budget_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BudgetNotifier.init();
  await BudgetNotifier.checkStartupNotification();
  runApp(const ProviderScope(child: FinioApp()));
}
```

- [ ] **Step 3: Verify**

```
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 4: Commit**

```
git add lib/core/notifications/budget_notifier.dart lib/main.dart
git commit -m "feat: add BudgetNotifier with local push notifications"
```

---

## Spec Coverage Check

| Spec requirement | Covered by |
|-----------------|-----------|
| Budgets 表定义（5 columns） | Task 2, `class Budgets extends Table` |
| BudgetDao: getBudgets, getOverallBudget, getCategoryBudgets | Task 2, `BudgetDao` |
| BudgetDao: upsertBudget, deleteBudget | Task 2, `BudgetDao.upsertBudget` / `deleteBudget` |
| schemaVersion 1 → 2, migration creates budgets table | Task 2, `onUpgrade` |
| dart run build_runner | Task 2, Step 3 |
| 设置页「预算设置」入口 | Task 5, `settings_screen.dart` |
| BudgetScreen 整体月预算卡片，可点击编辑 | Task 4, `_buildOverallCard` + `_showBudgetDialog` |
| BudgetScreen 分类预算列表，显示已设/未设，点击编辑 | Task 4, `_buildCategoryTile` + `_showBudgetDialog` |
| 清空金额 → 删除预算 | Task 4, `text.isEmpty && current != null` branch |
| /budget 路由 | Task 5, `app.dart` GoRoute |
| Dashboard 整体预算进度条（绿/橙/红 + 文案） | Task 6, `_BudgetProgressRow` |
| Dashboard 分类预算进度条 | Task 6, `_BudgetSection` maps `categoryBudgets` |
| 无预算时不显示 | Task 6, `_BudgetSection` returns `SizedBox.shrink()` |
| flutter_local_notifications 依赖 | Task 1 |
| BudgetNotifier init + 权限申请 | Task 7, `BudgetNotifier.init()` |
| main.dart async init | Task 7, `main()` with `ensureInitialized` |
| 80% 通知文案 | Task 7, `_checkAndNotify` |
| 100% 通知文案 | Task 7, `_checkAndNotify` |
| 通知标题「Finio 预算提醒」 | Task 7, `_plugin.show(0, 'Finio 预算提醒', ...)` |
| Android manifest POST_NOTIFICATIONS | Task 2, Step 4 |
