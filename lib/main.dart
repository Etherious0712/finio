import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/notifications/budget_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BudgetNotifier.initialize();
  runApp(const ProviderScope(child: FinioApp()));
}
