import 'package:flutter_test/flutter_test.dart';
import 'package:oss/main.dart';

void main() {
  testWidgets('renders home screen via router', (tester) async {
    await tester.pumpWidget(const OssApp());
    await tester.pumpAndSettle();
    expect(find.text('Home (Sprint 1)'), findsOneWidget);
  });
}
