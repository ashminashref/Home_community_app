import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Custom illustration matching the reference Splash Screen:
/// - Ornate hanging lanterns at the top corners
/// - Arched Islamic mihrab frame
/// - Mosque silhouette with domes and minarets
/// - Soft misty billowing clouds rising at the base
/// - Crescent moon and subtle stars
class MosqueMistyGraphic extends StatelessWidget {
  final double height;

  const MosqueMistyGraphic({
    super.key,
    this.height = 360,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _MosqueMistyPainter(),
      ),
    );
  }
}

class _MosqueMistyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Subtle arched Islamic mihrab contour
    final archPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final archPath = Path();
    archPath.moveTo(w * 0.08, h);
    archPath.lineTo(w * 0.08, h * 0.38);
    archPath.quadraticBezierTo(w * 0.08, h * 0.14, w * 0.5, h * 0.04);
    archPath.quadraticBezierTo(w * 0.92, h * 0.14, w * 0.92, h * 0.38);
    archPath.lineTo(w * 0.92, h);
    canvas.drawPath(archPath, archPaint);

    // 2. Hanging ornate lanterns (left and right)
    _drawLantern(canvas, Offset(w * 0.15, h * 0.16), chainLength: h * 0.12, scale: 0.9);
    _drawLantern(canvas, Offset(w * 0.23, h * 0.22), chainLength: h * 0.18, scale: 0.75);
    _drawLantern(canvas, Offset(w * 0.77, h * 0.22), chainLength: h * 0.18, scale: 0.75);
    _drawLantern(canvas, Offset(w * 0.85, h * 0.16), chainLength: h * 0.12, scale: 0.9);

    // 3. Crescent Moon at top
    final moonCenter = Offset(w * 0.5, h * 0.30);
    final moonRadius = 14.0;
    final moonPath = Path()
      ..addOval(Rect.fromCircle(center: moonCenter, radius: moonRadius));
    final moonCutout = Path()
      ..addOval(Rect.fromCircle(center: Offset(moonCenter.dx + 4, moonCenter.dy - 3), radius: moonRadius * 0.88));
    final crescent = Path.combine(PathOperation.difference, moonPath, moonCutout);

    final moonPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    canvas.drawPath(crescent, moonPaint);

    // 4. Mosque Silhouette rising behind clouds
    final mosquePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.85),
          Colors.white.withValues(alpha: 0.40),
          const Color(0xFF286E56),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.25, w, h * 0.65));

    final mosquePath = Path();
    final baseY = h * 0.85;

    // Left Minaret
    const minaretLeft = 0.20;
    final mlX = w * minaretLeft;
    mosquePath.moveTo(mlX - 12, baseY);
    mosquePath.lineTo(mlX - 10, h * 0.35);
    mosquePath.lineTo(mlX - 12, h * 0.34);
    mosquePath.lineTo(mlX + 12, h * 0.34);
    mosquePath.lineTo(mlX + 10, h * 0.35);
    mosquePath.lineTo(mlX + 8, h * 0.28);
    mosquePath.lineTo(mlX, h * 0.22); // minaret tip
    mosquePath.lineTo(mlX - 8, h * 0.28);
    mosquePath.lineTo(mlX - 10, h * 0.35);

    // Right Minaret
    const minaretRight = 0.80;
    final mrX = w * minaretRight;
    mosquePath.moveTo(mrX - 12, baseY);
    mosquePath.lineTo(mrX - 10, h * 0.35);
    mosquePath.lineTo(mrX - 12, h * 0.34);
    mosquePath.lineTo(mrX + 12, h * 0.34);
    mosquePath.lineTo(mrX + 10, h * 0.35);
    mosquePath.lineTo(mrX + 8, h * 0.28);
    mosquePath.lineTo(mrX, h * 0.22); // minaret tip
    mosquePath.lineTo(mrX - 8, h * 0.28);
    mosquePath.lineTo(mrX - 10, h * 0.35);

    // Inner left small minaret
    final smlX = w * 0.33;
    mosquePath.moveTo(smlX - 6, baseY);
    mosquePath.lineTo(smlX - 5, h * 0.45);
    mosquePath.lineTo(smlX, h * 0.38);
    mosquePath.lineTo(smlX + 5, h * 0.45);
    mosquePath.lineTo(smlX + 6, baseY);

    // Inner right small minaret
    final smrX = w * 0.67;
    mosquePath.moveTo(smrX - 6, baseY);
    mosquePath.lineTo(smrX - 5, h * 0.45);
    mosquePath.lineTo(smrX, h * 0.38);
    mosquePath.lineTo(smrX + 5, h * 0.45);
    mosquePath.lineTo(smrX + 6, baseY);

    // Central Grand Dome
    final domeCenterX = w * 0.5;
    final domeRadius = w * 0.17;
    final domeTopY = h * 0.36;

    mosquePath.moveTo(domeCenterX - domeRadius, baseY);
    mosquePath.quadraticBezierTo(domeCenterX - domeRadius, domeTopY + 15, domeCenterX - 6, domeTopY + 4);
    mosquePath.lineTo(domeCenterX, domeTopY - 10); // dome finial
    mosquePath.lineTo(domeCenterX + 6, domeTopY + 4);
    mosquePath.quadraticBezierTo(domeCenterX + domeRadius, domeTopY + 15, domeCenterX + domeRadius, baseY);

    canvas.drawPath(mosquePath, mosquePaint);

    // 5. Layered Misty Billowing Clouds
    _drawCloudLayer(canvas, size, h * 0.65, Colors.white.withValues(alpha: 0.12), scale: 1.1);
    _drawCloudLayer(canvas, size, h * 0.73, Colors.white.withValues(alpha: 0.22), scale: 0.95);
    _drawCloudLayer(canvas, size, h * 0.82, const Color(0xFF1E5B47), scale: 1.05);
    _drawCloudLayer(canvas, size, h * 0.90, AppColors.primaryEmerald, scale: 1.0);
  }

  void _drawLantern(Canvas canvas, Offset bottomPos, {required double chainLength, required double scale}) {
    final topPos = Offset(bottomPos.dx, bottomPos.dy - chainLength);

    // Chain
    final chainPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1.0;
    canvas.drawLine(topPos, bottomPos, chainPaint);

    // Lantern body
    final lanternW = 16.0 * scale;
    final lanternH = 26.0 * scale;

    final bodyPaint = Paint()
      ..color = const Color(0xFFBBE5D5)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(bottomPos.dx, bottomPos.dy - lanternH);
    path.lineTo(bottomPos.dx + lanternW / 2, bottomPos.dy - lanternH * 0.7);
    path.lineTo(bottomPos.dx + lanternW * 0.4, bottomPos.dy - lanternH * 0.2);
    path.lineTo(bottomPos.dx, bottomPos.dy);
    path.lineTo(bottomPos.dx - lanternW * 0.4, bottomPos.dy - lanternH * 0.2);
    path.lineTo(bottomPos.dx - lanternW / 2, bottomPos.dy - lanternH * 0.7);
    path.close();

    canvas.drawPath(path, bodyPaint);

    // Glow inside lantern
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(bottomPos.dx, bottomPos.dy - lanternH * 0.5), lanternW * 0.3, glowPaint);
  }

  void _drawCloudLayer(Canvas canvas, Size size, double baselineY, Color color, {double scale = 1.0}) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, baselineY);

    final w = size.width;
    path.quadraticBezierTo(w * 0.10, baselineY - 24 * scale, w * 0.25, baselineY - 8 * scale);
    path.quadraticBezierTo(w * 0.40, baselineY - 36 * scale, w * 0.60, baselineY - 14 * scale);
    path.quadraticBezierTo(w * 0.75, baselineY - 38 * scale, w * 0.90, baselineY - 10 * scale);
    path.quadraticBezierTo(w * 0.96, baselineY - 22 * scale, w, baselineY);
    path.lineTo(w, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
