import 'package:flutter_test/flutter_test.dart';
import 'package:robot_ak1/main.dart';

void main() {
  testWidgets('AK-1 app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const RobotAk1App());
    expect(find.text('ربات AK-1'), findsOneWidget);
    expect(find.text('تصویر زنده'), findsOneWidget);
    expect(find.text('بازی هوشمند'), findsOneWidget);
    expect(find.text('اتوماسیون هوشمند'), findsOneWidget);
    expect(find.text('کنترل لپتاپ'), findsOneWidget);
  });
}
