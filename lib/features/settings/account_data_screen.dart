import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:finio/app_localizations.dart';
import 'package:finio/shared/providers/currency_provider.dart';
import 'package:finio/shared/providers/database_provider.dart';
import 'package:finio/shared/providers/locale_provider.dart';
import 'package:finio/shared/providers/theme_provider.dart';

class AccountDataScreen extends ConsumerStatefulWidget {
  const AccountDataScreen({super.key});

  @override
  ConsumerState<AccountDataScreen> createState() => _AccountDataScreenState();
}

class _AccountDataScreenState extends ConsumerState<AccountDataScreen> {
  Future<void> _showForgotPasswordDialog(String? email) async {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: email ?? '');
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.forgotPassword),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: l.email),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.confirm),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      await Supabase.instance.client.auth
          .resetPasswordForEmail(controller.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.resetPasswordEmailSent),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      controller.dispose();
    }
  }

  Future<void> _showResetSettingsDialog() async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.resetSettings),
        content: Text(l.confirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    ref.read(localeProvider.notifier).setLocale(null);
    ref.read(themeProvider.notifier).setTheme(AppThemeMode.system);
    ref.read(currencyProvider.notifier).setCode('USD');
    await ref.read(appDatabaseProvider).budgetDao.deleteAllBudgets();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.settingsReset),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _showResetDataDialog(String? userId) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteConfirmDialog(
        title: l.resetData,
        body: l.confirmDelete,
        actionLabel: l.resetData,
      ),
    );
    if (confirmed != true || !mounted) return;

    final db = ref.read(appDatabaseProvider);
    await db.transactionDao.deleteAllTransactions();
    if (userId != null) {
      try {
        await Supabase.instance.client
            .from('transactions')
            .delete()
            .eq('user_id', userId);
      } catch (_) {}
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.dataReset),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _showDeleteAccountDialog(String userId) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteConfirmDialog(
        title: l.deleteAccount,
        body: l.confirmDelete,
        actionLabel: l.deleteAccount,
      ),
    );
    if (confirmed != true || !mounted) return;

    final supabase = Supabase.instance.client;
    final db = ref.read(appDatabaseProvider);
    bool rpcSucceeded = false;

    try {
      await supabase.from('transactions').delete().eq('user_id', userId);
    } catch (_) {}

    try {
      await supabase.rpc('delete_user');
      rpcSucceeded = true;
    } catch (_) {}

    await db.transactionDao.deleteAllTransactions();
    await db.budgetDao.deleteAllBudgets();
    await db.categoryDao.deleteCustomCategories();

    if (mounted) {
      ref.read(localeProvider.notifier).setLocale(null);
      ref.read(themeProvider.notifier).setTheme(AppThemeMode.system);
      ref.read(currencyProvider.notifier).setCode('USD');
    }

    await supabase.auth.signOut();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(rpcSucceeded ? l.accountDeleted : '账号将在 24 小时内删除'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final user = Supabase.instance.client.auth.currentUser;
    final isLoggedIn = user != null;

    return Scaffold(
      appBar: AppBar(title: Text(l.accountAndData), centerTitle: true),
      body: ListView(
        children: [
          if (isLoggedIn) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                l.account,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.lock_reset),
              title: Text(l.forgotPassword),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showForgotPasswordDialog(user.email),
            ),
            const Divider(height: 1),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Data Management',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: Text(l.resetSettings),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showResetSettingsDialog,
          ),
          ListTile(
            leading: const Icon(Icons.delete_sweep, color: Colors.red),
            title: Text(l.resetData,
                style: const TextStyle(color: Colors.red)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showResetDataDialog(user?.id),
          ),
          if (isLoggedIn) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                l.dangerZone,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.red,
                    ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.no_accounts, color: Colors.red),
              title: Text(l.deleteAccount,
                  style: const TextStyle(color: Colors.red)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showDeleteAccountDialog(user.id),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeleteConfirmDialog extends StatefulWidget {
  const _DeleteConfirmDialog({
    required this.title,
    required this.body,
    required this.actionLabel,
  });

  final String title;
  final String body;
  final String actionLabel;

  @override
  State<_DeleteConfirmDialog> createState() => _DeleteConfirmDialogState();
}

class _DeleteConfirmDialogState extends State<_DeleteConfirmDialog> {
  final _controller = TextEditingController();
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(
      () => setState(() => _confirmed = _controller.text == 'DELETE'),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.title, style: const TextStyle(color: Colors.red)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.body),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: l.typeDeleteToConfirm,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed:
              _confirmed ? () => Navigator.pop(context, true) : null,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text(widget.actionLabel),
        ),
      ],
    );
  }
}
