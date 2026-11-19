import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Interactive horizontal ruler slider with vertical tick marks.
/// Replicates the "Do You Fast Today?" ruler component from the reference image.
/// Reusable for fasting days, Quran pages goal, or daily dhikr target.
class RulerSlider extends StatefulWidget {
  final int min;
  final int max;
  final int value;
  final ValueChanged<int> onChanged;
  final String? leftLabel;
  final String? rightLabel;
  final double height;

  const RulerSlider({
    super.key,
    this.min = 1,
    this.max = 30,
    required this.value,
    required this.onChanged,
    this.leftLabel,
    this.rightLabel,
    this.height = 42.0,
  });

  @override
  State<RulerSlider> createState() => _RulerSliderState();
}

class _RulerSliderState extends State<RulerSlider> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value.clamp(widget.min, widget.max);
  }

  @override
  void didUpdateWidget(covariant RulerSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value.clamp(widget.min, widget.max);
    }
  }

  void _updateValueFromDx(double dx, double width) {
    final fraction = (dx / width).clamp(0.0, 1.0);
    final range = widget.max - widget.min;
    final newValue = (widget.min + (fraction * range)).round();
    if (newValue != _currentValue) {
      setState(() {
        _currentValue = newValue;
      });
      widget.onChanged(newValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final startLabel = widget.leftLabel ?? widget.min.toString().padLeft(2, '0');
    final endLabel = widget.rightLabel ?? widget.max.toString().padLeft(2, '0');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              startLabel,
              style: AppTextStyles.bodyText(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.mintMist,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$_currentValue',
                style: AppTextStyles.bodyText(
                  color: AppColors.primaryEmeraldLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              endLabel,
              style: AppTextStyles.bodyText(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s8),
        LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onHorizontalDragUpdate: (details) {
                _updateValueFromDx(details.localPosition.dx, constraints.maxWidth);
              },
              onTapDown: (details) {
                _updateValueFromDx(details.localPosition.dx, constraints.maxWidth);
              },
              child: CustomPaint(
                size: Size(constraints.maxWidth, widget.height),
                painter: _RulerTickPainter(
                  min: widget.min,
                  max: widget.max,
                  value: _currentValue,
                  activeColor: AppColors.primaryEmerald,
                  inactiveColor: const Color(0xFFE2E8F0),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RulerTickPainter extends CustomPainter {
  final int min;
  final int max;
  final int value;
  final Color activeColor;
  final Color inactiveColor;

  _RulerTickPainter({
    required this.min,
    required this.max,
    required this.value,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final totalTicks = (max - min) * 2; // sub-tick intervals
    if (totalTicks <= 0) return;

    final tickGap = size.width / totalTicks;
    final activeFraction = (value - min) / (max - min);
    final activeThresholdX = size.width * activeFraction;

    final activePaint = Paint()
      ..color = activeColor
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final inactivePaint = Paint()
      ..color = inactiveColor
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i <= totalTicks; i++) {
      final x = i * tickGap;
      final isMajor = i % 2 == 0;
      final isSemiMajor = i % 10 == 0;

      double tickHeight = size.height * 0.45;
      if (isSemiMajor) {
        tickHeight = size.height * 0.95;
      } else if (isMajor) {
        tickHeight = size.height * 0.70;
      }

      final yTop = size.height - tickHeight;
      final yBottom = size.height;

      final paint = x <= activeThresholdX ? activePaint : inactivePaint;
      canvas.drawLine(Offset(x, yTop), Offset(x, yBottom), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RulerTickPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.min != min ||
        oldDelegate.max != max;
  }
}

