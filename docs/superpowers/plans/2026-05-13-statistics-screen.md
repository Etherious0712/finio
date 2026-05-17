# Statistics Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Statistics tab (4th in bottom nav) that shows monthly category breakdown as a donut pie chart plus a 6-month income/expense bar chart.

**Architecture:** All chart data is derived in Riverpod providers from the existing `monthlyTransactionsProvider` stream (reactive to month changes) and the existing `getMonthlyTotals` DAO method (looped for 6 months). No new DAO methods needed. A `stats_models.dart` holds two simple data classes used by both the provider and the screen widgets.

**Tech Stack:** Flutter / Dart 3, Riverpod, Drift (existing), fl_chart ^0.68.0 (new)

---

## File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Modify | `pubspec.yaml` | add fl_chart dependency |
| Create | `lib/shared/models/stats_models.dart` | `CategoryStat`, `MonthSummary` data classes |
| Create | `lib/shared/providers/statistics_providers.dart` | `categoryStatsProvider`, `last6MonthsProvider` |
| Create | `lib/features/statistics/statistics_screen.dart` | full statistics screen + all sub-widgets |
| Modify | `lib/app.dart` | 4th tab + StatisticsScreen in IndexedStack |

---

## Task 1: Add fl_chart Dependency

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add fl_chart to pubspec.yaml**

In `pubspec.yaml`, add under the `# UI` comment block (after `cupertino_icons`):

```yaml
  fl_chart: ^0.68.0
```

Full dependencies section becomes:
```yaml
dependencies:
  flutter:
    sdk: flutter

  # UI
  cupertino_icons: ^1.0.8
  fl_chart: ^0.68.0

  # Color picker
  flutter_colorpicker: ^1.1.0

  # State management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  ...
```

- [ ] **Step 2: Install the package**

```
flutter pub get
```

Expected output contains: `+ fl_chart 0.68.0`

---

## Task 2: Create Data Models

**Files:**
- Create: `lib/shared/models/stats_models.dart`

- [ ] **Step 1: Create the models file**

```dart
// lib/shared/models/stats_models.dart

class CategoryStat {
  final String category;
  final String icon;
  final String color;
  final double amount;
  final double percentage;

  const CategoryStat({
    required this.category,
    required this.icon,
    required this.color,
    required this.amount,
    required this.percentage,
  });
}

class MonthSummary {
  final DateTime month;
  final double income;
  final double expense;

  const MonthSummary({
    required this.month,
    required this.income,
    required this.expense,
  });
}
```

- [ ] **Step 2: Verify with flutter analyze**

```
flutter analyze lib/shared/models/stats_models.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```
git add lib/shared/models/stats_models.dart
git commit -m "feat: add CategoryStat and MonthSummary data models"
```

---

## Task 3: Create Statistics Providers

**Files:**
- Create: `lib/shared/providers/statistics_providers.dart`

**Context:**
- `selectedMonthProvider` — `StateProvider<DateTime>` in `transaction_providers.dart`
- `monthlyTransactionsProvider` — `StreamProvider<List<Transaction>>`, watches `selectedMonthProvider`
- `categoriesByTypeProvider(type)` — `StreamProvider.autoDispose.family` for category list
- `appDatabaseProvider` — provides `AppDatabase`
- `AppDatabase.transactionDao.getMonthlyTotals(year, month)` — returns `Map<String, double>` with keys `'income'` and `'expense'`

- [ ] **Step 1: Create the providers file**

```dart
// lib/shared/providers/statistics_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/stats_models.dart';
import 'category_providers.dart';
import 'database_provider.dart';
import 'transaction_providers.dart';

/// Per-type category breakdown for the currently selected month.
/// Watches monthlyTransactionsProvider so it reacts to month changes + new entries.
final categoryStatsProvider =
    Provider.autoDispose.family<List<CategoryStat>, String>((ref, type) {
  final txs = ref.watch(monthlyTransactionsProvider).valueOrNull ?? [];
  final cats = ref.watch(categoriesByTypeProvider(type)).valueOrNull ?? [];

  final catMap = {for (final c in cats) c.name: c};

  // Aggregate amounts per category
  final totals = <String, double>{};
  for (final tx in txs.where((t) => t.type == type)) {
    totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
  }

  final grandTotal = totals.values.fold(0.0, (a, b) => a + b);
  if (grandTotal == 0) return [];

  final result = totals.entries.map((e) {
    final cat = catMap[e.key];
    return CategoryStat(
      category: e.key,
      icon: cat?.icon ?? 'more_horiz',
      color: cat?.color ?? '#B0B0B0',
      amount: e.value,
      percentage: e.value / grandTotal * 100,
    );
  }).toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));

  return result;
});

/// Last 6 months income + expense totals. Refreshes when any transaction changes
/// (watches monthlyTransactionsProvider as a reactive trigger).
final last6MonthsProvider =
    FutureProvider.autoDispose<List<MonthSummary>>((ref) async {
  ref.watch(monthlyTransactionsProvider); // reactive refresh trigger
  final db = ref.watch(appDatabaseProvider);
  final now = DateTime.now();

  final result = <MonthSummary>[];
  for (int i = 5; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i);
    final totals =
        await db.transactionDao.getMonthlyTotals(month.year, month.month);
    result.add(MonthSummary(
      month: month,
      income: totals['income']!,
      expense: totals['expense']!,
    ));
  }
  return result;
});
```

- [ ] **Step 2: Verify with flutter analyze**

```
flutter analyze lib/shared/providers/statistics_providers.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```
git add lib/shared/providers/statistics_providers.dart
git commit -m "feat: add categoryStats and last6Months Riverpod providers"
```

---

## Task 4: Build Statistics Screen

**Files:**
- Create: `lib/features/statistics/statistics_screen.dart`

**Context:**
- `MonthNav` — shared `ConsumerWidget` from `lib/shared/widgets/month_nav.dart`
- `parseCategoryColor(String hex)` → `Color` — from `lib/shared/utils/category_icon.dart`
- `categoryIconData(String iconName)` → `IconData` — same file
- `categoryStatsProvider(type)` returns `List<CategoryStat>` — provider from Task 3
- `last6MonthsProvider` returns `List<MonthSummary>` — provider from Task 3

**fl_chart 0.68 key types:**
- `PieChart(PieChartData(...))`, `PieChartSectionData`, `PieTouchData`, `FlTouchEvent.isInterestedForInteractions`
- `BarChart(BarChartData(...))`, `BarChartGroupData`, `BarChartRodData`, `FlTitlesData`, `AxisTitles`, `SideTitles`

- [ ] **Step 1: Create the statistics screen**

```dart
// lib/features/statistics/statistics_screen.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../shared/models/stats_models.dart';
import '../../shared/providers/statistics_providers.dart';
import '../../shared/utils/category_icon.dart';
import '../../shared/widgets/month_nav.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('统计'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: '支出'), Tab(text: '收入')],
        ),
      ),
      body: Column(
        children: [
          const MonthNav(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _StatsTab(type: 'expense'),
                _StatsTab(type: 'income'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab content
// ---------------------------------------------------------------------------

class _StatsTab extends ConsumerStatefulWidget {
  const _StatsTab({required this.type});
  final String type;

  @override
  ConsumerState<_StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends ConsumerState<_StatsTab> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(categoryStatsProvider(widget.type));
    final last6Async = ref.watch(last6MonthsProvider);
    final total = stats.fold(0.0, (s, c) => s + c.amount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        if (stats.isEmpty)
          _EmptyState(type: widget.type)
        else ...[
          _PieSection(
            stats: stats,
            total: total,
            touchedIndex: _touchedIndex,
            onTouch: (i) => setState(() => _touchedIndex = i),
          ),
          const SizedBox(height: 12),
          _LegendList(stats: stats, touchedIndex: _touchedIndex),
        ],
        const SizedBox(height: 28),
        Text('近6个月趋势', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: Colors.green.shade400, label: '收入'),
            const SizedBox(width: 20),
            _LegendDot(color: Colors.red.shade400, label: '支出'),
          ],
        ),
        const SizedBox(height: 8),
        last6Async.when(
          data: (months) => _BarSection(months: months),
          loading: () =>
              const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Text('加载失败: $e'),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Pie chart section
// ---------------------------------------------------------------------------

class _PieSection extends StatelessWidget {
  const _PieSection({
    required this.stats,
    required this.total,
    required this.touchedIndex,
    required this.onTouch,
  });

  final List<CategoryStat> stats;
  final double total;
  final int touchedIndex;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');

    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: List.generate(stats.length, (i) {
                final s = stats[i];
                final isTouched = i == touchedIndex;
                final color = parseCategoryColor(s.color);
                return PieChartSectionData(
                  value: s.amount,
                  color: color,
                  title: isTouched
                      ? '${s.percentage.toStringAsFixed(1)}%'
                      : '',
                  radius: isTouched ? 72 : 58,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  if (!event.isInterestedForInteractions ||
                      response?.touchedSection == null) {
                    onTouch(-1);
                    return;
                  }
                  onTouch(response!.touchedSection!.touchedSectionIndex);
                },
              ),
              centerSpaceRadius: 58,
              sectionsSpace: 2,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                touchedIndex >= 0 && touchedIndex < stats.length
                    ? stats[touchedIndex].category
                    : '总计',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                fmt.format(touchedIndex >= 0 && touchedIndex < stats.length
                    ? stats[touchedIndex].amount
                    : total),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category legend list
// ---------------------------------------------------------------------------

class _LegendList extends StatelessWidget {
  const _LegendList({required this.stats, required this.touchedIndex});

  final List<CategoryStat> stats;
  final int touchedIndex;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');

    return Column(
      children: List.generate(stats.length, (i) {
        final s = stats[i];
        final color = parseCategoryColor(s.color);
        final isHighlighted = i == touchedIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isHighlighted
                ? color.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Icon(categoryIconData(s.icon), size: 15, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(s.category,
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
              Text(
                fmt.format(s.amount),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 46,
                child: Text(
                  '${s.percentage.toStringAsFixed(1)}%',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Bar chart section (6-month trend)
// ---------------------------------------------------------------------------

class _BarSection extends StatelessWidget {
  const _BarSection({required this.months});

  final List<MonthSummary> months;

  @override
  Widget build(BuildContext context) {
    final maxVal = months.fold(0.0, (m, s) {
      final hi = s.income > s.expense ? s.income : s.expense;
      return hi > m ? hi : m;
    });
    final maxY = (maxVal * 1.25).ceilToDouble() + 1;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barGroups: List.generate(months.length, (i) {
            final m = months[i];
            return BarChartGroupData(
              x: i,
              barsSpace: 4,
              barRods: [
                BarChartRodData(
                  toY: m.income,
                  color: Colors.green.shade400,
                  width: 10,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                ),
                BarChartRodData(
                  toY: m.expense,
                  color: Colors.red.shade400,
                  width: 10,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= months.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('${months[i].month.month}月',
                        style: const TextStyle(fontSize: 11)),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 52,
                getTitlesWidget: (value, _) {
                  if (value == 0) {
                    return const Text('0',
                        style: TextStyle(fontSize: 10));
                  }
                  if (value >= 1000) {
                    return Text(
                      '${(value / 1000).toStringAsFixed(1)}K',
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared small widgets
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 48,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 12),
            Text(
              '本月暂无${type == 'expense' ? '支出' : '收入'}记录',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
```

- [ ] **Step 2: Verify with flutter analyze**

```
flutter analyze lib/features/statistics/statistics_screen.dart
```

Expected: `No issues found!`

- [ ] **Step 3: Commit**

```
git add lib/features/statistics/statistics_screen.dart
git commit -m "feat: add statistics screen with pie chart and 6-month bar chart"
```

---

## Task 5: Wire Up app.dart

**Files:**
- Modify: `lib/app.dart`

**Context:**
Current `MainShell._MainShellState.build` has an `IndexedStack` with 3 children (`DashboardScreen`, `TransactionListScreen`, `SettingsScreen`) and a `NavigationBar` with 3 destinations. Add `StatisticsScreen` as the 3rd child (index 2) and shift `SettingsScreen` to index 3.

- [ ] **Step 1: Add import**

In `lib/app.dart`, add after the existing feature imports:

```dart
import 'features/statistics/statistics_screen.dart';
```

Full imports block:
```dart
import 'features/categories/category_management_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/statistics/statistics_screen.dart';
import 'features/transactions/add_transaction_screen.dart';
import 'features/transactions/transaction_list_screen.dart';
```

- [ ] **Step 2: Update IndexedStack children**

Replace the 3-child IndexedStack with 4 children:

```dart
body: IndexedStack(
  index: _index,
  children: const [
    DashboardScreen(),
    TransactionListScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ],
),
```

- [ ] **Step 3: Update NavigationBar destinations**

Replace the 3-destination NavigationBar with 4 destinations, inserting 统计 before 设置:

```dart
bottomNavigationBar: NavigationBar(
  selectedIndex: _index,
  onDestinationSelected: (i) => setState(() => _index = i),
  destinations: const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: '主页',
    ),
    NavigationDestination(
      icon: Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long),
      label: '记录',
    ),
    NavigationDestination(
      icon: Icon(Icons.bar_chart_outlined),
      selectedIcon: Icon(Icons.bar_chart),
      label: '统计',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: '设置',
    ),
  ],
),
```

- [ ] **Step 4: Verify with flutter analyze**

```
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 5: Commit**

```
git add lib/app.dart
git commit -m "feat: add statistics tab (4th) to bottom navigation"
```

---

## Spec Coverage Check

| Spec requirement | Covered by |
|-----------------|-----------|
| 顶部月份切换 MonthNav | `StatisticsScreen.build` → `const MonthNav()` |
| TabBar 支出/收入 | `_tabController` + `TabBarView` with `_StatsTab(type: ...)` |
| PieChart 各分类占比 | `_PieSection` using `fl_chart PieChart` |
| 饼图中间显示总金额 | `Stack` center overlay in `_PieSection` |
| 饼图下方列表：圆点+名+金额+% | `_LegendList` rows |
| 点击区块高亮列表 | `_touchedIndex` in `_StatsTabState`, `AnimatedContainer` in `_LegendList` |
| 近6个月趋势 BarChart | `_BarSection` using `fl_chart BarChart` |
| 两根柱子（绿=收入，红=支出） | `BarChartRodData` with `Colors.green.shade400` / `Colors.red.shade400` |
| X轴显示月份 | `bottomTitles` `getTitlesWidget` → `'${months[i].month.month}月'` |
| Y轴自动适应最大值 | `maxY = (maxVal * 1.25).ceilToDouble() + 1` |
| 底部 Tab：bar_chart 图标，标签「统计」 | `NavigationDestination` with `Icons.bar_chart` |
| 按分类汇总月支出/收入 | `categoryStatsProvider` grouping in Dart |
| 近6个月每月收入+支出 | `last6MonthsProvider` looping `getMonthlyTotals` |
