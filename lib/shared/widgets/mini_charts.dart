import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../models/stats_models.dart';
import '../utils/category_icon.dart';

/// A tiny, axis-less line chart for at-a-glance trends (e.g. last 7 days of
/// spending). Decorative — no labels, just shape.
class MiniSparkline extends StatelessWidget {
  const MiniSparkline({
    super.key,
    required this.values,
    required this.color,
    this.height = 40,
  });

  final List<double> values;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) return SizedBox(height: height);
    final spots = [
      for (int i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
    ];

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          minY: 0,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: color,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: color.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
        duration: Duration.zero,
      ),
    );
  }
}

/// A compact donut summarizing category breakdown. Tapping the donut calls
/// [onTap] (e.g. to open full statistics).
class MiniDonut extends StatelessWidget {
  const MiniDonut({
    super.key,
    required this.stats,
    this.size = 96,
    this.onTap,
  });

  final List<CategoryStat> stats;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Show top 4 slices + an "other" remainder to avoid a cluttered ring.
    final top = stats.take(4).toList();
    final restPct =
        stats.skip(4).fold<double>(0, (sum, s) => sum + s.percentage);

    final sections = <PieChartSectionData>[
      for (final s in top)
        PieChartSectionData(
          value: s.percentage,
          color: parseCategoryColor(s.color),
          radius: size * 0.16,
          showTitle: false,
        ),
      if (restPct > 0.5)
        PieChartSectionData(
          value: restPct,
          color: Theme.of(context).colorScheme.outlineVariant,
          radius: size * 0.16,
          showTitle: false,
        ),
    ];

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: PieChart(
          PieChartData(
            sections: sections,
            sectionsSpace: 2,
            centerSpaceRadius: size * 0.28,
            startDegreeOffset: -90,
          ),
        ),
      ),
    );
  }
}

/// A horizontal color-dot legend for [MiniDonut].
class DonutLegend extends StatelessWidget {
  const DonutLegend({super.key, required this.stats, required this.labelOf});

  final List<CategoryStat> stats;
  final String Function(String key) labelOf;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final s in stats.take(5))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: parseCategoryColor(s.color),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: Insets.sm),
                Expanded(
                  child: Text(
                    labelOf(s.category),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Text(
                  '${s.percentage.round()}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
