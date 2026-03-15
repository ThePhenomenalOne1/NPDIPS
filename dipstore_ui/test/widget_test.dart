import 'package:flutter_test/flutter_test.dart';
import 'package:dipstore_ui/main.dart';

void main() {
  testWidgets('App builds', (tester) async {
    await tester.pumpWidget(const KrdApp());
    // Splash screen might take time or have animations.
    // We just verify it pumps without crashing.
    await tester.pump();
    expect(find.text('KRD BUSINESS HUB'), findsOneWidget);
  });
}
