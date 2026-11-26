import 'package:flutter_test/flutter_test.dart';
import 'package:younme_mobile/main.dart';

void main() {
  testWidgets('YoUnMeApp basic smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const YoUnMeApp());
    expect(find.byType(YoUnMeApp), findsOneWidget);
  });
}
