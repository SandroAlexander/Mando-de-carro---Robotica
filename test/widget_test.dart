import 'package:flutter_test/flutter_test.dart';
import 'package:car_controller/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App renders home screen with control modes', (WidgetTester tester) async {
    await tester.pumpWidget(const ArduinoCarApp());

    // Verify main components are present
    expect(find.text('ARDUINO CAR'), findsOneWidget);
    expect(find.text('TOUCH D-PAD'), findsOneWidget);
    expect(find.text('TILT / ACCEL'), findsOneWidget);
    expect(find.text('EMERGENCY STOP'), findsOneWidget);
  });
}
