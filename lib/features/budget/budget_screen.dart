import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finio/app_localizations.dart';
import 'package:finio/core/database/app_database.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/providers/budget_providers.dart';
import '../../shared/providers/category_providers.dart';
import '../../shared/providers/currency_provider.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/providers/statistics_providers.dart';
import '../../shared/providers/transaction_providers.dart';
import '../../shared/utils/category_localizer.dart';
import '../../shared/utils/currency_formatter.dart';
import '../../shared/widgets/budget_ring.dart';
import '../../shared/widgets/section_header.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final overall = ref.watch(overallBudgetProvider).valueOrNull;
    final catBudgets = ref.watch(categoryBudgetsProvider).valueOrNull ?? [];
    final expenseCategories =
        ref.watch(expenseCategoriesProvider).valueOrNull ?? [];
    final monthlyExpense = ref.watch(monthlyExpenseProvider);
    final stats = ref.watch(categoryStatsProvider('expense'));
    final symbol = ref.watch(currencySymbolProvider);

    final budgetByCategory = {
      for (final b in catBudgets)
        if (b.category != null) b.category!: b,
    };
    double spentFor(String key) =>
        stats.where((s) => s.category == key).firstOrNull?.amount ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(l.budgetSettings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.sm, Insets.lg, Insets.xxl),
        children: [
          _BudgetCard(
            label: l.monthlyBudget,
            spent: monthlyExpense,
            budget: overall?.amount,
            symbol: symbol,
            onEdit: () => _editBudget(context, ref, null, overall),
          ),
          SectionHeader(l.categoryBudget),
          for (final cat in expenseCategories)
            _BudgetCard(
              label: localizeCategory(l, cat.name),
              spent: spentFor(cat.name),
              budget: budgetByCategory[cat.name]?.amount,
              symbol: symbol,
              onEdit: () => _editBudget(
                  context, ref, cat.name, budgetByCategory[cat.name]),
            ),
        ],
      ),
    );
  }

  Future<void> _editBudget(
    BuildContext context,
    WidgetRef ref,
    String? category,
    Budget? current,
  ) async {
    final l = AppLocalizations.of(context)!;
    final db = ref.read(appDatabaseProvider);
    final symbol = ref.read(currencySymbolProvider);

    final result = await showDialog<String>(
      context: context,
      builder: (_) => _BudgetInputDialog(
        title: category == null
            ? l.monthlyBudget
            : l.categoryBudgetLabel(localizeCategory(l, category)),
        initialAmount: current?.amount,
        symbol: symbol,
      ),
    );
    if (result == null) return;

    final amount = double.tryParse(result.trim());
    if (amount == null || amount <= 0) {
      if (current != null) await db.budgetDao.deleteBudget(current.id);
    } else {
      await db.budgetDao.upsertBudget(category: category, amount: amount);
    }
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.label,
    required this.spent,
    required this.budget,
    required this.symbol,
    required this.onEdit,
  });

  final String label;
  final double spent;
  final double? budget;
  final String symbol;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final hasBudget = budget != null;

    return Card(
      margin: const EdgeInsets.only(bottom: Insets.sm),
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(Insets.md),
          child: Row(
            children: [
              if (hasBudget)
                BudgetRing(spent: spent, budget: budget!, size: 52, stroke: 6)
              else
                Icon(Icons.add_circle_outline, size: 36, color: scheme.outline),
              const SizedBox(width: Insets.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      hasBudget
                          ? '${formatAmount(spent, symbol)} / ${formatAmount(budget!, symbol)}'
                          : l.notSet,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.outline)
                          .tabular,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit_outlined, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetInputDialog extends StatefulWidget {
  const _BudgetInputDialog({
    required this.title,
    this.initialAmount,
    required this.symbol,
  });

  final String title;
  final double? initialAmount;
  final String symbol;

  @override
  State<_BudgetInputDialog> createState() => _BudgetInputDialogState();
}

class _BudgetInputDialogState extends State<_BudgetInputDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialAmount?.toStringAsFixed(2) ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        decoration: InputDecoration(
          prefixText: '${widget.symbol} ',
          hintText: l.budgetInputHint,
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
        TextButton(
            onPressed: () => Navigator.pop(context, _controller.text),
            child: Text(l.save)),
      ],
    );
  }
}
