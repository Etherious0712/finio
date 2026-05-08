import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/ai/rule_classifier.dart';
import '../../core/database/app_database.dart';
import '../../shared/providers/category_providers.dart';
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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('支出'),
                  icon: Icon(Icons.arrow_upward),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('收入'),
                  icon: Icon(Icons.arrow_downward),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() {
                _type = s.first;
                _selectedCategory = null;
              }),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _amountController,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: const InputDecoration(
                labelText: '金额',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return '请输入金额';
                final amount = double.tryParse(v);
                if (amount == null || amount <= 0) return '请输入大于 0 的金额';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: '备注（选填，可自动识别分类）',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 4),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(DateFormat('yyyy年M月d日').format(_selectedDate)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickDate,
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: Text(
                '分类',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            categoriesAsync.when(
              data: (cats) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cats
                    .map(
                      (c) => ChoiceChip(
                        avatar: Icon(
                          categoryIconData(c.icon),
                          size: 18,
                        ),
                        label: Text(c.name),
                        selected: c.name == _selectedCategory,
                        onSelected: (_) =>
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
    );
  }
}
