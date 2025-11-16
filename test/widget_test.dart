// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jobreport/main.dart';

void main() {
  testWidgets('App starts and displays Login Screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const JobReportApp());

    // Verify that the Login Screen is shown.
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);

    // Verify that a login button exists.
    expect(find.widgetWithText(ElevatedButton, 'LOGIN'), findsOneWidget);
  });
}
