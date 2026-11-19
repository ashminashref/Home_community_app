import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/glass_back_button.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/ruler_slider.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/tracking_provider.dart';

class RecitationStudioScreen extends ConsumerWidget {
  const RecitationStudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isMalayalam = locale.languageCode == 'ml';
    final trackingState = ref.watch(trackingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: AppSpacing.s12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar
              Row(
                children: [
                  GlassBackButton(
                    iconColor: AppColors.primaryEmerald,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(
                    child: Text(
                      l10n.recordRecitation,
                      style: AppTextStyles.cardTitle(
                        fontSize: 18,
                        isMalayalam: isMalayalam,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s24),

              // Recording Studio Card
              AppCard(
                backgroundColor: AppColors.primaryEmerald,
                child: Column(
                  children: [
                    Text(
                      isMalayalam ? 'ഖുർആൻ പാരായണം റെക്കോർഡ് ചെയ്യാം' : 'Record & Perfect Your Recitation',
                      style: AppTextStyles.cardTitle(
                        color: Colors.white,
                        fontSize: 16,
                        isMalayalam: isMalayalam,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Listen to your pronunciation and track your tajweed progress.',
                      style: AppTextStyles.bodyText(
                        color: AppColors.mintText,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.s24),

                    // Waveform Visualizer
                    Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryEmeraldDark,
                        borderRadius: AppRadii.buttonBorder,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: trackingState.waveformPoints.map((h) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 5,
                            height: (trackingState.isRecording ? (h * 48) : (h * 24)).clamp(6.0, 52.0),
                            decoration: BoxDecoration(
                              color: trackingState.isRecording
                                  ? AppColors.badgeRed
                                  : AppColors.emeraldAccent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s24),

                    // Record Action Button
                    GestureDetector(
                      onTap: () {
                        if (trackingState.isRecording) {
                          ref.read(trackingProvider.notifier).stopRecording();
                        } else {
                          ref.read(trackingProvider.notifier).startRecording();
                        }
                      },
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: trackingState.isRecording ? AppColors.badgeRed : Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          trackingState.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                          color: trackingState.isRecording ? Colors.white : AppColors.primaryEmerald,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s12),

                    Text(
                      trackingState.isRecording
                          ? (isMalayalam ? 'റെക്കോർഡ് ചെയ്യുന്നു...' : 'Recording...')
                          : (isMalayalam ? 'റെക്കോർഡ് ചെയ്യാൻ തട്ടുക' : 'Tap to Record'),
                      style: AppTextStyles.bodyText(
                        color: AppColors.mintText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    if (trackingState.hasRecordedAudio) ...[
                      const SizedBox(height: AppSpacing.s16),
                      PillButton(
                        label: trackingState.isPlayingRecording
                            ? (isMalayalam ? 'നിർത്തുക' : 'Pause Playback')
                            : (isMalayalam ? 'കേൾക്കാം' : 'Play My Recitation'),
                        variant: PillButtonVariant.white,
                        height: 40,
                        isMalayalam: isMalayalam,
                        icon: Icon(
                          trackingState.isPlayingRecording ? Icons.pause : Icons.play_arrow_rounded,
                          color: AppColors.primaryEmerald,
                          size: 18,
                        ),
                        onPressed: () {
                          ref.read(trackingProvider.notifier).togglePlayback();
                        },
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s24),

              // Daily Quran Pages Goal Card (reusing the ruler slider)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.dailyRecitationGoal,
                          style: AppTextStyles.cardTitle(
                            fontSize: 16,
                            isMalayalam: isMalayalam,
                          ),
                        ),
                        Text(
                          '${trackingState.quranPagesReadToday} / ${trackingState.quranPagesGoal} ${l10n.pages}',
                          style: AppTextStyles.bodyText(
                            color: AppColors.primaryEmeraldLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Adjust your daily recitation target using the ruler slider below.',
                      style: AppTextStyles.bodyText(fontSize: 12),
                    ),
                    const SizedBox(height: AppSpacing.s16),

                    // Ruler Slider
                    RulerSlider(
                      min: 1,
                      max: 30,
                      value: trackingState.quranPagesGoal,
                      leftLabel: '01',
                      rightLabel: '30',
                      onChanged: (val) {
                        ref.read(trackingProvider.notifier).setQuranPagesGoal(val);
                      },
                    ),
                    const SizedBox(height: AppSpacing.s16),

                    PillButton(
                      label: '+1 Page Read Today',
                      variant: PillButtonVariant.primary,
                      height: 38,
                      isMalayalam: isMalayalam,
                      icon: const Icon(Icons.check, color: Colors.white, size: 16),
                      onPressed: () {
                        ref.read(trackingProvider.notifier).incrementQuranPage();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
