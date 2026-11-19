import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum CelestialPrayerType {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha,
}

/// Custom painted celestial icons matching the reference design.
/// Zero default Material icons and zero emojis.
class CelestialPrayerIcon extends StatelessWidget {
  final CelestialPrayerType type;
  final double size;

  const CelestialPrayerIcon({
    super.key,
    required this.type,
    this.size = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CelestialIconPainter(type: type),
      ),
    );
  }
}

class _CelestialIconPainter extends CustomPainter {
  final CelestialPrayerType type;

  _CelestialIconPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    switch (type) {
      case CelestialPrayerType.fajr:
      case CelestialPrayerType.sunrise:
        _paintSunrise(canvas, center, w, h);
        break;
      case CelestialPrayerType.dhuhr:
        _paintMiddaySun(canvas, center, w, h);
        break;
      case CelestialPrayerType.asr:
        _paintAfternoonSun(canvas, center, w, h);
        break;
      case CelestialPrayerType.maghrib:
        _paintSunset(canvas, center, w, h);
        break;
      case CelestialPrayerType.isha:
        _paintNightMoon(canvas, center, w, h);
        break;
    }
  }

  void _paintSunrise(Canvas canvas, Offset center, double w, double h) {
    final horizonY = h * 0.65;
    final sunCenter = Offset(w / 2, horizonY);
    final sunRadius = w * 0.22;

    // Horizon line
    final linePaint = Paint()
      ..color = AppColors.goldenSun.withValues(alpha: 0.5)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.1, horizonY), Offset(w * 0.9, horizonY), linePaint);
    canvas.drawLine(Offset(w * 0.25, horizonY + 3.5), Offset(w * 0.75, horizonY + 3.5), linePaint);

    // Half sun
    final sunPaint = Paint()
      ..color = AppColors.goldenSun
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: sunCenter, radius: sunRadius),
      math.pi,
      math.pi,
      true,
      sunPaint,
    );

    // Sun rays
    final rayPaint = Paint()
      ..color = AppColors.goldenSun
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i <= 4; i++) {
      final angle = math.pi + (i / 4) * math.pi;
      final p1 = Offset(sunCenter.dx + (sunRadius + 3) * math.cos(angle), sunCenter.dy + (sunRadius + 3) * math.sin(angle));
      final p2 = Offset(sunCenter.dx + (sunRadius + 7) * math.cos(angle), sunCenter.dy + (sunRadius + 7) * math.sin(angle));
      canvas.drawLine(p1, p2, rayPaint);
    }
  }

  void _paintMiddaySun(Canvas canvas, Offset center, double w, double h) {
    final sunRadius = w * 0.24;

    // Sun disc
    final sunPaint = Paint()
      ..color = AppColors.goldenSun
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, sunRadius, sunPaint);

    // Radiating rays
    final rayPaint = Paint()
      ..color = AppColors.goldenSun
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi;
      final p1 = Offset(center.dx + (sunRadius + 3) * math.cos(angle), center.dy + (sunRadius + 3) * math.sin(angle));
      final p2 = Offset(center.dx + (sunRadius + 7) * math.cos(angle), center.dy + (sunRadius + 7) * math.sin(angle));
      canvas.drawLine(p1, p2, rayPaint);
    }
  }

  void _paintAfternoonSun(Canvas canvas, Offset center, double w, double h) {
    final sunRadius = w * 0.22;
    final sunPaint = Paint()
      ..color = AppColors.goldenSun
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, sunRadius, sunPaint);

    // Diagonal angled rays
    final rayPaint = Paint()
      ..color = AppColors.goldenSun
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 4) + (i / 6) * math.pi;
      final p1 = Offset(center.dx + (sunRadius + 3) * math.cos(angle), center.dy + (sunRadius + 3) * math.sin(angle));
      final p2 = Offset(center.dx + (sunRadius + 7.5) * math.cos(angle), center.dy + (sunRadius + 7.5) * math.sin(angle));
      canvas.drawLine(p1, p2, rayPaint);
    }
  }

  void _paintSunset(Canvas canvas, Offset center, double w, double h) {
    final horizonY = h * 0.58;
    final sunCenter = Offset(w / 2, horizonY);
    final sunRadius = w * 0.22;

    // Water reflection lines
    final linePaint = Paint()
      ..color = AppColors.sunsetCoral.withValues(alpha: 0.6)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.15, horizonY), Offset(w * 0.85, horizonY), linePaint);
    canvas.drawLine(Offset(w * 0.25, horizonY + 3.5), Offset(w * 0.75, horizonY + 3.5), linePaint);
    canvas.drawLine(Offset(w * 0.35, horizonY + 7), Offset(w * 0.65, horizonY + 7), linePaint);

    // Warm setting sun
    final sunPaint = Paint()
      ..color = AppColors.sunsetCoral
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: sunCenter, radius: sunRadius),
      math.pi,
      math.pi,
      true,
      sunPaint,
    );
  }

  void _paintNightMoon(Canvas canvas, Offset center, double w, double h) {
    final moonCenter = Offset(center.dx - 1, center.dy);
    final moonRadius = w * 0.28;

    final moonPath = Path()
      ..addOval(Rect.fromCircle(center: moonCenter, radius: moonRadius));

    final cutoutCenter = Offset(center.dx + 5, center.dy - 3);
    final cutoutPath = Path()
      ..addOval(Rect.fromCircle(center: cutoutCenter, radius: moonRadius * 0.85));

    final crescent = Path.combine(PathOperation.difference, moonPath, cutoutPath);

    final moonPaint = Paint()
      ..color = AppColors.starGold
      ..style = PaintingStyle.fill;
    canvas.drawPath(crescent, moonPaint);

    // Little night star
    final starCenter = Offset(w * 0.72, h * 0.28);
    final starPaint = Paint()..color = AppColors.starGold;
    canvas.drawCircle(starCenter, 1.8, starPaint);
  }

  @override
  bool shouldRepaint(covariant _CelestialIconPainter oldDelegate) {
    return oldDelegate.type != type;
  }
}

