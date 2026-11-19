import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Complete typographic tokens matching the reference:
/// 1. Expressive display serif for greetings & hero titles
/// 2. Clean geometric sans (Poppins) for modern UI
/// 3. Noto Sans Malayalam with safe line-height (1.55) to prevent glyph clipping
/// 4. Amiri for authentic Arabic script
class AppTextStyles {
  AppTextStyles._();

  // Helper to resolve font family by language
  static TextStyle displayHero({
    Color color = AppColors.textWhite,
    double fontSize = 28,
    FontWeight fontWeight = FontWeight.w700,
    bool isMalayalam = false,
  }) {
    if (isMalayalam) {
      return GoogleFonts.notoSansMalayalam(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: 1.5,
      );
    }
    return GoogleFonts.playfairDisplay(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: -0.3,
    );
  }

  static TextStyle greetingHeading({
    Color color = AppColors.textPrimary,
    double fontSize = 22,
    bool isMalayalam = false,
  }) {
    if (isMalayalam) {
      return GoogleFonts.notoSansMalayalam(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        height: 1.45,
      );
    }
    return GoogleFonts.playfairDisplay(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    );
  }

  static TextStyle cardTitle({
    Color color = AppColors.textPrimary,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    bool isMalayalam = false,
  }) {
    if (isMalayalam) {
      return GoogleFonts.notoSansMalayalam(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: 1.5,
      );
    }
    return GoogleFonts.poppins(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  static TextStyle bodyText({
    Color color = AppColors.textSecondary,
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w400,
    FontStyle? fontStyle,
    double? lineHeight,
    bool isMalayalam = false,
  }) {
    if (isMalayalam) {
      return GoogleFonts.notoSansMalayalam(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        height: lineHeight ?? 1.55,
      );
    }
    return GoogleFonts.poppins(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      height: lineHeight ?? 1.4,
    );
  }

  static TextStyle buttonText({
    Color color = AppColors.textWhite,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w600,
    bool isMalayalam = false,
  }) {
    if (isMalayalam) {
      return GoogleFonts.notoSansMalayalam(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: 1.4,
      );
    }
    return GoogleFonts.poppins(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: 0.2,
    );
  }

  static TextStyle dialTime({
    Color color = AppColors.textWhite,
  }) {
    return GoogleFonts.poppins(
      color: color,
      fontSize: 34,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    );
  }

  static TextStyle prayerName({
    Color color = AppColors.textPrimary,
    bool isMalayalam = false,
  }) {
    if (isMalayalam) {
      return GoogleFonts.notoSansMalayalam(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );
    }
    return GoogleFonts.poppins(
      color: color,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
  }

  static TextStyle prayerTimeRange({
    Color color = AppColors.textSecondary,
  }) {
    return GoogleFonts.poppins(
      color: color,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle arabicAyah({
    Color color = AppColors.textPrimary,
    double fontSize = 24,
  }) {
    return GoogleFonts.amiri(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      height: 2.1,
    );
  }
}
