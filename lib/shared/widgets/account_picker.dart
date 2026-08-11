import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finio/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../providers/account_providers.dart';
import '../utils/category_icon.dart';

/// Horizontal row of savings-jar chips, shared by the add/edit screen and the
/// quick-add sheet. Renders nothing until the user has created a jar, so the
/// entry screens stay unchanged for anyone not using the feature.
class AccountPicker extends ConsumerWidget {
  const AccountPicker({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  /// Selected jar name, or null for unassigned.
  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final accounts = ref.watch(accountsProvider).valueOrNull ?? const [];
    if (accounts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.savingsAccount, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: Insets.sm),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            // +1 for the "unassigned" escape hatch.
            itemCount: accounts.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: Insets.sm),
            itemBuilder: (_, i) {
              if (i == accounts.length) {
                return AccountChip(
                  label: l.unassignedAccount,
                  icon: Icons.more_horiz,
                  color: Theme.of(context).colorScheme.outline,
                  selected: selected == null,
                  onTap: () => onSelect(null),
                );
              }
              final a = accounts[i];
              return AccountChip(
                label: a.name,
                icon: categoryIconData(a.icon),
                color: parseCategoryColor(a.color),
                selected: a.name == selected,
                onTap: () => onSelect(a.name),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Pill-shaped selectable chip. Public so the quick-add sheet can reuse it.
class AccountChip extends StatelessWidget {
  const AccountChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Insets.md),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(Radii.pill),
          border: Border.all(
            color:
                selected ? color : Theme.of(context).colorScheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: Insets.xs),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? color
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
