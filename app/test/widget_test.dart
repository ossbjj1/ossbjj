import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oss/main.dart';

void main() {
  testWidgets('renders home screen via router', (tester) async {
    await tester.pumpWidget(const OssApp());
    await tester.pumpAndSettle();
    // Expect Home screen loaded (AppBar)
    expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);
  });
}
