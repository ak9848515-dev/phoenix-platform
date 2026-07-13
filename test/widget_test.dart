// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:phoenix_platform/main.dart';

void main() {
  testWidgets('Phoenix app starts with dashboard route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PhoenixApp());

    // Allow animations (FadeAnimation, SlideAnimation) to settle
    // so they don't leave pending timers.
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsAtLeastNWidgets(1));

    // The greeting is time-based; check for any recognized variant.
    final hour = DateTime.now().hour;
    if (hour < 12) {
      expect(find.text('Good morning'), findsOneWidget);
    } else if (hour < 17) {
      expect(find.text('Good afternoon'), findsOneWidget);
    } else {
      expect(find.text('Good evening'), findsOneWidget);
    }
  });
}
