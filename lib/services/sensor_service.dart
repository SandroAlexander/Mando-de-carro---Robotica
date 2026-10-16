import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class SensorReading {
  final double pitch; // Forward/Backward tilt in degrees (-90 to +90)
  final double roll; // Left/Right tilt in degrees (-90 to +90)
  final String? mappedCommand; // e.g. 'w', 'ww', 'www', 's', etc., or null

  const SensorReading({
    required this.pitch,
    required this.roll,
    this.mappedCommand,
  });
}

class SensorService {
  static final SensorService _instance = SensorService._internal();
  factory SensorService() => _instance;
  SensorService._internal();

  StreamSubscription<AccelerometerEvent>? _subscription;
  StreamController<SensorReading> _readingController =
      StreamController<SensorReading>.broadcast();
  Stream<SensorReading> get readingStream {
    if (_readingController.isClosed) {
      _readingController = StreamController<SensorReading>.broadcast();
    }
    return _readingController.stream;
  }

  double deadbandDegrees = 14.0; // degrees required to activate direction
  double pitchOffset = 0.0; // Calibration offset for comfortable wrist angle
  double rollOffset = 0.0;

  double _lastPitch = 0.0;
  double _lastRoll = 0.0;

  bool _isActive = false;
  bool get isActive => _isActive;

  void startListening() {
    if (_isActive) return;
    _isActive = true;

    try {
      _subscription =
          accelerometerEventStream(
            samplingPeriod: const Duration(milliseconds: 25),
          ).listen((AccelerometerEvent event) {
            _processEvent(event);
          }, onError: (_) {});
    } catch (_) {}
  }

  void stopListening() {
    _isActive = false;
    _subscription?.cancel();
    _subscription = null;
    if (!_readingController.isClosed) {
      _readingController.add(
        const SensorReading(pitch: 0.0, roll: 0.0, mappedCommand: null),
      );
    }
  }

  /// Calibrate current phone position as neutral (0, 0)
  void calibrateZero() {
    pitchOffset = _lastPitch + pitchOffset;
    rollOffset = _lastRoll + rollOffset;
  }

  /// Reset calibration offsets back to factory horizontal flat
  void resetCalibration() {
    pitchOffset = 0.0;
    rollOffset = 0.0;
  }

  /// Maps an angle magnitude to a speed level 1-3.
  /// Speed levels:
  ///   1 = low  (1 char):  deadband .. deadband*1.6
  ///   2 = med  (2 chars): deadband*1.6 .. deadband*2.4
  ///   3 = high (3 chars): deadband*2.4+
  int _speedLevel(double angleMagnitude) {
    final t1 = deadbandDegrees * 1.6;
    final t2 = deadbandDegrees * 2.4;
    if (angleMagnitude >= t2) return 3;
    if (angleMagnitude >= t1) return 2;
    return 1;
  }

  void _processEvent(AccelerometerEvent event) {
    // Phone in portrait orientation:
    // event.x: right (+), left (-)
    // event.y: top (+), bottom (-)
    // event.z: face up (+)

    // Calculate raw pitch and roll in degrees
    final double rawPitch =
        atan2(-event.y, sqrt(event.x * event.x + event.z * event.z)) *
        (180.0 / pi);
    final double rawRoll =
        atan2(event.x, sqrt(event.y * event.y + event.z * event.z)) *
        (180.0 / pi);

    final double calibratedPitch = rawPitch - pitchOffset;
    final double calibratedRoll = rawRoll - rollOffset;

    _lastPitch = calibratedPitch;
    _lastRoll = calibratedRoll;

    // Map to dominant direction based on deadband + speed level
    String? command;
    final double absPitch = calibratedPitch.abs();
    final double absRoll = calibratedRoll.abs();

    if (absPitch >= deadbandDegrees || absRoll >= deadbandDegrees) {
      // Determine dominant axis
      if (absPitch > absRoll) {
        // Forward / Backward
        if (calibratedPitch > deadbandDegrees) {
          // Tilting phone top edge away from user -> Forward
          final level = _speedLevel(absPitch);
          command = 'w' * level * level + 'x';
        } else if (calibratedPitch < -deadbandDegrees) {
          // Tilting phone towards user -> Backward
          final level = _speedLevel(absPitch);
          command = 's' * level * level + 'x';
        }
      } else {
        // Left / Right
        if (calibratedRoll > deadbandDegrees) {
          // Tilting phone right edge down -> Left
          final level = _speedLevel(absRoll);
          command = 'd' * level * level + 'x';
        } else if (calibratedRoll < -deadbandDegrees) {
          // Tilting phone left edge down -> Right
          final level = _speedLevel(absRoll);
          command = 'a' * level * level + 'x';
        }
      }
    }

    _readingController.add(
      SensorReading(
        pitch: calibratedPitch,
        roll: calibratedRoll,
        mappedCommand: command,
      ),
    );
  }

  void dispose() {
    _isActive = false;
    _subscription?.cancel();
    _subscription = null;
    if (!_readingController.isClosed) {
      _readingController.close();
    }
  }
}
