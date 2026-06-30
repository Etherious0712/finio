import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finio/app_localizations.dart';
import 'package:finio/core/database/app_database.dart';
import '../../core/ai/rule_classifier.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../providers/category_providers.dart';
import '../providers/currency_provider.dart';
import '../providers/database_provider.dart';
import '../utils/category_icon.dart';
import '../utils/category_localizer.dart';
import 'amount_keypad.dart';

/// Fast transaction entry as a bottom sheet: type → amount (custom keypad) →
/// category (one-tap chips, auto-suggested from the note). The "2-tap" path.
class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({super.key, required this.initialType});

  final TransactionType initialType;

  /// Opens the sheet. Returns true if a transaction was saved.
  static Future<bool?> show(BuildContext context, TransactionType type) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => QuickAddSheet(initialType: type),
    );
  }

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  late TransactionType _type = widget.initialType;
  final _noteController = TextEditingController();
  final _classifier = RuleClassifier();
  String _amount = '';
  String? _category;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _classifier.load();
    _noteController.addListener(_onNoteChanged);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onNoteChanged() {
    final note = _noteController.text;
    if (note.isEmpty) return;
    final suggested = _classifier.classifyWithLearning(title: note, type: _type);
    if (!suggested.startsWith('catOther') && suggested != _category) {
      setState(() => _category = suggested);
    }
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    final amount = double.tryParse(_amount) ?? 0;
    if (amount <= 0) {
      _toast(l.pleaseEnterPositiveAmount);
      return;
    }
    if (_category == null) {
      _toast(l.pleaseSelectCategory);
      return;
    }

    setState(() => _saving = true);
    final note = _noteController.text.trim();
    await ref.read(appDatabaseProvider).transactionDao.insertTransaction(
          TransactionsCompanion.insert(
            title: note.isNotEmpty ? note : _category!,
            amount: amount,
            type: _type == TransactionType.expense ? 'expense' : 'income',
            category: _category!,
            date: DateTime.now(),
            note: note.isNotEmpty ? Value(note) : const Value.absent(),
          ),
        );
    if (mounted) Navigator.pop(context, true);
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final finio = context.finio;
    final symbol = ref.watch(currencySymbolProvider);
    final isExpense = _type == TransactionType.expense;
    final typeColor = finio.forType(isExpense ? 'expense' : 'income');
    final categories = (isExpense
            ? ref.watch(expenseCategoriesProvider)
            : ref.watch(incomeCategoriesProvider))
        .valueOrNull ??
        const <Category>[];

    return Padding(
      padding: EdgeInsets.only(
        left: Insets.lg,
        right: Insets.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + Insets.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Type toggle
          Center(
            child: SegmentedButton<TransactionType>(
              segments: [
                ButtonSegment(
                    value: TransactionType.expense, label: Text(l.expense)),
                ButtonSegment(
                    value: TransactionType.income, label: Text(l.income)),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() {
                _type = s.first;
                _category = null;
              }),
            ),
          ),
          const SizedBox(height: Insets.lg),
          // Amount display
          Text(
            '$symbol ${_amount.isEmpty ? '0' : _amount}',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .displayMedium
                ?.copyWith(color: typeColor, fontWeight: FontWeight.w700)
                .tabular,
          ),
          const SizedBox(height: Insets.sm),
          // Optional note (drives auto-categorization)
          TextField(
            controller: _noteController,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              isDense: true,
              hintText: l.note,
              prefixIcon: const Icon(Icons.notes, size: 20),
            ),
          ),
          const SizedBox(height: Insets.md),
          // Category chips (one-tap)
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: Insets.sm),
              itemBuilder: (_, i) {
                final c = categories[i];
                final color = parseCategoryColor(c.color);
                final selected = c.name == _category;
                return _CatChip(
                  label: localizeCategory(l, c.name),
                  icon: categoryIconData(c.icon),
                  color: color,
                  selected: selected,
                  onTap: () => setState(() => _category = c.name),
                );
              },
            ),
          ),
          const SizedBox(height: Insets.sm),
          AmountKeypad(
            value: _amount,
            onChanged: (v) => setState(() => _amount = v),
          ),
          const SizedBox(height: Insets.sm),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(backgroundColor: typeColor),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(l.save),
          ),
        ],
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  const _CatChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Insets.md),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(Radii.pill),
          border: Border.all(
            color: selected ? color : Theme.of(context).colorScheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: Insets.xs),
            Text(label,
                style: TextStyle(
                  color: selected
                      ? color
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                )),
          ],
        ),
      ),
    );
  }
}
