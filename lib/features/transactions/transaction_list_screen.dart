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
import '../../shared/widgets/month_nav.dart';
import '../../shared/widgets/transaction_tile.dart';

/// How the Records list is scoped + grouped.
/// - date: selected month, grouped by day
/// - month: selected year, grouped by month
/// - year: all-time, grouped by year
/// (Category breakdown lives on the Statistics tab.)
enum RecordGroup { date, month, year }

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  RecordGroup _group = RecordGroup.date;
  int _year = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final symbol = ref.watch(currencySymbolProvider);
    final categoryMap = {
      for (final c in ref.watch(allCategoriesProvider).valueOrNull ?? [])
        '${c.type}:${c.name}': c,
    };

    // Pick the data source for the active mode.
    final AsyncValue<List<Transaction>> async;
    switch (_group) {
      case RecordGroup.date:
        async = ref.watch(monthlyTransactionsProvider);
      case RecordGroup.month:
      case RecordGroup.year:
        async = ref.watch(allTransactionsProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.transactions),
        actions: [
          PopupMenuButton<RecordGroup>(
            icon: const Icon(Icons.sort),
            initialValue: _group,
            onSelected: (g) => setState(() => _group = g),
            itemBuilder: (_) => [
              PopupMenuItem(value: RecordGroup.date, child: Text(l.groupByDay)),
              PopupMenuItem(
                  value: RecordGroup.month, child: Text(l.groupByMonth)),
              PopupMenuItem(value: RecordGroup.year, child: Text(l.groupByYear)),
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
          _periodBar(l),
          Expanded(
            child: async.when(
              data: (all) {
                final txs = _scoped(all);
                if (txs.isEmpty) {
                  return Center(child: Text(l.noMonthlyRecords));
                }
                final items = _buildItems(txs, l);
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

  /// The period selector changes with the mode.
  Widget _periodBar(AppLocalizations l) {
    switch (_group) {
      case RecordGroup.date:
        return const MonthNav();
      case RecordGroup.month:
        return _YearNav(
          year: _year,
          onChanged: (y) => setState(() => _year = y),
        );
      case RecordGroup.year:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: Insets.md),
          child: Center(
            child: Text(l.allTime,
                style: Theme.of(context).textTheme.titleMedium),
          ),
        );
    }
  }

  /// Filter the raw stream down to the active scope.
  List<Transaction> _scoped(List<Transaction> all) {
    switch (_group) {
      case RecordGroup.date:
        return all; // already month-scoped by the provider
      case RecordGroup.month:
        return all.where((t) => t.date.year == _year).toList();
      case RecordGroup.year:
        return all;
    }
  }

  List<Object> _buildItems(List<Transaction> txs, AppLocalizations l) {
    switch (_group) {
      case RecordGroup.date:
        return _groupByDay(txs);
      case RecordGroup.month:
        return _groupByPeriod(txs, monthly: true, l: l);
      case RecordGroup.year:
        return _groupByPeriod(txs, monthly: false, l: l);
    }
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

  /// Group by calendar month or by year, with a signed net total per period.
  List<Object> _groupByPeriod(List<Transaction> txs,
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
        // Net for the whole period (income − expense).
        final periodTxs = txs.where((t) => (monthly
            ? '${t.date.year}-${t.date.month}'
            : '${t.date.year}') == key);
        final net = periodTxs.fold<double>(
            0, (s, t) => s + (t.type == 'income' ? t.amount : -t.amount));
        items.add(_Header(label, total: net, isNet: true));
        lastKey = key;
      }
      items.add(tx);
    }
    return items;
  }
}

class _YearNav extends StatelessWidget {
  const _YearNav({required this.year, required this.onChanged});

  final int year;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Insets.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => onChanged(year - 1),
          ),
          Text('$year', style: Theme.of(context).textTheme.titleMedium),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => onChanged(year + 1),
          ),
        ],
      ),
    );
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
