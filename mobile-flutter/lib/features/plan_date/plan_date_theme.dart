// ─────────────────────────────────────────────────────────────────────────────
// Plan a Date — Design Tokens
// All colours, radii, gradients used by this feature.
// NO hardcoded hex values in widget files.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

abstract final class PDColors {
  // Backgrounds
  static const Color bg          = Color(0xFF0A0610);
  static const Color card        = Color(0xFF15101C);
  static const Color cardBorder  = Color(0xFF2B2236);

  // Text
  static const Color textPrimary = Color(0xFFF6F1FA);
  static const Color textMuted   = Color(0xFFB9ADC9);
  static const Color textAccent  = Color(0xFFFF7FAE);
  static const Color textViolet  = Color(0xFFC9A4FF);
  static const Color textSuccess = Color(0xFF34D399);

  // Glow radials (used as radial gradient stops)
  static const Color glowPink    = Color(0x33E8226F);
  static const Color glowViolet  = Color(0x22A8189B);

  // Online
  static const Color online      = Color(0xFF34D399);
  static const Color offline     = Color(0xFF6E6480);

  // Interactive
  static const Color chipBorder        = Color(0xFF3A2E4A);
  static const Color chipBorderActive  = Color(0xFFE8226F);
  static const Color inputBorder       = Color(0xFF2B2236);
  static const Color inputFill         = Color(0xFF0F0A16);
  static const Color disabledFill      = Color(0xFF120C19);
  static const Color disabledBorder    = Color(0xFF1E1727);
  static const Color disabledText      = Color(0xFF7A6E8C);
  static const Color divider           = Color(0xFF2B2236);

  // Map pin colours
  static const Color pinMe      = Color(0xFF4DA3FF);
  static const Color pinPartner = Color(0xFFFF7FAE);
  static const Color pinSpot    = Color(0xFF34D399);

  // Safety tip
  static const Color safetyBg  = Color(0xFF1A1226);
  static const Color safetyBorder = Color(0xFF2B2236);
}

abstract final class PDGradients {
  /// Primary gradient: used for selected states and the main CTA.
  static const LinearGradient primary = LinearGradient(
    colors: [Color(0xFFE8226F), Color(0xFFA8189B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradient ring for partner avatar.
  static const LinearGradient avatarRing = LinearGradient(
    colors: [Color(0xFFE8226F), Color(0xFFC9A4FF), Color(0xFFA8189B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradient for mode toggle selected pill.
  static const LinearGradient modePill = LinearGradient(
    colors: [Color(0xFFE8226F), Color(0xFFA8189B)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  /// Subtle background gradient (top to bottom) — the page background.
  static RadialGradient bgPinkGlow(Size size) => const RadialGradient(
    center: Alignment(-0.5, -0.8),
    radius: 0.9,
    colors: [PDColors.glowPink, Colors.transparent],
  );

  static RadialGradient bgVioletGlow(Size size) => const RadialGradient(
    center: Alignment(0.7, -0.6),
    radius: 0.7,
    colors: [PDColors.glowViolet, Colors.transparent],
  );
}

abstract final class PDRadius {
  static const double card    = 24.0;
  static const double control = 16.0;
  static const double chip    = 14.0;
  static const double input   = 14.0;
  static const double avatar  = 999.0; // circle
  static const double map     = 20.0;
}

abstract final class PDShadows {
  /// Pink glow shadow for the CTA button.
  static List<BoxShadow> ctaGlow = [
    BoxShadow(
      color: const Color(0xFFE8226F).withValues(alpha: 0.45),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.35),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}

abstract final class PDTextStyles {
  static const TextStyle heading = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: PDColors.textPrimary,
    letterSpacing: -0.4,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: PDColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: PDColors.textPrimary,
  );

  static const TextStyle muted = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: PDColors.textMuted,
  );

  static const TextStyle accent = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: PDColors.textAccent,
  );
}

/// Minimum touch-target side length (44 px per WCAG 2.5.5).
const double kMinTouchTarget = 44.0;

