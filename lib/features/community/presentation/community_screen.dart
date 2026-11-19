import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/islamic_star_badge.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../quran/data/quran_repository.dart';
import '../../quran/presentation/surah_reader_screen.dart';
import '../domain/community_models.dart';
import '../providers/community_provider.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  int _selectedTabIndex = 0; // 0: Notices & Alerts, 1: Khatm Al-Quran, 2: Committee

  // Community Khatm 30 Juz state
  late List<KhatmJuzAssignment> _khatmJuzList;

  @override
  void initState() {
    super.initState();
    _initializeKhatmJuz();
  }

  void _initializeKhatmJuz() {
    final sampleReaders = [
      'Abdulla K. (വടക്കേതിൽ)',
      'Fatima M. (ബൈത്തുൽ നൂർ)',
      'Muhammedali P. (പിലാത്തോട്ടം)',
      'Aisha C. (ചാത്തോത്ത്)',
      'Usman Haji (കിഴക്കേക്കര)',
      'Zainaba (പുത്തൻപുര)',
      'Ibrahim V. (കുന്നത്തുപറമ്പ്)',
      'Khadija (മണ്ണിൽ)',
    ];

    _khatmJuzList = List.generate(30, (i) {
      final juzNumber = i + 1;
      final juzInfo = QuranRepository.allJuz[i];
      final isCompleted = i < 18;
      final isClaimed = i < 24;
      final reader = isClaimed ? sampleReaders[i % sampleReaders.length] : null;

      return KhatmJuzAssignment(
        juzNumber: juzNumber,
        juzNameArabic: juzInfo.nameArabic,
        readerName: reader,
        isCompleted: isCompleted,
        completedAt: isCompleted ? DateTime.now().subtract(Duration(hours: 30 - i)) : null,
      );
    });
  }

  int get _completedJuzCount => _khatmJuzList.where((j) => j.isCompleted).length;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isMalayalam = locale.languageCode == 'ml';
    final communityState = ref.watch(communityProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.s24, AppSpacing.s12, AppSpacing.s24, AppSpacing.s12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.community,
                          style: AppTextStyles.greetingHeading(
                            fontSize: 22,
                            isMalayalam: isMalayalam,
                          ),
                        ),
                        Text(
                          isMalayalam ? 'മഹല്ല് അറിയിപ്പുകൾ • ഖത്മുൽ ഖുർആൻ • കമ്മിറ്റി' : 'Mahal Notices • Community Khatm • Committee',
                          style: AppTextStyles.bodyText(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Segmented Pill Switch (No default TabBar)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: AppRadii.pillBorder,
                  boxShadow: const [
                    BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    _buildSegmentPill(0, isMalayalam ? 'അറിയിപ്പുകൾ' : 'Notices & SOS'),
                    _buildSegmentPill(1, isMalayalam ? 'ഖത്മുൽ ഖുർആൻ' : 'Khatm Al-Quran'),
                    _buildSegmentPill(2, isMalayalam ? 'കമ്മിറ്റി' : 'Committee'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.s12),

            // Body
            Expanded(
              child: _selectedTabIndex == 0
                  ? _buildNoticesAndAlertsView(isMalayalam, communityState)
                  : _selectedTabIndex == 1
                      ? _buildKhatmulQuranView(isMalayalam)
                      : _buildCommitteeView(isMalayalam, communityState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentPill(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedTabIndex = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryEmerald : Colors.transparent,
            borderRadius: AppRadii.pillBorder,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.buttonText(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: NOTICES, JANAZA & EMERGENCY BLOOD SOS ALERTS
  // ---------------------------------------------------------------------------
  Widget _buildNoticesAndAlertsView(bool isMalayalam, CommunityState communityState) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(AppSpacing.s24, 0, AppSpacing.s24, 100),
      children: [
        // 1. URGENT JANAZA BROADCAST CARD (Kerala Mahal Signature)
        AppCard(
          backgroundColor: const Color(0xFF0F172A), // Elegant dark slate for solemnity
          padding: const EdgeInsets.all(AppSpacing.s18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: AppRadii.pillBorder,
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.notifications_active_rounded, color: Color(0xFF38BDF8), size: 14),
                        const SizedBox(width: 6),
                        Text(
                          isMalayalam ? 'മരണ അറിയിപ്പ് (ജനാസ)' : 'URGENT JANAZA NOTICE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text('ഇന്ന് / Today', style: TextStyle(color: Colors.white60, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                isMalayalam
                    ? 'മൊയ്തീൻ കുട്ടി ഹാജി (74)'
                    : 'Moideen Kutty Haji (74)',
                style: AppTextStyles.cardTitle(
                  color: Colors.white,
                  fontSize: 17,
                  isMalayalam: isMalayalam,
                ),
              ),
              Text(
                isMalayalam ? 'വടക്കേതിൽ വീട്, എകരൂൽ തെരുവ്' : 'Vadakkethil House, Ekarool Ward 4',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: AppColors.emeraldAccent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isMalayalam
                            ? 'ജനാസ നമസ്കാരം: ഇന്ന് അസർ നമസ്കാര ശേഷം (4:45 PM) എകരൂൽ വലിയ ജുമാ മസ്ജിദിൽ'
                            : 'Janaza Prayer: Today after Asr Salah (4:45 PM) at Ekarool Juma Masjid',
                        style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: PillButton(
                      label: isMalayalam ? 'ഖബർസ്ഥാൻ ലൊക്കേഷൻ' : 'Graveyard Route',
                      variant: PillButtonVariant.secondary,
                      height: 34,
                      isMalayalam: isMalayalam,
                      icon: const Icon(Icons.directions_rounded, size: 14, color: AppColors.primaryEmerald),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Opening Google Maps route to Ekarool Mahal Qabarsthan...'),
                            backgroundColor: AppColors.primaryEmerald,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  PillButton(
                    label: isMalayalam ? 'അറിയിക്കുക' : 'Share',
                    variant: PillButtonVariant.white,
                    height: 34,
                    isMalayalam: isMalayalam,
                    icon: const Icon(Icons.share_rounded, size: 14, color: AppColors.primaryEmerald),
                    onPressed: () {
                      Share.share('ഇന്നാ ലില്ലാഹി വഇന്നാ ഇലൈഹി റാജിഊൻ.\n\nമൊയ്തീൻ കുട്ടി ഹാജി (74) നിര്യാതനായി. ജനാസ നമസ്കാരം ഇന്ന് അസർ നമസ്കാര ശേഷം എകരൂൽ ജുമാ മസ്ജിദ് ഖബർസ്ഥാനിൽ.\n\nShared via Mahal App');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.s12),

        // 2. EMERGENCY BLOOD DONATION SOS CARD
        AppCard(
          backgroundColor: const Color(0xFFFFF1F2), // Light urgent red wash
          border: Border.all(color: const Color(0xFFFDA4AF)),
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'BLOOD SOS: O+ve',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isMalayalam ? 'രക്തദാനം അടിയന്തിരം' : 'Urgent Donor Needed',
                        style: const TextStyle(color: Color(0xFF9F1239), fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const Icon(Icons.bloodtype_rounded, color: Color(0xFFE11D48), size: 22),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isMalayalam
                    ? 'രോഗി: അബ്ദുൽ റഹ്മാൻ (38) • ഗവ. മെഡിക്കൽ കോളേജ്, കോഴിക്കോട് (ഐ.സി.യു വാർഡ്)'
                    : 'Patient: Abdul Rahman (38) • Govt Medical College Kozhikode (ICU Ward)',
                style: const TextStyle(color: Color(0xFF881337), fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: PillButton(
                      label: isMalayalam ? 'സഹായിയെ വിളിക്കുക' : 'Call Coordinator',
                      variant: PillButtonVariant.primary,
                      height: 34,
                      isMalayalam: isMalayalam,
                      icon: const Icon(Icons.call_rounded, size: 14, color: Colors.white),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Calling Mahal Blood Cell Coordinator (+91 98471 23456)...'),
                            backgroundColor: Color(0xFFE11D48),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  PillButton(
                    label: isMalayalam ? 'ഗ്രൂപ്പുകളിൽ പങ്കുവെക്കുക' : 'Share SOS',
                    variant: PillButtonVariant.secondary,
                    height: 34,
                    isMalayalam: isMalayalam,
                    icon: const Icon(Icons.share_outlined, size: 14, color: Color(0xFFE11D48)),
                    onPressed: () {
                      Share.share('രക്തദാനം അടിയന്തിരം!\nO+ve രക്തം ആവശ്യമുണ്ട്. രോഗി: അബ്ദുൽ റഹ്മാൻ (38), ഗവ. മെഡിക്കൽ കോളേജ് കോഴിക്കോട്.\nബന്ധപ്പെടുക: +91 98471 23456\nShared via Mahal App');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.s16),

        // Filter Pills Row
        SizedBox(
          height: 34,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterChip(
                label: 'All',
                isSelected: communityState.selectedFilter == null,
                onTap: () => ref.read(communityProvider.notifier).setFilter(null),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: isMalayalam ? 'മരണങ്ങൾ (ജനാസ)' : 'Janaza',
                isSelected: communityState.selectedFilter == NoticeCategory.janaza,
                onTap: () => ref.read(communityProvider.notifier).setFilter(NoticeCategory.janaza),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: isMalayalam ? 'ഖുതുബ' : 'Khutbah',
                isSelected: communityState.selectedFilter == NoticeCategory.khutbah,
                onTap: () => ref.read(communityProvider.notifier).setFilter(NoticeCategory.khutbah),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: isMalayalam ? 'പരിപാടികൾ' : 'Events',
                isSelected: communityState.selectedFilter == NoticeCategory.event,
                onTap: () => ref.read(communityProvider.notifier).setFilter(NoticeCategory.event),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.s12),

        // Notices Feed Cards
        ...communityState.filteredNotices.map((notice) {
          final isJanaza = notice.category == NoticeCategory.janaza;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s12),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpacing.s16),
              border: isJanaza ? Border.all(color: const Color(0xFF1E293B), width: 1.5) : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isJanaza ? const Color(0xFF0F172A) : AppColors.mintMist,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          notice.category.name.toUpperCase(),
                          style: AppTextStyles.bodyText(
                            color: isJanaza ? Colors.white : AppColors.primaryEmeraldLight,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (notice.eventDate != null)
                        Row(
                          children: [
                            const Icon(Icons.event_outlined, size: 12, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              notice.eventDate!,
                              style: AppTextStyles.bodyText(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s10),
                  Text(
                    isMalayalam ? notice.titleMl : notice.titleEn,
                    style: AppTextStyles.cardTitle(fontSize: 15.5, isMalayalam: isMalayalam),
                  ),
                  const SizedBox(height: AppSpacing.s6),
                  Text(
                    isMalayalam ? notice.contentMl : notice.contentEn,
                    style: AppTextStyles.bodyText(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      isMalayalam: isMalayalam,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('By ${notice.author}', style: AppTextStyles.bodyText(color: AppColors.textMuted, fontSize: 11)),
                      Row(
                        children: [
                          if (notice.category == NoticeCategory.event)
                            TextButton.icon(
                              onPressed: () {
                                ref.read(communityProvider.notifier).toggleRsvp(notice.id);
                              },
                              icon: Icon(
                                notice.hasRsvp ? Icons.check_circle : Icons.add_circle_outline,
                                size: 16,
                                color: AppColors.primaryEmeraldLight,
                              ),
                              label: Text(
                                'RSVP (${notice.rsvpCount})',
                                style: AppTextStyles.buttonText(color: AppColors.primaryEmeraldLight, fontSize: 11),
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.share_outlined, size: 18, color: AppColors.textSecondary),
                            onPressed: () {
                              Share.share('${notice.titleEn}\n\n${notice.contentEn}\n\nShared via Mahal App');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: KHATMUL QURAN COMMUNITY COLLECTIVE TRACKER
  // ---------------------------------------------------------------------------
  Widget _buildKhatmulQuranView(bool isMalayalam) {
    final progress = _completedJuzCount / 30.0;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(AppSpacing.s24, 0, AppSpacing.s24, 100),
      children: [
        // Hero Progress Card
        AppCard(
          backgroundColor: AppColors.primaryEmerald,
          padding: const EdgeInsets.all(AppSpacing.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.emeraldAccent,
                      borderRadius: AppRadii.pillBorder,
                    ),
                    child: Text(
                      isMalayalam ? 'മഹല്ല് ഖത്മ് #18' : 'MAHAL KHATM #18',
                      style: const TextStyle(
                        color: AppColors.primaryEmerald,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    '${(_completedJuzCount / 30 * 100).round()}% Completed',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                isMalayalam ? 'മഹല്ല് സമൂഹ ഖത്മുൽ ഖുർആൻ' : 'Community Khatmul Quran Tally',
                style: AppTextStyles.cardTitle(color: Colors.white, fontSize: 18, isMalayalam: isMalayalam),
              ),
              Text(
                isMalayalam ? '30 ജുസ്ഉകളിൽ $_completedJuzCount എണ്ണം പൂർത്തിയായി' : '$_completedJuzCount of 30 Juz Recited & Verified',
                style: const TextStyle(color: AppColors.mintText, fontSize: 12),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 7,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.emeraldAccent),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.s16),

        // 30 Juz interactive cards
        Text(
          isMalayalam ? 'ജുസ്അ് തിരഞ്ഞെടുക്കുക / വായിക്കുക' : 'Claim or Read Your Assigned Juz',
          style: AppTextStyles.cardTitle(fontSize: 15, isMalayalam: isMalayalam),
        ),
        const SizedBox(height: AppSpacing.s8),

        ..._khatmJuzList.map((assignment) {
          final isClaimed = assignment.readerName != null;
          final startSurah = QuranRepository.allSurahs.firstWhere(
            (s) => s.juzNumber == assignment.juzNumber,
            orElse: () => QuranRepository.allSurahs.first,
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s10),
            child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s12),
              child: Row(
                children: [
                  IslamicStarBadge(number: assignment.juzNumber, size: 38),
                  const SizedBox(width: AppSpacing.s14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Juz ${assignment.juzNumber}',
                              style: AppTextStyles.cardTitle(fontSize: 14),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              assignment.juzNameArabic,
                              style: AppTextStyles.arabicAyah(fontSize: 16, color: AppColors.primaryEmeraldLight),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isClaimed
                              ? '${assignment.readerName} ${assignment.isCompleted ? "• പൂർത്തിയായി ✓" : "• ഓതുന്നു..."}'
                              : (isMalayalam ? 'ലഭ്യമാണ് (ആരും ഏറ്റെടുത്തിട്ടില്ല)' : 'Available to Claim'),
                          style: TextStyle(
                            color: assignment.isCompleted
                                ? AppColors.primaryEmeraldLight
                                : isClaimed
                                    ? AppColors.textSecondary
                                    : AppColors.sunsetCoral,
                            fontSize: 11,
                            fontWeight: assignment.isCompleted ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!assignment.isCompleted)
                    PillButton(
                      label: isClaimed ? (isMalayalam ? 'ഓതാം' : 'Read') : (isMalayalam ? 'ഏറ്റെടുക്കാം' : 'Claim'),
                      variant: isClaimed ? PillButtonVariant.outline : PillButtonVariant.primary,
                      height: 30,
                      isMalayalam: isMalayalam,
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        if (!isClaimed) {
                          setState(() {
                            final idx = _khatmJuzList.indexWhere((j) => j.juzNumber == assignment.juzNumber);
                            if (idx != -1) {
                              _khatmJuzList[idx] = assignment.copyWith(readerName: 'You (നിങ്ങൾ)');
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Juz ${assignment.juzNumber} claimed by you. May Allah accept your recitation!'),
                              backgroundColor: AppColors.primaryEmerald,
                            ),
                          );
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => SurahReaderScreen(surah: startSurah)),
                          );
                        }
                      },
                    )
                  else
                    const Icon(Icons.check_circle_rounded, color: AppColors.primaryEmeraldLight, size: 22),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: COMMITTEE MEMBERS DIRECTORY
  // ---------------------------------------------------------------------------
  Widget _buildCommitteeView(bool isMalayalam, CommunityState communityState) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(AppSpacing.s24, AppSpacing.s4, AppSpacing.s24, 100),
      itemCount: communityState.committee.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s12),
      itemBuilder: (context, index) {
        final member = communityState.committee[index];

        return AppCard(
          padding: const EdgeInsets.all(AppSpacing.s16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.mintMist,
                ),
                child: Center(
                  child: Text(
                    member.name.isNotEmpty ? member.name[0] : 'M',
                    style: const TextStyle(
                      color: AppColors.primaryEmerald,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: AppTextStyles.cardTitle(
                        fontSize: 15,
                        isMalayalam: isMalayalam,
                      ),
                    ),
                    Text(
                      '${isMalayalam ? member.roleMl : member.roleEn} • ${member.houseName}',
                      style: AppTextStyles.bodyText(
                        color: AppColors.primaryEmeraldLight,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        isMalayalam: isMalayalam,
                      ),
                    ),
                    Text(
                      member.phone,
                      style: AppTextStyles.bodyText(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.call_outlined, color: AppColors.primaryEmerald),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Calling ${member.name} (${member.phone})'),
                      backgroundColor: AppColors.primaryEmerald,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryEmerald : AppColors.cardSurface,
          borderRadius: AppRadii.pillBorder,
          boxShadow: isSelected ? null : const [BoxShadow(color: Color(0x06000000), blurRadius: 4, offset: Offset(0, 1.5))],
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyText(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
