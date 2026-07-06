import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finio/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../providers/transaction_providers.dart';
import 'month_nav.dart';

/// Scope toolbar (Month / Year / All time) above a scope-aware period picker.
/// Shared by Records + Statistics. Replaces the old sort menu + inconsistent
/// period navigators.
class ScopeBar extends ConsumerWidget {
  const ScopeBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final scope = ref.watch(recordScopeProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              Insets.lg, Insets.sm, Insets.lg, Insets.xs),
          child: SegmentedButton<RecordScope>(
            segments: [
              ButtonSegment(value: RecordScope.month, label: Text(l.groupByMonth)),
              ButtonSegment(value: RecordScope.year, label: Text(l.groupByYear)),
              ButtonSegment(value: RecordScope.allTime, label: Text(l.allTime)),
            ],
            selected: {scope},
            showSelectedIcon: false,
            onSelectionChanged: (s) =>
                ref.read(recordScopeProvider.notifier).state = s.first,
          ),
        ),
        _periodPicker(context, ref, scope, l),
      ],
    );
  }

  Widget _periodPicker(
      BuildContext context, WidgetRef ref, RecordScope scope, AppLocalizations l) {
    switch (scope) {
      case RecordScope.month:
        return const MonthNav();
      case RecordScope.year:
        final year = ref.watch(selectedMonthProvider).year;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: Insets.xs),
          child: Center(
            child: PeriodPickerButton(
              label: '$year',
              onTap: () => _openYearPicker(context, ref, year),
            ),
          ),
        );
      case RecordScope.allTime:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: Insets.md),
          child: Center(
            child:
                Text(l.allTime, style: Theme.of(context).textTheme.titleMedium),
          ),
        );
    }
  }

  Future<void> _openYearPicker(
      BuildContext context, WidgetRef ref, int current) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (_) => _YearPickerSheet(current: current),
    );
    if (picked != null) {
      final m = ref.read(selectedMonthProvider);
      // Preserve the month component; only the year changes.
      ref.read(selectedMonthProvider.notifier).state = DateTime(picked, m.month);
    }
  }
}

class _YearPickerSheet extends StatelessWidget {
  const _YearPickerSheet({required this.current});
  final int current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    // 12 years ending at whichever is later (handles future-dated selections).
    final base = current > now.year ? current : now.year;
    final years = [for (int i = 0; i < 12; i++) base - i];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Insets.lg),
        child: GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.6,
          mainAxisSpacing: Insets.sm,
          crossAxisSpacing: Insets.sm,
          children: [
            for (final y in years)
              Material(
                color: y == current
                    ? scheme.primary
                    : scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(Radii.md),
                child: InkWell(
                  borderRadius: BorderRadius.circular(Radii.md),
                  onTap: () => Navigator.pop(context, y),
                  child: Center(
                    child: Text(
                      '$y',
                      style: TextStyle(
                        color: y == current ? scheme.onPrimary : scheme.onSurface,
                        fontWeight: y == (now.year)
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
