import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/database/app_database.dart';
import '../../shared/providers/category_providers.dart';
import '../../shared/providers/currency_provider.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/utils/category_icon.dart';
import '../../shared/utils/category_localizer.dart';
import '../../shared/utils/currency_formatter.dart';
import 'package:finio/app_localizations.dart';

Color _hexToColor(String hex) =>
    Color(int.parse(hex.replaceFirst('#', '0xFF')));

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<Transaction>? _results;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    _debounce?.cancel();
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() {
        _results = null;
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(text));
  }

  Future<void> _search(String keyword) async {
    final db = ref.read(appDatabaseProvider);
    final results = await db.transactionDao.searchTransactions(keyword);
    if (!mounted) return;
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  void _showDetail(Transaction tx, String symbol) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _DetailSheet(tx: tx, symbol: symbol),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final symbol = ref.watch(currencySymbolProvider);
    final Map<String, Category> categoryMap = {
      for (final c in ref.watch(allCategoriesProvider).valueOrNull ?? [])
        '${c.type}:${c.name}': c,
    };

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l.searchTransactions,
            border: InputBorder.none,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _controller.clear(),
                  )
                : null,
          ),
        ),
      ),
      body: _buildBody(context, symbol, categoryMap),
    );
  }

  Widget _buildBody(BuildContext context, String symbol, Map<String, Category> categoryMap) {
    final l = AppLocalizations.of(context)!;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results == null) {
      return Center(
        child: Text(l.searchHint,
            style: const TextStyle(color: Colors.grey)),
      );
    }

    if (_results!.isEmpty) {
      return Center(
        child: Text(l.noResults,
            style: const TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      itemCount: _results!.length,
      itemBuilder: (ctx, i) {
        final tx = _results![i];
        final cat = categoryMap['${tx.type}:${tx.category}'];
        final isIncome = tx.type == 'income';
        final catColor = cat != null
            ? _hexToColor(cat.color)
            : (isIncome ? Colors.green : Colors.red);
        final iconName = cat?.icon ?? 'more_horiz';

        return ListTile(
          onTap: () => _showDetail(tx, symbol),
          leading: CircleAvatar(
            backgroundColor: catColor.withValues(alpha: 0.15),
            child:
                Icon(categoryIconData(iconName), size: 20, color: catColor),
          ),
          title: Text(tx.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${localizeCategory(l, tx.category)}  ·  ${DateFormat('yyyy/M/d').format(tx.date)}',
          ),
          trailing: Text(
            '${isIncome ? '+' : '-'}${formatAmount(tx.amount, symbol)}',
            style: TextStyle(
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        );
      },
    );
  }
}

class _DetailSheet extends StatelessWidget {
  const _DetailSheet({required this.tx, required this.symbol});
  final Transaction tx;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
          _Row(label: l.typeLabel, value: isIncome ? l.income : l.expense),
          _Row(label: l.category, value: localizeCategory(l, tx.category)),
          if (tx.title.isNotEmpty) _Row(label: l.note, value: tx.title),
          _Row(label: l.date, value: DateFormat('yyyy年M月d日').format(tx.date)),
          _Row(
            label: l.recordTime,
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
