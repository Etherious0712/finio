import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:finio/app_localizations.dart';
import '../../core/sync/sync_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _syncing = false;

  Future<void> _sync() async {
    setState(() => _syncing = true);
    try {
      await ref.read(syncServiceProvider).syncAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.syncSuccess),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.syncFailed),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.settings), centerTitle: true),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              l.account,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          StreamBuilder<AuthState>(
            stream: Supabase.instance.client.auth.onAuthStateChange,
            builder: (context, snapshot) {
              final user = snapshot.data?.session?.user ??
                  Supabase.instance.client.auth.currentUser;
              if (user == null) {
                return ListTile(
                  leading: const Icon(Icons.account_circle_outlined),
                  title: Text(l.signIn),
                  subtitle: Text(l.loginForSync),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/auth'),
                );
              }
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.account_circle),
                    title: Text(user.email ?? ''),
                    subtitle: _syncing
                        ? LinearProgressIndicator(
                            minHeight: 2,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                          )
                        : Text(l.cloudSync),
                    trailing: _syncing
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.sync),
                            onPressed: _sync,
                          ),
                    onTap: _syncing ? null : _sync,
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: Text(l.signOut),
                    onTap: _signOut,
                  ),
                ],
              );
            },
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              l.settings,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.manage_accounts),
            title: Text(l.accountAndData),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/account-data'),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l.language),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/language'),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l.appearance),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/appearance'),
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: Text(l.currency),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/currency'),
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: Text(l.categoryManagement),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/categories'),
          ),
          ListTile(
            leading: const Icon(Icons.savings_outlined),
            title: Text(l.savingsAccounts),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/accounts'),
          ),
        ],
      ),
    );
  }
}
