import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:finio/app.dart';
import 'package:finio/core/config/supabase_config.dart';
import 'package:finio/core/database/app_database.dart';
import 'package:finio/core/notifications/budget_notifier.dart';
import 'package:finio/shared/providers/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('=== FLUTTER ERROR: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
  };

  await BudgetNotifier.initialize();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  final db = AppDatabase();

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWith((ref) {
          ref.onDispose(() => db.close());
          return db;
        }),
      ],
      child: const FinioApp(),
    ),
  );
}
