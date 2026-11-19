import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'animated_loader_screen.dart';

enum AppLoaderVariant {
  fullScreen,
  cardInline,
  compactButton,
}

/// Branded loader consistent with the emerald astrolabe & crescent design:
/// A crescent moon with a small star and a soft glowing celestial ring that rotates and pulses.
/// Strictly CustomPainter, no default CircularProgressIndicator, no generic AI styling.
class AppLoader extends StatefulWidget {
  final AppLoaderVariant variant;
  final String? message;
  final Color? backgroundColor;

  const AppLoader({
    super.key,
    this.variant = AppLoaderVariant.cardInline,
    this.message,
    this.backgroundColor,
  });

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.variant == AppLoaderVariant.fullScreen) {
      return AnimatedLoaderScreen(
        customMessage: widget.message,
      );
    }

    if (widget.variant == AppLoaderVariant.compactButton) {
      return SizedBox(
        width: 22,
        height: 22,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _CrescentLoaderPainter(
                rotation: _controller.value * 2 * math.pi,
                glowOpacity: 0.85,
                ringColor: Colors.white,
                moonColor: Colors.white,
              ),
            );
          },
        ),
      );
    }

    // Card Inline variant
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 58,
              height: 58,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _CrescentLoaderPainter(
                      rotation: _controller.value * 2 * math.pi,
                      glowOpacity: 0.6 + 0.4 * math.sin(_controller.value * math.pi),
                      ringColor: const Color(0xFFE6C875),
                      moonColor: AppColors.primaryEmeraldLight,
                    ),
                  );
                },
              ),
            ),
            if (widget.message != null) ...[
              const SizedBox(height: 12),
              Text(
                widget.message!,
                style: AppTextStyles.bodyText(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CrescentLoaderPainter extends CustomPainter {
  final double rotation;
  final double glowOpacity;
  final Color ringColor;
  final Color moonColor;

  _CrescentLoaderPainter({
    required this.rotation,
    required this.glowOpacity,
    required this.ringColor,
    required this.moonColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // 1. Rotating dashed glowing arc ring
    final ringPaint = Paint()
      ..color = ringColor.withValues(alpha: 0.25)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, ringPaint);

    final activeArcPaint = Paint()
      ..color = ringColor.withValues(alpha: glowOpacity)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      rotation,
      math.pi * 0.9,
      false,
      activeArcPaint,
    );

    // 2. Centered glowing crescent moon
    final moonRadius = radius * 0.46;
    final moonCenter = center;

    final moonPath = Path()..addOval(Rect.fromCircle(center: moonCenter, radius: moonRadius));
    final cutoutCenter = Offset(center.dx + moonRadius * 0.45, center.dy - moonRadius * 0.28);
    final cutoutPath = Path()..addOval(Rect.fromCircle(center: cutoutCenter, radius: moonRadius * 0.9));

    final crescent = Path.combine(PathOperation.difference, moonPath, cutoutPath);

    final moonPaint = Paint()
      ..color = moonColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(crescent, moonPaint);

    // Little night star in the hollow
    final starCenter = Offset(center.dx + moonRadius * 0.52, center.dy + moonRadius * 0.08);
    final starPaint = Paint()..color = moonColor;
    canvas.drawCircle(starCenter, 1.8, starPaint);
  }

  @override
  bool shouldRepaint(covariant _CrescentLoaderPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.glowOpacity != glowOpacity;
  }
}
