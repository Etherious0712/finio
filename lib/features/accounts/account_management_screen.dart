import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finio/app_localizations.dart';
import 'package:finio/core/database/app_database.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/providers/account_providers.dart';
import '../../shared/providers/currency_provider.dart';
import '../../shared/providers/database_provider.dart';
import '../../shared/utils/account_localizer.dart';
import '../../shared/utils/category_icon.dart';
import '../../shared/utils/currency_formatter.dart';

/// Manage accounts: the cash, banks, cards and e-wallets money sits in.
class AccountManagementScreen extends ConsumerStatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  ConsumerState<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState
    extends ConsumerState<AccountManagementScreen> {
  Future<void> _delete(Account account) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.accountLabel),
        content: Text(l.confirmDeleteCategoryMsg(account.name)),
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
      // Transactions keep the jar name and simply fall into "unassigned" —
      // deliberately not deleted along with the jar.
      await ref.read(appDatabaseProvider).accountDao.deleteAccount(account.id);
    }
  }

  void _openSheet({Account? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AccountSheet(existing: existing),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final async = ref.watch(accountsProvider);
    final balances = ref.watch(accountBalancesProvider);
    final symbol = ref.watch(currencySymbolProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l.accounts), centerTitle: true),
      body: async.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.savings_outlined,
                      size: 64, color: scheme.outlineVariant),
                  const SizedBox(height: Insets.lg),
                  Text(l.noAccountYet,
                      style: TextStyle(color: scheme.outline)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 96),
            itemCount: accounts.length,
            itemBuilder: (_, i) {
              final a = accounts[i];
              final color = parseCategoryColor(a.color);
              final balance = balances
                  .where((b) => b.name == a.name)
                  .firstOrNull
                  ?.balance ??
                  0;
              return Dismissible(
                key: ValueKey('account-${a.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: scheme.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: Insets.xl),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  await _delete(a);
                  return false;
                },
                child: ListTile(
                  onTap: () => _openSheet(existing: a),
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(categoryIconData(a.icon), color: color, size: 20),
                  ),
                  title: Text(a.name),
                  subtitle: Text(
                    [
                      localizeAccountType(l, a.type),
                      if (a.isDefault) l.defaultLabel,
                    ].join(' · '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: Text(
                    formatAmount(balance, symbol),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          // A credit card sits in the red; say so.
                          color: balance < 0
                              ? context.finio.expense
                              : context.finio.income,
                        ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l.loadFailed}: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openSheet(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Add or edit an account: name, type, opening balance, icon, color, and
/// whether it's the default pick.
class _AccountSheet extends ConsumerStatefulWidget {
  const _AccountSheet({this.existing});

  final Account? existing;

  @override
  ConsumerState<_AccountSheet> createState() => _AccountSheetState();
}

class _AccountSheetState extends ConsumerState<_AccountSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _openingController;
  late String _selectedIcon;
  late String _selectedColor;
  late String _selectedType;
  late bool _isDefault;
  bool _saving = false;
  /// Set once the user picks an icon by hand, so switching type stops
  /// overwriting their choice.
  bool _iconTouched = false;

  bool get _isEditing => widget.existing != null;
  bool get _isCard => _selectedType == 'creditCard';

  @override
  void initState() {
    super.initState();
    final a = widget.existing;
    _nameController = TextEditingController(text: a?.name ?? '');
    // Stored negative on a card (money owed); the field shows what's owed.
    final opening = a?.openingBalance ?? 0;
    _openingController = TextEditingController(
        text: opening == 0 ? '' : opening.abs().toStringAsFixed(2));
    _selectedType = a?.type ?? 'cash';
    // Default to the savings icon; the grid itself is the shared category icon
    // list, so finance icons sit further down it.
    _selectedIcon = a?.icon ?? defaultIconForAccountType(_selectedType);
    _selectedColor = a?.color ?? kPresetColors.first;
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _openingController.dispose();
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
    final l = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final dao = ref.read(appDatabaseProvider).accountDao;
    // Names are the join key for transactions and are uniquely indexed, so
    // check here rather than letting the insert surface a SqliteException.
    final clash = (await dao.getAllAccounts())
        .where((a) => a.name == name && a.id != widget.existing?.id);
    if (clash.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.duplicateAccountName)));
      }
      return;
    }

    final typed = double.tryParse(_openingController.text.trim()) ?? 0;
    // A card's opening balance is debt, so it's stored negative.
    final opening = _isCard ? -typed.abs() : typed;

    setState(() => _saving = true);
    try {
      int id;
      if (_isEditing) {
        final old = widget.existing!;
        // Rename goes through the DAO so existing transactions follow the
        // account.
        if (old.name != name) {
          await dao.renameAccount(id: old.id, oldName: old.name, newName: name);
        }
        await dao.updateAccount(old.copyWith(
          name: name,
          icon: _selectedIcon,
          color: _selectedColor,
          type: _selectedType,
          openingBalance: opening,
        ));
        id = old.id;
      } else {
        id = await dao.insertAccount(AccountsCompanion.insert(
          name: name,
          icon: _selectedIcon,
          color: _selectedColor,
          type: Value(_selectedType),
          openingBalance: Value(opening),
        ));
      }
      // setDefault clears the flag on every other account, so only call it when
      // the switch is on; turning it off just leaves no default.
      if (_isDefault) {
        await dao.setDefault(id);
      } else if (_isEditing && widget.existing!.isDefault) {
        await dao.updateAccount(
          (await dao.getAllAccounts()).firstWhere((a) => a.id == id).copyWith(
                isDefault: false,
              ),
        );
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
    final symbol = ref.watch(currencySymbolProvider);
    final accent = parseCategoryColor(_selectedColor);
    final isCustomColor = !kPresetColors.contains(_selectedColor);

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
                Text(
                  _isEditing ? l.editAccount : l.addAccount,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
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
            TextField(
              controller: _nameController,
              autofocus: !_isEditing,
              maxLength: 20,
              decoration: InputDecoration(labelText: l.accountName),
            ),
            const SizedBox(height: Insets.sm),
            Text(l.accountType, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: Insets.sm),
            // Chips, not a SegmentedButton: five localized labels don't fit on
            // one row at 360dp.
            Wrap(
              spacing: Insets.sm,
              children: [
                for (final t in kAccountTypes)
                  ChoiceChip(
                    label: Text(localizeAccountType(l, t)),
                    selected: t == _selectedType,
                    onSelected: (_) => setState(() {
                      _selectedType = t;
                      if (!_isEditing && !_iconTouched) {
                        _selectedIcon = defaultIconForAccountType(t);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: Insets.md),
            TextField(
              controller: _openingController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: _isCard ? l.amountOwed : l.openingBalance,
                prefixText: '$symbol ',
                hintText: '0.00',
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _isDefault,
              onChanged: (v) => setState(() => _isDefault = v),
              title: Text(l.setAsDefaultAccount),
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
                      onTap: () => setState(() {
                        _selectedIcon = e.key;
                        _iconTouched = true;
                      }),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              selected ? accent.withValues(alpha: 0.15) : null,
                          borderRadius: BorderRadius.circular(Radii.sm),
                          border: Border.all(
                            color: selected ? accent : scheme.outlineVariant,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Icon(e.value,
                            size: 26,
                            color:
                                selected ? accent : scheme.onSurfaceVariant),
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
