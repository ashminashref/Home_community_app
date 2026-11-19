import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;
  final bool isMalayalam;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s12),
    this.isMalayalam = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.cardTitle(
              fontSize: 17,
              isMalayalam: isMalayalam,
            ),
          ),
          if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: AppTextStyles.bodyText(
                  color: AppColors.primaryEmeraldLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  isMalayalam: isMalayalam,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

