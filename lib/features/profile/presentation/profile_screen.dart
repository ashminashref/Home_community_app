import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../app/config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/mosque_misty_graphic.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../admin/presentation/admin_dashboard_screen.dart';
import '../../auth/domain/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../certificates/presentation/certificate_portal_screen.dart';
import '../../certificates/providers/certificate_provider.dart';
import '../../tracking/presentation/recitation_studio_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isMalayalam = locale.languageCode == 'ml';
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final mahal = authState.currentMahal;
    final certState = ref.watch(certificateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. EMERALD HERO ZONE (Islamic silhouettes, glowing avatar ring, member title)
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: 290,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryEmerald,
                  ),
                  child: Stack(
                    children: [
                      // Misty mosque silhouette
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 180,
                        child: Opacity(
                          opacity: 0.22,
                          child: const MosqueMistyGraphic(height: 180),
                        ),
                      ),
                      // Hanging lanterns
                      Positioned(
                        top: 40,
                        left: 20,
                        child: Opacity(
                          opacity: 0.35,
                          child: Icon(Icons.flare_outlined, color: AppColors.mintText, size: 26),
                        ),
                      ),
                      Positioned(
                        top: 36,
                        right: 24,
                        child: Opacity(
                          opacity: 0.35,
                          child: Icon(Icons.nightlight_round, color: AppColors.mintText, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),

                // Hero Member Details
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: AppSpacing.s8),
                    child: Column(
                      children: [
                        // Screen Title Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.profile,
                              style: AppTextStyles.cardTitle(
                                color: Colors.white,
                                fontSize: 18,
                                isMalayalam: isMalayalam,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: AppRadii.pillBorder,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: AppColors.mintText,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    user?.role == UserRole.committeeAdmin ? 'Admin' : 'Member',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.s16),

                        // Glowing Avatar Ring
                        Container(
                          width: 86,
                          height: 86,
                          padding: const EdgeInsets.all(3.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE6C875), Color(0xFF5DBB9B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryEmerald.withValues(alpha: 0.4),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.mintMist,
                            ),
                            child: ClipOval(
                              child: user?.avatarUrl != null
                                  ? Image.network(
                                      user!.avatarUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const Icon(Icons.person, color: AppColors.primaryEmerald, size: 44),
                                    )
                                  : const Icon(Icons.person, color: AppColors.primaryEmerald, size: 44),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.s12),

                        // Member Name
                        Text(
                          user?.name ?? 'Mahal Member',
                          style: AppTextStyles.greetingHeading(
                            color: Colors.white,
                            fontSize: 21,
                            isMalayalam: isMalayalam,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 4),

                        // House Name & Family ID Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: AppRadii.pillBorder,
                          ),
                          child: Text(
                            '${user?.houseName ?? "Baitul Noor"}  •  ${user?.familyId ?? "EK-FAM-142"}',
                            style: AppTextStyles.bodyText(
                              color: AppColors.mintText,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. SLIDE-UP WHITE SHEET SECTION (Overlaps emerald hero smoothly)
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0.0, -18.0, 0.0),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadii.sheetRadius),
                  topRight: Radius.circular(AppRadii.sheetRadius),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(AppSpacing.s24, AppSpacing.s24, AppSpacing.s24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // MAHAL MEMBERSHIP & QR CARD
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.s18),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: AppColors.mintMist,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.mosque_outlined, color: AppColors.primaryEmerald, size: 22),
                            ),
                            const SizedBox(width: AppSpacing.s12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mahal.name,
                                    style: AppTextStyles.cardTitle(fontSize: 15, isMalayalam: isMalayalam),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Code: ${mahal.code} • ${mahal.district}',
                                    style: AppTextStyles.bodyText(color: AppColors.textSecondary, fontSize: 11.5),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s8),
                            GestureDetector(
                              onTap: () => context.go('/join'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: AppRadii.pillBorder,
                                  border: Border.all(color: AppColors.primaryEmeraldLight, width: 1.2),
                                ),
                                child: Text(
                                  l10n.switchMahal,
                                  style: AppTextStyles.buttonText(
                                    color: AppColors.primaryEmerald,
                                    fontSize: 11,
                                    isMalayalam: isMalayalam,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s14),
                        const Divider(color: AppColors.divider, height: 1),
                        const SizedBox(height: AppSpacing.s14),

                        // Digital Mahal Identity QR snippet
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: QrImageView(
                                data: 'MAHAL:${mahal.code}:MEMBER:${user?.familyId ?? "EK-142"}',
                                version: QrVersions.auto,
                                size: 52,
                                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: AppColors.primaryEmerald),
                                dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: AppColors.primaryEmeraldDark),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isMalayalam ? 'ഡിജിറ്റൽ മഹല്ല് പാസ്സ്' : 'Digital Mahal ID Pass',
                                    style: AppTextStyles.cardTitle(fontSize: 13, isMalayalam: isMalayalam),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isMalayalam
                                        ? 'ജനറൽ ബോഡി മീറ്റിംഗുകളിലും വോട്ടെടുപ്പിലും തിരിച്ചറിയാൻ'
                                        : 'Verified member barcode for general body meetings & voting',
                                    style: AppTextStyles.bodyText(color: AppColors.textSecondary, fontSize: 11, isMalayalam: isMalayalam),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.s16),

                  // USER CONTACT INFORMATION CARD (Standard & Secure Registration details)
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isMalayalam ? 'രജിസ്റ്റർ ചെയ്ത വിവരങ്ങൾ' : 'Account & Contact Details',
                              style: AppTextStyles.cardTitle(fontSize: 13.5, isMalayalam: isMalayalam),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.mintMist,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'OTP Verified',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryEmerald,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s12),
                        Row(
                          children: [
                            const Icon(Icons.phone_outlined, size: 16, color: AppColors.primaryEmerald),
                            const SizedBox(width: AppSpacing.s8),
                            Text(
                              user?.phone ?? '+91 98470 12345',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined, size: 16, color: AppColors.primaryEmerald),
                            const SizedBox(width: AppSpacing.s8),
                            Expanded(
                              child: Text(
                                user?.email ?? 'abdul.rahman@gmail.com',
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.s16),

                  // MAHAL CERTIFICATES & DOCUMENTS PORTAL CARD
                  AppCard(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CertificatePortalScreen()),
                      );
                    },
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.description_outlined, color: Color(0xFF0D9488), size: 22),
                        ),
                        const SizedBox(width: AppSpacing.s14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isMalayalam ? 'എന്റെ സർട്ടിഫിക്കറ്റുകൾ' : 'My Certificates & Documents',
                                style: AppTextStyles.cardTitle(fontSize: 14, isMalayalam: isMalayalam),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${certState.requests.length} documents on file • Nikkah, Birth & Death',
                                style: AppTextStyles.bodyText(color: AppColors.textSecondary, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.mintMist,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${certState.approvedCount} Issued',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryEmerald,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.s16),

                  // RECITATION STUDIO SHORTCUT WITH LIVE WAVEFORM PREVIEW
                  AppCard(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RecitationStudioScreen()),
                      );
                    },
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF3E8FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.graphic_eq_rounded, color: Color(0xFF7E22CE), size: 22),
                        ),
                        const SizedBox(width: AppSpacing.s14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.recordRecitation,
                                style: AppTextStyles.cardTitle(fontSize: 14, isMalayalam: isMalayalam),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Tajweed recording studio with audio waveform',
                                style: AppTextStyles.bodyText(color: AppColors.textSecondary, fontSize: 11),
                              ),
                              const SizedBox(height: 6),
                              // Mini waveform preview bars
                              Row(
                                children: [0.3, 0.7, 0.9, 0.4, 0.8, 0.6, 1.0, 0.5, 0.3, 0.7, 0.4].map((h) {
                                  return Container(
                                    width: 3,
                                    height: 14 * h,
                                    margin: const EdgeInsets.only(right: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF7E22CE).withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.s16),

                  // COMMITTEE ADMIN PANEL SHORTCUT (If admin)
                  if (user?.role == UserRole.committeeAdmin) ...[
                    AppCard(
                      backgroundColor: AppColors.primaryEmerald,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                        );
                      },
                      padding: const EdgeInsets.all(AppSpacing.s16),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.admin_panel_settings_outlined, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: AppSpacing.s14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.adminPanel,
                                  style: AppTextStyles.cardTitle(color: Colors.white, fontSize: 14.5, isMalayalam: isMalayalam),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Manage announcements, prayer times & dues',
                                  style: AppTextStyles.bodyText(color: AppColors.mintText, fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s8),
                          const Icon(Icons.chevron_right_rounded, color: Colors.white),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                  ],

                  // PREFERENCES CARD: Language Switcher & Role Testing Switch
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.s16),
                    child: Column(
                      children: [
                        // Language Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.language_rounded, color: AppColors.primaryEmerald, size: 20),
                                  const SizedBox(width: AppSpacing.s12),
                                  Expanded(
                                    child: Text(
                                      l10n.selectLanguage,
                                      style: AppTextStyles.cardTitle(fontSize: 13.5, isMalayalam: isMalayalam),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s8),
                            PillButton(
                              label: isMalayalam ? 'മലയാളം' : 'English',
                              variant: PillButtonVariant.outline,
                              height: 32,
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                ref.read(localeProvider.notifier).toggleLocale();
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.s12),
                        const Divider(color: AppColors.divider, height: 1),
                        const SizedBox(height: AppSpacing.s12),

                        // Switch Role Toggle (Reviewer convenience)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Test Role Mode',
                                    style: AppTextStyles.cardTitle(fontSize: 13.5),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    user?.role == UserRole.committeeAdmin ? 'Active as Admin' : 'Active as Member',
                                    style: AppTextStyles.bodyText(color: AppColors.textSecondary, fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s8),
                            PillButton(
                              label: user?.role == UserRole.committeeAdmin ? 'To Member' : 'To Admin',
                              variant: PillButtonVariant.secondary,
                              height: 32,
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                ref.read(authProvider.notifier).toggleRole();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.s24),

                  // SOFT ROSE LOGOUT PILL
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      ref.read(authProvider.notifier).logout();
                      context.go('/login');
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: AppRadii.pillBorder,
                        border: Border.all(color: const Color(0xFFFECDD3)),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.logout_rounded, color: AppColors.badgeRed, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            l10n.logout,
                            style: AppTextStyles.buttonText(
                              color: AppColors.badgeRed,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              isMalayalam: isMalayalam,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.s16),

                  // App version info
                  Center(
                    child: Text(
                      '${AppConfig.appName} v${AppConfig.appVersion} • Made with care for the community',
                      style: AppTextStyles.bodyText(color: AppColors.textMuted, fontSize: 10.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
