import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

/// Comprehensive Shimmer Skeleton system for UI fallbacks and loading states across all app elements.
/// Perfectly tuned with the emerald design system: soft neutral base and delicate highlight.
class ShimmerSkeleton extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
    this.margin,
  });

  static const Color baseColor = Color(0xFFE8ECEF);
  static const Color highlightColor = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius ?? BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Circular avatar / button placeholder
  static Widget circle({required double size, EdgeInsetsGeometry? margin}) {
    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  /// Text line placeholder with rounded ends
  static Widget textLine({
    double width = double.infinity,
    double height = 12,
    EdgeInsetsGeometry? margin,
  }) {
    return ShimmerSkeleton(
      width: width,
      height: height,
      margin: margin,
      borderRadius: BorderRadius.circular(height / 2),
    );
  }

  /// Rectangular box placeholder
  static Widget box({
    double? width,
    required double height,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? margin,
  }) {
    return ShimmerSkeleton(
      width: width,
      height: height,
      borderRadius: borderRadius,
      margin: margin,
    );
  }

  /// Full Card Container Skeleton
  static Widget card({
    double height = 140,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry padding = const EdgeInsets.all(AppSpacing.s16),
    Widget? child,
  }) {
    return Container(
      height: child == null ? height : null,
      margin: margin ?? const EdgeInsets.symmetric(vertical: AppSpacing.s8),
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppRadii.cardBorder,
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child ??
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadii.cardBorder,
              ),
            ),
          ),
    );
  }

  // ==========================================
  // SCREEN-SPECIFIC RICH FALLBACK SKELETONS
  // ==========================================

  /// Surah Reader Screen Skeleton (used while fetching Arabic & Malayalam verses)
  static Widget surahReader() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(AppSpacing.s24, 110, AppSpacing.s24, 140),
      children: [
        // Bismillah Banner Skeleton
        Center(
          child: Column(
            children: [
              ShimmerSkeleton.textLine(width: 140, height: 24),
              const SizedBox(height: 16),
              ShimmerSkeleton.textLine(width: 220, height: 32),
              const SizedBox(height: 20),
            ],
          ),
        ),
        // 5 Ayah Card Skeletons
        ...List.generate(5, (index) => _buildAyahSkeletonItem()),
      ],
    );
  }

  static Widget _buildAyahSkeletonItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerSkeleton.circle(size: 28),
              ShimmerSkeleton.textLine(width: 60, height: 14),
            ],
          ),
          const SizedBox(height: 14),
          // Arabic lines (varying widths right-aligned)
          Align(
            alignment: Alignment.centerRight,
            child: ShimmerSkeleton.textLine(width: 280, height: 22),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ShimmerSkeleton.textLine(width: 200, height: 22),
          ),
          const SizedBox(height: 16),
          // Malayalam lines (left-aligned)
          ShimmerSkeleton.textLine(width: 260, height: 13),
          const SizedBox(height: 6),
          ShimmerSkeleton.textLine(width: 180, height: 13),
        ],
      ),
    );
  }

  /// Home Screen Fallback Skeleton
  static Widget homeScreen() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: AppSpacing.s12),
      children: [
        // Header Row Skeleton
        Row(
          children: [
            ShimmerSkeleton.circle(size: 48),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerSkeleton.textLine(width: 140, height: 16),
                  const SizedBox(height: 6),
                  ShimmerSkeleton.textLine(width: 90, height: 11),
                ],
              ),
            ),
            ShimmerSkeleton.circle(size: 44),
          ],
        ),
        const SizedBox(height: AppSpacing.s16),

        // Services Quick Ribbon Skeleton
        Row(
          children: List.generate(
            4,
            (i) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                child: ShimmerSkeleton.box(height: 38, borderRadius: BorderRadius.circular(19)),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s16),

        // Feature Card 1 Skeleton (Ramadan Moments)
        ShimmerSkeleton.card(
          height: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerSkeleton.textLine(width: 140, height: 16),
              const SizedBox(height: 8),
              ShimmerSkeleton.textLine(width: 180, height: 12),
              const SizedBox(height: 16),
              ShimmerSkeleton.box(width: 120, height: 36, borderRadius: BorderRadius.circular(18)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),

        // Feature Card 2 Skeleton (Photo Card)
        ShimmerSkeleton.card(
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerSkeleton.box(height: 130, borderRadius: BorderRadius.circular(16)),
              const SizedBox(height: 12),
              Row(
                children: [
                  ShimmerSkeleton.circle(size: 32),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerSkeleton.textLine(width: 120, height: 12),
                        const SizedBox(height: 4),
                        ShimmerSkeleton.textLine(width: 80, height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s16),

        // Feature Card 3 Skeleton (Ruler Slider)
        ShimmerSkeleton.card(
          height: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerSkeleton.textLine(width: 130, height: 15),
              const SizedBox(height: 6),
              ShimmerSkeleton.textLine(width: 190, height: 11),
              const SizedBox(height: 16),
              ShimmerSkeleton.box(height: 24, borderRadius: BorderRadius.circular(12)),
            ],
          ),
        ),
      ],
    );
  }

  /// Quran Index Screen Skeleton
  static Widget quranIndex() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s8),
      children: [
        // Continue Reading Hero Card Skeleton
        ShimmerSkeleton.card(height: 130),
        const SizedBox(height: AppSpacing.s16),

        // Segmented Switcher Skeleton
        ShimmerSkeleton.box(height: 44, borderRadius: BorderRadius.circular(22)),
        const SizedBox(height: AppSpacing.s16),

        // Surah Item Skeletons
        ...List.generate(6, (index) => _buildSurahSkeletonItem()),
      ],
    );
  }

  static Widget _buildSurahSkeletonItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          ShimmerSkeleton.circle(size: 38),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerSkeleton.textLine(width: 120, height: 14),
                const SizedBox(height: 6),
                ShimmerSkeleton.textLine(width: 80, height: 11),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShimmerSkeleton.textLine(width: 60, height: 16),
              const SizedBox(height: 6),
              ShimmerSkeleton.textLine(width: 40, height: 10),
            ],
          ),
        ],
      ),
    );
  }

  /// Duas & Supplications Screen Skeleton
  static Widget duasList() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s8),
      children: [
        // Search bar
        ShimmerSkeleton.box(height: 48, borderRadius: BorderRadius.circular(16)),
        const SizedBox(height: AppSpacing.s14),

        // Category pills row
        Row(
          children: List.generate(
            4,
            (i) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                child: ShimmerSkeleton.box(height: 36, borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s16),

        // Dua Cards
        ...List.generate(
          4,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerSkeleton.textLine(width: 90, height: 18),
                    ShimmerSkeleton.circle(size: 26),
                  ],
                ),
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerRight, child: ShimmerSkeleton.textLine(width: 220, height: 20)),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: ShimmerSkeleton.textLine(width: 170, height: 20)),
                const SizedBox(height: 14),
                ShimmerSkeleton.textLine(width: 240, height: 12),
                const SizedBox(height: 6),
                ShimmerSkeleton.textLine(width: 160, height: 12),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Certificate Portal Screen Skeleton
  static Widget certificateList() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s8),
      children: [
        // Top 3 Stat Cards
        Row(
          children: [
            Expanded(child: ShimmerSkeleton.box(height: 74, borderRadius: BorderRadius.circular(18))),
            const SizedBox(width: 10),
            Expanded(child: ShimmerSkeleton.box(height: 74, borderRadius: BorderRadius.circular(18))),
            const SizedBox(width: 10),
            Expanded(child: ShimmerSkeleton.box(height: 74, borderRadius: BorderRadius.circular(18))),
          ],
        ),
        const SizedBox(height: AppSpacing.s16),

        // Filter Pills
        Row(
          children: List.generate(
            4,
            (i) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                child: ShimmerSkeleton.box(height: 38, borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.s16),

        // Certificate Cards
        ...List.generate(
          3,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShimmerSkeleton.circle(size: 38),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerSkeleton.textLine(width: 140, height: 14),
                          const SizedBox(height: 4),
                          ShimmerSkeleton.textLine(width: 100, height: 11),
                        ],
                      ),
                    ),
                    ShimmerSkeleton.box(width: 60, height: 22, borderRadius: BorderRadius.circular(10)),
                  ],
                ),
                const SizedBox(height: 12),
                ShimmerSkeleton.box(width: double.infinity, height: 28, borderRadius: BorderRadius.circular(8)),
                const SizedBox(height: 12),
                ShimmerSkeleton.box(height: 38, borderRadius: BorderRadius.circular(19)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Payments & Chanda Screen Skeleton
  static Widget payments() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: AppSpacing.s12),
      children: [
        // Chanda Hero Status Card
        ShimmerSkeleton.card(height: 160),
        const SizedBox(height: AppSpacing.s16),

        // Tabs
        ShimmerSkeleton.box(height: 44, borderRadius: BorderRadius.circular(22)),
        const SizedBox(height: AppSpacing.s16),

        // Payment History Items
        ...List.generate(
          4,
          (_) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                ShimmerSkeleton.circle(size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerSkeleton.textLine(width: 110, height: 13),
                      const SizedBox(height: 4),
                      ShimmerSkeleton.textLine(width: 70, height: 11),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ShimmerSkeleton.textLine(width: 60, height: 14),
                    const SizedBox(height: 4),
                    ShimmerSkeleton.box(width: 48, height: 18, borderRadius: BorderRadius.circular(8)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Prayer Times Screen Skeleton
  static Widget prayerTimes() {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // Sky Header with back button & dial skeleton
        Container(
          height: 320,
          color: const Color(0xFF4A89AC),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerSkeleton.circle(size: 44),
                  ShimmerSkeleton.textLine(width: 100, height: 16),
                  const SizedBox(width: 44),
                ],
              ),
              const SizedBox(height: 30),
              ShimmerSkeleton.circle(size: 140),
            ],
          ),
        ),
        // White Bottom Sheet Timeline
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: List.generate(
              5,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    ShimmerSkeleton.circle(size: 10),
                    const SizedBox(width: 14),
                    ShimmerSkeleton.circle(size: 36),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerSkeleton.textLine(width: 80, height: 13),
                          const SizedBox(height: 4),
                          ShimmerSkeleton.textLine(width: 120, height: 11),
                        ],
                      ),
                    ),
                    ShimmerSkeleton.circle(size: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
