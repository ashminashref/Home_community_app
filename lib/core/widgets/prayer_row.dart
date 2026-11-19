import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class PrayerRow extends StatelessWidget {
  final String name;
  final String timeRange;
  final String? jamaathTime;
  final Widget icon;
  final bool isCurrent;
  final bool isMuted;
  final VoidCallback onToggleMute;
  final bool isLast;
  final bool isMalayalam;

  const PrayerRow({
    super.key,
    required this.name,
    required this.timeRange,
    this.jamaathTime,
    required this.icon,
    this.isCurrent = false,
    this.isMuted = false,
    required this.onToggleMute,
    this.isLast = false,
    this.isMalayalam = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Timeline indicator
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isCurrent ? AppColors.emeraldAccent : AppColors.textMuted.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: AppColors.divider,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.s8),

          // Celestial Prayer Icon
          SizedBox(
            width: 38,
            height: 38,
            child: Center(child: icon),
          ),
          const SizedBox(width: AppSpacing.s12),

          // Prayer Name & Time Range
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.prayerName(
                          color: isCurrent ? AppColors.primaryEmerald : AppColors.textPrimary,
                          isMalayalam: isMalayalam,
                        ),
                      ),
                    ),
                    if (jamaathTime != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.mintMist,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Jam: $jamaathTime',
                          style: AppTextStyles.bodyText(
                            color: AppColors.primaryEmeraldLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  timeRange,
                  style: AppTextStyles.prayerTimeRange(),
                ),
              ],
            ),
          ),

          // Speaker / Mute Toggle Icon
          IconButton(
            onPressed: onToggleMute,
            splashRadius: 20,
            icon: Icon(
              isMuted ? Icons.volume_off_outlined : Icons.volume_up_outlined,
              color: isMuted ? AppColors.textMuted : AppColors.primaryEmeraldLight,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
