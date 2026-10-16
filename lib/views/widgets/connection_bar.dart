import 'package:flutter/material.dart';
import '../../controllers/car_controller.dart';
import '../../models/connection_state.dart';
import '../../theme/cyber_theme.dart';
import 'device_selection_dialog.dart';

class ConnectionBar extends StatelessWidget {
  final CarController controller;

  const ConnectionBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final status = controller.bluetooth.status;
    final device = controller.bluetooth.connectedDevice;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case BluetoothStatus.connected:
        statusColor = CyberTheme.aquamarine;
        statusText = device?.name ?? 'HC-06 ONLINE';
        statusIcon = Icons.bluetooth_connected;
        break;
      case BluetoothStatus.connecting:
        statusColor = const Color(0xFFFFD600);
        statusText = 'SYNCING LINK...';
        statusIcon = Icons.bluetooth_searching;
        break;
      case BluetoothStatus.error:
        statusColor = const Color(0xFFFF1744);
        statusText = 'LINK FAILURE';
        statusIcon = Icons.bluetooth_disabled;
        break;
      case BluetoothStatus.disconnected:
        statusColor = CyberTheme.purpleBlueBright;
        statusText = 'HC-06 OFFLINE';
        statusIcon = Icons.bluetooth;
        break;
    }

    final isConnected = status == BluetoothStatus.connected;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF10132B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isConnected
              ? CyberTheme.aquamarine.withValues(alpha: 0.6)
              : CyberTheme.purpleBlue.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isConnected
                ? CyberTheme.aquamarine.withValues(alpha: 0.2)
                : CyberTheme.purpleBlue.withValues(alpha: 0.15),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status Icon Orb
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: isConnected
                  ? CyberTheme.primaryGradient
                  : LinearGradient(
                      colors: [
                        statusColor.withValues(alpha: 0.25),
                        const Color(0xFF1A1A3A),
                      ],
                    ),
              shape: BoxShape.circle,
              boxShadow: isConnected ? CyberTheme.aquaGlow : [],
            ),
            child: Icon(
              statusIcon,
              color: isConnected ? const Color(0xFF060711) : statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Status & Device Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor,
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.8),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: isConnected ? CyberTheme.aquamarine : Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1.1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  device != null
                      ? 'MAC: ${device.address}'
                      : 'Tap to connect HC-06 Bluetooth module',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Action Button
          if (isConnected)
            IconButton(
              icon: const Icon(Icons.link_off, color: Color(0xFFFF5252)),
              tooltip: 'Disconnect',
              onPressed: () => controller.bluetooth.disconnect(),
            )
          else
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => DeviceSelectionDialog(
                    bluetoothService: controller.bluetooth,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: CyberTheme.horizontalGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: CyberTheme.aquaGlow,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bluetooth, size: 16, color: Color(0xFF060711)),
                    SizedBox(width: 6),
                    Text(
                      'CONNECT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF060711),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
