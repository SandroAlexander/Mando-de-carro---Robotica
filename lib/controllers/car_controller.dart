import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/connection_state.dart';
import '../services/bluetooth_service.dart';
import '../services/sensor_service.dart';

class CarController extends ChangeNotifier {
  final BluetoothService _bluetoothService = BluetoothService();
  final SensorService _sensorService = SensorService();

  ControlMode _controlMode = ControlMode.dpad;
  ControlMode get controlMode => _controlMode;

  String? _activeCommand;
  String? get activeCommand => _activeCommand;

  /// Returns the base direction letter for display (strips speed repetition).
  /// e.g. 'ww' -> 'w', 'aaa' -> 'a', 'x' -> 'x', null -> null
  String? get activeCommandDisplay {
    final cmd = _activeCommand;
    if (cmd == null || cmd.isEmpty) return null;
    return cmd[0];
  }

  int _transmissionIntervalMs = 50; // default 50ms = 20 Hz
  int get transmissionIntervalMs => _transmissionIntervalMs;

  Timer? _streamTimer;
  Timer? _rateCalculatorTimer;
  StreamSubscription<SensorReading>? _sensorSubscription;

  int _packetsSentTotal = 0;
  int _packetsInCurrentSecond = 0;
  double _packetsPerSecond = 0.0;
  double _currentPitch = 0.0;
  double _currentRoll = 0.0;

  int get packetsSentTotal => _packetsSentTotal;
  double get packetsPerSecond => _packetsPerSecond;
  double get currentPitch => _currentPitch;
  double get currentRoll => _currentRoll;

  BluetoothService get bluetooth => _bluetoothService;
  SensorService get sensor => _sensorService;

  bool _isDisposed = false;
  StreamSubscription? _bluetoothSubscription;

  CarController() {
    // Periodically update packet transmission rate (Hz) for telemetry display
    _rateCalculatorTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      _packetsPerSecond = _packetsInCurrentSecond.toDouble();
      _packetsInCurrentSecond = 0;
      notifyListeners();
    });

    // Listen to bluetooth status changes to trigger UI rebuilds
    _bluetoothSubscription = _bluetoothService.statusStream.listen((_) {
      if (!_isDisposed) {
        notifyListeners();
      }
    });
  }

  /// Switch between D-Pad (Touch) and Tilt (Accelerometer) modes
  void setControlMode(ControlMode mode) {
    if (_controlMode == mode) return;

    // Reset current command when switching modes
    clearCommand();

    _controlMode = mode;
    if (_controlMode == ControlMode.tilt) {
      _sensorService.startListening();
      _sensorSubscription = _sensorService.readingStream.listen((reading) {
        _currentPitch = reading.pitch;
        _currentRoll = reading.roll;
        if (_controlMode == ControlMode.tilt) {
          final cmd = reading.mappedCommand;
          if (cmd == null && _activeCommand != null && _activeCommand != 'x') {
            // Returning to neutral: send one stop packet then go quiet
            _setTiltNeutral();
          } else if (cmd != null) {
            setCommand(cmd);
          }
        }
      });
    } else {
      _sensorSubscription?.cancel();
      _sensorSubscription = null;
      _sensorService.stopListening();
      _currentPitch = 0.0;
      _currentRoll = 0.0;
    }

    notifyListeners();
  }

  /// Set the continuous active command ('w', 'a', 's', 'd', or null to stop)
  void setCommand(String? command) {
    if (_activeCommand == command) return;

    _activeCommand = command;
    _streamTimer?.cancel();
    _streamTimer = null;

    if (command != null && command.isNotEmpty) {
      // Send first packet immediately for minimal latency
      _sendPacket(command);

      // Start periodic packet stream
      _streamTimer = Timer.periodic(
        Duration(milliseconds: _transmissionIntervalMs),
        (_) => _sendPacket(command),
      );
    } else {
      // Stop on silence: no packets sent when neutral/released
    }

    notifyListeners();
  }

  /// Tilt neutral: send one stop packet then go quiet (no continuous 'x' stream)
  void _setTiltNeutral() {
    _streamTimer?.cancel();
    _streamTimer = null;
    _activeCommand = null;
    // Send a single stop burst so the Arduino halts immediately
    _sendPacket('x');
    notifyListeners();
  }

  /// Clear any active command and halt packet transmission immediately
  void clearCommand() {
    setCommand("x");
  }

  /// Emergency Stop: clears all commands, cancels stream timers immediately
  void emergencyStop() {
    _streamTimer?.cancel();
    _streamTimer = null;
    _activeCommand = "x";
    notifyListeners();
  }

  /// Internal packet sender
  void _sendPacket(String char) {
    if (_bluetoothService.status != BluetoothStatus.connected) return;

    final success = _bluetoothService.sendString(char);
    if (success) {
      _packetsSentTotal++;
      _packetsInCurrentSecond++;
    }
  }

  /// Update transmission interval (e.g. 30ms - 150ms)
  void setTransmissionInterval(int ms) {
    if (ms < 20) ms = 20;
    if (ms > 250) ms = 250;
    _transmissionIntervalMs = ms;

    // If currently streaming, restart timer with new interval
    if (_activeCommand != null) {
      _streamTimer?.cancel();
      _streamTimer = Timer.periodic(
        Duration(milliseconds: _transmissionIntervalMs),
        (_) => _sendPacket(_activeCommand!),
      );
    }
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _streamTimer?.cancel();
    _rateCalculatorTimer?.cancel();
    _sensorSubscription?.cancel();
    _bluetoothSubscription?.cancel();
    _sensorService.dispose();
    _bluetoothService.dispose();
    super.dispose();
  }
}
