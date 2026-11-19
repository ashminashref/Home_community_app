import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';

class GlassBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color iconColor;

  const GlassBackButton({
    super.key,
    this.onPressed,
    this.iconColor = AppColors.textWhite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () {
        if (context.canPop()) {
          context.pop();
        }
      },
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.glassWhite,
              border: Border.all(color: AppColors.glassWhiteBorder, width: 1.2),
              boxShadow: AppShadows.glassButton,
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

