import 'package:flutter/material.dart';

/// Centralized Cyberpunk Aquamarine & Purple-Blue theme definition.
class CyberTheme {
  // --- Core Colors ---
  static const Color aquamarine = Color(0xFF00FFD1);
  static const Color aquamarineLight = Color(0xFF70FFEB);
  static const Color aquamarineDark = Color(0xFF00BFA5);

  static const Color purpleBlue = Color(0xFF7000FF);
  static const Color purpleBlueLight = Color(0xFF9D4EDD);
  static const Color purpleBlueBright = Color(0xFF5B50F6);
  static const Color purpleBlueDark = Color(0xFF3C096C);

  // Backgrounds & Surfaces
  static const Color backgroundTop = Color(0xFF090A1A);
  static const Color backgroundBottom = Color(0xFF060711);
  static const Color surfaceCard = Color(0xFF121530);
  static const Color surfaceGlass = Color(0x38181D45);
  static const Color surfaceCardBorder = Color(0x4000FFD1);

  // --- Gradients ---
  /// Signature gradient: Neon Aquamarine to Electric Purple-Blue
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [aquamarine, purpleBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Horizontal signature gradient
  static const LinearGradient horizontalGradient = LinearGradient(
    colors: [aquamarine, purpleBlue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Reverse gradient
  static const LinearGradient reverseGradient = LinearGradient(
    colors: [purpleBlue, aquamarine],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Subtle dark background gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundTop, backgroundBottom],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Translucent glass container gradient
  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x4D181D45),
      Color(0x280F122E),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Translucent glass border gradient
  static const LinearGradient glassBorderGradient = LinearGradient(
    colors: [
      Color(0x8000FFD1),
      Color(0x4D7000FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Emergency hazard gradient (Crimson into Electric Purple)
  static const LinearGradient hazardGradient = LinearGradient(
    colors: [
      Color(0xFFFF1744),
      Color(0xFF7000FF),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // --- Shadows / Glows ---
  static List<BoxShadow> get aquaGlow => [
        BoxShadow(
          color: aquamarine.withValues(alpha: 0.45),
          blurRadius: 18,
          spreadRadius: 2,
        ),
      ];

  static List<BoxShadow> get purpleGlow => [
        BoxShadow(
          color: purpleBlue.withValues(alpha: 0.5),
          blurRadius: 18,
          spreadRadius: 2,
        ),
      ];

  static List<BoxShadow> get dualGlow => [
        BoxShadow(
          color: aquamarine.withValues(alpha: 0.35),
          blurRadius: 16,
          spreadRadius: 1,
          offset: const Offset(-2, -2),
        ),
        BoxShadow(
          color: purpleBlue.withValues(alpha: 0.35),
          blurRadius: 16,
          spreadRadius: 1,
          offset: const Offset(2, 2),
        ),
      ];
}

/// Helper widget to render text with a gradient shader mask
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;

  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.gradient = CyberTheme.horizontalGradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}
