import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/app_database.dart';
import '../../shared/providers/budget_providers.dart';
import '../../shared/providers/category_providers.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/utils/category_icon.dart';

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overallBudget = ref.watch(overallBudgetProvider).valueOrNull;
    final categoryBudgets = ref.watch(categoryBudgetsProvider).valueOrNull ?? [];
    final expenseCategories =
        ref.watch(expenseCategoriesProvider).valueOrNull ?? [];

    final budgetByCategory = {
      for (final b in categoryBudgets)
        if (b.category != null) b.category!: b,
    };

    final fmt = NumberFormat('#,##0.00');

    return Scaffold(
      appBar: AppBar(title: const Text('预算设置'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overall budget card
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('月度总预算'),
              subtitle: Text(
                overallBudget != null
                    ? '¥ ${fmt.format(overallBudget.amount)}'
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
                context,
                ref,
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
          // Category budget rows
          ...expenseCategories.map((cat) {
            final budget = budgetByCategory[cat.name];
            final color = parseCategoryColor(cat.color);
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(categoryIconData(cat.icon), size: 18, color: color),
              ),
              title: Text(cat.name),
              subtitle: Text(
                budget != null ? '¥ ${fmt.format(budget.amount)}' : '未设置',
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
                context,
                ref,
                category: cat.name,
                currentBudget: budget,
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _editBudget(
    BuildContext context,
    WidgetRef ref, {
    required String? category,
    required Budget? currentBudget,
  }) async {
    // Capture db before any async gap so ref is not accessed after dispose.
    final db = ref.read(appDatabaseProvider);

    final controller = TextEditingController(
      text: currentBudget != null
          ? currentBudget.amount.toStringAsFixed(2)
          : '',
    );
    final title = category == null ? '月度总预算' : '$category 预算';

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: const InputDecoration(
            prefixText: '¥ ',
            hintText: '输入金额（清空则删除预算）',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    controller.dispose();
    if (result == null) return;

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
