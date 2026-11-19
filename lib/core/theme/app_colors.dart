import 'package:flutter/material.dart';

/// Single source of truth for all color tokens extracted from the reference design.
/// Strictly anti-"AI look": no purple/blue generic gradients or harsh contrasts.
class AppColors {
  AppColors._();

  // Primary Emerald Palette (Spiritual, refined Kerala Mosque palette)
  static const Color primaryEmerald = Color(0xFF0E3E2E);
  static const Color primaryEmeraldLight = Color(0xFF14523D);
  static const Color primaryEmeraldDark = Color(0xFF09281E);
  static const Color emeraldAccent = Color(0xFF10B981);
  static const Color mintMist = Color(0xFFE8F3EE);
  static const Color mintText = Color(0xFFB4D3C5);

  // Surface & Canvas Palette
  static const Color background = Color(0xFFF5F6F8);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color cardSurfaceMuted = Color(0xFFF8F9FA);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFEDF2F7);

  // Typography Palette
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textMuted = Color(0xFFA0AEC0);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Atmospheric Prayer Header Sky Gradient
  static const Color skyGradientStart = Color(0xFF6CA4C8);
  static const Color skyGradientEnd = Color(0xFF3A7CA5);

  // Celestial & Indicator Colors
  static const Color goldenSun = Color(0xFFF59E0B);
  static const Color sunsetCoral = Color(0xFFF97316);
  static const Color badgeRed = Color(0xFFEF4444);
  static const Color starGold = Color(0xFFFCD34D);

  // Dial Specific Colors
  static const Color dialArcTrack = Color(0x47FFFFFF);
  static const Color dialArcActive = Color(0xFFFFFFFF);

  // Frosted Glass Overlays
  static const Color glassWhite = Color(0x33FFFFFF);
  static const Color glassWhiteBorder = Color(0x4DFFFFFF);

  // Gradients
  static const LinearGradient emeraldGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      primaryEmerald,
      primaryEmeraldDark,
    ],
  );

  static const LinearGradient prayerSkyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      skyGradientStart,
      skyGradientEnd,
    ],
  );

  static const LinearGradient mistGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x33387B64),
      primaryEmerald,
    ],
  );
}

