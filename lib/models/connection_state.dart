enum BluetoothStatus {
  disconnected,
  connecting,
  connected,
  error,
}

enum ControlMode {
  dpad,
  tilt,
}

class CarTelemetry {
  final int packetsSent;
  final double packetsPerSecond;
  final String? lastCommand;
  final double pitch;
  final double roll;

  const CarTelemetry({
    this.packetsSent = 0,
    this.packetsPerSecond = 0.0,
    this.lastCommand,
    this.pitch = 0.0,
    this.roll = 0.0,
  });
}
