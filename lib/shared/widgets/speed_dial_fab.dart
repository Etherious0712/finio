import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finio/app_localizations.dart';
import '../../core/ai/rule_classifier.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import 'quick_add_sheet.dart';

/// Expanding FAB: tap to reveal expense/income quick-add actions, each opening
/// the [QuickAddSheet]. Replaces the single static add button.
class SpeedDialFab extends ConsumerStatefulWidget {
  const SpeedDialFab({super.key});

  @override
  ConsumerState<SpeedDialFab> createState() => _SpeedDialFabState();
}

class _SpeedDialFabState extends ConsumerState<SpeedDialFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: Motion.medium);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _ctrl.forward() : _ctrl.reverse();
  }

  Future<void> _quickAdd(TransactionType type) async {
    _toggle();
    await QuickAddSheet.show(context, type);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final finio = context.finio;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _action(
          visible: _open,
          label: l.income,
          icon: Icons.arrow_downward_rounded,
          color: finio.income,
          onTap: () => _quickAdd(TransactionType.income),
        ),
        _action(
          visible: _open,
          label: l.expense,
          icon: Icons.arrow_upward_rounded,
          color: finio.expense,
          onTap: () => _quickAdd(TransactionType.expense),
        ),
        FloatingActionButton(
          onPressed: _toggle,
          child: AnimatedRotation(
            turns: _open ? 0.125 : 0,
            duration: Motion.medium,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _action({
    required bool visible,
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 0.4),
      duration: Motion.medium,
      curve: Motion.curve,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: Motion.fast,
        child: IgnorePointer(
          ignoring: !visible,
          child: Padding(
            padding: const EdgeInsets.only(bottom: Insets.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Card(
                  color: Theme.of(context).colorScheme.inverseSurface,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Insets.md, vertical: Insets.sm),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onInverseSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Insets.md),
                FloatingActionButton.small(
                  heroTag: label,
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  onPressed: onTap,
                  child: Icon(icon),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
