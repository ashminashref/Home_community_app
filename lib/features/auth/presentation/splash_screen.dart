import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/mosque_misty_graphic.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isMalayalam = locale.languageCode == 'ml';

    return Scaffold(
      backgroundColor: AppColors.primaryEmerald,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.emeraldGradient,
            ),
          ),

          // Misty Mosque Graphic with Hanging Lanterns & Mihrab Arch
          const Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: MosqueMistyGraphic(height: 380),
          ),

          // Language Switcher Chip at top right
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () {
                ref.read(localeProvider.notifier).toggleLocale();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.glassWhite,
                  borderRadius: AppRadii.pillBorder,
                  border: Border.all(color: AppColors.glassWhiteBorder, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.language_rounded, size: 14, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      isMalayalam ? 'English' : 'മലയാളം',
                      style: AppTextStyles.buttonText(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // App Name Title overlaid on top
          Positioned(
            top: 130,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                AppConfig.appName,
                style: AppTextStyles.displayHero(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  isMalayalam: isMalayalam,
                ),
              ),
            ),
          ),

          // Content & Actions at the bottom
          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Small crescent icon with subtle glow
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x3310B981),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.nightlight_round,
                      color: AppColors.emeraldAccent,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s12),

                // Hero Heading: "Stay Connected with Mahal"
                Text(
                  l10n.tagline,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayHero(
                    color: Colors.white,
                    fontSize: 26,
                    isMalayalam: isMalayalam,
                  ),
                ),
                const SizedBox(height: AppSpacing.s8),

                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    l10n.splashSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyText(
                      color: AppColors.mintText,
                      fontSize: 13,
                      isMalayalam: isMalayalam,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s32),

                // Full-width White Pill CTA Button: "Start Now"
                PillButton(
                  label: l10n.startNow,
                  variant: PillButtonVariant.white,
                  fullWidth: true,
                  height: 56,
                  isMalayalam: isMalayalam,
                  icon: const Icon(
                    Icons.nightlight_round,
                    color: AppColors.primaryEmerald,
                    size: 18,
                  ),
                  onPressed: () {
                    final authState = ref.read(authProvider);
                    if (authState.isAuthenticated && authState.user != null) {
                      context.go('/loader?next=/home');
                    } else {
                      context.go('/loader?next=/login');
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.s16),

                // Already have an account? Log in
                GestureDetector(
                  onTap: () {
                    context.go('/login');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodyText(
                          color: AppColors.mintText,
                          fontSize: 13,
                          isMalayalam: isMalayalam,
                        ),
                        children: [
                          TextSpan(text: '${l10n.alreadyHaveAccount} '),
                          TextSpan(
                            text: l10n.logIn,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
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

