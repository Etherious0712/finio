import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finio/app.dart';

void main() {
  testWidgets('App smoke test — Dashboard renders', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: FinioApp()),
    );
    await tester.pump();

    expect(find.text('Finio'), findsOneWidget);
  });
}
