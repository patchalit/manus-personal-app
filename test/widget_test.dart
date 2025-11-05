import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manus_personal_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ManusPersonalApp());

    // Verify that the app starts with a splash screen
    expect(find.text('Manus Personal App'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
