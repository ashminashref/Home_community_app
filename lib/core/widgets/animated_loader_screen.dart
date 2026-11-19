import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/config.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'mosque_misty_graphic.dart';

/// An authentic, beautifully crafted Islamic loader screen that embodies
/// the exact aesthetic of the Mahal app reference:
/// Deep emerald gradient, hanging brass lanterns, misty mosque silhouette,
/// a radiant golden crescent moon with a star, and a soft glowing celestial
/// ring that gently breathes and pulses as the app title fades in.
///
/// Strictly non-generic: Zero stock AI progress bars, zero sci-fi HUDs.
class AnimatedLoaderScreen extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onCompleted;
  final String? customMessage;

  const AnimatedLoaderScreen({
    super.key,
    this.duration = const Duration(milliseconds: 2200),
    this.onCompleted,
    this.customMessage,
  });

  @override
  State<AnimatedLoaderScreen> createState() => _AnimatedLoaderScreenState();
}

class _AnimatedLoaderScreenState extends State<AnimatedLoaderScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late AnimationController _lanternController;

  @override
  void initState() {
    super.initState();

    // 1. Soft breathing pulse for the golden halo (2.4s cycle)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // 2. Slow, graceful celestial ring orbit (4.8s cycle)
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4800),
    )..repeat();

    // 3. App Title & Subtitle Fade-in
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    // 4. Subtle lantern sway (3.6s cycle)
    _lanternController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);

    // Auto-advance if onCompleted callback is provided
    if (widget.onCompleted != null) {
      Future.delayed(widget.duration, () {
        if (mounted) {
          widget.onCompleted!();
        }
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _fadeController.dispose();
    _lanternController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryEmeraldDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Deep Emerald Atmosphere Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF061A13),
                  AppColors.primaryEmerald,
                  Color(0xFF04140E),
                ],
              ),
            ),
          ),

          // 2. Subtle Islamic Geometric Star Pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.04,
              child: CustomPaint(
                painter: _GeometricIslamicPatternPainter(),
              ),
            ),
          ),

          // 3. Misty Mosque Architecture Silhouette at base
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height * 0.40,
            child: Opacity(
              opacity: 0.35,
              child: const MosqueMistyGraphic(height: 280),
            ),
          ),

          // 4. Hanging Lanterns at top corners with gentle sway
          AnimatedBuilder(
            animation: _lanternController,
            builder: (context, child) {
              final angle = math.sin(_lanternController.value * math.pi * 2) * 0.05;
              return Stack(
                children: [
                  Positioned(
                    top: -10,
                    left: 24,
                    child: Transform.rotate(
                      angle: angle,
                      alignment: Alignment.topCenter,
                      child: _buildLantern(height: 120),
                    ),
                  ),
                  Positioned(
                    top: -20,
                    right: 28,
                    child: Transform.rotate(
                      angle: -angle,
                      alignment: Alignment.topCenter,
                      child: _buildLantern(height: 140),
                    ),
                  ),
                ],
              );
            },
          ),

          // 5. Centered Islamic Crescent Moon & Glowing Celestial Ring
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Luminous Crescent Moon + Star + Orbital Ring
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_pulseController, _rotationController]),
                      builder: (context, child) {
                        return CustomPaint(
                          painter: _CelestialCrescentLoaderPainter(
                            rotation: _rotationController.value * 2 * math.pi,
                            pulse: _pulseController.value,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Bismillah Calligraphy
                  FadeTransition(
                    opacity: _fadeController,
                    child: const Text(
                      'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ',
                      style: TextStyle(
                        fontFamily: 'NotoNaskhArabic',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Color(0xFFD7C297),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // App Brand Title ("Mahal") with breathing golden glow
                  FadeTransition(
                    opacity: _fadeController,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final shimmer = 0.90 + 0.10 * math.sin(_pulseController.value * math.pi);
                        return Opacity(
                          opacity: shimmer,
                          child: Text(
                            AppConfig.appName,
                            style: AppTextStyles.displayHero(
                              color: Colors.white,
                              fontSize: 34,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Serene Subtitle matching Splash reference
                  FadeTransition(
                    opacity: _fadeController,
                    child: Text(
                      widget.customMessage ?? 'Stay Connected with Mahal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mintText,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLantern({required double height}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 1.5,
          height: height * 0.45,
          color: const Color(0xFFD7C297).withValues(alpha: 0.6),
        ),
        Container(
          width: 26,
          height: height * 0.55,
          decoration: BoxDecoration(
            color: const Color(0xFF061A13).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD7C297), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD7C297).withValues(alpha: 0.4),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.nightlight_round, size: 13, color: Color(0xFFE6C875)),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the delicate celestial crescent moon and luminous breathing halo.
class _CelestialCrescentLoaderPainter extends CustomPainter {
  final double rotation;
  final double pulse; // 0.0 to 1.0

  _CelestialCrescentLoaderPainter({
    required this.rotation,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Soft glowing outer atmospheric aura (breathing)
    final auraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFE6C875).withValues(alpha: 0.22 + 0.12 * pulse),
          AppColors.primaryEmeraldLight.withValues(alpha: 0.10 + 0.06 * pulse),
          Colors.transparent,
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.4));

    canvas.drawCircle(center, radius * 1.35, auraPaint);

    // 2. Delicate orbital celestial arc (slowly rotating)
    final arcPaint = Paint()
      ..color = const Color(0xFFE6C875).withValues(alpha: 0.70)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final arcRect = Rect.fromCircle(center: center, radius: radius * 0.85);
    canvas.drawArc(arcRect, rotation, math.pi * 1.25, false, arcPaint);

    // Small glowing orbital comet dot
    final dotAngle = rotation + math.pi * 1.25;
    final dotX = center.dx + math.cos(dotAngle) * radius * 0.85;
    final dotY = center.dy + math.sin(dotAngle) * radius * 0.85;

    final dotGlow = Paint()
      ..color = const Color(0xFFFFFBEB)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset(dotX, dotY), 3.5, dotGlow);

    final dotPaint = Paint()..color = const Color(0xFFFDE68A);
    canvas.drawCircle(Offset(dotX, dotY), 2.2, dotPaint);

    // 3. Sculpted Golden Crescent Moon (Hilal)
    final moonCenter = Offset(center.dx - 2, center.dy);
    final moonRadius = radius * 0.48;

    final moonPath = Path()
      ..addArc(
        Rect.fromCircle(center: moonCenter, radius: moonRadius),
        -math.pi * 0.55,
        math.pi * 1.1,
      );

    moonPath.arcTo(
      Rect.fromCircle(center: Offset(moonCenter.dx + 8, moonCenter.dy), radius: moonRadius * 0.82),
      math.pi * 0.55,
      -math.pi * 1.1,
      false,
    );
    moonPath.close();

    // Moon Glow
    final moonGlow = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(moonPath, moonGlow);

    // Golden Moon Fill with subtle gradient
    final moonPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFFBEB),
          Color(0xFFFDE68A),
          Color(0xFFF59E0B),
        ],
      ).createShader(Rect.fromCircle(center: moonCenter, radius: moonRadius));
    canvas.drawPath(moonPath, moonPaint);

    // 4. Five-pointed star nestled inside the crescent cradle
    final starCenter = Offset(center.dx + 15, center.dy - 6);
    final starSize = 5.5 + 1.2 * pulse;

    final starPath = Path();
    for (int i = 0; i < 5; i++) {
      final outerAngle = -math.pi / 2 + (i * 4 * math.pi / 5);
      final x = starCenter.dx + math.cos(outerAngle) * starSize;
      final y = starCenter.dy + math.sin(outerAngle) * starSize;
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();

    final starGlow = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(starPath, starGlow);

    final starPaint = Paint()..color = const Color(0xFFFFFBEB);
    canvas.drawPath(starPath, starPaint);
  }

  @override
  bool shouldRepaint(covariant _CelestialCrescentLoaderPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.pulse != pulse;
  }
}

/// Subtle geometric star pattern for the deep emerald background
class _GeometricIslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 52.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      for (double y = 0; y < size.height + spacing; y += spacing) {
        final c = Offset(x, y);
        const r = 16.0;
        canvas.drawRect(
          Rect.fromCenter(center: c, width: r * 2, height: r * 2),
          paint,
        );
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(math.pi / 4);
        canvas.drawRect(
          const Rect.fromCenter(center: Offset.zero, width: r * 2, height: r * 2),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
