import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.settings), centerTitle: true),
      body: ListView(
        children: [
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
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: Text(l.budgetSettings),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/budget'),
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: Text(l.categoryManagement),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/categories'),
          ),
        ],
      ),
    );
  }
}
