import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// A small uppercase-ish section label with an optional trailing action.
/// Used to title groups (Recent, Budgets, Categories…) consistently.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.sm, Insets.xs),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                  letterSpacing: 0.6,
                ),
          ),
          const Spacer(),
          ?action,
        ],
      ),
    );
  }
}
