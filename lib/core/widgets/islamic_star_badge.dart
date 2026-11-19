import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 8-pointed Islamic geometric star (Rub el Hizb style) badge for numbering Surahs and Ayahs.
class IslamicStarBadge extends StatelessWidget {
  final int number;
  final double size;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  const IslamicStarBadge({
    super.key,
    required this.number,
    this.size = 38.0,
    this.backgroundColor = AppColors.mintMist,
    this.borderColor = AppColors.emeraldAccent,
    this.textColor = AppColors.primaryEmeraldLight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _IslamicStarPainter(
              bg: backgroundColor,
              border: borderColor,
            ),
          ),
          Text(
            '$number',
            style: AppTextStyles.cardTitle(
              color: textColor,
              fontSize: size * 0.34,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _IslamicStarPainter extends CustomPainter {
  final Color bg;
  final Color border;

  _IslamicStarPainter({required this.bg, required this.border});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    final fillPaint = Paint()
      ..color = bg
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = border
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final path = Path();
    const points = 8;
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : radius * 0.72;
      final angle = (i * math.pi) / points - (math.pi / 2);
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _IslamicStarPainter oldDelegate) {
    return oldDelegate.bg != bg || oldDelegate.border != border;
  }
}
