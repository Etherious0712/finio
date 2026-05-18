import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置'), centerTitle: true),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('外观设置'),
            subtitle: const Text('Appearance'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/appearance'),
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('货币设置'),
            subtitle: const Text('Currency'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/currency'),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('预算设置'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/budget'),
          ),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('分类管理'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/categories'),
          ),
        ],
      ),
    );
  }
}
