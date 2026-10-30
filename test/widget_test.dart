import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intima/app/app.dart';

void main() {
  testWidgets('IntimaApp initial render smoke test', (WidgetTester tester) async {
    final container = ProviderContainer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const IntimaApp(),
      ),
    );

    // Initial frame
    await tester.pump();
    expect(find.byType(IntimaApp), findsOneWidget);
  });
}
