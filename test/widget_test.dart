import 'package:flutter_test/flutter_test.dart';
import 'package:field_time/main.dart';

void main() {
  testWidgets('App renders test', (WidgetTester tester) async {
    await tester.pumpWidget(const FieldTimeApp());
    expect(find.byType(FieldTimeApp), findsOneWidget);
  });
}
