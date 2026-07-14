import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:phoenix_platform/main.dart';

void main() {
  testWidgets('Phoenix app starts without crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PhoenixApp());

    // Allow animations to settle
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify the app renders by checking for navigation elements
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
