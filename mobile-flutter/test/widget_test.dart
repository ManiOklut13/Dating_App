import 'package:flutter_test/flutter_test.dart';
import 'package:younme_mobile/main.dart';

void main() {
  testWidgets('YoUnMe app smoke test builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const YoUnMeApp());
    expect(find.byType(YoUnMeApp), findsOneWidget);
  });
}

