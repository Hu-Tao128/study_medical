import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:study_medical/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app builds (finds a Material App or Login Page)
    // Since we don't know exactly what's in Login Page, just checking if it pumps without error is a good start.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
