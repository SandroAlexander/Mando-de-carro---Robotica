import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial_plus/flutter_bluetooth_serial_plus.dart';
import '../../services/bluetooth_service.dart';
import '../../theme/cyber_theme.dart';

class DeviceSelectionDialog extends StatefulWidget {
  final BluetoothService bluetoothService;

  const DeviceSelectionDialog({
    super.key,
    required this.bluetoothService,
  });

  @override
  State<DeviceSelectionDialog> createState() => _DeviceSelectionDialogState();
}

class _DeviceSelectionDialogState extends State<DeviceSelectionDialog> {
  List<BluetoothDevice> _devices = [];
  bool _isLoading = true;
  String? _connectingAddress;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    setState(() => _isLoading = true);
    final devices = await widget.bluetoothService.getPairedDevices();
    if (mounted) {
      setState(() {
        _devices = devices;
        _isLoading = false;
      });
    }
  }

  Future<void> _connectTo(BluetoothDevice device) async {
    setState(() => _connectingAddress = device.address);
    final success = await widget.bluetoothService.connect(device);
    if (mounted) {
      setState(() => _connectingAddress = null);
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: CyberTheme.aquamarine),
                const SizedBox(width: 10),
                Text('Connected to ${device.name ?? device.address}'),
              ],
            ),
            backgroundColor: const Color(0xFF10132B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: CyberTheme.aquamarine),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.bluetoothService.errorMessage.isNotEmpty
                ? widget.bluetoothService.errorMessage
                : 'Failed to connect to ${device.name ?? device.address}'),
            backgroundColor: const Color(0xFFD50000),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF10132B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: CyberTheme.purpleBlue.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: CyberTheme.primaryGradient,
            ),
            child: const Icon(Icons.bluetooth_searching, color: Color(0xFF060711), size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: GradientText(
              'Select HC-06 Module',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: CyberTheme.aquamarine, size: 20),
            onPressed: _isLoading ? null : _loadDevices,
            tooltip: 'Refresh paired devices',
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF161A3D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CyberTheme.aquamarine.withValues(alpha: 0.35),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: CyberTheme.aquamarine, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pair your HC-06 in phone Bluetooth settings (PIN: 1234 or 0000) first.',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(color: CyberTheme.aquamarine),
                ),
              )
            else if (_devices.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'No paired Bluetooth devices found.\nPlease pair your HC-06 module first in Android Settings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _devices.length,
                  separatorBuilder: (_, _) => const Divider(color: Colors.white10),
                  itemBuilder: (context, index) {
                    final device = _devices[index];
                    final isConnecting = _connectingAddress == device.address;
                    final isCurrent = widget.bluetoothService.connectedDevice?.address == device.address;
                    final isHC06 = (device.name ?? '').toUpperCase().contains('HC-06') ||
                                   (device.name ?? '').toUpperCase().contains('HC-05');

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: isCurrent
                            ? CyberTheme.aquamarine.withValues(alpha: 0.25)
                            : isHC06
                                ? CyberTheme.purpleBlue.withValues(alpha: 0.3)
                                : Colors.white10,
                        child: Icon(
                          Icons.bluetooth,
                          color: isCurrent
                              ? CyberTheme.aquamarine
                              : isHC06
                                  ? CyberTheme.purpleBlueBright
                                  : Colors.white60,
                        ),
                      ),
                      title: Text(
                        device.name ?? 'Unknown Device',
                        style: TextStyle(
                          color: isCurrent
                              ? CyberTheme.aquamarine
                              : isHC06
                                  ? Colors.white
                                  : Colors.white70,
                          fontWeight: isHC06 ? FontWeight.w900 : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        device.address,
                        style: const TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                      trailing: isConnecting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: CyberTheme.aquamarine,
                              ),
                            )
                          : isCurrent
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: CyberTheme.aquamarine.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: CyberTheme.aquamarine),
                                  ),
                                  child: const Text(
                                    'Connected',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: CyberTheme.aquamarine,
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () => _connectTo(device),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                    decoration: BoxDecoration(
                                      gradient: isHC06 ? CyberTheme.horizontalGradient : null,
                                      color: isHC06 ? null : const Color(0xFF1E234A),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: isHC06 ? CyberTheme.aquaGlow : [],
                                    ),
                                    child: Text(
                                      'CONNECT',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: isHC06 ? const Color(0xFF060711) : Colors.white,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CLOSE', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
