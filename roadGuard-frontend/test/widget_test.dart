import 'package:flutter_test/flutter_test.dart';

import 'package:roadguard_frontend/main.dart';

void main() {
  testWidgets('RoadGuard app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const RoadGuardApp());

    expect(find.text('RoadGuard'), findsOneWidget);
  });
}
