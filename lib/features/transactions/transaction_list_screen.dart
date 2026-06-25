import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:finio/app_localizations.dart';
import 'package:finio/core/database/app_database.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/providers/category_providers.dart';
import '../../shared/providers/currency_provider.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/providers/transaction_providers.dart';
import '../../shared/utils/category_localizer.dart';
import '../../shared/utils/currency_formatter.dart';
import '../../shared/widgets/month_nav.dart';
import '../../shared/widgets/transaction_tile.dart';

enum _GroupBy { day, category }

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  _GroupBy _groupBy = _GroupBy.day;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final transactionsAsync = ref.watch(monthlyTransactionsProvider);
    final symbol = ref.watch(currencySymbolProvider);
    final categoryMap = {
      for (final c in ref.watch(allCategoriesProvider).valueOrNull ?? [])
        '${c.type}:${c.name}': c,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l.transactions),
        actions: [
          PopupMenuButton<_GroupBy>(
            icon: const Icon(Icons.sort),
            initialValue: _groupBy,
            onSelected: (g) => setState(() => _groupBy = g),
            itemBuilder: (_) => [
              PopupMenuItem(value: _GroupBy.day, child: Text(l.groupByDay)),
              PopupMenuItem(
                  value: _GroupBy.category, child: Text(l.groupByCategory)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: Column(
        children: [
          const MonthNav(),
          Expanded(
            child: transactionsAsync.when(
              data: (txs) {
                if (txs.isEmpty) {
                  return Center(child: Text(l.noMonthlyRecords));
                }
                final items = _groupBy == _GroupBy.day
                    ? _groupByDay(txs)
                    : _groupByCategory(txs, l);
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final item = items[i];
                    if (item is _Header) {
                      return _SectionHeaderRow(
                          label: item.label, total: item.total, symbol: symbol);
                    }
                    final tx = item as Transaction;
                    return TransactionTile(
                      tx: tx,
                      category: categoryMap['${tx.type}:${tx.category}'],
                      symbol: symbol,
                      onEdit: () => context.push('/transactions/add', extra: tx),
                      onDelete: () => ref
                          .read(appDatabaseProvider)
                          .transactionDao
                          .deleteTransaction(tx.id),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${l.loadFailed}: $e')),
            ),
          ),
        ],
      ),
    );
  }

  List<Object> _groupByDay(List<Transaction> txs) {
    final locale = Localizations.localeOf(context).toString();
    final items = <Object>[];
    DateTime? lastDay;
    for (final tx in txs) {
      final day = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (lastDay == null || day != lastDay) {
        items.add(_Header(DateFormat.MMMEd(locale).format(day)));
        lastDay = day;
      }
      items.add(tx);
    }
    return items;
  }

  List<Object> _groupByCategory(List<Transaction> txs, AppLocalizations l) {
    final groups = <String, List<Transaction>>{};
    for (final tx in txs) {
      groups.putIfAbsent(tx.category, () => []).add(tx);
    }
    // Sort categories by total amount, descending.
    final sorted = groups.entries.toList()
      ..sort((a, b) {
        final ta = a.value.fold<double>(0, (s, t) => s + t.amount);
        final tb = b.value.fold<double>(0, (s, t) => s + t.amount);
        return tb.compareTo(ta);
      });
    final items = <Object>[];
    for (final e in sorted) {
      final total = e.value.fold<double>(0, (s, t) => s + t.amount);
      items.add(_Header(localizeCategory(l, e.key), total: total));
      items.addAll(e.value);
    }
    return items;
  }
}

class _Header {
  _Header(this.label, {this.total});
  final String label;
  final double? total;
}

class _SectionHeaderRow extends StatelessWidget {
  const _SectionHeaderRow({
    required this.label,
    required this.total,
    required this.symbol,
  });

  final String label;
  final double? total;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.lg, Insets.xs),
      child: Row(
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: scheme.outline)),
          const Spacer(),
          if (total != null)
            Text(formatAmount(total!, symbol),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: scheme.outline)
                    .tabular),
        ],
      ),
    );
  }
}
