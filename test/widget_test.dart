import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomatev01/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RoommateApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}