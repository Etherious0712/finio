import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:finio/app_localizations.dart';
import 'package:finio/core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/providers/category_providers.dart';
import '../../shared/providers/currency_provider.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/providers/transaction_providers.dart';
import '../../shared/utils/currency_formatter.dart';
import '../../shared/widgets/scope_bar.dart';
import '../../shared/widgets/transaction_tile.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final symbol = ref.watch(currencySymbolProvider);
    final scope = ref.watch(recordScopeProvider);
    final async = ref.watch(scopedTransactionsProvider);
    final categoryMap = {
      for (final c in ref.watch(allCategoriesProvider).valueOrNull ?? [])
        '${c.type}:${c.name}': c,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l.transactions),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: Column(
        children: [
          const ScopeBar(),
          Expanded(
            child: async.when(
              data: (txs) {
                if (txs.isEmpty) {
                  final emptyText = switch (scope) {
                    RecordScope.month => l.noMonthlyRecords,
                    RecordScope.year => l.noYearlyRecords,
                    RecordScope.allTime => l.noRecords,
                  };
                  return Center(child: Text(emptyText));
                }
                final items = _buildItems(context, txs, scope, l);
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: items.length,
                  itemBuilder: (ctx, i) {
                    final item = items[i];
                    if (item is _Header) {
                      return _SectionHeaderRow(header: item, symbol: symbol);
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

  /// Grouping is derived from scope: month → by day, year → by month,
  /// all-time → by year.
  List<Object> _buildItems(BuildContext context, List<Transaction> txs,
      RecordScope scope, AppLocalizations l) {
    switch (scope) {
      case RecordScope.month:
        return _groupByDay(context, txs);
      case RecordScope.year:
        return _groupByPeriod(context, txs, monthly: true, l: l);
      case RecordScope.allTime:
        return _groupByPeriod(context, txs, monthly: false, l: l);
    }
  }

  List<Object> _groupByDay(BuildContext context, List<Transaction> txs) {
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

  /// Group by calendar month or by year, with a signed net total per period.
  List<Object> _groupByPeriod(BuildContext context, List<Transaction> txs,
      {required bool monthly, required AppLocalizations l}) {
    final locale = Localizations.localeOf(context).toString();
    final items = <Object>[];
    String? lastKey;
    for (final tx in txs) {
      final key =
          monthly ? '${tx.date.year}-${tx.date.month}' : '${tx.date.year}';
      if (key != lastKey) {
        final label = monthly
            ? DateFormat.yMMMM(locale)
                .format(DateTime(tx.date.year, tx.date.month))
            : '${tx.date.year}';
        // Net for the whole period (income − expense). A transfer nets to zero
        // within any period, so it contributes nothing.
        final periodTxs = txs.where((t) => (monthly
            ? '${t.date.year}-${t.date.month}'
            : '${t.date.year}') == key);
        final net = periodTxs.fold<double>(
            0,
            (s, t) => s +
                switch (t.type) {
                  'income' => t.amount,
                  'expense' => -t.amount,
                  _ => 0.0,
                });
        items.add(_Header(label, total: net, isNet: true));
        lastKey = key;
      }
      items.add(tx);
    }
    return items;
  }
}

class _Header {
  _Header(this.label, {this.total, this.isNet = false});
  final String label;
  final double? total;

  /// When true, [total] is a net value rendered signed + colored.
  final bool isNet;
}

class _SectionHeaderRow extends StatelessWidget {
  const _SectionHeaderRow({required this.header, required this.symbol});

  final _Header header;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final total = header.total;

    Widget? trailing;
    if (total != null) {
      if (header.isNet) {
        final color = total < 0 ? context.finio.expense : context.finio.income;
        trailing = Text(
          '${total < 0 ? '-' : '+'}${formatAmount(total.abs(), symbol)}',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: color, fontWeight: FontWeight.w700)
              .tabular,
        );
      } else {
        trailing = Text(
          formatAmount(total, symbol),
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: scheme.outline)
              .tabular,
        );
      }
    }

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(Insets.lg, Insets.md, Insets.lg, Insets.xs),
      child: Row(
        children: [
          Text(header.label,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: scheme.outline)),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}
