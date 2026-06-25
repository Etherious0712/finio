import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finio/app_localizations.dart';
import 'package:finio/core/database/app_database.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/providers/category_providers.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/providers/transaction_providers.dart';
import '../../shared/utils/category_icon.dart';
import '../../shared/utils/category_localizer.dart';

class CategoryManagementScreen extends ConsumerStatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  ConsumerState<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState
    extends ConsumerState<CategoryManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 2, vsync: this)..addListener(() => setState(() {}));

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _currentType => _tabController.index == 0 ? 'expense' : 'income';

  Future<void> _deleteCategory(Category cat) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteCategory),
        content: Text(l.confirmDeleteCategoryMsg(localizeCategory(l, cat.name))),
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
    if (confirmed == true && mounted) {
      await ref.read(appDatabaseProvider).categoryDao.deleteCategory(cat.id);
    }
  }

  void _openSheet({Category? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CategorySheet(type: _currentType, existing: existing),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.categoryManagement),
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: l.expense), Tab(text: l.income)],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CategoryList(
              type: 'expense', onDelete: _deleteCategory, onEdit: (c) => _openSheet(existing: c)),
          _CategoryList(
              type: 'income', onDelete: _deleteCategory, onEdit: (c) => _openSheet(existing: c)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openSheet(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  const _CategoryList({
    required this.type,
    required this.onDelete,
    required this.onEdit,
  });

  final String type;
  final Future<void> Function(Category) onDelete;
  final ValueChanged<Category> onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final async = ref.watch(categoriesByTypeProvider(type));
    final usage = ref.watch(categoryUsageProvider);
    final scheme = Theme.of(context).colorScheme;

    return async.when(
      data: (cats) {
        if (cats.isEmpty) return Center(child: Text(l.noCategoryYet));
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 96),
          itemCount: cats.length,
          separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
          itemBuilder: (_, i) {
            final cat = cats[i];
            final color = parseCategoryColor(cat.color);
            final count = usage[cat.name] ?? 0;

            final tile = ListTile(
              onTap: () => onEdit(cat),
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(categoryIconData(cat.icon), color: color, size: 20),
              ),
              title: Text(localizeCategory(l, cat.name)),
              subtitle: count > 0
                  ? Text('$count ${l.recordsUsed}',
                      style: Theme.of(context).textTheme.bodySmall)
                  : null,
              trailing: cat.isCustom
                  ? const Icon(Icons.edit_outlined, size: 18)
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Insets.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(Radii.sm),
                      ),
                      child: Text(l.defaultLabel,
                          style: TextStyle(
                              fontSize: 11, color: scheme.outline)),
                    ),
            );

            // Only custom categories can be swiped away.
            if (!cat.isCustom) return tile;
            return Dismissible(
              key: ValueKey(cat.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: scheme.error,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: Insets.xl),
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              confirmDismiss: (_) async {
                await onDelete(cat);
                return false; // deletion handled with confirm dialog
              },
              child: tile,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('${l.loadFailed}: $e')),
    );
  }
}

/// Add or edit a category. For built-in categories the name is a localization
/// key, so the name field is locked — only icon/color are editable.
class _CategorySheet extends ConsumerStatefulWidget {
  const _CategorySheet({required this.type, this.existing});

  final String type;
  final Category? existing;

  @override
  ConsumerState<_CategorySheet> createState() => _CategorySheetState();
}

class _CategorySheetState extends ConsumerState<_CategorySheet> {
  late final TextEditingController _nameController;
  late String _selectedIcon;
  late String _selectedColor;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;
  bool get _isBuiltIn => _isEditing && !widget.existing!.isCustom;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _nameController = TextEditingController(text: c?.isCustom == true ? c!.name : '');
    _selectedIcon = c?.icon ?? kPickableIcons.keys.first;
    _selectedColor = c?.color ?? kPresetColors.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _colorToHex(Color c) {
    final r = (c.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (c.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (c.b * 255).round().toRadixString(16).padLeft(2, '0');
    return '#$r$g$b'.toUpperCase();
  }

  Future<void> _openCustomColorPicker() async {
    final l = AppLocalizations.of(context)!;
    Color tempColor = parseCategoryColor(_selectedColor);
    final result = await showDialog<Color>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.customColor),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: tempColor,
            onColorChanged: (c) => tempColor = c,
            enableAlpha: false,
            hexInputBar: true,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, tempColor),
              child: Text(l.confirm)),
        ],
      ),
    );
    if (result != null && mounted) {
      setState(() => _selectedColor = _colorToHex(result));
    }
  }

  Future<void> _save() async {
    final db = ref.read(appDatabaseProvider).categoryDao;
    if (!_isBuiltIn && _nameController.text.trim().isEmpty) return;

    setState(() => _saving = true);
    try {
      if (_isEditing) {
        await db.updateCategory(widget.existing!.copyWith(
          name: _isBuiltIn ? widget.existing!.name : _nameController.text.trim(),
          icon: _selectedIcon,
          color: _selectedColor,
        ));
      } else {
        await db.insertCategory(CategoriesCompanion.insert(
          name: _nameController.text.trim(),
          type: widget.type,
          icon: _selectedIcon,
          color: _selectedColor,
          isCustom: const Value(true),
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
    final scheme = Theme.of(context).colorScheme;
    final accent = parseCategoryColor(_selectedColor);
    final isCustomColor = !kPresetColors.contains(_selectedColor);
    final title = _isEditing
        ? l.editCategory
        : (widget.type == 'expense' ? l.addExpenseCategory : l.addIncomeCategory);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          Insets.lg, Insets.sm, Insets.lg, Insets.lg + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
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
            if (_isBuiltIn)
              // Built-in name is a translation key; show it read-only.
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: accent.withValues(alpha: 0.15),
                  child: Icon(categoryIconData(_selectedIcon), color: accent),
                ),
                title: Text(localizeCategory(l, widget.existing!.name)),
                subtitle: Text(l.defaultLabel),
              )
            else
              TextField(
                controller: _nameController,
                autofocus: true,
                maxLength: 20,
                decoration: InputDecoration(labelText: l.categoryName),
              ),
            const SizedBox(height: Insets.sm),
            Text(l.iconLabel, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: Insets.sm),
            SizedBox(
              height: 200,
              child: SingleChildScrollView(
                child: GridView.count(
                  crossAxisCount: 7,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: Insets.xs,
                  crossAxisSpacing: Insets.xs,
                  children: kPickableIcons.entries.map((e) {
                    final selected = e.key == _selectedIcon;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = e.key),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selected ? accent.withValues(alpha: 0.15) : null,
                          borderRadius: BorderRadius.circular(Radii.sm),
                          border: Border.all(
                            color: selected ? accent : scheme.outlineVariant,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Icon(e.value,
                            size: 26,
                            color: selected ? accent : scheme.onSurfaceVariant),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: Insets.md),
            Text(l.colorLabel, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: Insets.sm),
            Wrap(
              spacing: Insets.md,
              runSpacing: Insets.md,
              children: [
                for (final hex in kPresetColors)
                  _Swatch(
                    color: parseCategoryColor(hex),
                    selected: hex == _selectedColor,
                    onTap: () => setState(() => _selectedColor = hex),
                  ),
                _Swatch(
                  color: isCustomColor ? accent : scheme.surfaceContainerHighest,
                  selected: isCustomColor,
                  icon: Icons.brush,
                  onTap: _openCustomColorPicker,
                ),
              ],
            ),
            const SizedBox(height: Insets.sm),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: selected
              ? Border.all(
                  color: Theme.of(context).colorScheme.onSurface, width: 2.5)
              : null,
        ),
        child: icon != null
            ? Icon(icon, size: 16, color: Colors.white)
            : (selected
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null),
      ),
    );
  }
}
