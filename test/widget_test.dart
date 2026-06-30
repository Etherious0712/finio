import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finio/app.dart';
import 'package:finio/core/database/app_database.dart';
import 'package:finio/shared/providers/database_provider.dart';

void main() {
  testWidgets('App smoke test — Dashboard renders', (tester) async {
    // Use an in-memory database so the test doesn't open the real native DB
    // (which leaves a pending timer).
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const FinioApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Finio'), findsOneWidget);

    // Unmount and flush drift's deferred stream-close timer so it doesn't
    // linger past the end of the test.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });
}
