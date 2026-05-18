import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/app_database.dart';
import '../../shared/providers/category_providers.dart';
import '../../shared/providers/currency_provider.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/providers/transaction_providers.dart';
import '../../shared/utils/category_icon.dart';
import '../../shared/utils/currency_formatter.dart';
import '../../shared/widgets/month_nav.dart';

const _kWeekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

Color _hexToColor(String hex) {
  return Color(int.parse(hex.replaceFirst('#', '0xFF')));
}

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(monthlyTransactionsProvider);
    final symbol = ref.watch(currencySymbolProvider);
    final categoryMap = {
      for (final c in ref.watch(allCategoriesProvider).valueOrNull ?? [])
        '${c.type}:${c.name}': c,
    };

    return Scaffold(
      appBar: AppBar(title: const Text('交易记录'), centerTitle: true),
      body: Column(
        children: [
          const MonthNav(),
          Expanded(
            child: transactionsAsync.when(
              data: (txs) {
                if (txs.isEmpty) {
                  return const Center(child: Text('本月暂无记录'));
                }
                final items = _buildItems(txs);
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final item = items[i];
                    if (item is DateTime) return _DateHeader(date: item);
                    final tx = item as Transaction;
                    final cat = categoryMap['${tx.type}:${tx.category}'];
                    return Dismissible(
                      key: ValueKey(tx.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => ref
                          .read(appDatabaseProvider)
                          .transactionDao
                          .deleteTransaction(tx.id),
                      child: _TransactionTile(
                        tx: tx,
                        category: cat,
                        symbol: symbol,
                        onTap: () => _showDetail(context, tx, symbol),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败: $e')),
            ),
          ),
        ],
      ),
    );
  }

  List<Object> _buildItems(List<Transaction> txs) {
    final items = <Object>[];
    DateTime? lastDay;
    for (final tx in txs) {
      final day = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (lastDay == null || day != lastDay) {
        items.add(day);
        lastDay = day;
      }
      items.add(tx);
    }
    return items;
  }

  void _showDetail(BuildContext context, Transaction tx, String symbol) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _DetailSheet(tx: tx, symbol: symbol),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final label =
        '${DateFormat('M月d日').format(date)} ${_kWeekdays[date.weekday - 1]}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.tx,
    required this.category,
    required this.symbol,
    required this.onTap,
  });

  final Transaction tx;
  final Category? category;
  final String symbol;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == 'income';
    final catColor = category != null
        ? _hexToColor(category!.color)
        : (isIncome ? Colors.green : Colors.red);
    final iconName = category?.icon ?? 'more_horiz';

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: catColor.withValues(alpha: 0.15),
        child: Icon(categoryIconData(iconName), size: 20, color: catColor),
      ),
      title: Text(tx.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(tx.category),
      trailing: Text(
        '${isIncome ? '+' : '-'}${formatAmount(tx.amount, symbol)}',
        style: TextStyle(
          color: isIncome ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}

class _DetailSheet extends StatelessWidget {
  const _DetailSheet({required this.tx, required this.symbol});
  final Transaction tx;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == 'income';
    final typeColor = isIncome ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${formatAmount(tx.amount, symbol)}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: typeColor,
            ),
          ),
          const SizedBox(height: 20),
          _Row(label: '类型', value: isIncome ? '收入' : '支出'),
          _Row(label: '分类', value: tx.category),
          if (tx.title.isNotEmpty) _Row(label: '备注', value: tx.title),
          _Row(
              label: '日期',
              value: DateFormat('yyyy年M月d日').format(tx.date)),
          _Row(
            label: '记录时间',
            value: DateFormat('yyyy/M/d HH:mm').format(tx.createdAt),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
