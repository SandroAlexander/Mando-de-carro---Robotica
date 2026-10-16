import 'package:flutter/material.dart';
import '../controllers/car_controller.dart';
import '../theme/cyber_theme.dart';

class SettingsDialog extends StatefulWidget {
  final CarController controller;

  const SettingsDialog({
    super.key,
    required this.controller,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late double _intervalMs;
  late double _deadbandDegrees;

  @override
  void initState() {
    super.initState();
    _intervalMs = widget.controller.transmissionIntervalMs.toDouble();
    _deadbandDegrees = widget.controller.sensor.deadbandDegrees;
  }

  @override
  Widget build(BuildContext context) {
    final hz = (1000 / _intervalMs).toStringAsFixed(1);

    return AlertDialog(
      backgroundColor: const Color(0xFF10132B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: CyberTheme.purpleBlue.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      title: const Row(
        children: [
          Icon(Icons.tune, color: CyberTheme.aquamarine, size: 22),
          SizedBox(width: 12),
          GradientText(
            'Control Settings',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transmission Rate Section
            const Text(
              'Continuous Stream Rate',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Controls how frequently WASD packets are streamed to HC-06.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_intervalMs.toInt()} ms per packet',
                  style: const TextStyle(
                    color: CyberTheme.aquamarine,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$hz packets/sec (Hz)',
                  style: const TextStyle(
                    color: CyberTheme.purpleBlueBright,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: CyberTheme.aquamarine,
                inactiveTrackColor: CyberTheme.purpleBlue.withValues(alpha: 0.3),
                thumbColor: CyberTheme.aquamarine,
                overlayColor: CyberTheme.aquamarine.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: _intervalMs,
                min: 25.0,
                max: 200.0,
                divisions: 35,
                onChanged: (val) {
                  setState(() => _intervalMs = val);
                  widget.controller.setTransmissionInterval(val.toInt());
                },
              ),
            ),

            const Divider(color: Colors.white12, height: 32),

            // Tilt Deadband Section
            const Text(
              'Tilt Neutral Deadzone',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Angle required to tilt the phone before movement activates.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '±${_deadbandDegrees.toInt()}° deadzone',
              style: const TextStyle(
                color: CyberTheme.aquamarine,
                fontWeight: FontWeight.bold,
              ),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: CyberTheme.aquamarine,
                inactiveTrackColor: CyberTheme.purpleBlue.withValues(alpha: 0.3),
                thumbColor: CyberTheme.aquamarine,
                overlayColor: CyberTheme.aquamarine.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: _deadbandDegrees,
                min: 5.0,
                max: 30.0,
                divisions: 25,
                onChanged: (val) {
                  setState(() => _deadbandDegrees = val);
                  widget.controller.sensor.deadbandDegrees = val;
                },
              ),
            ),

            const Divider(color: Colors.white12, height: 32),

            // Hardware Tips Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF161A3D),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: CyberTheme.purpleBlue.withValues(alpha: 0.3),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.memory_rounded, size: 16, color: CyberTheme.aquamarine),
                      SizedBox(width: 8),
                      Text(
                        'HC-06 & Arduino Tips:',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    '• Default baud rate for HC-06 is 9600.\n'
                    '• Commands sent: "w" (Fwd), "s" (Rev), "a" (Left), "d" (Right).\n'
                    '• Stop on silence: Motors halt automatically when packets stop.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              gradient: CyberTheme.horizontalGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: CyberTheme.aquaGlow,
            ),
            child: const Text(
              'DONE',
              style: TextStyle(
                color: Color(0xFF060711),
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
