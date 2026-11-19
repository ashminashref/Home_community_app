import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/islamic_star_badge.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/quran_repository.dart';
import 'duas_screen.dart';
import 'surah_reader_screen.dart';

class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});

  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen> {
  String _searchQuery = '';
  int _selectedTabIndex = 0; // 0: Surah, 1: Juz, 2: Bookmarks
  String _revelationFilter = 'All'; // 'All', 'Meccan', 'Medinan'
  bool _isLoading = false;

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 650));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isMalayalam = locale.languageCode == 'ml';

    final filteredSurahs = QuranRepository.allSurahs.where((s) {
      if (_revelationFilter != 'All' && s.revelationType != _revelationFilter) {
        return false;
      }
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase().trim();
      return s.nameEnglish.toLowerCase().contains(q) ||
          s.nameArabic.contains(q) ||
          s.nameMalayalam.contains(q) ||
          s.number.toString() == q;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? ShimmerSkeleton.quranIndex()
            : RefreshIndicator(
                color: AppColors.primaryEmerald,
                onRefresh: _handleRefresh,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  slivers: [
                    // 1. In-Content Header matching Home reference
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.s24, AppSpacing.s12, AppSpacing.s24, AppSpacing.s16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.quran,
                            style: AppTextStyles.greetingHeading(
                              fontSize: 22,
                              isMalayalam: isMalayalam,
                            ),
                          ),
                          Text(
                            isMalayalam ? '114 അധ്യായങ്ങൾ • 30 ജുസ്ഉകൾ • പാരായണം' : '114 Surahs • 30 Juz • Recitation & Dua',
                            style: AppTextStyles.bodyText(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Link to Duas
                    PillButton(
                      label: l10n.duas,
                      variant: PillButtonVariant.outline,
                      height: 38,
                      isMalayalam: isMalayalam,
                      icon: const Icon(Icons.spa_outlined, color: AppColors.primaryEmeraldLight, size: 16),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const DuasScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 2. "Continue Reading" Emerald Hero Card with Circular Progress Ring & White Pill
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                child: AppCard(
                  backgroundColor: AppColors.primaryEmerald,
                  child: Stack(
                    children: [
                      // Subtle decorative star pattern
                      Positioned(
                        right: -15,
                        top: -15,
                        child: Opacity(
                          opacity: 0.08,
                          child: Icon(
                            Icons.brightness_7_rounded,
                            size: 150,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          // Circular Progress Ring (Ayah 1 of 7 = 14%)
                          SizedBox(
                            width: 58,
                            height: 58,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: 0.14,
                                  strokeWidth: 4.5,
                                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.emeraldAccent),
                                ),
                                const Text(
                                  '14%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.bookmark_rounded, color: AppColors.emeraldAccent, size: 14),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        isMalayalam ? 'അവസാനം വായിച്ചത്' : 'Continue Reading',
                                        style: AppTextStyles.bodyText(
                                          color: AppColors.mintText,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isMalayalam ? 'അൽ ഫാത്തിഹ' : 'Al-Fatihah',
                                  style: AppTextStyles.cardTitle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    isMalayalam: isMalayalam,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Ayah 1 of 7 • Juz 1',
                                  style: AppTextStyles.bodyText(
                                    color: AppColors.mintText,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s8),
                          PillButton(
                            label: isMalayalam ? 'തുടങ്ങാം' : 'Resume',
                            variant: PillButtonVariant.white,
                            height: 34,
                            isMalayalam: isMalayalam,
                            icon: const Icon(Icons.play_arrow_rounded, color: AppColors.primaryEmerald, size: 16),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SurahReaderScreen(surah: QuranRepository.allSurahs.first),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s16)),

            // 3. Segmented Pill Switch (Surahs • Juz • Bookmarks)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: AppRadii.pillBorder,
                    boxShadow: const [
                      BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildSegmentPill(0, '${isMalayalam ? 'സൂറത്തുകൾ' : 'Surahs'} (114)'),
                      _buildSegmentPill(1, '${isMalayalam ? 'ജുസ്അ്' : 'Juz'} (30)'),
                      _buildSegmentPill(2, '${isMalayalam ? 'സൂക്ഷിച്ചവ' : 'Bookmarks'} (${QuranRepository.userBookmarks.length})'),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s12)),

            // 4. Search and Filters
            if (_selectedTabIndex == 0) ...[
              // Search input
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Color(0x06000000), blurRadius: 10, offset: Offset(0, 3)),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: isMalayalam ? 'സൂറത്തിന്റെ പേര് അല്ലെങ്കിൽ നമ്പർ തിരയുക...' : 'Search Surah name or number...',
                              hintStyle: AppTextStyles.bodyText(color: AppColors.textMuted, fontSize: 13),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () => setState(() => _searchQuery = ''),
                            child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s8)),
              // Revelation filter pills
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                    children: [
                      _buildChip(
                        label: isMalayalam ? 'എല്ലാം' : 'All',
                        selected: _revelationFilter == 'All',
                        onTap: () => setState(() => _revelationFilter = 'All'),
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        label: isMalayalam ? 'മക്കീ സൂറത്തുകൾ' : 'Meccan',
                        selected: _revelationFilter == 'Meccan',
                        onTap: () => setState(() => _revelationFilter = 'Meccan'),
                      ),
                      const SizedBox(width: 8),
                      _buildChip(
                        label: isMalayalam ? 'മദനീയ സൂറത്തുകൾ' : 'Medinan',
                        selected: _revelationFilter == 'Medinan',
                        onTap: () => setState(() => _revelationFilter = 'Medinan'),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s12)),

            // 5A. TAB 0: All 114 Surahs
            if (_selectedTabIndex == 0) ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final surah = filteredSurahs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s10),
                        child: AppCard(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s14),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SurahReaderScreen(surah: surah),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              IslamicStarBadge(
                                number: surah.number,
                                size: 40,
                              ),
                              const SizedBox(width: AppSpacing.s16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isMalayalam ? surah.nameMalayalam : surah.nameEnglish,
                                      style: AppTextStyles.cardTitle(
                                        fontSize: 15.5,
                                        isMalayalam: isMalayalam,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: AppColors.mintMist,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            surah.revelationType.toUpperCase(),
                                            style: AppTextStyles.bodyText(
                                              color: AppColors.primaryEmeraldLight,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            '${surah.numberOfAyahs} ${l10n.ayah} • Juz ${surah.juzNumber}',
                                            style: AppTextStyles.bodyText(fontSize: 11),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s12),
                              Text(
                                surah.nameArabic,
                                style: AppTextStyles.arabicAyah(
                                  fontSize: 20,
                                  color: AppColors.primaryEmeraldLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: filteredSurahs.length,
                  ),
                ),
              ),
            ]

            // 5B. TAB 1: Complete 30 Juz
            else if (_selectedTabIndex == 1) ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final juz = QuranRepository.allJuz[index];
                      final startSurah = QuranRepository.allSurahs.firstWhere(
                        (s) => s.number == juz.startSurahNumber,
                        orElse: () => QuranRepository.allSurahs.first,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s10),
                        child: AppCard(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s14),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SurahReaderScreen(surah: startSurah),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              IslamicStarBadge(
                                number: juz.number,
                                size: 40,
                              ),
                              const SizedBox(width: AppSpacing.s16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Juz ${juz.number} • ${juz.nameEnglish}',
                                      style: AppTextStyles.cardTitle(fontSize: 15),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${juz.startSurahName} (${juz.startAyahNumber}) — ${juz.endSurahName} (${juz.endAyahNumber})',
                                      style: AppTextStyles.bodyText(
                                        color: AppColors.textSecondary,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                juz.nameArabic,
                                style: AppTextStyles.arabicAyah(
                                  fontSize: 18,
                                  color: AppColors.primaryEmeraldLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: QuranRepository.allJuz.length,
                  ),
                ),
              ),
            ]

            // 5C. TAB 2: Bookmarked Verses
            else ...[
              if (QuranRepository.userBookmarks.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.s32),
                    child: Center(
                      child: Text(
                        isMalayalam ? 'സൂക്ഷിച്ച സൂക്തങ്ങളൊന്നുമില്ല' : 'No bookmarked verses yet',
                        style: AppTextStyles.bodyText(),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final bookmark = QuranRepository.userBookmarks[index];
                        final targetSurah = QuranRepository.allSurahs.firstWhere(
                          (s) => s.number == bookmark.surahNumber,
                          orElse: () => QuranRepository.allSurahs.first,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                          child: AppCard(
                            padding: const EdgeInsets.all(AppSpacing.s16),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => SurahReaderScreen(surah: targetSurah),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.mintMist,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${bookmark.surahName} : Ayah ${bookmark.ayahNumber}',
                                        style: AppTextStyles.bodyText(
                                          color: AppColors.primaryEmeraldLight,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.bookmark_added_rounded, color: AppColors.primaryEmerald, size: 18),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  bookmark.arabicText,
                                  style: AppTextStyles.arabicAyah(fontSize: 19),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  bookmark.translationText,
                                  style: AppTextStyles.bodyText(
                                    fontSize: 12.5,
                                    color: AppColors.textSecondary,
                                    isMalayalam: isMalayalam,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: QuranRepository.userBookmarks.length,
                    ),
                  ),
                ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryEmerald : AppColors.cardSurface,
          borderRadius: AppRadii.pillBorder,
          boxShadow: selected ? null : const [BoxShadow(color: Color(0x06000000), blurRadius: 4, offset: Offset(0, 1.5))],
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyText(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentPill(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
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
}
