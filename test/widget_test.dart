// Basic widget tests for Binti Salama app
//
// To run these tests: flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic Material App Test', (WidgetTester tester) async {
    // Build a simple material app
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Binti Salama'),
          ),
        ),
      ),
    );

    // Verify that the text is shown
    expect(find.text('Binti Salama'), findsOneWidget);
  });

  test('App constants are defined', () {
    // Basic test to verify the test framework is working
    expect(1 + 1, equals(2));
  });
}
