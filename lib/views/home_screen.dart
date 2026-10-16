import 'package:flutter/material.dart';
import '../controllers/car_controller.dart';
import '../models/connection_state.dart';
import '../theme/cyber_theme.dart';
import 'settings_dialog.dart';
import 'widgets/connection_bar.dart';
import 'widgets/dpad_view.dart';
import 'widgets/emergency_stop_button.dart';
import 'widgets/tilt_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final CarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CarController();
    // Try auto-connecting to the previously used device on startup
    _controller.bluetooth.autoConnectLastDevice();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final mode = _controller.controlMode;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: CyberTheme.backgroundGradient,
            ),
            child: Stack(
              children: [
                // Ambient glowing background orbs (Aquamarine top-left, Purple-Blue bottom-right)
                Positioned(
                  top: -60,
                  left: -60,
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CyberTheme.aquamarine.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 120,
                  right: -80,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CyberTheme.purpleBlue.withValues(alpha: 0.14),
                    ),
                  ),
                ),

                // Main Foreground Content
                SafeArea(
                  child: Column(
                    children: [
                      // Sci-Fi Cyber AppBar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: CyberTheme.primaryGradient,
                                boxShadow: CyberTheme.aquaGlow,
                              ),
                              child: const Icon(
                                Icons.directions_car_filled,
                                color: Color(0xFF060711),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GradientText(
                                    'ARDUINO CAR',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2.5,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    'ROBOTIC TELEMETRY & CONTROL',
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: 9,
                                      letterSpacing: 1.2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: CyberTheme.surfaceGlass,
                                border: Border.all(
                                  color: CyberTheme.aquamarine.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.tune,
                                  color: CyberTheme.aquamarine,
                                  size: 20,
                                ),
                                tooltip: 'Settings',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => SettingsDialog(controller: _controller),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Futuristic Underline Divider
                      Container(
                        height: 1.5,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: const BoxDecoration(
                          gradient: CyberTheme.horizontalGradient,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Bluetooth Connection HUD Card
                      ConnectionBar(controller: _controller),

                      // Cockpit Mode Selector Tabs (D-PAD vs TILT)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF101328),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: CyberTheme.purpleBlue.withValues(alpha: 0.35),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _ModeTab(
                                  icon: Icons.gamepad_outlined,
                                  label: 'TOUCH D-PAD',
                                  isSelected: mode == ControlMode.dpad,
                                  onTap: () => _controller.setControlMode(ControlMode.dpad),
                                ),
                              ),
                              Expanded(
                                child: _ModeTab(
                                  icon: Icons.screen_rotation,
                                  label: 'TILT / ACCEL',
                                  isSelected: mode == ControlMode.tilt,
                                  onTap: () => _controller.setControlMode(ControlMode.tilt),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Central Arena (DPadView or TiltView)
                      Expanded(
                        child: mode == ControlMode.dpad
                            ? DPadView(controller: _controller)
                            : TiltView(controller: _controller),
                      ),

                      // Real-time HUD Telemetry Bar
                      _TelemetryBar(controller: _controller),

                      // Emergency Stop Button
                      EmergencyStopButton(controller: _controller),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ModeTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? CyberTheme.horizontalGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? CyberTheme.aquaGlow : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? const Color(0xFF060711) : Colors.white60,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF060711) : Colors.white70,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                letterSpacing: 1.1,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TelemetryBar extends StatelessWidget {
  final CarController controller;

  const _TelemetryBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final activeCommand = controller.activeCommandDisplay;
    // Raw command used to show speed level (char count in tilt mode)
    final rawCmd = controller.activeCommand;
    final int speedLevel = (rawCmd != null && rawCmd.length > 1) ? rawCmd.length : 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF10132B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CyberTheme.purpleBlue.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _TelemetryItem(
            label: 'STREAM RATE',
            value: '${controller.packetsPerSecond.toInt()} Hz',
            highlight: controller.packetsPerSecond > 0,
          ),
          _TelemetryItem(
            label: 'TOTAL PACKETS',
            value: '${controller.packetsSentTotal}',
            highlight: false,
          ),
          Row(
            children: [
              const Text(
                'COMMAND: ',
                style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: activeCommand != null ? CyberTheme.horizontalGradient : null,
                  color: activeCommand != null ? null : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      activeCommand?.toUpperCase() ?? 'IDLE',
                      style: TextStyle(
                        color: activeCommand != null ? const Color(0xFF060711) : Colors.white54,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 12,
                      ),
                    ),
                    if (activeCommand != null && speedLevel > 1) ...[
                      const SizedBox(width: 5),
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TelemetryItem extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _TelemetryItem({
    required this.label,
    required this.value,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 9,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            color: highlight ? CyberTheme.aquamarine : Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
