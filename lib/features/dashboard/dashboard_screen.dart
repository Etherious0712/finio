import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/database/app_database.dart';
import '../../shared/providers/transaction_providers.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finio'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const MonthNav(),
          _SummaryCard(
            monthlyIncome: monthlyIncome,
            monthlyExpense: monthlyExpense,
            todayIncome: todayIncome,
            todayExpense: todayExpense,
          ),
          Expanded(
            child: transactionsAsync.when(
              data: (txs) => txs.isEmpty
                  ? const Center(child: Text('暂无记录，点击 + 添加'))
                  : ListView.builder(
                      itemCount: txs.length,
                      itemBuilder: (ctx, i) => _TransactionTile(tx: txs[i]),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transactions/add'),
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
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('本月', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _Stat(
                      label: '收入',
                      value: fmt.format(monthlyIncome),
                      color: Colors.green),
                ),
                Expanded(
                  child: _Stat(
                      label: '支出',
                      value: fmt.format(monthlyExpense),
                      color: Colors.red),
                ),
                Expanded(
                  child: _Stat(
                    label: '结余',
                    value: fmt.format(monthlyIncome - monthlyExpense),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text('今日', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _Stat(
                      label: '收入',
                      value: fmt.format(todayIncome),
                      color: Colors.green),
                ),
                Expanded(
                  child: _Stat(
                      label: '支出',
                      value: fmt.format(todayExpense),
                      color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.tx});
  final Transaction tx;

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == 'income';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            isIncome ? Colors.green.shade50 : Colors.red.shade50,
        child: Icon(
          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: isIncome ? Colors.green : Colors.red,
          size: 18,
        ),
      ),
      title: Text(tx.title),
      subtitle: Text(
          '${tx.category} · ${DateFormat('M/d').format(tx.date)}'),
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
