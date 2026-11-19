import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum PillButtonVariant {
  primary,   // Deep emerald background, white text (like "Ramadan Special")
  white,     // White background, emerald text (like splash "Start Now")
  outline,   // Transparent background with subtle border
  secondary, // Soft muted background with dark text
}

class PillButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final PillButtonVariant variant;
  final Widget? icon;
  final bool fullWidth;
  final double height;
  final bool isMalayalam;

  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PillButtonVariant.primary,
    this.icon,
    this.fullWidth = false,
    this.height = 54.0,
    this.isMalayalam = false,
  });

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    Border? border;

    switch (widget.variant) {
      case PillButtonVariant.white:
        bg = AppColors.cardSurface;
        textColor = AppColors.primaryEmerald;
        break;
      case PillButtonVariant.outline:
        bg = Colors.transparent;
        textColor = AppColors.primaryEmerald;
        border = Border.all(color: AppColors.primaryEmeraldLight, width: 1.5);
        break;
      case PillButtonVariant.secondary:
        bg = AppColors.cardSurfaceMuted;
        textColor = AppColors.textPrimary;
        border = Border.all(color: AppColors.cardBorder);
        break;
      case PillButtonVariant.primary:
        bg = AppColors.primaryEmeraldLight;
        textColor = AppColors.textWhite;
        break;
    }

    Widget content = Container(
      height: widget.height,
      padding: EdgeInsets.symmetric(
        horizontal: widget.height <= 36 ? AppSpacing.s12 : AppSpacing.s24,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadii.pillBorder,
        border: border,
        boxShadow: widget.variant == PillButtonVariant.white
            ? const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            widget.icon!,
            const SizedBox(width: AppSpacing.s8),
          ],
          Flexible(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.buttonText(
                color: textColor,
                isMalayalam: widget.isMalayalam,
              ),
            ),
          ),
        ],
      ),
    );

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.fullWidth ? SizedBox(width: double.infinity, child: content) : content,
        ),
      ),
    );
  }
}
