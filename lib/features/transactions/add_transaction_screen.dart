import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/ai/rule_classifier.dart';
import '../../core/database/app_database.dart';
import '../../shared/providers/category_providers.dart';
import '../../shared/providers/currency_provider.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/utils/category_icon.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState
    extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _saving = false;

  final _classifier = RuleClassifier();

  @override
  void initState() {
    super.initState();
    _classifier.load();
    _noteController.addListener(_onNoteChanged);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onNoteChanged() {
    final note = _noteController.text;
    if (note.isEmpty) return;
    final suggested =
        _classifier.classifyWithLearning(title: note, type: _type);
    if (suggested != '其他' && suggested != _selectedCategory) {
      setState(() => _selectedCategory = suggested);
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择分类')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final noteText = _noteController.text.trim();
      final title = noteText.isNotEmpty ? noteText : _selectedCategory!;

      await db.transactionDao.insertTransaction(
        TransactionsCompanion.insert(
          title: title,
          amount: double.parse(_amountController.text),
          type: _type == TransactionType.expense ? 'expense' : 'income',
          category: _selectedCategory!,
          date: _selectedDate,
          note: noteText.isNotEmpty ? Value(noteText) : const Value.absent(),
        ),
      );

      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = _type == TransactionType.expense
        ? ref.watch(expenseCategoriesProvider)
        : ref.watch(incomeCategoriesProvider);

    final isExpense = _type == TransactionType.expense;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final symbol = ref.watch(currencySymbolProvider);
    final typeColor =
        isExpense ? Colors.red.shade400 : Colors.green.shade500;
    final typeBgColor = isExpense
        ? (isDark ? const Color(0xFF3D1212) : Colors.red.shade50)
        : (isDark ? const Color(0xFF0F2E1A) : Colors.green.shade50);

    return Scaffold(
      appBar: AppBar(
        title: const Text('新增记录'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _saving
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TextButton(
                    onPressed: _save,
                    child: const Text('保存'),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Fixed top: type toggle + large amount display
            Container(
              width: double.infinity,
              color: typeBgColor,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: [
                  SegmentedButton<TransactionType>(
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: isExpense
                          ? (isDark ? const Color(0xFF5C2020) : Colors.red.shade100)
                          : (isDark ? const Color(0xFF1A4D2E) : Colors.green.shade100),
                      selectedForegroundColor: isExpense
                          ? (isDark ? Colors.red.shade200 : Colors.red.shade700)
                          : (isDark ? Colors.green.shade300 : Colors.green.shade700),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    segments: const [
                      ButtonSegment(
                        value: TransactionType.expense,
                        label: Text('支出'),
                        icon: Icon(Icons.remove_circle_outline),
                      ),
                      ButtonSegment(
                        value: TransactionType.income,
                        label: Text('收入'),
                        icon: Icon(Icons.add_circle_outline),
                      ),
                    ],
                    selected: {_type},
                    onSelectionChanged: (s) => setState(() {
                      _type = s.first;
                      _selectedCategory = null;
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _amountController,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: typeColor,
                    ),
                    decoration: InputDecoration(
                      prefixText: '$symbol ',
                      prefixStyle: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: typeColor,
                      ),
                      hintText: '0.00',
                      hintStyle: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: typeColor.withValues(alpha: 0.25),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      errorStyle: const TextStyle(fontSize: 12),
                      errorMaxLines: 1,
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return '请输入金额';
                      final amount = double.tryParse(v);
                      if (amount == null || amount <= 0) return '请输入大于 0 的金额';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            // Scrollable body
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _noteController,
                    maxLength: 100,
                    decoration: const InputDecoration(
                      labelText: '备注（选填，可自动识别分类）',
                      prefixIcon: Icon(Icons.notes),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Card(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                          DateFormat('yyyy年M月d日').format(_selectedDate)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('分类',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  categoriesAsync.when(
                    data: (cats) => GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 0.82,
                      children: cats
                          .map(
                            (c) => _CategoryCell(
                              category: c,
                              selected: c.name == _selectedCategory,
                              onTap: () =>
                                  setState(() => _selectedCategory = c.name),
                            ),
                          )
                          .toList(),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('加载分类失败: $e'),
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

class _CategoryCell extends StatelessWidget {
  const _CategoryCell({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final Category category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final catColor = parseCategoryColor(category.color);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: selected
              ? catColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(color: catColor, width: 2)
              : Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 1,
                ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected
                    ? catColor
                    : catColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                categoryIconData(category.icon),
                size: 20,
                color: selected ? Colors.white : catColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 11,
                color: selected
                    ? catColor
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
