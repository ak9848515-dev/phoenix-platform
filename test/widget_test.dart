import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:phoenix_platform/main.dart';

void main() {
  testWidgets('Phoenix app renders without crashing', (
    WidgetTester tester,
  ) async {
    // The full app requires async initialization (Firebase, bootstrap, etc.)
    // that cannot complete in a test environment. This smoke test verifies
    // that the PhoenixApp widget tree builds without throwing synchronously.
    await tester.pumpWidget(const PhoenixApp());

    // Pump a single frame to verify the MaterialApp renders
    await tester.pump();

    // Verify the app renders by checking for navigation elements
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
