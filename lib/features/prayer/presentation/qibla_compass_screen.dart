import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/glass_back_button.dart';
import '../../auth/providers/auth_provider.dart';

class QiblaCompassScreen extends ConsumerStatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  ConsumerState<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends ConsumerState<QiblaCompassScreen> with SingleTickerProviderStateMixin {
  // Kerala Qibla angle is ~292° from True North (West-Northwest)
  static const double qiblaBearingKerala = 292.0;

  double _deviceHeading = 290.0; // Interactive simulated or sensor heading
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  bool get _isFacingQibla => (_deviceHeading - qiblaBearingKerala).abs() <= 4.0;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isMalayalam = locale.languageCode == 'ml';

    final qiblaDiff = ((qiblaBearingKerala - _deviceHeading) % 360 + 360) % 360;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s12),
              child: Row(
                children: [
                  GlassBackButton(
                    iconColor: AppColors.primaryEmerald,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMalayalam ? 'ഖിബ്‌ല ദിശ (കിബ്‌ല കോമ്പസ്)' : 'Qibla Direction Compass',
                          style: AppTextStyles.cardTitle(
                            fontSize: 18,
                            isMalayalam: isMalayalam,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          isMalayalam ? 'കേരളം • 292° പടിഞ്ഞാറ്-വടക്ക് പടിഞ്ഞാറ്' : 'Kerala, India • 292° WNW towards Kaaba',
                          style: AppTextStyles.bodyText(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s12),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                child: Column(
                  children: [
                    // Status Pill Banner
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: _isFacingQibla ? AppColors.primaryEmerald : AppColors.cardSurface,
                        borderRadius: AppRadii.pillBorder,
                        boxShadow: AppShadows.subtle,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isFacingQibla ? Icons.check_circle_rounded : Icons.explore_rounded,
                            color: _isFacingQibla ? Colors.white : AppColors.primaryEmerald,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isFacingQibla
                                ? (isMalayalam ? 'നിങ്ങൾ കൃത്യമായി ഖിബ്‌ലക്ക് നേരെയാണ്!' : 'You are facing the Holy Qibla!')
                                : (isMalayalam
                                    ? 'ഖിബ്‌ലയിലേക്ക് തിരിയുക: ${qiblaDiff.round()}°'
                                    : 'Turn ${qiblaDiff.round()}° to face Kaaba'),
                            style: AppTextStyles.buttonText(
                              color: _isFacingQibla ? Colors.white : AppColors.textPrimary,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.s24),

                    // Interactive Celestial Compass Dial
                    GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          _deviceHeading = (_deviceHeading + details.delta.dx * 0.4) % 360;
                          if (_deviceHeading < 0) _deviceHeading += 360;
                        });
                        if (_isFacingQibla) {
                          HapticFeedback.mediumImpact();
                        }
                      },
                      child: SizedBox(
                        width: 300,
                        height: 300,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer Glow Ring when aligned
                            if (_isFacingQibla)
                              AnimatedBuilder(
                                animation: _animController,
                                builder: (_, child) {
                                  return Container(
                                    width: 290 + (_animController.value * 12),
                                    height: 290 + (_animController.value * 12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primaryEmerald.withOpacity(0.08 * (1 - _animController.value)),
                                    ),
                                  );
                                },
                              ),

                            // Custom Painted Compass Dial with Ticks & Cardinal Points
                            Transform.rotate(
                              angle: -(_deviceHeading * math.pi / 180),
                              child: CustomPaint(
                                size: const Size(280, 280),
                                painter: _CompassDialPainter(),
                              ),
                            ),

                            // Fixed Kaaba Direction Arrow Pointer (Rotates relative to device)
                            Transform.rotate(
                              angle: ((qiblaBearingKerala - _deviceHeading) * math.pi / 180),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Kaaba Icon at the tip
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primaryEmerald,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryEmerald.withOpacity(0.4),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.mosque_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: 3.5,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryEmerald,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(height: 74), // Balance offset
                                ],
                              ),
                            ),

                            // Center Hub with Current Heading Degrees
                            Container(
                              width: 82,
                              height: 82,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.cardSurface,
                                boxShadow: AppShadows.card,
                                border: Border.all(
                                  color: _isFacingQibla ? AppColors.primaryEmerald : AppColors.cardBorder,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${_deviceHeading.round()}°',
                                    style: AppTextStyles.cardTitle(
                                      fontSize: 18,
                                      color: _isFacingQibla ? AppColors.primaryEmerald : AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    _getCardinalDirection(_deviceHeading),
                                    style: AppTextStyles.bodyText(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.s24),

                    // Quick Calibration & Distance Info Card
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.s18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.mintMist,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.location_on_rounded, color: AppColors.primaryEmerald, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isMalayalam ? 'മക്കയിലേക്കുള്ള ദൂരം' : 'Distance to Holy Kaaba',
                                        style: AppTextStyles.cardTitle(fontSize: 13.5, isMalayalam: isMalayalam),
                                      ),
                                      Text(
                                        '4,082 km from Kerala',
                                        style: AppTextStyles.bodyText(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.cardSurfaceMuted,
                                  borderRadius: AppRadii.pillBorder,
                                ),
                                child: Text(
                                  '292° WNW',
                                  style: AppTextStyles.buttonText(color: AppColors.primaryEmerald, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: AppColors.divider),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.textMuted),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  isMalayalam
                                      ? 'കൃത്യമായ ദിശ അറിയാൻ ഫോൺ പരന്ന പ്രതലത്തിൽ വെക്കുക. കാന്തിക വസ്തുക്കളിൽ നിന്ന് അകറ്റി സൂക്ഷിക്കുക.'
                                      : 'Place your device flat away from metallic objects for the most accurate magnetic reading. Drag compass dial to test heading.',
                                  style: AppTextStyles.bodyText(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                    isMalayalam: isMalayalam,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCardinalDirection(double deg) {
    if (deg >= 337.5 || deg < 22.5) return 'N';
    if (deg >= 22.5 && deg < 67.5) return 'NE';
    if (deg >= 67.5 && deg < 112.5) return 'E';
    if (deg >= 112.5 && deg < 157.5) return 'SE';
    if (deg >= 157.5 && deg < 202.5) return 'S';
    if (deg >= 202.5 && deg < 247.5) return 'SW';
    if (deg >= 247.5 && deg < 292.5) return 'W';
    return 'NW';
  }
}

// ---------------------------------------------------------------------------
// COMPASS DIAL CUSTOM PAINTER
// ---------------------------------------------------------------------------
class _CompassDialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer subtle circle
    final outerRingPaint = Paint()
      ..color = AppColors.divider.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius - 4, outerRingPaint);

    // Inner dial background
    final bgPaint = Paint()
      ..color = AppColors.cardSurface
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 8, bgPaint);

    // Draw degree tick marks
    const totalTicks = 72; // every 5 degrees
    for (int i = 0; i < totalTicks; i++) {
      final angle = (i * (360 / totalTicks)) * math.pi / 180;
      final isMajor = i % 6 == 0; // every 30 degrees
      final tickLength = isMajor ? 12.0 : 6.0;

      final inner = Offset(
        center.dx + (radius - 12 - tickLength) * math.cos(angle),
        center.dy + (radius - 12 - tickLength) * math.sin(angle),
      );
      final outer = Offset(
        center.dx + (radius - 12) * math.cos(angle),
        center.dy + (radius - 12) * math.sin(angle),
      );

      final tickPaint = Paint()
        ..color = isMajor ? AppColors.textPrimary : AppColors.textMuted.withOpacity(0.4)
        ..strokeWidth = isMajor ? 1.8 : 1.0
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(inner, outer, tickPaint);
    }

    // Draw N, E, S, W labels
    _drawText(canvas, 'N', Offset(center.dx, center.dy - radius + 32), const Color(0xFFE53E3E), 13, FontWeight.w800);
    _drawText(canvas, 'E', Offset(center.dx + radius - 32, center.dy), AppColors.textSecondary, 12, FontWeight.w600);
    _drawText(canvas, 'S', Offset(center.dx, center.dy + radius - 32), AppColors.textSecondary, 12, FontWeight.w600);
    _drawText(canvas, 'W', Offset(center.dx - radius + 32, center.dy), AppColors.textSecondary, 12, FontWeight.w600);
  }

  void _drawText(Canvas canvas, String text, Offset center, Color color, double fontSize, FontWeight weight) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: weight),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
