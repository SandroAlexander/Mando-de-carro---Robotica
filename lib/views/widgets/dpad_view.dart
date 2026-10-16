import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/car_controller.dart';
import '../../theme/cyber_theme.dart';

class DPadView extends StatelessWidget {
  final CarController controller;

  const DPadView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final activeCommand = controller.activeCommand;

    return Center(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0D0F24),
            border: Border.all(
              color: CyberTheme.purpleBlue.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: CyberTheme.purpleBlue.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.7),
                blurRadius: 20,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Concentric Sci-Fi Radar Rings & Crosshairs
              CustomPaint(
                size: const Size(double.infinity, double.infinity),
                painter: _DPadArenaPainter(),
              ),

              // Center Status Orb showing active command
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF131738),
                  border: Border.all(
                    color: activeCommand != null
                        ? CyberTheme.aquamarine
                        : CyberTheme.purpleBlue.withValues(alpha: 0.4),
                    width: 2.5,
                  ),
                  boxShadow: activeCommand != null
                      ? CyberTheme.dualGlow
                      : [
                          BoxShadow(
                            color: CyberTheme.purpleBlue.withValues(alpha: 0.2),
                            blurRadius: 16,
                          ),
                        ],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (activeCommand != null)
                        GradientText(
                          activeCommand.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        )
                      else
                        const Text(
                          'READY',
                          style: TextStyle(
                            color: Colors.white24,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        activeCommand != null
                            ? '${controller.packetsPerSecond.toInt()} Hz'
                            : 'STANDBY',
                        style: TextStyle(
                          color: activeCommand != null
                              ? CyberTheme.aquamarine
                              : Colors.white24,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Forward Button (W)
              Align(
                alignment: const Alignment(0, -0.84),
                child: _CyberDirectionButton(
                  icon: Icons.keyboard_arrow_up_rounded,
                  label: 'W',
                  subLabel: 'FWD',
                  isActive: activeCommand == 'w',
                  onPress: () => _handlePress('w'),
                  onRelease: _handleRelease,
                ),
              ),

              // Backward Button (S)
              Align(
                alignment: const Alignment(0, 0.84),
                child: _CyberDirectionButton(
                  icon: Icons.keyboard_arrow_down_rounded,
                  label: 'S',
                  subLabel: 'REV',
                  isActive: activeCommand == 's',
                  onPress: () => _handlePress('s'),
                  onRelease: _handleRelease,
                ),
              ),

              // Left Button (A)
              Align(
                alignment: const Alignment(-0.84, 0),
                child: _CyberDirectionButton(
                  icon: Icons.keyboard_arrow_left_rounded,
                  label: 'A',
                  subLabel: 'LEFT',
                  isActive: activeCommand == 'd',
                  onPress: () => _handlePress('d'),
                  onRelease: _handleRelease,
                ),
              ),

              // Right Button (D)
              Align(
                alignment: const Alignment(0.84, 0),
                child: _CyberDirectionButton(
                  icon: Icons.keyboard_arrow_right_rounded,
                  label: 'D',
                  subLabel: 'RIGHT',
                  isActive: activeCommand == 'a',
                  onPress: () => _handlePress('a'),
                  onRelease: _handleRelease,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handlePress(String cmd) {
    HapticFeedback.lightImpact();
    controller.setCommand(cmd);
  }

  void _handleRelease() {
    controller.clearCommand();
  }
}

class _CyberDirectionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subLabel;
  final bool isActive;
  final VoidCallback onPress;
  final VoidCallback onRelease;

  const _CyberDirectionButton({
    required this.icon,
    required this.label,
    required this.subLabel,
    required this.isActive,
    required this.onPress,
    required this.onRelease,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => onPress(),
      onPointerUp: (_) => onRelease(),
      onPointerCancel: (_) => onRelease(),
      child: AnimatedScale(
        scale: isActive ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            gradient: isActive
                ? CyberTheme.primaryGradient
                : const LinearGradient(
                    colors: [Color(0xFF161A3D), Color(0xFF10132F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isActive
                  ? Colors.white
                  : CyberTheme.aquamarine.withValues(alpha: 0.35),
              width: isActive ? 2.5 : 1.5,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: CyberTheme.aquamarine.withValues(alpha: 0.7),
                      blurRadius: 22,
                      spreadRadius: 3,
                    ),
                    BoxShadow(
                      color: CyberTheme.purpleBlue.withValues(alpha: 0.6),
                      blurRadius: 22,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: isActive
                    ? const Color(0xFF060711)
                    : CyberTheme.aquamarine,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isActive ? const Color(0xFF060711) : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    subLabel,
                    style: TextStyle(
                      color: isActive
                          ? const Color(0xFF060711).withValues(alpha: 0.7)
                          : CyberTheme.purpleBlueBright,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DPadArenaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Subtle Sci-Fi grid rings
    final ringPaint = Paint()
      ..color = CyberTheme.purpleBlue.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final aquaRingPaint = Paint()
      ..color = CyberTheme.aquamarine.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius * 0.42, ringPaint);
    canvas.drawCircle(center, radius * 0.74, aquaRingPaint);

    // Crosshair axis lines
    final axisPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(center.dx - radius + 25, center.dy),
      Offset(center.dx + radius - 25, center.dy),
      axisPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius + 25),
      Offset(center.dx, center.dy + radius - 25),
      axisPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
