import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/database/app_database.dart';
import '../../shared/providers/budget_providers.dart';
import '../../shared/providers/category_providers.dart';
import '../../shared/providers/statistics_providers.dart';
import '../../shared/providers/transaction_providers.dart';
import '../../shared/utils/category_icon.dart';
import '../../shared/widgets/month_nav.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyIncome = ref.watch(monthlyIncomeProvider);
    final monthlyExpense = ref.watch(monthlyExpenseProvider);
    final todayIncome = ref.watch(todayIncomeProvider);
    final todayExpense = ref.watch(todayExpenseProvider);
    final transactionsAsync = ref.watch(monthlyTransactionsProvider);
    final categoryMap = {
      for (final c in ref.watch(allCategoriesProvider).valueOrNull ?? [])
        '${c.type}:${c.name}': c,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Finio'), centerTitle: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MonthNav(),
          _SummaryCard(
            monthlyIncome: monthlyIncome,
            monthlyExpense: monthlyExpense,
            todayIncome: todayIncome,
            todayExpense: todayExpense,
          ),
          const _BudgetSection(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Text(
              '最近交易',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ),
          Expanded(
            child: transactionsAsync.when(
              data: (txs) => txs.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      itemCount: txs.length,
                      itemBuilder: (ctx, i) => _TransactionTile(
                        tx: txs[i],
                        category: categoryMap[
                            '${txs[i].type}:${txs[i].category}'],
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transactions/add'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.monthlyIncome,
    required this.monthlyExpense,
    required this.todayIncome,
    required this.todayExpense,
  });

  final double monthlyIncome;
  final double monthlyExpense;
  final double todayIncome;
  final double todayExpense;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00');
    final balance = monthlyIncome - monthlyExpense;
    final isNegative = balance < 0;
    final gradientStart =
        isNegative ? const Color(0xFFE74C3C) : const Color(0xFF2ECC71);
    final gradientEnd =
        isNegative ? const Color(0xFFC0392B) : const Color(0xFF1A9952);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: gradientStart.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '本月结余',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              fmt.format(balance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _GradientStat(
                    label: '收入',
                    value: fmt.format(monthlyIncome),
                    icon: Icons.arrow_downward_rounded,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.25),
                ),
                Expanded(
                  child: _GradientStat(
                    label: '支出',
                    value: fmt.format(monthlyExpense),
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 24),
            Row(
              children: [
                const Icon(Icons.today_outlined,
                    color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                const Text(
                  '今日',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  '+${fmt.format(todayIncome)}',
                  style: TextStyle(
                    color: Colors.green.shade300,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '-${fmt.format(todayExpense)}',
                  style: TextStyle(
                    color: Colors.red.shade200,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientStat extends StatelessWidget {
  const _GradientStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 13),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            '还没有记录',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击 + 开始记账',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.tx, this.category});

  final Transaction tx;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == 'income';
    final catColor = category != null
        ? parseCategoryColor(category!.color)
        : (isIncome ? Colors.green : Colors.red);
    final iconName = category?.icon ?? 'more_horiz';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: catColor.withValues(alpha: 0.15),
        child: Icon(categoryIconData(iconName), size: 20, color: catColor),
      ),
      title: Text(tx.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle:
          Text('${tx.category} · ${DateFormat('M/d').format(tx.date)}'),
      trailing: Text(
        '${isIncome ? '+' : '-'}${NumberFormat('#,##0.00').format(tx.amount)}',
        style: TextStyle(
          color: isIncome ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _BudgetSection extends ConsumerWidget {
  const _BudgetSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overallBudget = ref.watch(overallBudgetProvider).valueOrNull;
    final categoryBudgets =
        ref.watch(categoryBudgetsProvider).valueOrNull ?? [];
    final monthlyExpense = ref.watch(monthlyExpenseProvider);
    final categoryStats = ref.watch(categoryStatsProvider('expense'));

    if (overallBudget == null && categoryBudgets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (overallBudget != null)
            _BudgetProgressRow(
              label: '月度总预算',
              spent: monthlyExpense,
              budget: overallBudget.amount,
            ),
          ...categoryBudgets.map((b) {
            final stat = categoryStats
                .where((s) => s.category == b.category)
                .firstOrNull;
            return _BudgetProgressRow(
              label: b.category ?? '未知分类',
              spent: stat?.amount ?? 0.0,
              budget: b.amount,
            );
          }),
        ],
      ),
    );
  }
}

class _BudgetProgressRow extends StatelessWidget {
  const _BudgetProgressRow({
    required this.label,
    required this.spent,
    required this.budget,
  });

  final String label;
  final double spent;
  final double budget;

  @override
  Widget build(BuildContext context) {
    final ratio = budget > 0 ? spent / budget : 0.0;
    final clamped = ratio.clamp(0.0, 1.0);
    final fmt = NumberFormat('#,##0.00');

    final Color barColor;
    final String? warningText;
    if (ratio >= 1.0) {
      barColor = Colors.red;
      warningText = '❌ 已超支';
    } else if (ratio >= 0.8) {
      barColor = Colors.orange;
      warningText = '⚠️ 即将超支';
    } else {
      barColor = Colors.green;
      warningText = null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              Text(
                '${fmt.format(spent)} / ${fmt.format(budget)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              if (warningText != null) ...[
                const SizedBox(width: 6),
                Text(warningText,
                    style: const TextStyle(fontSize: 11)),
              ],
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: clamped,
              backgroundColor: barColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
