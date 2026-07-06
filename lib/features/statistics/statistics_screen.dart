import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:finio/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/models/stats_models.dart';
import '../../shared/providers/category_providers.dart';
import '../../shared/providers/currency_provider.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/providers/statistics_providers.dart';
import '../../shared/providers/transaction_providers.dart';
import '../../shared/utils/category_icon.dart';
import '../../shared/utils/category_localizer.dart';
import '../../shared/utils/currency_formatter.dart';
import '../../shared/widgets/scope_bar.dart';
import '../../shared/widgets/transaction_tile.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // Single view: expense breakdown (by main, drills into subs) + the
    // income-vs-expense trend below. No expense/income tabs.
    return Scaffold(
      appBar: AppBar(title: Text(l.statistics)),
      body: Column(
        children: const [
          ScopeBar(),
          Expanded(child: _StatsTab(type: 'expense')),
        ],
      ),
    );
  }
}

class _StatsTab extends ConsumerStatefulWidget {
  const _StatsTab({required this.type});
  final String type;

  @override
  ConsumerState<_StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends ConsumerState<_StatsTab> {
  int _touchedIndex = -1;

  void _select(int i) => setState(() => _touchedIndex = i);

  void _drill(BuildContext context, String category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CategoryDrillSheet(type: widget.type, category: category),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final stats = ref.watch(categoryStatsProvider(widget.type));
    final last6Async = ref.watch(last6MonthsProvider);
    final symbol = ref.watch(currencySymbolProvider);
    final total = stats.fold(0.0, (s, c) => s + c.amount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.sm, Insets.lg, Insets.xxl),
      children: [
        if (stats.isEmpty)
          _EmptyState(type: widget.type)
        else ...[
          _PieSection(
            stats: stats,
            total: total,
            touchedIndex: _touchedIndex,
            onTouch: _select,
            symbol: symbol,
          ),
          _MoMBadge(type: widget.type),
          const SizedBox(height: Insets.md),
          _LegendList(
            stats: stats,
            touchedIndex: _touchedIndex,
            symbol: symbol,
            onTap: (i) {
              _select(i);
              _drill(context, stats[i].category);
            },
          ),
        ],
        const SizedBox(height: Insets.xl),
        Text(l.last6MonthsTrend, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: Insets.sm),
        last6Async.when(
          data: (months) => _BarSection(months: months),
          loading: () => const SizedBox(
              height: 200, child: Center(child: CircularProgressIndicator())),
          error: (e, _) =>
              SizedBox(height: 200, child: Center(child: Text(l.loadFailed))),
        ),
      ],
    );
  }
}

/// Month-over-month delta for the active type, derived from the 6-month series.
class _MoMBadge extends ConsumerWidget {
  const _MoMBadge({required this.type});
  final String type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    // "% vs last month" only makes sense in month scope.
    if (ref.watch(recordScopeProvider) != RecordScope.month) {
      return const SizedBox.shrink();
    }
    final months = ref.watch(last6MonthsProvider).valueOrNull;
    if (months == null || months.length < 2) {
      return const SizedBox.shrink();
    }
    double valOf(MonthSummary m) => type == 'expense' ? m.expense : m.income;
    final current = valOf(months.last);
    final prev = valOf(months[months.length - 2]);
    if (prev == 0) return const SizedBox.shrink();

    final delta = (current - prev) / prev * 100;
    final up = delta >= 0;
    final finio = context.finio;
    // For expenses, up is "bad" (red); for income, up is "good" (green).
    final good = type == 'expense' ? !up : up;
    final color = good ? finio.income : finio.expense;

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(up ? Icons.trending_up : Icons.trending_down,
              size: 16, color: color),
          const SizedBox(width: Insets.xs),
          Text(
            '${up ? '+' : ''}${delta.toStringAsFixed(0)}% ${l.vsLastMonth}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _PieSection extends StatelessWidget {
  const _PieSection({
    required this.stats,
    required this.total,
    required this.touchedIndex,
    required this.onTouch,
    required this.symbol,
  });

  final List<CategoryStat> stats;
  final double total;
  final int touchedIndex;
  final ValueChanged<int> onTouch;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
                return PieChartSectionData(
                  value: s.amount,
                  color: parseCategoryColor(s.color),
                  title: isTouched ? '${s.percentage.toStringAsFixed(1)}%' : '',
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
                    ? localizeCategory(l, stats[touchedIndex].category)
                    : l.totalLabel,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 2),
              Text(
                formatAmount(
                  touchedIndex >= 0 && touchedIndex < stats.length
                      ? stats[touchedIndex].amount
                      : total,
                  symbol,
                ),
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)
                    .tabular,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendList extends StatelessWidget {
  const _LegendList({
    required this.stats,
    required this.touchedIndex,
    required this.symbol,
    required this.onTap,
  });

  final List<CategoryStat> stats;
  final int touchedIndex;
  final String symbol;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      children: List.generate(stats.length, (i) {
        final s = stats[i];
        final color = parseCategoryColor(s.color);
        final isHighlighted = i == touchedIndex;

        return InkWell(
          borderRadius: BorderRadius.circular(Radii.sm),
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 2),
            padding:
                const EdgeInsets.symmetric(horizontal: Insets.sm, vertical: Insets.sm),
            decoration: BoxDecoration(
              color: isHighlighted ? color.withValues(alpha: 0.1) : null,
              borderRadius: BorderRadius.circular(Radii.sm),
            ),
            child: Row(
              children: [
                Icon(categoryIconData(s.icon), size: 16, color: color),
                const SizedBox(width: Insets.sm),
                Expanded(
                  child: Text(localizeCategory(l, s.category),
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                Text(formatAmount(s.amount, symbol),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)
                        .tabular),
                const SizedBox(width: Insets.sm),
                SizedBox(
                  width: 46,
                  child: Text('${s.percentage.toStringAsFixed(1)}%',
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodySmall),
                ),
                const Icon(Icons.chevron_right, size: 16),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _BarSection extends ConsumerWidget {
  const _BarSection({required this.months});

  final List<MonthSummary> months;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final finio = context.finio;
    final locale = Localizations.localeOf(context).toString();

    if (months.isEmpty) {
      return SizedBox(
        height: 80,
        child: Center(child: Text(l.noData)),
      );
    }

    final maxVal = months.fold(0.0, (m, s) {
      final hi = s.income > s.expense ? s.income : s.expense;
      return hi > m ? hi : m;
    });
    final maxY = (maxVal * 1.25).ceilToDouble() + 1;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: finio.income, label: l.income),
            const SizedBox(width: Insets.xl),
            _LegendDot(color: finio.expense, label: l.expense),
          ],
        ),
        const SizedBox(height: Insets.sm),
        SizedBox(
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
                      color: finio.income,
                      width: 10,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                    BarChartRodData(
                      toY: m.expense,
                      color: finio.expense,
                      width: 10,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                );
              }),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
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
                        child: Text(
                          DateFormat.MMM(locale).format(months[i].month),
                          style: const TextStyle(fontSize: 11),
                        ),
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
                        return const Text('0', style: TextStyle(fontSize: 10));
                      }
                      if (value >= 1000) {
                        return Text('${(value / 1000).toStringAsFixed(1)}K',
                            style: const TextStyle(fontSize: 10));
                      }
                      return Text(value.toInt().toString(),
                          style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
              ),
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bottom sheet for a tapped MAIN category: its sub-category breakdown, then
/// every transaction rolled up under it for the active scope.
class _CategoryDrillSheet extends ConsumerWidget {
  const _CategoryDrillSheet({required this.type, required this.category});

  final String type;
  final String category; // main category name

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final symbol = ref.watch(currencySymbolProvider);
    final mainKeyMap = ref.watch(categoryMainKeyProvider);
    final subStats =
        ref.watch(subcategoryStatsProvider((type: type, main: category)));
    final txs = (ref.watch(scopedTransactionsProvider).valueOrNull ?? [])
        .where((t) =>
            t.type == type &&
            (mainKeyMap['${t.type}:${t.category}'] ?? t.category) == category)
        .toList();
    final categoryMap = {
      for (final c in ref.watch(allCategoriesProvider).valueOrNull ?? [])
        '${c.type}:${c.name}': c,
    };

    // Only worth showing a sub list when there's real sub-detail.
    final showSubs = subStats.length > 1 ||
        (subStats.length == 1 && subStats.first.category != category);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.only(bottom: Insets.xl),
        children: [
          Padding(
            padding: const EdgeInsets.all(Insets.lg),
            child: Text(localizeCategory(l, category),
                style: Theme.of(context).textTheme.titleLarge),
          ),
          if (showSubs) ...[
            for (final s in subStats)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Insets.lg, vertical: Insets.xs),
                child: Row(
                  children: [
                    Icon(categoryIconData(s.icon),
                        size: 16, color: parseCategoryColor(s.color)),
                    const SizedBox(width: Insets.sm),
                    Expanded(
                      child: Text(localizeCategory(l, s.category),
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    Text(formatAmount(s.amount, symbol),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)
                            .tabular),
                    const SizedBox(width: Insets.sm),
                    SizedBox(
                      width: 44,
                      child: Text('${s.percentage.toStringAsFixed(0)}%',
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
            const Divider(height: Insets.xl),
          ],
          for (final tx in txs)
            TransactionTile(
              tx: tx,
              category: categoryMap['${tx.type}:${tx.category}'],
              symbol: symbol,
              showDate: true,
              onEdit: () {
                Navigator.pop(context);
                context.push('/transactions/add', extra: tx);
              },
              onDelete: () => ref
                  .read(appDatabaseProvider)
                  .transactionDao
                  .deleteTransaction(tx.id),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState({required this.type});
  final String type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    // Month keeps the type-specific message; year/all-time reuse the generic
    // ones (the active tab already indicates expense vs income).
    final text = switch (ref.watch(recordScopeProvider)) {
      RecordScope.month =>
        type == 'expense' ? l.noMonthlyExpenseRecords : l.noMonthlyIncomeRecords,
      RecordScope.year => l.noYearlyRecords,
      RecordScope.allTime => l.noRecords,
    };
    return SizedBox(
      height: 160,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pie_chart_outline, size: 48, color: scheme.outlineVariant),
            const SizedBox(height: Insets.md),
            Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.outline),
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
        const SizedBox(width: Insets.xs),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
