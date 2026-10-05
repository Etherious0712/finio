import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
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
import '../../shared/utils/cents_input_formatter.dart';
import '../../shared/widgets/account_picker.dart';
import '../../shared/widgets/category_picker.dart';
import '../../shared/widgets/credit_line.dart';

/// Add or edit a transaction. Pass an existing [Transaction] via GoRouter
/// `extra` to enter edit mode.
class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({
    super.key,
    this.existing,
    this.initialType,
    this.initialToAccount,
  });

  final Transaction? existing;

  /// Preselected segment for a new record — the FAB opens straight into
  /// transfer mode. Ignored when editing.
  final TransactionType? initialType;

  /// Preselected transfer destination — a card's Pay button opens a transfer
  /// into that card. Ignored when editing.
  final String? initialToAccount;

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
  /// Transfer destination. Only used when [_type] is transfer.
  String? _toAccount;
  // Only preselect the default account once, so it can't overwrite a manual
  // pick on a later rebuild.
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
    _type = switch (tx?.type) {
      // A refund is the income segment on a credit card.
      'income' || 'refund' => TransactionType.income,
      'transfer' => TransactionType.transfer,
      'expense' => TransactionType.expense,
      _ => widget.initialType ?? TransactionType.expense,
    };
    _selectedCategory = tx?.category;
    _selectedAccount = tx?.account;
    _toAccount = tx?.toAccount ?? widget.initialToAccount;
    // Editing keeps whatever the record already had, including "unassigned".
    _accountInitialized = _isEditing;
    _selectedDate = tx?.date ?? DateTime.now();
    _amountController =
        TextEditingController(text: tx != null ? centsTextFor(tx.amount) : '');
    _noteController = TextEditingController(text: tx?.note ?? '');
    _classifier.load();
    if (!_isEditing) _noteController.addListener(_onNoteChanged);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onNoteChanged() {
    final note = _noteController.text;
    // A transfer has no category to suggest — the note is just a description.
    if (note.isEmpty || _isTransfer) return;
    // Always reflect the classifier's main (Other included) so a note alone is
    // never left uncategorized.
    final suggested =
        _classifier.classifyWithLearning(title: note, type: _categoryType);
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

  bool get _isTransfer => _type == TransactionType.transfer;

  bool _isCard(String? name) =>
      ref.read(accountBalanceProvider(name))?.isCreditCard ?? false;

  /// Income on a credit card is a refund: it files under an expense category
  /// and takes spending back. A card income recorded before refunds existed
  /// stays income while its account is left alone.
  bool get _isRefund => _type == TransactionType.income && _incomeIsRefund;

  /// Whether the income segment means "refund" for the selected account —
  /// it's labelled that way even while another segment is picked.
  bool get _incomeIsRefund {
    if (!_isCard(_selectedAccount)) return false;
    final old = widget.existing;
    return !(old != null &&
        old.type == 'income' &&
        old.account == _selectedAccount);
  }

  /// Which side's categories (and classifier rules) apply.
  TransactionType get _categoryType =>
      _isRefund ? TransactionType.expense : _type;

  /// Picks the account, dropping the category when that flips income ↔
  /// refund, since the two use different category lists.
  void _selectAccount(String? name) {
    final wasRefund = _isRefund;
    setState(() {
      _selectedAccount = name;
      _accountInitialized = true;
      if (_isRefund != wasRefund) {
        _selectedCategory = null;
        _autoSuggested = false;
      }
    });
  }

  /// How the record being edited moved [account]'s balance, so an edit can
  /// hand that credit back before checking the limit.
  double _existingEffectOn(String? account) {
    final t = widget.existing;
    if (t == null || account == null) return 0;
    var effect = 0.0;
    if (t.account == account) {
      effect += switch (t.type) {
        'income' || 'refund' => t.amount,
        _ => -t.amount, // expense, or the source end of a transfer
      };
    }
    if (t.type == 'transfer' && t.toAccount == account) effect += t.amount;
    return effect;
  }

  /// Warns, but never blocks, when [amount] leaving [account] runs past a
  /// card's available credit.
  Future<bool> _withinLimit(String? account, double amount) =>
      confirmWithinLimit(
        context,
        card: ref.read(accountBalanceProvider(account)),
        amount: amount,
        symbol: ref.read(currencySymbolProvider),
        credit: -_existingEffectOn(account),
      );

  /// Writes a transfer: one row holding both ends, so every income/expense
  /// fold can skip it with a single type check.
  Future<void> _saveTransfer() async {
    final l = AppLocalizations.of(context)!;
    final from = _selectedAccount;
    final to = _toAccount;
    if (from == null || to == null || from == to) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.sameAccountTransfer)));
      return;
    }

    final amount = parseCentsInput(_amountController.text)!;
    // Moving money out of a card (a cash advance) spends its credit too.
    if (!await _withinLimit(from, amount)) return;

    setState(() => _saving = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final noteText = _noteController.text.trim();
      // Paying a card is its own thing in the list: with no note, the title
      // falls back to the "Card Payment" category rather than "A → B".
      final isPayment = _isCard(to);
      final category = isPayment ? 'catCardPayment' : 'catTransfer';
      final title =
          noteText.isNotEmpty ? noteText : (isPayment ? '' : '$from → $to');

      if (_isEditing) {
        await db.transactionDao.updateTransaction(
          widget.existing!.copyWith(
            title: title,
            amount: amount,
            type: 'transfer',
            category: category,
            date: _selectedDate,
            note: noteText.isNotEmpty ? Value(noteText) : const Value(null),
            account: Value(from),
            toAccount: Value(to),
            isSynced: false,
            updatedAt: DateTime.now(),
          ),
        );
      } else {
        await db.transactionDao.insertTransaction(
          TransactionsCompanion.insert(
            title: title,
            amount: amount,
            type: 'transfer',
            category: category,
            date: _selectedDate,
            note: noteText.isNotEmpty ? Value(noteText) : const Value.absent(),
            account: Value(from),
            toAccount: Value(to),
          ),
        );
      }
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isTransfer) return _saveTransfer();

    final amount = parseCentsInput(_amountController.text)!;
    final isExpense = _type == TransactionType.expense;
    if (isExpense && !await _withinLimit(_selectedAccount, amount)) return;

    setState(() => _saving = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final noteText = _noteController.text.trim();
      final typeStr =
          isExpense ? 'expense' : (_isRefund ? 'refund' : 'income');
      final categoryType = _categoryType;

      // A note alone always resolves to a main category: fall back to the
      // classifier (Other when nothing matches) instead of forcing a pick.
      final main = _selectedCategory ??
          _classifier.classifyWithLearning(
              title: noteText, type: categoryType);
      final auto = _autoSuggested || _selectedCategory == null;

      // No note typed = no title. Falling back to the category KEY here is
      // what put literal 'catOtherIncome' on the dashboard; the list shows
      // the localized category instead via transactionTitle().
      final title = noteText;

      // Auto path: file under a sub named from the matched keyword, or the note
      // text itself when nothing matched. Manual picks create no sub.
      var categoryToStore = main;
      if (!_isEditing && auto && noteText.isNotEmpty) {
        final subName = RuleClassifier.matchedKeyword(
                title: noteText, type: categoryType) ??
            _cleanSub(noteText);
        if (subName.isNotEmpty) {
          final mains = ref.read(categoryType == TransactionType.expense
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
              // The categories table only knows the two sides.
              type: categoryType == TransactionType.expense
                  ? 'expense'
                  : 'income',
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
    // Accounts arrive asynchronously, so seed the default pick on the first
    // build that has them. Guarded so it never clobbers a manual choice.
    final defaultAccount = ref.watch(defaultAccountProvider);
    if (!_accountInitialized && defaultAccount != null) {
      // Paying the default card itself: leave the source for the user to pick.
      if (defaultAccount.name != _toAccount) {
        _selectedAccount = defaultAccount.name;
      }
      _accountInitialized = true;
    }

    // Watched so the refund relabel follows the account list as it loads.
    final selectedBalance = ref.watch(accountBalanceProvider(_selectedAccount));
    final incomeIsRefund = _incomeIsRefund;
    final categoriesAsync = _categoryType == TransactionType.expense
        ? ref.watch(expenseCategoriesProvider)
        : ref.watch(incomeCategoriesProvider);
    final symbol = ref.watch(currencySymbolProvider);
    final typeColor = finio.forType(switch (_type) {
      TransactionType.expense => 'expense',
      TransactionType.income => 'income',
      TransactionType.transfer => 'transfer',
    });
    final fromBalance = ref.watch(accountBalanceProvider(
        _isTransfer ? _selectedAccount : null));
    final toBalance =
        ref.watch(accountBalanceProvider(_isTransfer ? _toAccount : null));
    final accountCount =
        (ref.watch(accountsProvider).valueOrNull ?? const []).length;

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
                  // Labels only: three icon+label segments overflow at 360dp
                  // in the wordier locales.
                  SegmentedButton<TransactionType>(
                    segments: [
                      ButtonSegment(
                        value: TransactionType.expense,
                        label: Text(l.expense),
                      ),
                      ButtonSegment(
                        value: TransactionType.income,
                        label: Text(incomeIsRefund ? l.refund : l.income),
                      ),
                      ButtonSegment(
                        value: TransactionType.transfer,
                        label: Text(l.transfer),
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
                    keyboardType: TextInputType.number,
                    inputFormatters: const [CentsInputFormatter()],
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
                      final amount = parseCentsInput(v ?? '');
                      if (amount == null) return l.pleaseEnterAmount;
                      if (amount <= 0) {
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
                  // A transfer has no category — it swaps the picker for the
                  // two ends of the move.
                  if (_isTransfer) ...[
                    if (accountCount < 2)
                      Text(l.needTwoAccountsForTransfer,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.outline))
                    else ...[
                      AccountPicker(
                        label: l.fromAccount,
                        selected: _selectedAccount,
                        exclude: _toAccount,
                        allowUnassigned: false,
                        onSelect: _selectAccount,
                      ),
                      if (fromBalance?.isCreditCard ?? false) ...[
                        const SizedBox(height: Insets.xs),
                        CreditLine(balance: fromBalance!, symbol: symbol),
                      ],
                      const SizedBox(height: Insets.lg),
                      AccountPicker(
                        label: l.toAccount,
                        selected: _toAccount,
                        exclude: _selectedAccount,
                        allowUnassigned: false,
                        onSelect: (name) => setState(() => _toAccount = name),
                      ),
                      if (toBalance?.isCreditCard ?? false) ...[
                        const SizedBox(height: Insets.xs),
                        Text(
                          cardBalanceLabel(l, toBalance!, symbol),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ] else ...[
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
                      onSelect: _selectAccount,
                    ),
                    if (selectedBalance?.isCreditCard ?? false) ...[
                      const SizedBox(height: Insets.xs),
                      CreditLine(balance: selectedBalance!, symbol: symbol),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
