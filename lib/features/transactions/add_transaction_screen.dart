import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:finio/app_localizations.dart';
import 'package:finio/core/database/app_database.dart';
import '../../core/ai/rule_classifier.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../shared/providers/account_providers.dart';
import '../../shared/providers/category_providers.dart';
import '../../shared/providers/currency_provider.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/widgets/account_picker.dart';
import '../../shared/widgets/category_picker.dart';

/// Add or edit a transaction. Pass an existing [Transaction] via GoRouter
/// `extra` to enter edit mode.
class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key, this.existing});

  final Transaction? existing;

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late TransactionType _type;
  String? _selectedCategory;
  String? _selectedAccount;
  // Only preselect the default jar once, so it can't overwrite a manual pick on
  // a later rebuild.
  bool _accountInitialized = false;
  late DateTime _selectedDate;
  bool _saving = false;
  // True while the category is the classifier's suggestion (user hasn't picked
  // one manually). Only then do we auto-create a sub-category on save.
  bool _autoSuggested = false;

  final _classifier = RuleClassifier();

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final tx = widget.existing;
    _type = tx?.type == 'income'
        ? TransactionType.income
        : TransactionType.expense;
    _selectedCategory = tx?.category;
    _selectedAccount = tx?.account;
    // Editing keeps whatever the record already had, including "unassigned".
    _accountInitialized = _isEditing;
    _selectedDate = tx?.date ?? DateTime.now();
    _amountController =
        TextEditingController(text: tx != null ? _trimAmount(tx.amount) : '');
    _noteController = TextEditingController(text: tx?.note ?? '');
    _classifier.load();
    if (!_isEditing) _noteController.addListener(_onNoteChanged);
  }

  String _trimAmount(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onNoteChanged() {
    final note = _noteController.text;
    if (note.isEmpty) return;
    // Always reflect the classifier's main (Other included) so a note alone is
    // never left uncategorized.
    final suggested = _classifier.classifyWithLearning(title: note, type: _type);
    if (suggested != _selectedCategory) {
      setState(() {
        _selectedCategory = suggested;
        _autoSuggested = true;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  /// Trimmed, length-capped note used as a fallback sub-category name.
  String _cleanSub(String note) {
    final s = note.trim();
    return s.length <= 30 ? s : s.substring(0, 30).trim();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final noteText = _noteController.text.trim();
      final typeStr = _type == TransactionType.expense ? 'expense' : 'income';

      // A note alone always resolves to a main category: fall back to the
      // classifier (Other when nothing matches) instead of forcing a pick.
      final main = _selectedCategory ??
          _classifier.classifyWithLearning(title: noteText, type: _type);
      final auto = _autoSuggested || _selectedCategory == null;

      final title = noteText.isNotEmpty ? noteText : main;
      final amount = double.parse(_amountController.text);

      // Auto path: file under a sub named from the matched keyword, or the note
      // text itself when nothing matched. Manual picks create no sub.
      var categoryToStore = main;
      if (!_isEditing && auto && noteText.isNotEmpty) {
        final subName =
            RuleClassifier.matchedKeyword(title: noteText, type: _type) ??
                _cleanSub(noteText);
        if (subName.isNotEmpty) {
          final mains = ref.read(_type == TransactionType.expense
                      ? expenseCategoriesProvider
                      : incomeCategoriesProvider)
                  .valueOrNull ??
              const <Category>[];
          Category? mainCat;
          for (final c in mains) {
            if (c.name == main) {
              mainCat = c;
              break;
            }
          }
          if (mainCat != null) {
            final sub = await db.categoryDao.findOrCreateSub(
              parentId: mainCat.id,
              name: subName,
              type: typeStr,
              icon: mainCat.icon,
              color: mainCat.color,
            );
            categoryToStore = sub.name;
          }
        }
      }

      if (_isEditing) {
        // Edit: replace the row, re-flag for sync.
        await db.transactionDao.updateTransaction(
          widget.existing!.copyWith(
            title: title,
            amount: amount,
            type: typeStr,
            category: main,
            date: _selectedDate,
            note: noteText.isNotEmpty ? Value(noteText) : const Value(null),
            account: Value(_selectedAccount),
            isSynced: false,
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        await db.transactionDao.insertTransaction(
          TransactionsCompanion.insert(
            title: title,
            amount: amount,
            type: typeStr,
            category: categoryToStore,
            date: _selectedDate,
            note: noteText.isNotEmpty ? Value(noteText) : const Value.absent(),
            account: Value(_selectedAccount),
          ),
        );
      }

      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final finio = context.finio;
    final locale = Localizations.localeOf(context).toString();
    final categoriesAsync = _type == TransactionType.expense
        ? ref.watch(expenseCategoriesProvider)
        : ref.watch(incomeCategoriesProvider);
    final isExpense = _type == TransactionType.expense;
    final symbol = ref.watch(currencySymbolProvider);
    final typeColor = finio.forType(isExpense ? 'expense' : 'income');

    // Jars arrive asynchronously, so seed the default pick on the first build
    // that has them. Guarded so it never clobbers a manual choice.
    final defaultAccount = ref.watch(defaultAccountProvider);
    if (!_accountInitialized && defaultAccount != null) {
      _selectedAccount = defaultAccount.name;
      _accountInitialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l.editTransaction : l.addTransaction),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: Insets.sm),
            child: _saving
                ? const Padding(
                    padding: EdgeInsets.all(Insets.md),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TextButton(onPressed: _save, child: Text(l.save)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: typeColor.withValues(alpha: 0.08),
              padding: const EdgeInsets.fromLTRB(
                  Insets.xl, Insets.lg, Insets.xl, Insets.xl),
              child: Column(
                children: [
                  SegmentedButton<TransactionType>(
                    segments: [
                      ButtonSegment(
                        value: TransactionType.expense,
                        label: Text(l.expense),
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      ButtonSegment(
                        value: TransactionType.income,
                        label: Text(l.income),
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (s) => setState(() {
                      _type = s.first;
                      _selectedCategory = null;
                      _autoSuggested = false;
                    }),
                  ),
                  const SizedBox(height: Insets.md),
                  TextFormField(
                    controller: _amountController,
                    autofocus: !_isEditing,
                    textAlign: TextAlign.center,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(color: typeColor)
                        .tabular,
                    decoration: InputDecoration(
                      filled: false,
                      prefixText: '$symbol ',
                      prefixStyle: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(color: typeColor),
                      hintText: '0.00',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      errorStyle: const TextStyle(fontSize: 12),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return l.pleaseEnterAmount;
                      final amount = double.tryParse(v);
                      if (amount == null || amount <= 0) {
                        return l.pleaseEnterPositiveAmount;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(Insets.lg),
                children: [
                  TextFormField(
                    controller: _noteController,
                    maxLength: 100,
                    decoration: InputDecoration(
                      labelText: l.note,
                      prefixIcon: const Icon(Icons.notes),
                    ),
                  ),
                  const SizedBox(height: Insets.xs),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(DateFormat.yMMMMd(locale).format(_selectedDate)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(height: Insets.lg),
                  Text(l.category,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: Insets.sm),
                  categoriesAsync.when(
                    data: (cats) => CategoryPicker(
                      categories: cats,
                      selected: _selectedCategory,
                      onSelect: (name) => setState(() {
                        _selectedCategory = name;
                        _autoSuggested = false;
                      }),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('${l.loadFailed}: $e'),
                  ),
                  const SizedBox(height: Insets.lg),
                  AccountPicker(
                    selected: _selectedAccount,
                    onSelect: (name) => setState(() {
                      _selectedAccount = name;
                      _accountInitialized = true;
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
