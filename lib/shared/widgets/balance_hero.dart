import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:finio/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../utils/currency_formatter.dart';

/// The dashboard's headline card: this month's balance over a gradient that
/// flips green↔red with the sign, plus income/expense split and today's deltas.
/// Theme-driven (gradients come from [FinioColors]).
class BalanceHero extends StatelessWidget {
  const BalanceHero({
    super.key,
    required this.totalBalance,
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.todayIncome,
    required this.todayExpense,
    required this.symbol,
    required this.currencyCode,
    required this.hidden,
    required this.onHiddenChanged,
  });

  /// All-time net balance shown as the headline.
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpense;
  final double todayIncome;
  final double todayExpense;
  final String symbol;
  final String currencyCode;

  /// Masks every number on the card behind dots.
  final bool hidden;
  final ValueChanged<bool> onHiddenChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final finio = context.finio;
    // While hidden the gradient must not leak the sign the numbers don't show.
    final isNegative = !hidden && totalBalance < 0;
    final fmt = NumberFormat('#,##0.00');
    String mask(String s) => hidden ? '••••' : s;
    final gradient = isNegative ? finio.negativeHero : finio.positiveHero;
    final onHero = finio.onHero;

    return Container(
      margin: const EdgeInsets.fromLTRB(Insets.lg, 0, Insets.lg, Insets.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(Insets.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l.totalBalance,
                    style: TextStyle(color: onHero.withValues(alpha: 0.7), fontSize: 13)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(currencyCode,
                        style: TextStyle(
                            color: onHero.withValues(alpha: 0.7), fontSize: 12)),
                    IconButton(
                      onPressed: () => onHiddenChanged(!hidden),
                      // Doubles as the screen-reader label.
                      tooltip: hidden ? l.showAmounts : l.hideAmounts,
                      icon: Icon(
                        hidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: onHero.withValues(alpha: 0.7),
                      ),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: Insets.xs),
            Text(
              mask(formatAmount(totalBalance, symbol)),
              style: TextStyle(
                color: onHero,
                fontSize: 36,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ).tabular,
            ),
            const SizedBox(height: Insets.lg),
            // Income/Expense below are scoped to the selected month.
            Text(l.thisMonth,
                style: TextStyle(
                    color: onHero.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4)),
            const SizedBox(height: Insets.sm),
            Row(
              children: [
                Expanded(
                  child: _Stat(
                    label: l.income,
                    value: mask(fmt.format(monthlyIncome)),
                    icon: Icons.arrow_downward_rounded,
                    onHero: onHero,
                  ),
                ),
                Container(
                    width: 1, height: 40, color: onHero.withValues(alpha: 0.25)),
                Expanded(
                  child: _Stat(
                    label: l.expense,
                    value: mask(fmt.format(monthlyExpense)),
                    icon: Icons.arrow_upward_rounded,
                    onHero: onHero,
                  ),
                ),
              ],
            ),
            Divider(color: onHero.withValues(alpha: 0.2), height: Insets.xl),
            Row(
              children: [
                Icon(Icons.today_outlined,
                    color: onHero.withValues(alpha: 0.7), size: 14),
                const SizedBox(width: Insets.xs),
                Text(l.today,
                    style: TextStyle(
                        color: onHero.withValues(alpha: 0.7), fontSize: 12)),
                const Spacer(),
                Text(mask('+${fmt.format(todayIncome)}'),
                    style: TextStyle(
                            color: onHero, fontSize: 13, fontWeight: FontWeight.w600)
                        .tabular),
                const SizedBox(width: Insets.lg),
                Text(mask('-${fmt.format(todayExpense)}'),
                    style: TextStyle(
                            color: onHero.withValues(alpha: 0.85),
                            fontSize: 13,
                            fontWeight: FontWeight.w600)
                        .tabular),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.icon,
    required this.onHero,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color onHero;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Insets.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: onHero.withValues(alpha: 0.7), size: 13),
              const SizedBox(width: Insets.xs),
              Text(label,
                  style: TextStyle(
                      color: onHero.withValues(alpha: 0.7), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                      color: onHero, fontSize: 18, fontWeight: FontWeight.w700)
                  .tabular),
        ],
      ),
    );
  }
}
