import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:finio/app_localizations.dart';
import 'package:finio/core/database/app_database.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/providers/budget_providers.dart';
import '../../shared/providers/category_providers.dart';
import '../../shared/providers/currency_provider.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/utils/category_localizer.dart';
import '../../shared/utils/currency_formatter.dart';
import '../../shared/widgets/budget_ring.dart';

/// Localized name of a budget's period key.
String periodLabel(AppLocalizations l, String period) => switch (period) {
      'week' => l.periodWeekly,
      'year' => l.periodYearly,
      _ => l.periodMonthly,
    };

/// Budgets the user created — nothing is listed until they add one.
class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final statuses = ref.watch(budgetStatusesProvider);
    final symbol = ref.watch(currencySymbolProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.budgetSettings)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context, null),
        child: const Icon(Icons.add),
      ),
      body: statuses.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.savings_outlined,
                      size: 64, color: scheme.outlineVariant),
                  const SizedBox(height: Insets.lg),
                  Text(l.noBudgetYet, style: TextStyle(color: scheme.outline)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                  Insets.lg, Insets.sm, Insets.lg, Insets.xxl),
              children: [
                for (final s in statuses)
                  _BudgetCard(
                    status: s,
                    symbol: symbol,
                    onEdit: () => _openEditor(context, s.budget),
                    onDelete: () => _confirmDelete(context, ref, s.budget),
                  ),
              ],
            ),
    );
  }

  Future<void> _openEditor(BuildContext context, Budget? existing) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _BudgetEditorSheet(existing: existing),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Budget budget) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteBudget),
        content: Text(l.confirmDelete),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(appDatabaseProvider).budgetDao.deleteBudget(budget.id);
    }
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.status,
    required this.symbol,
    required this.onEdit,
    required this.onDelete,
  });

  final BudgetStatus status;
  final String symbol;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final b = status.budget;
    final label =
        b.category == null ? l.overallBudget : localizeCategory(l, b.category!);
    final sub = status.overridden
        ? '${periodLabel(l, b.period)} · ${l.monthOverride}'
        : periodLabel(l, b.period);

    return Card(
      margin: const EdgeInsets.only(bottom: Insets.sm),
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(Insets.md),
          child: Row(
            children: [
              BudgetRing(
                  spent: status.spent,
                  budget: status.limit,
                  size: 52,
                  stroke: 6),
              const SizedBox(width: Insets.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      '${formatAmount(status.spent, symbol)} / '
                      '${formatAmount(status.limit, symbol)}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: scheme.outline)
                          .tabular,
                    ),
                    Text(sub,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: scheme.outline)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Create or edit a budget: what it applies to, the period, the amount, and
/// optionally a different amount for one single month.
class _BudgetEditorSheet extends ConsumerStatefulWidget {
  const _BudgetEditorSheet({this.existing});

  final Budget? existing;

  @override
  ConsumerState<_BudgetEditorSheet> createState() => _BudgetEditorSheetState();
}

class _BudgetEditorSheetState extends ConsumerState<_BudgetEditorSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _overrideController;
  String? _category;
  late String _period;
  late bool _override;
  late DateTime _overrideMonth;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;
  bool get _isMonthly => _period == 'month';

  @override
  void initState() {
    super.initState();
    final b = widget.existing;
    _category = b?.category;
    _period = b?.period ?? 'month';
    _amountController =
        TextEditingController(text: b?.amount.toStringAsFixed(2) ?? '');
    _override = b?.overrideAmount != null;
    _overrideController = TextEditingController(
        text: b?.overrideAmount?.toStringAsFixed(2) ?? '');
    final now = DateTime.now();
    _overrideMonth = (b != null && b.month > 0)
        ? DateTime(b.year, b.month)
        : DateTime(now.year, now.month);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _overrideController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) return;
    // An override only means something for a monthly window, so any other
    // period writes it away rather than leaving a stale one behind.
    final overrideAmount = _isMonthly && _override
        ? double.tryParse(_overrideController.text.trim())
        : null;
    final hasOverride = overrideAmount != null && overrideAmount > 0;

    final dao = ref.read(appDatabaseProvider).budgetDao;
    setState(() => _saving = true);
    try {
      if (_isEditing) {
        await dao.updateBudget(widget.existing!.copyWith(
          amount: amount,
          period: _period,
          month: hasOverride ? _overrideMonth.month : 0,
          year: hasOverride ? _overrideMonth.year : 0,
          overrideAmount: Value(hasOverride ? overrideAmount : null),
        ));
      } else {
        await dao.insertBudget(BudgetsCompanion.insert(
          category: Value(_category),
          amount: amount,
          period: Value(_period),
          month: hasOverride ? _overrideMonth.month : 0,
          year: hasOverride ? _overrideMonth.year : 0,
          overrideAmount: Value(hasOverride ? overrideAmount : null),
        ));
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final symbol = ref.watch(currencySymbolProvider);
    // One budget per target: offer only what isn't taken yet.
    final taken = {
      for (final b in ref.watch(budgetsProvider).valueOrNull ?? const <Budget>[])
        b.category,
    };
    final categories = (ref.watch(expenseCategoriesProvider).valueOrNull ?? [])
        .where((c) => !taken.contains(c.name))
        .toList();
    final now = DateTime.now();
    // The next 12 months, plus whatever month an existing override names.
    final months = <DateTime>[
      for (var i = 0; i < 12; i++) DateTime(now.year, now.month + i),
    ];
    if (!months.contains(_overrideMonth)) months.insert(0, _overrideMonth);

    return Padding(
      padding: EdgeInsets.fromLTRB(Insets.lg, Insets.sm, Insets.lg,
          Insets.lg + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(_isEditing ? l.editBudget : l.addBudget,
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (_saving)
                  const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                else
                  TextButton(onPressed: _save, child: Text(l.save)),
              ],
            ),
            const SizedBox(height: Insets.md),
            // The target is fixed once created — changing it is delete + create.
            if (_isEditing)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.budgetTarget),
                trailing: Text(_category == null
                    ? l.overallBudget
                    : localizeCategory(l, _category!)),
              )
            else
              DropdownButtonFormField<String?>(
                initialValue: _category,
                decoration: InputDecoration(labelText: l.budgetTarget),
                items: [
                  if (!taken.contains(null))
                    DropdownMenuItem(value: null, child: Text(l.overallBudget)),
                  for (final c in categories)
                    DropdownMenuItem(
                        value: c.name,
                        child: Text(localizeCategory(l, c.name))),
                ],
                onChanged: (v) => setState(() => _category = v),
              ),
            const SizedBox(height: Insets.md),
            Text(l.budgetPeriod, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: Insets.sm),
            Wrap(
              spacing: Insets.sm,
              children: [
                for (final p in const ['week', 'month', 'year'])
                  ChoiceChip(
                    label: Text(periodLabel(l, p)),
                    selected: p == _period,
                    onSelected: (_) => setState(() => _period = p),
                  ),
              ],
            ),
            const SizedBox(height: Insets.md),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: l.amount,
                prefixText: '$symbol ',
                hintText: '0.00',
              ),
            ),
            // A single month can only differ from a monthly budget.
            if (_isMonthly) ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _override,
                onChanged: (v) => setState(() => _override = v),
                title: Text(l.monthOverride),
              ),
              if (_override) ...[
                DropdownButtonFormField<DateTime>(
                  initialValue: _overrideMonth,
                  decoration: InputDecoration(labelText: l.overrideMonth),
                  items: [
                    for (final m in months)
                      DropdownMenuItem(
                          value: m,
                          child: Text(DateFormat.yMMM(locale).format(m))),
                  ],
                  onChanged: (v) =>
                      setState(() => _overrideMonth = v ?? _overrideMonth),
                ),
                const SizedBox(height: Insets.md),
                TextField(
                  controller: _overrideController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    labelText: l.overrideAmount,
                    prefixText: '$symbol ',
                    hintText: '0.00',
                  ),
                ),
              ],
            ],
            const SizedBox(height: Insets.sm),
          ],
        ),
      ),
    );
  }
}
