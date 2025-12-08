import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:session_lock/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SessionLockApp());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
