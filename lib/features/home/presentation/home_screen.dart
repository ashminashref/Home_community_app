import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/ruler_slider.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../certificates/domain/certificate_models.dart';
import '../../certificates/presentation/apply_certificate_screen.dart';
import '../../certificates/presentation/certificate_portal_screen.dart';
import '../../certificates/providers/certificate_provider.dart';
import '../../payments/presentation/payments_screen.dart';
import '../../payments/presentation/zakat_calculator_screen.dart';
import '../../prayer/presentation/prayer_screen.dart';
import '../../prayer/presentation/qibla_compass_screen.dart';
import '../../quran/presentation/duas_screen.dart';
import '../../quran/presentation/quran_screen.dart';
import '../../tracking/providers/tracking_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isMalayalam = locale.languageCode == 'ml';
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final mahal = authState.currentMahal;
    final trackingState = ref.watch(trackingProvider);
    final certState = ref.watch(certificateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: authState.isLoading
            ? ShimmerSkeleton.homeScreen()
            : RefreshIndicator(
                color: AppColors.primaryEmerald,
                onRefresh: () => ref.read(authProvider.notifier).refresh(),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  slivers: [
                    // In-content Header matching Reference Screen 2
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.s24, AppSpacing.s12, AppSpacing.s24, AppSpacing.s12),
                child: Row(
                  children: [
                    // User Avatar with clean soft border
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.mintMist,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x10000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                        image: user?.avatarUrl != null
                            ? DecorationImage(
                                image: NetworkImage(user!.avatarUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: user?.avatarUrl == null
                          ? const Icon(Icons.person, color: AppColors.primaryEmerald)
                          : null,
                    ),
                    const SizedBox(width: AppSpacing.s12),

                    // Greeting & Location
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user != null ? '${l10n.greeting}, ${user.name.split(' ').first}!' : '${l10n.greeting}!',
                            style: AppTextStyles.greetingHeading(
                              color: AppColors.textPrimary,
                              isMalayalam: isMalayalam,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 13,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  mahal.location,
                                  style: AppTextStyles.bodyText(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Circular White Bell Button with Notification Dot
                    GestureDetector(
                      onTap: () {
                        _showNotificationsSheet(context, isMalayalam);
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.cardSurface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x0C000000),
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.notifications_none_rounded,
                              color: AppColors.textPrimary,
                              size: 22,
                            ),
                            Positioned(
                              top: 11,
                              right: 12,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.badgeRed,
                                  shape: BoxShape.circle,
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
            ),

            // Services Quick Ribbon (Replacing story row with pristine luxury pill access)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                  children: [
                    _buildServicePill(
                      context,
                      icon: Icons.assignment_outlined,
                      label: isMalayalam ? 'സർട്ടിഫിക്കറ്റ്' : 'Certificates',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CertificatePortalScreen()),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildServicePill(
                      context,
                      icon: Icons.receipt_long_rounded,
                      label: l10n.payChanda,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PaymentsScreen(initialTab: 0)),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildServicePill(
                      context,
                      icon: Icons.menu_book_rounded,
                      label: l10n.quran,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const QuranScreen()),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildServicePill(
                      context,
                      icon: Icons.spa_rounded,
                      label: l10n.duas,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const DuasScreen()),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildServicePill(
                      context,
                      icon: Icons.volunteer_activism_rounded,
                      label: l10n.donate,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PaymentsScreen(initialTab: 1)),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildServicePill(
                      context,
                      icon: Icons.calculate_outlined,
                      label: isMalayalam ? 'സകാത്ത്' : 'Zakat Calc',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ZakatCalculatorScreen()),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildServicePill(
                      context,
                      icon: Icons.explore_rounded,
                      label: isMalayalam ? 'ഖിബ്‌ല' : 'Qibla',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const QiblaCompassScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s16)),

            // Feature Card 1 (Matches Reference Ramadan Moments Card)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                child: AppCard(
                  child: Stack(
                    children: [
                      // Content on the left
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                l10n.ramadanMoments,
                                style: AppTextStyles.cardTitle(
                                  fontSize: 17,
                                  isMalayalam: isMalayalam,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text('🌙', style: TextStyle(fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.s4),
                          SizedBox(
                            width: 190,
                            child: Text(
                              l10n.ramadanSubtitle,
                              style: AppTextStyles.bodyText(
                                color: AppColors.textSecondary,
                                fontSize: 11.5,
                                isMalayalam: isMalayalam,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s16),
                          PillButton(
                            label: l10n.ramadanSpecial,
                            variant: PillButtonVariant.primary,
                            height: 38,
                            isMalayalam: isMalayalam,
                            icon: const Icon(
                              Icons.play_circle_fill_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const PrayerScreen()),
                              );
                            },
                          ),
                        ],
                      ),

                      // Mosque 3D Architecture Graphic at bottom right
                      Positioned(
                        right: -10,
                        bottom: -15,
                        child: Opacity(
                          opacity: 0.95,
                          child: Icon(
                            Icons.mosque_rounded,
                            size: 105,
                            color: AppColors.primaryEmeraldLight.withValues(alpha: 0.20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s16)),

            // Feature Card 2 (Matches Reference Community Photo Card)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                child: AppCard(
                  padding: const EdgeInsets.all(AppSpacing.s12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rounded Photo of Grand Mosque
                      ClipRRect(
                        borderRadius: AppRadii.innerImageBorder,
                        child: Container(
                          height: 140,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE2E8F0),
                            image: DecorationImage(
                              image: NetworkImage('https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?w=800'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),

                      // Author Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFCBD5E1),
                                image: DecorationImage(
                                  image: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isMalayalam ? 'സെക്രട്ടറി അറിയിപ്പ് ചേർത്തതാണ്' : 'Aziz Added Islamic Picture',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.cardTitle(
                                      fontSize: 12.5,
                                      isMalayalam: isMalayalam,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 10, color: AppColors.textMuted),
                                      const SizedBox(width: 2),
                                      Expanded(
                                        child: Text(
                                          mahal.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.bodyText(
                                            color: AppColors.textSecondary,
                                            fontSize: 10.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s16)),

            // Feature Card 3 (Matches Reference "Do You Fast Today?" Ruler Slider)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.doYouFastToday,
                        style: AppTextStyles.cardTitle(
                          fontSize: 16,
                          isMalayalam: isMalayalam,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.fastingHabitSubtitle,
                        style: AppTextStyles.bodyText(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          isMalayalam: isMalayalam,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),

                      // Horizontal Ruler Slider with tick marks!
                      RulerSlider(
                        min: 1,
                        max: 30,
                        value: trackingState.fastedDays,
                        leftLabel: '06',
                        rightLabel: '30',
                        onChanged: (val) {
                          ref.read(trackingProvider.notifier).setFastedDays(val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s16)),

            // Card 4: Mahal Community & Records Notice Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                child: AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.mintMist,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Icon(Icons.assignment_turned_in_outlined, color: AppColors.primaryEmerald, size: 22),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMalayalam ? 'മഹല്ല് സർട്ടിഫിക്കറ്റ് സേവനങ്ങൾ' : 'Mahal Certificate Services',
                              style: AppTextStyles.cardTitle(fontSize: 13.5, isMalayalam: isMalayalam),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isMalayalam ? 'വിവാഹം, ജനനം, മരണം സാക്ഷ്യപത്രങ്ങൾ' : 'Marriage, Birth & Demise attestations',
                              style: AppTextStyles.bodyText(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      PillButton(
                        label: isMalayalam ? 'തുറക്കുക' : 'Open',
                        variant: PillButtonVariant.primary,
                        height: 34,
                        isMalayalam: isMalayalam,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CertificatePortalScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom space for floating navigation bar
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildServicePill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadii.pillBorder,
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primaryEmerald),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showJanazaDetailSheet(BuildContext context, bool isMalayalam) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.s24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.campaign_rounded, color: AppColors.badgeRed, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMalayalam ? 'മയ്യിത്ത് നമസ്കാരം അറിയിപ്പ്' : 'Janaza Prayer Notification',
                          style: AppTextStyles.cardTitle(fontSize: 16),
                        ),
                        Text(
                          'Ekarool Central Juma Masjid Mahal Committee',
                          style: AppTextStyles.bodyText(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s16),
              Container(
                padding: const EdgeInsets.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  color: AppColors.mintMist,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'NotoNaskhArabic',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryEmerald,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isMalayalam
                          ? 'ഏകരൂൽ സ്വദേശി കുന്നത്ത് പറമ്പിൽ അലവി ഹാജി (78) നിര്യാതനായി. മയ്യിത്ത് നമസ്കാരം ഇന്ന് അസർ നമസ്കാരാനന്തരം (4:45 PM) ഏകരൂൽ സെൻട്രൽ ജുമാ മസ്ജിദിൽ നടക്കും. ഖബറടക്കം മഹല്ല് ഖബർസ്ഥാനിൽ.'
                          : 'Late Kunnathu Parambil Alavi Haji (78) passed away. Janaza prayer will be held today immediately after Asr (4:45 PM) at Ekarool Central Juma Masjid followed by burial at Mahal Qabarsthan.',
                      style: const TextStyle(fontSize: 12.5, height: 1.5, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              Row(
                children: [
                  Expanded(
                    child: PillButton(
                      label: 'Call Helpline',
                      variant: PillButtonVariant.secondary,
                      height: 44,
                      icon: const Icon(Icons.phone_in_talk_rounded, size: 16, color: AppColors.primaryEmerald),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: PillButton(
                      label: 'Share Notice',
                      variant: PillButtonVariant.primary,
                      height: 44,
                      icon: const Icon(Icons.share_rounded, size: 16, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationsSheet(BuildContext context, bool isMalayalam) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.s24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              Text(
                isMalayalam ? 'അറിയിപ്പുകൾ' : 'Mahal Announcements',
                style: AppTextStyles.cardTitle(fontSize: 17),
              ),
              const SizedBox(height: AppSpacing.s16),
              _buildNotificationItem(
                title: 'Monthly Chanda Due Reminder',
                time: '2 hours ago',
                icon: Icons.receipt_long_rounded,
                isUnread: true,
              ),
              _buildNotificationItem(
                title: 'Nikkah Certificate Ready for Download',
                time: 'Yesterday',
                icon: Icons.verified_rounded,
                isUnread: false,
              ),
              _buildNotificationItem(
                title: 'Friday Khutbah Topic: Parents in Islam',
                time: '2 days ago',
                icon: Icons.mic_none_rounded,
                isUnread: false,
              ),
              const SizedBox(height: AppSpacing.s16),
              PillButton(
                label: 'Close',
                variant: PillButtonVariant.primary,
                fullWidth: true,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String time,
    required IconData icon,
    required bool isUnread,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isUnread ? AppColors.mintMist : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isUnread ? AppColors.primaryEmerald : AppColors.textMuted, size: 20),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(time, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
              ],
            ),
          ),
          if (isUnread)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: AppColors.badgeRed, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}
