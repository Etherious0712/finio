import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../providers/transaction_providers.dart';

/// Gesture-first month selector. Swipe horizontally to change month, tap to
/// open a month-grid picker. Chevron buttons remain as the tap alternative for
/// accessibility. Date label is locale-aware (replaces the old hardcoded
/// Chinese date format).
class MonthNav extends ConsumerWidget {
  const MonthNav({super.key});

  void _shift(WidgetRef ref, int delta) {
    final m = ref.read(selectedMonthProvider);
    ref.read(selectedMonthProvider.notifier).state =
        DateTime(m.year, m.month + delta);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final locale = Localizations.localeOf(context).toString();
    final label = DateFormat.yMMMM(locale).format(month);

    return GestureDetector(
      // Swipe left → next month, swipe right → previous month.
      onHorizontalDragEnd: (details) {
        final v = details.primaryVelocity ?? 0;
        if (v < -120) _shift(ref, 1);
        if (v > 120) _shift(ref, -1);
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: Insets.sm, vertical: Insets.xs),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _shift(ref, -1),
            ),
            Expanded(
              child: Center(
                child: PeriodPickerButton(
                  label: label,
                  onTap: () => _openPicker(context, ref, month),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _shift(ref, 1),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPicker(
      BuildContext context, WidgetRef ref, DateTime current) async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      builder: (_) => _MonthPickerSheet(current: current),
    );
    if (picked != null) {
      ref.read(selectedMonthProvider.notifier).state = picked;
    }
  }
}

/// Tappable period label with a visible affordance (filled pill + caret) so it
/// reads as a button, not plain text. Shared by [MonthNav] and the year picker.
class PeriodPickerButton extends StatelessWidget {
  const PeriodPickerButton({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(Radii.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.pill),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(
              left: Insets.md, right: Insets.sm, top: Insets.xs, bottom: Insets.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: Motion.fast,
                child: Text(
                  label,
                  key: ValueKey(label),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Icon(Icons.arrow_drop_down, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthPickerSheet extends StatefulWidget {
  const _MonthPickerSheet({required this.current});
  final DateTime current;

  @override
  State<_MonthPickerSheet> createState() => _MonthPickerSheetState();
}

class _MonthPickerSheetState extends State<_MonthPickerSheet> {
  late int _year = widget.current.year;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Insets.lg, 0, Insets.lg, Insets.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() => _year--),
                ),
                Text('$_year',
                    style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() => _year++),
                ),
              ],
            ),
            const SizedBox(height: Insets.sm),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.6,
              mainAxisSpacing: Insets.sm,
              crossAxisSpacing: Insets.sm,
              children: [
                for (int m = 1; m <= 12; m++)
                  _MonthCell(
                    label: DateFormat.MMM(locale).format(DateTime(_year, m)),
                    selected:
                        _year == widget.current.year && m == widget.current.month,
                    isCurrent: _year == now.year && m == now.month,
                    onTap: () =>
                        Navigator.pop(context, DateTime(_year, m)),
                    scheme: scheme,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthCell extends StatelessWidget {
  const _MonthCell({
    required this.label,
    required this.selected,
    required this.isCurrent,
    required this.onTap,
    required this.scheme,
  });

  final String label;
  final bool selected;
  final bool isCurrent;
  final VoidCallback onTap;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? scheme.primary : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(Radii.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.md),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? scheme.onPrimary : scheme.onSurface,
              fontWeight: (selected || isCurrent)
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
