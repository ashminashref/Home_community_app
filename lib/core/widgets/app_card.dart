import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

/// Pure white card with 24px border radius and diffused soft shadow.
/// Matches the reference cards exactly.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final double? width;
  final double? height;
  final Border? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor = AppColors.cardSurface,
    this.width,
    this.height,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: width ?? double.infinity,
      height: height,
      margin: margin,
      clipBehavior: Clip.antiAlias,
      padding: padding ?? const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadii.cardBorder,
        boxShadow: AppShadows.card,
        border: border,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: content,
      );
    }

    return content;
  }
}

