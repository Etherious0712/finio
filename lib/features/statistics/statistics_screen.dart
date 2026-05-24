import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/stats_models.dart';
import '../../shared/providers/currency_provider.dart';
import '../../shared/providers/statistics_providers.dart';
import '../../shared/utils/category_icon.dart';
import '../../shared/utils/category_localizer.dart';
import '../../shared/utils/currency_formatter.dart';
import '../../shared/widgets/month_nav.dart';
import 'package:finio/app_localizations.dart';

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.statistics),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: l.expense), Tab(text: l.income)],
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
    final symbol = ref.watch(currencySymbolProvider);
    final total = stats.fold(0.0, (s, c) => s + c.amount);

    final l = AppLocalizations.of(context)!;
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
            symbol: symbol,
          ),
          const SizedBox(height: 12),
          _LegendList(
            stats: stats,
            touchedIndex: _touchedIndex,
            symbol: symbol,
          ),
        ],
        const SizedBox(height: 28),
        Text(l.last6MonthsTrend, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: Colors.green.shade400, label: l.income),
            const SizedBox(width: 20),
            _LegendDot(color: Colors.red.shade400, label: l.expense),
          ],
        ),
        const SizedBox(height: 8),
        last6Async.when(
          data: (months) => _BarSection(months: months),
          loading: () => const SizedBox(
              height: 200, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => SizedBox(
            height: 200,
            child: Center(child: Text(l.loadFailed)),
          ),
        ),
      ],
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
                    ? localizeCategory(AppLocalizations.of(context)!, stats[touchedIndex].category)
                    : AppLocalizations.of(context)!.totalLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                formatAmount(
                  touchedIndex >= 0 && touchedIndex < stats.length
                      ? stats[touchedIndex].amount
                      : total,
                  symbol,
                ),
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

class _LegendList extends StatelessWidget {
  const _LegendList({
    required this.stats,
    required this.touchedIndex,
    required this.symbol,
  });

  final List<CategoryStat> stats;
  final int touchedIndex;
  final String symbol;

  @override
  Widget build(BuildContext context) {
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
                child: Text(localizeCategory(AppLocalizations.of(context)!, s.category),
                    style: Theme.of(context).textTheme.bodyMedium),
              ),
              Text(
                formatAmount(s.amount, symbol),
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

class _BarSection extends StatelessWidget {
  const _BarSection({required this.months});

  final List<MonthSummary> months;

  @override
  Widget build(BuildContext context) {
    if (months.isEmpty) {
      final l = AppLocalizations.of(context)!;
      return SizedBox(
        height: 80,
        child: Center(
          child: Text(
            l.noData,
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ),
      );
    }

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
                    return const Text('0', style: TextStyle(fontSize: 10));
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
              type == 'expense' ? l.noMonthlyExpenseRecords : l.noMonthlyIncomeRecords,
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
