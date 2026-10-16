import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/car_controller.dart';
import '../../theme/cyber_theme.dart';

class EmergencyStopButton extends StatefulWidget {
  final CarController controller;

  const EmergencyStopButton({
    super.key,
    required this.controller,
  });

  @override
  State<EmergencyStopButton> createState() => _EmergencyStopButtonState();
}

class _EmergencyStopButtonState extends State<EmergencyStopButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _triggerEmergencyStop(context);
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: CyberTheme.hazardGradient,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFFF8A80),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF1744).withValues(alpha: 0.5),
                  blurRadius: 18,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: CyberTheme.purpleBlue.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.dangerous_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                SizedBox(width: 10),
                Text(
                  'EMERGENCY STOP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _triggerEmergencyStop(BuildContext context) {
    HapticFeedback.heavyImpact();
    widget.controller.emergencyStop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'EMERGENCY STOP ACTIVATED — Motors Halted',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFD50000),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }
}
