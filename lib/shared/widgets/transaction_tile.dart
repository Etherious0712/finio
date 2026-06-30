import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:finio/app_localizations.dart';
import 'package:finio/core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../utils/category_icon.dart';
import '../utils/category_localizer.dart';
import '../utils/currency_formatter.dart';

/// A transaction row with swipe gestures:
/// swipe right → edit, swipe left → delete. Tap also triggers [onTap]
/// (defaults to edit). Replaces the per-screen tile + Dismissible duplication.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.tx,
    required this.category,
    required this.symbol,
    required this.onEdit,
    required this.onDelete,
    this.showDate = false,
  });

  final Transaction tx;
  final Category? category;
  final String symbol;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// When true, shows the date in the subtitle (used on the dashboard where
  /// rows are not grouped under day headers).
  final bool showDate;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final finio = context.finio;
    final scheme = Theme.of(context).colorScheme;
    final isIncome = tx.type == 'income';
    final amountColor = finio.forType(tx.type);
    final catColor =
        category != null ? parseCategoryColor(category!.color) : amountColor;
    final iconName = category?.icon ?? 'more_horiz';

    final subtitle = showDate
        ? '${localizeCategory(l, tx.category)} · ${DateFormat.MMMd().format(tx.date)}'
        : localizeCategory(l, tx.category);

    return Dismissible(
      key: ValueKey(tx.id),
      background: _SwipeBg(
        color: scheme.primary,
        icon: Icons.edit_outlined,
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _SwipeBg(
        color: finio.expense,
        icon: Icons.delete_outline,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          onEdit();
          return false; // snap back; edit opens a screen
        }
        return true; // endToStart → delete
      },
      onDismissed: (_) => onDelete(),
      child: ListTile(
        onTap: onEdit,
        leading: CircleAvatar(
          backgroundColor: catColor.withValues(alpha: 0.15),
          child: Icon(categoryIconData(iconName), size: 20, color: catColor),
        ),
        title: Text(tx.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle),
        trailing: Text(
          '${isIncome ? '+' : '-'}${formatAmount(tx.amount, symbol)}',
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(color: amountColor, fontWeight: FontWeight.w700)
              .tabular,
        ),
      ),
    );
  }
}

class _SwipeBg extends StatelessWidget {
  const _SwipeBg({
    required this.color,
    required this.icon,
    required this.alignment,
  });

  final Color color;
  final IconData icon;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: Insets.xl),
      child: Icon(icon, color: Colors.white),
    );
  }
}
