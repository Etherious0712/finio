import 'package:flutter/material.dart';

/// Brand seed color (finance green — growth/trust).
const Color kBrandSeed = Color(0xFF2E7D52);

/// Semantic finance colors that adapt to light/dark. Exposed as a
/// [ThemeExtension] so widgets read them from the theme via `context.finio`
/// instead of hardcoding `Colors.green` / `Colors.red` everywhere.
@immutable
class FinioColors extends ThemeExtension<FinioColors> {
  const FinioColors({
    required this.income,
    required this.expense,
    required this.transfer,
    required this.budgetSafe,
    required this.budgetWarning,
    required this.budgetDanger,
    required this.positiveHero,
    required this.negativeHero,
    required this.onHero,
  });

  /// Income / positive amounts.
  final Color income;

  /// Expense / negative amounts.
  final Color expense;

  /// Transfers — neither a gain nor a loss, so neither green nor red.
  final Color transfer;

  /// Budget progress states.
  final Color budgetSafe;
  final Color budgetWarning;
  final Color budgetDanger;

  /// Two-stop gradients for the dashboard balance hero.
  final List<Color> positiveHero;
  final List<Color> negativeHero;

  /// Text/icon color drawn on top of the hero gradient.
  final Color onHero;

  static const FinioColors light = FinioColors(
    income: Color(0xFF1A9952),
    expense: Color(0xFFE05252),
    transfer: Color(0xFF3B82F6),
    budgetSafe: Color(0xFF1A9952),
    budgetWarning: Color(0xFFF59E0B),
    budgetDanger: Color(0xFFE05252),
    positiveHero: [Color(0xFF2ECC71), Color(0xFF1A9952)],
    negativeHero: [Color(0xFFE74C3C), Color(0xFFC0392B)],
    onHero: Colors.white,
  );

  static const FinioColors dark = FinioColors(
    income: Color(0xFF4ADE80),
    expense: Color(0xFFF87171),
    transfer: Color(0xFF60A5FA),
    budgetSafe: Color(0xFF4ADE80),
    budgetWarning: Color(0xFFFBBF24),
    budgetDanger: Color(0xFFF87171),
    positiveHero: [Color(0xFF1A7A44), Color(0xFF0F5030)],
    negativeHero: [Color(0xFF8B2E22), Color(0xFF6B1E18)],
    onHero: Colors.white,
  );

  /// Returns the color for a transaction `type` string.
  Color forType(String type) => switch (type) {
        'income' => income,
        'transfer' => transfer,
        _ => expense,
      };

  @override
  FinioColors copyWith({
    Color? income,
    Color? expense,
    Color? transfer,
    Color? budgetSafe,
    Color? budgetWarning,
    Color? budgetDanger,
    List<Color>? positiveHero,
    List<Color>? negativeHero,
    Color? onHero,
  }) {
    return FinioColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      transfer: transfer ?? this.transfer,
      budgetSafe: budgetSafe ?? this.budgetSafe,
      budgetWarning: budgetWarning ?? this.budgetWarning,
      budgetDanger: budgetDanger ?? this.budgetDanger,
      positiveHero: positiveHero ?? this.positiveHero,
      negativeHero: negativeHero ?? this.negativeHero,
      onHero: onHero ?? this.onHero,
    );
  }

  @override
  FinioColors lerp(FinioColors? other, double t) {
    if (other == null) return this;
    return FinioColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      transfer: Color.lerp(transfer, other.transfer, t)!,
      budgetSafe: Color.lerp(budgetSafe, other.budgetSafe, t)!,
      budgetWarning: Color.lerp(budgetWarning, other.budgetWarning, t)!,
      budgetDanger: Color.lerp(budgetDanger, other.budgetDanger, t)!,
      positiveHero: [
        Color.lerp(positiveHero[0], other.positiveHero[0], t)!,
        Color.lerp(positiveHero[1], other.positiveHero[1], t)!,
      ],
      negativeHero: [
        Color.lerp(negativeHero[0], other.negativeHero[0], t)!,
        Color.lerp(negativeHero[1], other.negativeHero[1], t)!,
      ],
      onHero: Color.lerp(onHero, other.onHero, t)!,
    );
  }
}

/// Convenience accessor: `context.finio.income`.
extension FinioColorsX on BuildContext {
  FinioColors get finio => Theme.of(this).extension<FinioColors>()!;
}
