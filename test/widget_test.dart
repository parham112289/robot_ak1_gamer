import 'package:flutter_test/flutter_test.dart';
import 'package:ak1/main.dart';

void main() {
  testWidgets('AK-1 app starts', (tester) async {
    await tester.pumpWidget(const AK1App());
    expect(find.text('AK-1 🤖'), findsOneWidget);
  });
}
