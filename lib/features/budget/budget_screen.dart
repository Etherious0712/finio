import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../shared/providers/budget_providers.dart';
import '../../shared/providers/category_providers.dart';
import '../../shared/providers/currency_provider.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/utils/category_icon.dart';
import '../../shared/utils/currency_formatter.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  @override
  Widget build(BuildContext context) {
    final overallBudget = ref.watch(overallBudgetProvider).valueOrNull;
    final categoryBudgets =
        ref.watch(categoryBudgetsProvider).valueOrNull ?? [];
    final expenseCategories =
        ref.watch(expenseCategoriesProvider).valueOrNull ?? [];
    final symbol = ref.watch(currencySymbolProvider);

    final budgetByCategory = {
      for (final b in categoryBudgets)
        if (b.category != null) b.category!: b,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('预算设置'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('月度总预算'),
              subtitle: Text(
                overallBudget != null
                    ? formatAmount(overallBudget.amount, symbol)
                    : '未设置',
                style: TextStyle(
                  color: overallBudget != null
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                  fontWeight: overallBudget != null
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
              trailing: const Icon(Icons.edit_outlined, size: 18),
              onTap: () => _editBudget(
                category: null,
                currentBudget: overallBudget,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              '分类预算',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ),
          ...expenseCategories.map((cat) {
            final budget = budgetByCategory[cat.name];
            final color = parseCategoryColor(cat.color);
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child:
                    Icon(categoryIconData(cat.icon), size: 18, color: color),
              ),
              title: Text(cat.name),
              subtitle: Text(
                budget != null
                    ? formatAmount(budget.amount, symbol)
                    : '未设置',
                style: TextStyle(
                  color: budget != null
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                  fontWeight:
                      budget != null ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              trailing: const Icon(Icons.edit_outlined, size: 18),
              onTap: () => _editBudget(
                category: cat.name,
                currentBudget: budget,
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _editBudget({
    required String? category,
    required Budget? currentBudget,
  }) async {
    final db = ref.read(appDatabaseProvider);
    final symbol = ref.read(currencySymbolProvider);

    final result = await showDialog<String>(
      context: context,
      builder: (_) => _BudgetInputDialog(
        title: category == null ? '月度总预算' : '$category 预算',
        initialAmount: currentBudget?.amount,
        symbol: symbol,
      ),
    );

    if (!mounted || result == null) return;

    final amount = double.tryParse(result.trim());
    if (amount == null || amount <= 0) {
      if (currentBudget != null) {
        await db.budgetDao.deleteBudget(currentBudget.id);
      }
    } else {
      await db.budgetDao.upsertBudget(category: category, amount: amount);
    }
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
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialAmount?.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          hintText: '输入金额（清空则删除预算）',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('保存'),
        ),
      ],
    );
  }
}
