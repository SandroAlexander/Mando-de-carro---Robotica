import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial_plus/flutter_bluetooth_serial_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/connection_state.dart';

class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  BluetoothConnection? _connection;
  BluetoothDevice? _connectedDevice;
  BluetoothStatus _status = BluetoothStatus.disconnected;
  String _errorMessage = '';

  StreamController<BluetoothStatus> _statusController =
      StreamController<BluetoothStatus>.broadcast();
  Stream<BluetoothStatus> get statusStream {
    if (_statusController.isClosed) {
      _statusController = StreamController<BluetoothStatus>.broadcast();
    }
    return _statusController.stream;
  }

  BluetoothStatus get status => _status;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  String get errorMessage => _errorMessage;

  static const String _prefLastDeviceAddress = 'last_connected_device_address';

  /// Request Bluetooth & Location permissions required for classic Bluetooth on Android
  Future<bool> requestPermissions() async {
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.location,
    ];

    Map<Permission, PermissionStatus> statuses = await permissions.request();
    bool allGranted = true;
    for (var status in statuses.values) {
      if (status.isDenied || status.isPermanentlyDenied) {
        allGranted = false;
      }
    }
    return allGranted;
  }

  /// Get list of paired / bonded Bluetooth devices (HC-06 should already be paired in Android settings)
  Future<List<BluetoothDevice>> getPairedDevices() async {
    try {
      await requestPermissions();
      bool? isEnabled = await FlutterBluetoothSerial.instance.isEnabled;
      if (isEnabled != true) {
        await FlutterBluetoothSerial.instance.requestEnable();
      }
      return await FlutterBluetoothSerial.instance.getBondedDevices();
    } catch (e) {
      _errorMessage = 'Error getting paired devices: $e';
      return [];
    }
  }

  /// Connect to device by MAC address
  Future<bool> connect(BluetoothDevice device) async {
    if (_status == BluetoothStatus.connecting) return false;

    _updateStatus(BluetoothStatus.connecting);
    _errorMessage = '';

    try {
      await requestPermissions();
      await disconnect();

      _connection = await BluetoothConnection.toAddress(device.address);
      _connectedDevice = device;
      _updateStatus(BluetoothStatus.connected);

      // Save as last connected device
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefLastDeviceAddress, device.address);

      // Listen for unexpected disconnect
      _connection!.input.listen(
        (Uint8List data) {
          // incoming data from Arduino (telemetry or debug)
        },
        onDone: () {
          disconnect();
        },
        onError: (error) {
          _errorMessage = 'Connection error: $error';
          disconnect();
        },
      );

      return true;
    } catch (e) {
      _errorMessage =
          'Failed to connect to ${device.name ?? device.address}: $e';
      _updateStatus(BluetoothStatus.error);
      return false;
    }
  }

  /// Attempt auto-reconnect to the last saved device address
  Future<bool> autoConnectLastDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastAddress = prefs.getString(_prefLastDeviceAddress);
      if (lastAddress == null || lastAddress.isEmpty) return false;

      final devices = await getPairedDevices();
      final match = devices.firstWhere(
        (d) => d.address == lastAddress,
        orElse: () => throw Exception('Device not found in paired list'),
      );

      return await connect(match);
    } catch (_) {
      return false;
    }
  }

  /// Send string message (e.g. 'w', 'a', 's', 'd') to HC-06
  bool sendString(String message) {
    if (_connection == null || !_connection!.isConnected) {
      return false;
    }

    try {
      _connection!.output.add(Uint8List.fromList(utf8.encode(message)));
      return true;
    } catch (e) {
      _errorMessage = 'Send error: $e';
      return false;
    }
  }

  /// Disconnect current session
  Future<void> disconnect() async {
    try {
      if (_connection != null) {
        await _connection!.close();
        _connection!.dispose();
        _connection = null;
      }
    } catch (_) {}

    _connectedDevice = null;
    _updateStatus(BluetoothStatus.disconnected);
  }

  void _updateStatus(BluetoothStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
  }

  void dispose() {
    disconnect();
    if (!_statusController.isClosed) {
      _statusController.close();
    }
  }
}
