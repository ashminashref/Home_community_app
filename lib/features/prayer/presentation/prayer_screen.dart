import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/prayer_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/celestial_prayer_icon.dart';
import '../../../core/widgets/glass_back_button.dart';
import '../../../core/widgets/prayer_row.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../../../core/widgets/tick_dial.dart';
import '../../auth/providers/auth_provider.dart';
import 'qibla_compass_screen.dart';

class PrayerScreen extends ConsumerStatefulWidget {
  const PrayerScreen({super.key});

  @override
  ConsumerState<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends ConsumerState<PrayerScreen> {
  final Map<String, bool> _mutedPrayers = {};
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(milliseconds: 650));
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isRefreshing) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: ShimmerSkeleton.prayerTimes(),
        ),
      );
    }

    final locale = ref.watch(localeProvider);
    final isMalayalam = locale.languageCode == 'ml';
    final authState = ref.watch(authProvider);
    final mahal = authState.currentMahal;

    // Calculate prayer times using Adhan package + Jamaath overrides
    final schedule = PrayerService.calculateTodayTimes(
      jamaathOverrides: mahal.jamaathOverrides,
    );

    final nextPrayer = schedule.nextPrayer ?? schedule.prayers.first;
    final fajrPrayer = schedule.prayers.firstWhere((p) => p.key == 'fajr');
    final maghribPrayer = schedule.prayers.firstWhere((p) => p.key == 'maghrib');

    return Scaffold(
      backgroundColor: AppColors.skyGradientEnd,
      body: Stack(
        children: [
          // Background Atmospheric Sky Gradient with Mosque silhouette backdrop
          Container(
            height: MediaQuery.of(context).size.height * 0.52,
            decoration: const BoxDecoration(
              gradient: AppColors.prayerSkyGradient,
            ),
            child: Stack(
              children: [
                // Soft background mosque dome illustration in bokeh
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Opacity(
                      opacity: 0.18,
                      child: Icon(
                        Icons.mosque_rounded,
                        size: 260,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Safe Area content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // In-Content Header: Glass Back Button + Centered Title + Qibla toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const GlassBackButton(),
                      Text(
                        isMalayalam ? '${nextPrayer.nameMl} സമയം' : '${nextPrayer.nameEn} Time',
                        style: AppTextStyles.cardTitle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Action Buttons: Refresh & Qibla Compass
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: _handleRefresh,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.glassWhite,
                                border: Border.all(color: AppColors.glassWhiteBorder, width: 1.2),
                              ),
                              child: const Icon(
                                Icons.refresh_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const QiblaCompassScreen()),
                              );
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.glassWhite,
                                border: Border.all(color: AppColors.glassWhiteBorder, width: 1.2),
                              ),
                              child: const Icon(
                                Icons.explore_outlined,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.s8),

                // Semicircular Tick-Mark Dial (Matching Reference Screen 3)
                TickDial(
                  location: mahal.location,
                  displayTime: nextPrayer.formattedTime,
                  progress: schedule.currentProgress,
                  leftLabel: isMalayalam ? fajrPrayer.nameMl : fajrPrayer.nameEn,
                  leftTime: fajrPrayer.formattedTime,
                  rightLabel: isMalayalam ? 'ഇഫ്താർ' : 'Iftar',
                  rightTime: maghribPrayer.formattedTime,
                  leftIcon: const CelestialPrayerIcon(type: CelestialPrayerType.sunrise, size: 22),
                  rightIcon: const CelestialPrayerIcon(type: CelestialPrayerType.maghrib, size: 22),
                ),

                const SizedBox(height: AppSpacing.s16),

                // White Bottom Sheet Timeline (Matching Reference Screen 3)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: AppRadii.sheetBorder,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x18000000),
                          blurRadius: 24,
                          offset: Offset(0, -6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Pill Notch Handle
                        Container(
                          width: 36,
                          height: 4,
                          margin: const EdgeInsets.only(top: 12, bottom: 8),
                          decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: AppRadii.pillBorder,
                          ),
                        ),

                        // Timeline prayer items
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(AppSpacing.s24, AppSpacing.s12, AppSpacing.s24, 90),
                            itemCount: schedule.prayers.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              final prayer = schedule.prayers[index];
                              final isMuted = _mutedPrayers[prayer.key] ?? false;

                              CelestialPrayerType cType;
                              switch (prayer.key) {
                                case 'fajr':
                                  cType = CelestialPrayerType.fajr;
                                  break;
                                case 'dhuhr':
                                  cType = CelestialPrayerType.dhuhr;
                                  break;
                                case 'asr':
                                  cType = CelestialPrayerType.asr;
                                  break;
                                case 'maghrib':
                                  cType = CelestialPrayerType.maghrib;
                                  break;
                                case 'isha':
                                default:
                                  cType = CelestialPrayerType.isha;
                                  break;
                              }

                              return PrayerRow(
                                name: isMalayalam ? prayer.nameMl : prayer.nameEn,
                                timeRange: prayer.formattedRange,
                                jamaathTime: prayer.jamaathTime,
                                icon: CelestialPrayerIcon(type: cType, size: 28),
                                isCurrent: prayer.isCurrent,
                                isMuted: isMuted,
                                isLast: index == schedule.prayers.length - 1,
                                isMalayalam: isMalayalam,
                                onToggleMute: () {
                                  setState(() {
                                    _mutedPrayers[prayer.key] = !isMuted;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      duration: const Duration(milliseconds: 900),
                                      content: Text(
                                        !isMuted
                                            ? '${prayer.nameEn} adhan reminder muted'
                                            : '${prayer.nameEn} adhan reminder activated',
                                      ),
                                      backgroundColor: AppColors.primaryEmerald,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
