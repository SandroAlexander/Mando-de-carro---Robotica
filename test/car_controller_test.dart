import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:car_controller/controllers/car_controller.dart';
import 'package:car_controller/models/connection_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('dev.fluttercommunity.plus/sensors/method');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    channel,
    (MethodCall methodCall) async => null,
  );

  group('CarController Unit Tests', () {
    late CarController controller;

    setUp(() {
      controller = CarController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('Initial state is idle and dpad mode', () {
      expect(controller.controlMode, ControlMode.dpad);
      expect(controller.activeCommand, isNull);
      expect(controller.transmissionIntervalMs, 50);
      expect(controller.packetsSentTotal, 0);
    });

    test('setCommand updates activeCommand correctly', () {
      controller.setCommand('w');
      expect(controller.activeCommand, 'w');

      controller.setCommand('a');
      expect(controller.activeCommand, 'a');

      controller.clearCommand();
      expect(controller.activeCommand, isNull);
    });

    test('Emergency stop immediately halts command', () {
      controller.setCommand('w');
      expect(controller.activeCommand, 'w');

      controller.emergencyStop();
      expect(controller.activeCommand, isNull);
    });

    test('setTransmissionInterval enforces limits', () {
      controller.setTransmissionInterval(10);
      expect(controller.transmissionIntervalMs, 20); // clamped to min 20

      controller.setTransmissionInterval(300);
      expect(controller.transmissionIntervalMs, 250); // clamped to max 250

      controller.setTransmissionInterval(80);
      expect(controller.transmissionIntervalMs, 80);
    });

    test('Switching control mode resets active command', () {
      controller.setCommand('w');
      expect(controller.activeCommand, 'w');

      controller.setControlMode(ControlMode.tilt);
      expect(controller.controlMode, ControlMode.tilt);
      expect(controller.activeCommand, isNull);

      controller.setControlMode(ControlMode.dpad);
      expect(controller.controlMode, ControlMode.dpad);
    });
  });
}
