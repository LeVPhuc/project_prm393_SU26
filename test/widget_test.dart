import 'package:flutter_test/flutter_test.dart';
import 'package:appvunven/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const AppVunVen());
    expect(find.byType(AppVunVen), findsOneWidget);
  });
}
