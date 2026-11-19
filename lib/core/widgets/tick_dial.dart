import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Semicircular tick-mark gauge dial extracted from the Prayer Screen reference.
/// Displays radial tick marks, glowing position handle, big center time, and flanking times.
class TickDial extends StatelessWidget {
  final String location;
  final String displayTime;
  final double progress; // 0.0 to 1.0 along the arc (e.g. from Fajr to Maghrib)
  final String leftLabel;
  final String leftTime;
  final String rightLabel;
  final String rightTime;
  final Widget? leftIcon;
  final Widget? rightIcon;

  const TickDial({
    super.key,
    required this.location,
    required this.displayTime,
    required this.progress,
    required this.leftLabel,
    required this.leftTime,
    required this.rightLabel,
    required this.rightTime,
    this.leftIcon,
    this.rightIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 300,
          height: 170,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CustomPaint(
                size: const Size(300, 170),
                painter: _SemicircleTickPainter(progress: progress),
              ),
              Positioned(
                bottom: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      location,
                      style: AppTextStyles.bodyText(
                        color: AppColors.textWhite.withValues(alpha: 0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayTime,
                      style: AppTextStyles.dialTime(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFlankItem(leftIcon, leftLabel, leftTime),
              _buildFlankItem(rightIcon, rightLabel, rightTime),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlankItem(Widget? icon, String label, String time) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          icon,
          const SizedBox(width: 6),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodyText(
                color: AppColors.textWhite.withValues(alpha: 0.75),
                fontSize: 11,
              ),
            ),
            Text(
              time,
              style: AppTextStyles.bodyText(
                color: AppColors.textWhite,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SemicircleTickPainter extends CustomPainter {
  final double progress;

  _SemicircleTickPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 16;
    const totalTicks = 72;
    const startAngle = math.pi; // 180 degrees (left)
    const sweepAngle = math.pi; // 180 degree semicircle to right

    final activeTicks = (totalTicks * progress.clamp(0.0, 1.0)).round();

    for (int i = 0; i <= totalTicks; i++) {
      final angle = startAngle + (i / totalTicks) * sweepAngle;
      final isMajor = i % 6 == 0;
      final tickLength = isMajor ? 14.0 : 8.0;

      final innerPoint = Offset(
        center.dx + (radius - tickLength) * math.cos(angle),
        center.dy + (radius - tickLength) * math.sin(angle),
      );
      final outerPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      final isActive = i <= activeTicks;
      final paint = Paint()
        ..color = isActive
            ? AppColors.dialArcActive
            : AppColors.dialArcTrack
        ..strokeWidth = isMajor ? 1.8 : 1.2
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(innerPoint, outerPoint, paint);
    }

    // Draw glowing needle handle at the progress angle
    final currentAngle = startAngle + progress.clamp(0.0, 1.0) * sweepAngle;
    final handleCenter = Offset(
      center.dx + (radius - 4) * math.cos(currentAngle),
      center.dy + (radius - 4) * math.sin(currentAngle),
    );

    // Outer glow
    final glowPaint = Paint()
      ..color = AppColors.dialArcActive.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(handleCenter, 8, glowPaint);

    // Inner bright circle
    final handlePaint = Paint()
      ..color = AppColors.dialArcActive
      ..style = PaintingStyle.fill;
    canvas.drawCircle(handleCenter, 4.5, handlePaint);
  }

  @override
  bool shouldRepaint(covariant _SemicircleTickPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
