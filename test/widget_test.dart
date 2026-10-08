import 'package:flutter_test/flutter_test.dart';
import 'package:flingshot_game/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    // Just verify the app widget can be constructed.
    // Full SceneView needs Flutter GPU, so we only smoke-test the root widget.
    await tester.pumpWidget(const FlingShotApp());
    expect(find.byType(FlingShotApp), findsOneWidget);
  });
}
