import 'package:flutter/material.dart';
import '../../controllers/car_controller.dart';
import '../../theme/cyber_theme.dart';

class TiltView extends StatelessWidget {
  final CarController controller;

  const TiltView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final pitch = controller.currentPitch;
    final roll = controller.currentRoll;
    // Use display command (base letter only) so 'ww'/'www' all show as 'w'
    final command = controller.activeCommandDisplay;
    final deadband = controller.sensor.deadbandDegrees;

    // Speed level for indicator badges (1=low, 2=med, 3=high)
    final rawCmd = controller.activeCommand;
    final int speedLevel = rawCmd != null && rawCmd.length > 1 ? rawCmd.length : 1;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Angle readout telemetry HUD chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AngleChip(
                label: 'PITCH (Nose)',
                value: '${pitch.toStringAsFixed(1)}°',
                isEngaged: (command == 'w' || command == 's'),
              ),
              _AngleChip(
                label: 'ROLL (Bank)',
                value: '${roll.toStringAsFixed(1)}°',
                isEngaged: (command == 'a' || command == 'd'),
              ),
            ],
          ),
        ),

        // Gyroscopic Horizon Arena — wrapped in RepaintBoundary so only the
        // canvas itself repaints instead of the entire widget tree.
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0D0F24),
                    border: Border.all(
                      color: CyberTheme.purpleBlue.withValues(alpha: 0.45),
                      width: 2,
                    ),
                    // Reduced to a single shadow — dual shadows at 40Hz were expensive
                    boxShadow: [
                      BoxShadow(
                        color: CyberTheme.purpleBlue.withValues(alpha: 0.2),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: RepaintBoundary(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Canvas: static grid + deadband drawn only when those change;
                        // bubble repaints every sensor tick (25ms).
                        CustomPaint(
                          size: const Size(double.infinity, double.infinity),
                          painter: _HorizonPainter(
                            pitch: pitch,
                            roll: roll,
                            deadband: deadband,
                            isEngaged: command != null,
                          ),
                        ),

                        // Static directional badges — plain containers, no animation
                        Align(
                          alignment: const Alignment(0, -0.92),
                          child: _TiltDirectionBadge(
                            label: 'FWD',
                            icon: Icons.keyboard_arrow_up_rounded,
                            isActive: command == 'w',
                            speedLevel: speedLevel,
                          ),
                        ),
                        Align(
                          alignment: const Alignment(0, 0.92),
                          child: _TiltDirectionBadge(
                            label: 'REV',
                            icon: Icons.keyboard_arrow_down_rounded,
                            isActive: command == 's',
                            speedLevel: speedLevel,
                          ),
                        ),
                        Align(
                          alignment: const Alignment(-0.96, 0),
                          child: _TiltDirectionBadge(
                            label: 'LEFT',
                            icon: Icons.keyboard_arrow_left_rounded,
                            isActive: command == 'a',
                            speedLevel: speedLevel,
                          ),
                        ),
                        Align(
                          alignment: const Alignment(0.96, 0),
                          child: _TiltDirectionBadge(
                            label: 'RIGHT',
                            icon: Icons.keyboard_arrow_right_rounded,
                            isActive: command == 'd',
                            speedLevel: speedLevel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Calibration Controls
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  controller.sensor.calibrateZero();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Neutral calibrated to current phone position'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131738),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: CyberTheme.aquamarine.withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.my_location, size: 16, color: CyberTheme.aquamarine),
                      SizedBox(width: 8),
                      Text(
                        'Set Current Angle as Neutral (0°)',
                        style: TextStyle(
                          color: CyberTheme.aquamarine,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF131738),
                  border: Border.all(
                    color: CyberTheme.purpleBlue.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.restart_alt, color: Colors.white60, size: 20),
                  tooltip: 'Reset calibration to flat',
                  onPressed: () => controller.sensor.resetCalibration(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Angle Chip — only redraws when isEngaged toggles, not on every sensor tick
// ─────────────────────────────────────────────────────────────────────────────
class _AngleChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isEngaged;

  const _AngleChip({
    required this.label,
    required this.value,
    required this.isEngaged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111432),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isEngaged
              ? CyberTheme.aquamarine
              : CyberTheme.purpleBlue.withValues(alpha: 0.35),
          width: isEngaged ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 9,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: isEngaged ? CyberTheme.aquamarine : Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Direction badge — no AnimatedContainer (saves layout passes at 40 Hz)
// speedLevel dots indicate current throttle intensity
// ─────────────────────────────────────────────────────────────────────────────
class _TiltDirectionBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final int speedLevel;

  const _TiltDirectionBadge({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.speedLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? CyberTheme.aquamarine : const Color(0xFF121535),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive
              ? CyberTheme.aquamarine
              : CyberTheme.purpleBlue.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF060711) : Colors.white54,
            size: 14,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF060711) : Colors.white60,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          if (isActive && speedLevel > 1) ...[
            const SizedBox(width: 4),
            // Speed indicator dots
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                speedLevel,
                (i) => Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.only(left: 2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF060711),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter — all Paint objects cached as fields; NO MaskFilter.blur;
// NO gradient shader recreation per frame.
// ─────────────────────────────────────────────────────────────────────────────
class _HorizonPainter extends CustomPainter {
  final double pitch;
  final double roll;
  final double deadband;
  final bool isEngaged;

  _HorizonPainter({
    required this.pitch,
    required this.roll,
    required this.deadband,
    required this.isEngaged,
  });

  // ── Cached paints (created once, reused every frame) ──────────────────────
  static final _ringPurple = Paint()
    ..color = const Color(0x2E7000FF) // purpleBlue 18% alpha
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  static final _ringAqua = Paint()
    ..color = const Color(0x2E00FFD1) // aquamarine 18% alpha
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  static final _crosshair = Paint()
    ..color = const Color(0x14FFFFFF) // white 8% alpha
    ..strokeWidth = 1.0;

  static final _deadbandFill = Paint()
    ..color = const Color(0x1A7000FF); // purpleBlue 10% alpha fill

  static final _deadbandBorder = Paint()
    ..color = const Color(0x8000FFD1) // aquamarine 50% alpha
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  static final _lineEngaged = Paint()
    ..color = const Color(0xB300FFD1) // aquamarine 70%
    ..strokeWidth = 2.5;

  static final _lineIdle = Paint()
    ..color = const Color(0x3DFFFFFF) // white 24%
    ..strokeWidth = 1.5;

  static final _bubbleEngaged = Paint()..color = CyberTheme.aquamarine;
  static final _bubbleIdle = Paint()..color = const Color(0xB3FFFFFF); // white 70%
  static final _bubbleEngagedRing = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.0;
  static final _bubbleIdleRing = Paint()
    ..color = const Color(0x4D7000FF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  static final _innerDot = Paint()..color = const Color(0xFF060711);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Reference rings
    canvas.drawCircle(center, radius * 0.33, _ringPurple);
    canvas.drawCircle(center, radius * 0.66, _ringAqua);

    // Crosshairs
    canvas.drawLine(
      Offset(center.dx - radius + 25, center.dy),
      Offset(center.dx + radius - 25, center.dy),
      _crosshair,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius + 25),
      Offset(center.dx, center.dy + radius - 25),
      _crosshair,
    );

    // Deadband zone
    const maxAngle = 45.0;
    final deadbandRadius = (deadband / maxAngle) * (radius - 40);
    canvas.drawCircle(center, deadbandRadius, _deadbandFill);
    canvas.drawCircle(center, deadbandRadius, _deadbandBorder);

    // Bubble position
    final clampedPitch = pitch.clamp(-maxAngle, maxAngle);
    final clampedRoll = roll.clamp(-maxAngle, maxAngle);
    final bubbleX = center.dx + (clampedRoll / maxAngle) * (radius - 40);
    final bubbleY = center.dy - (clampedPitch / maxAngle) * (radius - 40);
    final bubbleOffset = Offset(bubbleX, bubbleY);

    // Vector line
    canvas.drawLine(center, bubbleOffset, isEngaged ? _lineEngaged : _lineIdle);

    // Bubble fill + ring (no MaskFilter — plain solid rendering)
    canvas.drawCircle(bubbleOffset, 14, isEngaged ? _bubbleEngaged : _bubbleIdle);
    canvas.drawCircle(bubbleOffset, 14, isEngaged ? _bubbleEngagedRing : _bubbleIdleRing);

    // Center dot
    canvas.drawCircle(bubbleOffset, 3.5, _innerDot);
  }

  @override
  bool shouldRepaint(covariant _HorizonPainter old) {
    return old.pitch != pitch ||
        old.roll != roll ||
        old.deadband != deadband ||
        old.isEngaged != isEngaged;
  }
}
