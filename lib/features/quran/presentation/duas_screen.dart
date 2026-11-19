import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/glass_back_button.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../tracking/providers/tracking_provider.dart';
import '../data/quran_repository.dart';

class DuasScreen extends ConsumerStatefulWidget {
  const DuasScreen({super.key});

  @override
  ConsumerState<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends ConsumerState<DuasScreen> {
  int _selectedTabIndex = 0; // 0 = Daily Duas, 1 = Digital Tasbih
  String _selectedCategory = 'All';
  String _duaSearchQuery = '';
  final Set<String> _favoriteDuaIds = {'dua_morning_sayyid', 'dua_younus_relief', 'dua_parents_quran'};
  String? _currentlyPlayingDuaId;
  bool _isLoading = false;

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 650));
    if (mounted) setState(() => _isLoading = false);
  }

  // Tasbih config
  final List<_DhikrPreset> _dhikrPresets = [
    const _DhikrPreset(
      nameEn: 'SubhanAllah',
      nameMl: 'സുബ്ഹാനല്ലാഹ്',
      arabic: 'سُبْحَانَ اللَّهِ',
      meaningEn: 'Glory be to Allah',
      meaningMl: 'അല്ലാഹു എത്രയോ പരിശുദ്ധൻ',
      target: 33,
    ),
    const _DhikrPreset(
      nameEn: 'Alhamdulillah',
      nameMl: 'അൽഹംദുലില്ലാഹ്',
      arabic: 'الْحَمْدُ لِلَّهِ',
      meaningEn: 'All praise is due to Allah',
      meaningMl: 'സർവ്വസ്തുതിയും അല്ലാഹുവിന്',
      target: 33,
    ),
    const _DhikrPreset(
      nameEn: 'Allahu Akbar',
      nameMl: 'അല്ലാഹു അക്ബർ',
      arabic: 'اللَّهُ أَكْبَرُ',
      meaningEn: 'Allah is the Greatest',
      meaningMl: 'അല്ലാഹു ഏറ്റവും വലിയവൻ',
      target: 34,
    ),
    const _DhikrPreset(
      nameEn: 'Astaghfirullah',
      nameMl: 'അസ്തഗ്ഫിറുല്ലാഹ്',
      arabic: 'أَسْتَغْفِرُ اللَّهَ',
      meaningEn: 'I seek forgiveness from Allah',
      meaningMl: 'ഞാൻ അല്ലാഹുവോട് പാപമോചനം തേടുന്നു',
      target: 100,
    ),
    const _DhikrPreset(
      nameEn: 'La Ilaha Illallah',
      nameMl: 'ലാ ഇലാഹ ഇല്ലല്ലാഹ്',
      arabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
      meaningEn: 'There is no god but Allah',
      meaningMl: 'അല്ലാഹുവല്ലാതെ മറ്റൊരു ഇലാഹുമില്ല',
      target: 100,
    ),
  ];

  int _selectedDhikrIndex = 0;
  int _lapCount = 0;
  int _customTarget = 33;
  bool _hapticEnabled = true;

  @override
  void initState() {
    super.initState();
    _customTarget = _dhikrPresets[0].target;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isMalayalam = locale.languageCode == 'ml';
    final trackingState = ref.watch(trackingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s12),
              child: Row(
                children: [
                  GlassBackButton(
                    iconColor: AppColors.primaryEmerald,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.duas,
                          style: AppTextStyles.cardTitle(
                            fontSize: 18,
                            isMalayalam: isMalayalam,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          isMalayalam ? '32+ പ്രാർത്ഥനകൾ • ഡിജിറ്റൽ തസ്ബീഹ്' : '32+ Authentic Duas & Digital Tasbih',
                          style: AppTextStyles.bodyText(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            isMalayalam: isMalayalam,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Segmented Pill Switch (Daily Duas vs Digital Tasbih)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: AppSpacing.s8),
              child: Container(
                height: 46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.cardSurfaceMuted,
                  borderRadius: AppRadii.pillBorder,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedTabIndex = 0);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 0 ? AppColors.primaryEmerald : Colors.transparent,
                            borderRadius: AppRadii.pillBorder,
                            boxShadow: _selectedTabIndex == 0 ? AppShadows.subtle : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isMalayalam ? 'പ്രാർത്ഥനകൾ (ഹിസ്നുൽ മുസ്ലിം)' : 'Daily Duas (${QuranRepository.sampleDuas.length})',
                            style: AppTextStyles.buttonText(
                              color: _selectedTabIndex == 0 ? Colors.white : AppColors.textSecondary,
                              fontSize: 12.5,
                              fontWeight: _selectedTabIndex == 0 ? FontWeight.w600 : FontWeight.w500,
                              isMalayalam: isMalayalam,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedTabIndex = 1);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 1 ? AppColors.primaryEmerald : Colors.transparent,
                            borderRadius: AppRadii.pillBorder,
                            boxShadow: _selectedTabIndex == 1 ? AppShadows.subtle : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isMalayalam ? 'ഡിജിറ്റൽ തസ്ബീഹ്' : 'Digital Tasbih',
                            style: AppTextStyles.buttonText(
                              color: _selectedTabIndex == 1 ? Colors.white : AppColors.textSecondary,
                              fontSize: 12.5,
                              fontWeight: _selectedTabIndex == 1 ? FontWeight.w600 : FontWeight.w500,
                              isMalayalam: isMalayalam,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.s6),

            // Content Area
            Expanded(
              child: _selectedTabIndex == 0
                  ? _buildDuasListView(isMalayalam)
                  : _buildTasbihView(isMalayalam, trackingState),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: DAILY DUAS (HISNUL MUSLIM)
  // ---------------------------------------------------------------------------
  Widget _buildDuasListView(bool isMalayalam) {
    final categories = [
      {'en': 'All', 'ml': 'എല്ലാം'},
      {'en': 'Favorites', 'ml': 'പ്രിയപ്പെട്ടവ'},
      {'en': 'Morning & Evening', 'ml': 'പ്രഭാതം & സന്ധ്യ'},
      {'en': 'Salah & Wudu', 'ml': 'നമസ്കാരം & വുളൂഅ്'},
      {'en': 'Daily Habits', 'ml': 'നിത്യജീവിതം'},
      {'en': 'Ruqyah & Healing', 'ml': 'രോഗശമനം'},
      {'en': 'Travel & Protection', 'ml': 'യാത്രയും കാവലും'},
      {'en': 'Family & Parents', 'ml': 'കുടുംബം'},
      {'en': 'Forgiveness & Tawbah', 'ml': 'പാപമോചനം'},
      {'en': 'Distress & Hardship', 'ml': 'വിഷമഘട്ടം'},
    ];

    final filteredDuas = QuranRepository.sampleDuas.where((d) {
      if (_selectedCategory == 'Favorites') {
        if (!_favoriteDuaIds.contains(d.id)) return false;
      } else if (_selectedCategory != 'All' && d.categoryEn != _selectedCategory) {
        return false;
      }

      if (_duaSearchQuery.isEmpty) return true;
      final q = _duaSearchQuery.toLowerCase().trim();
      return d.titleEn.toLowerCase().contains(q) ||
          d.titleMl.contains(q) ||
          d.arabic.contains(q) ||
          d.transliteration.toLowerCase().contains(q) ||
          d.meaningEn.toLowerCase().contains(q) ||
          d.meaningMl.contains(q) ||
          d.reference.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: 4),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => _duaSearchQuery = val),
                    decoration: InputDecoration(
                      hintText: isMalayalam ? 'പ്രാർത്ഥനകൾ തിരയുക...' : 'Search Duas by keyword or category...',
                      hintStyle: AppTextStyles.bodyText(color: AppColors.textMuted, fontSize: 12),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_duaSearchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _duaSearchQuery = ''),
                    child: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Horizontal category pill carousel
        SizedBox(
          height: 36,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final catEn = cat['en']!;
              final isSelected = _selectedCategory == catEn;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedCategory = catEn);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryEmerald : AppColors.cardSurface,
                    borderRadius: AppRadii.pillBorder,
                    border: Border.all(
                      color: isSelected ? AppColors.primaryEmerald : AppColors.cardBorder,
                      width: 1,
                    ),
                    boxShadow: isSelected ? AppShadows.subtle : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (catEn == 'Favorites') ...[
                        Icon(
                          Icons.favorite_rounded,
                          size: 13,
                          color: isSelected ? Colors.white : const Color(0xFFE53E3E),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        isMalayalam ? cat['ml']! : catEn,
                        style: AppTextStyles.bodyText(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          isMalayalam: isMalayalam,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: AppSpacing.s10),

        // Dua Cards List
        Expanded(
          child: _isLoading
              ? ShimmerSkeleton.duasList()
              : RefreshIndicator(
                  color: AppColors.primaryEmerald,
                  onRefresh: _handleRefresh,
                  child: filteredDuas.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 80),
                            Center(
                              child: Text(
                                isMalayalam ? 'പ്രാർത്ഥനകളൊന്നും കണ്ടെത്തിയില്ല' : 'No Duas found matching your filter',
                                style: AppTextStyles.bodyText(),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.fromLTRB(AppSpacing.s24, AppSpacing.s4, AppSpacing.s24, 100),
                          itemCount: filteredDuas.length,
                          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.s14),
                          itemBuilder: (context, index) {
                    final dua = filteredDuas[index];
                    final isFav = _favoriteDuaIds.contains(dua.id);
                    final isPlaying = _currentlyPlayingDuaId == dua.id;

                    return AppCard(
                      padding: const EdgeInsets.all(AppSpacing.s18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Meta row: Category pill + Reference + Fav + Share + Audio
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.mintMist,
                                  borderRadius: AppRadii.pillBorder,
                                ),
                                child: Text(
                                  isMalayalam ? dua.categoryMl : dua.categoryEn,
                                  style: AppTextStyles.bodyText(
                                    color: AppColors.primaryEmeraldLight,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    isMalayalam: isMalayalam,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s8),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Audio Recitation simulation
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        setState(() {
                                          _currentlyPlayingDuaId = isPlaying ? null : dua.id;
                                        });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isPlaying
                                                  ? 'Recitation stopped'
                                                  : 'Playing recitation: ${isMalayalam ? dua.titleMl : dua.titleEn}',
                                            ),
                                            backgroundColor: AppColors.primaryEmerald,
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: isPlaying ? AppColors.primaryEmerald : AppColors.cardSurfaceMuted,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isPlaying ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
                                          size: 15,
                                          color: isPlaying ? Colors.white : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    // Favorite toggle
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        setState(() {
                                          if (isFav) {
                                            _favoriteDuaIds.remove(dua.id);
                                          } else {
                                            _favoriteDuaIds.add(dua.id);
                                          }
                                        });
                                      },
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: isFav ? const Color(0xFFFFECEC) : AppColors.cardSurfaceMuted,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                          size: 15,
                                          color: isFav ? const Color(0xFFE53E3E) : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    // Share button
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        Share.share(
                                          '${dua.arabic}\n\n${dua.transliteration}\n\n${isMalayalam ? dua.meaningMl : dua.meaningEn}\n\n(${dua.reference})\n\nShared via Mahal App',
                                        );
                                      },
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: AppColors.cardSurfaceMuted,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.share_outlined,
                                          size: 15,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.s12),

                          // Title
                          Text(
                            isMalayalam ? dua.titleMl : dua.titleEn,
                            style: AppTextStyles.cardTitle(
                              fontSize: 16,
                              isMalayalam: isMalayalam,
                            ),
                          ),

                          const SizedBox(height: AppSpacing.s10),

                          // Arabic Calligraphy in RTL
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              alignment: Alignment.centerRight,
                              child: Text(
                                dua.arabic,
                                style: AppTextStyles.arabicAyah(
                                  fontSize: 21,
                                  color: AppColors.primaryEmerald,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.s8),

                          // Transliteration
                          Text(
                            dua.transliteration,
                            style: AppTextStyles.bodyText(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              lineHeight: 1.45,
                            ),
                          ),

                          const SizedBox(height: AppSpacing.s10),

                          // Meaning Container with Mint Accent
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.s12),
                            decoration: BoxDecoration(
                              color: AppColors.cardSurfaceMuted,
                              borderRadius: AppRadii.cardInnerBorder,
                              border: Border.all(color: AppColors.cardBorder.withOpacity(0.5)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 3,
                                  height: 24,
                                  margin: const EdgeInsets.only(top: 2, right: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryEmeraldLight,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isMalayalam ? dua.meaningMl : dua.meaningEn,
                                        style: AppTextStyles.bodyText(
                                          color: AppColors.textPrimary,
                                          fontSize: 12.5,
                                          lineHeight: 1.5,
                                          isMalayalam: isMalayalam,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Ref: ${dua.reference}',
                                        style: AppTextStyles.bodyText(
                                          color: AppColors.textMuted,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: DIGITAL TASBIH
  // ---------------------------------------------------------------------------
  Widget _buildTasbihView(bool isMalayalam, TrackingState trackingState) {
    final activePreset = _dhikrPresets[_selectedDhikrIndex];
    final currentCount = trackingState.dhikrCount;
    final target = _customTarget;
    final progress = target > 0 ? (currentCount % target) / target : 0.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(AppSpacing.s24, AppSpacing.s8, AppSpacing.s24, AppSpacing.s32),
      child: Column(
        children: [
          // Dhikr Preset Chips Horizontal List
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _dhikrPresets.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.s8),
              itemBuilder: (context, index) {
                final preset = _dhikrPresets[index];
                final isSelected = index == _selectedDhikrIndex;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedDhikrIndex = index;
                      _customTarget = preset.target;
                      _lapCount = 0;
                    });
                    ref.read(trackingProvider.notifier).setActiveDhikr(
                          isMalayalam ? preset.nameMl : preset.nameEn,
                        );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryEmerald : AppColors.cardSurface,
                      borderRadius: AppRadii.pillBorder,
                      border: Border.all(
                        color: isSelected ? AppColors.primaryEmerald : AppColors.cardBorder,
                      ),
                      boxShadow: isSelected ? AppShadows.subtle : null,
                    ),
                    child: Text(
                      isMalayalam ? '${preset.nameMl} (${preset.target})' : '${preset.nameEn} (${preset.target})',
                      style: AppTextStyles.bodyText(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        isMalayalam: isMalayalam,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.s16),

          // Semicircular Radial Dial Tasbih Card (Signature Reference Component)
          AppCard(
            padding: const EdgeInsets.fromLTRB(AppSpacing.s16, AppSpacing.s20, AppSpacing.s16, AppSpacing.s24),
            child: Column(
              children: [
                // Arabic Dhikr Title Calligraphy
                Text(
                  activePreset.arabic,
                  style: AppTextStyles.arabicAyah(
                    fontSize: 26,
                    color: AppColors.primaryEmerald,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  isMalayalam ? activePreset.meaningMl : activePreset.meaningEn,
                  style: AppTextStyles.bodyText(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    isMalayalam: isMalayalam,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.s16),

                // Interactive Semicircular Radial Tick Gauge Dial
                GestureDetector(
                  onTap: () {
                    if (_hapticEnabled) {
                      HapticFeedback.lightImpact();
                    }
                    final nextCount = currentCount + 1;
                    ref.read(trackingProvider.notifier).incrementDhikr();
                    if (nextCount > 0 && nextCount % target == 0) {
                      setState(() => _lapCount++);
                      if (_hapticEnabled) {
                        HapticFeedback.heavyImpact();
                      }
                    }
                  },
                  child: Container(
                    color: Colors.transparent, // Ensures entire region is hit-testable
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 280,
                          height: 160,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              CustomPaint(
                                size: const Size(280, 160),
                                painter: _TasbihTickDialPainter(
                                  progress: currentCount == 0 ? 0.0 : (currentCount % target == 0 ? 1.0 : progress),
                                ),
                              ),
                              Positioned(
                                bottom: 10,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$currentCount',
                                      style: AppTextStyles.dialTime(
                                        color: AppColors.primaryEmerald,
                                      ).copyWith(fontSize: 48, fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      'Target: $target • ${isMalayalam ? "തട്ടുക" : "Tap to count"}',
                                      style: AppTextStyles.bodyText(
                                        color: AppColors.textSecondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        isMalayalam: isMalayalam,
                                      ),
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

                const SizedBox(height: AppSpacing.s16),

                // Flanking Controls: Target Modifier & Haptic & Reset
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Target selector dialog trigger
                      GestureDetector(
                        onTap: () => _showTargetDialog(isMalayalam),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.mintMist,
                            borderRadius: AppRadii.pillBorder,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.tune_rounded, size: 14, color: AppColors.primaryEmeraldLight),
                              const SizedBox(width: 4),
                              Text(
                                'Target: $_customTarget',
                                style: AppTextStyles.bodyText(
                                  color: AppColors.primaryEmeraldLight,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Haptic toggle
                      GestureDetector(
                        onTap: () {
                          setState(() => _hapticEnabled = !_hapticEnabled);
                          if (_hapticEnabled) HapticFeedback.mediumImpact();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _hapticEnabled ? AppColors.mintMist : AppColors.cardSurfaceMuted,
                            borderRadius: AppRadii.pillBorder,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _hapticEnabled ? Icons.vibration_rounded : Icons.smartphone_rounded,
                                size: 14,
                                color: _hapticEnabled ? AppColors.primaryEmeraldLight : AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _hapticEnabled ? 'Haptic ON' : 'Haptic OFF',
                                style: AppTextStyles.bodyText(
                                  color: _hapticEnabled ? AppColors.primaryEmeraldLight : AppColors.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Reset button
                      PillButton(
                        label: isMalayalam ? 'റീസെറ്റ്' : 'Reset',
                        variant: PillButtonVariant.secondary,
                        height: 32,
                        isMalayalam: isMalayalam,
                        icon: const Icon(Icons.refresh_rounded, size: 14, color: AppColors.textSecondary),
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          setState(() => _lapCount = 0);
                          ref.read(trackingProvider.notifier).resetDhikr();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.s16),

          // Tasbih Virtues Card
          AppCard(
            backgroundColor: AppColors.cardSurfaceMuted,
            padding: const EdgeInsets.all(AppSpacing.s16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.mintMist,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, color: AppColors.primaryEmerald, size: 18),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMalayalam ? 'തസ്ബീഹിന്റെ പ്രാധാന്യം' : 'Virtue of Dhikr',
                        style: AppTextStyles.cardTitle(fontSize: 13, isMalayalam: isMalayalam),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isMalayalam
                            ? 'ഹൃദയങ്ങൾക്ക് ശാന്തി ലഭിക്കുന്നത് അല്ലാഹുവെ സ്മരിക്കുന്നത് കൊണ്ടാണ്. (സൂറഃ റഅ്ദ് 28)'
                            : 'Unquestionably, by the remembrance of Allah hearts are assured. (Surah Ar-Ra\'d 28)',
                        style: AppTextStyles.bodyText(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                          isMalayalam: isMalayalam,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTargetDialog(bool isMalayalam) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.sheetBorder),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.divider, borderRadius: AppRadii.pillBorder),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isMalayalam ? 'ലക്ഷ്യം നിശ്ചയിക്കുക (Target)' : 'Set Tasbih Target',
                style: AppTextStyles.cardTitle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [33, 100, 500, 1000].map((t) {
                  final isSelected = _customTarget == t;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _customTarget = t);
                      Navigator.of(ctx).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryEmerald : AppColors.cardSurfaceMuted,
                        borderRadius: AppRadii.pillBorder,
                      ),
                      child: Text(
                        '$t',
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// DHIKR PRESET MODEL
// ---------------------------------------------------------------------------
class _DhikrPreset {
  final String nameEn;
  final String nameMl;
  final String arabic;
  final String meaningEn;
  final String meaningMl;
  final int target;

  const _DhikrPreset({
    required this.nameEn,
    required this.nameMl,
    required this.arabic,
    required this.meaningEn,
    required this.meaningMl,
    required this.target,
  });
}

// ---------------------------------------------------------------------------
// TASBIH RADIAL TICK PAINTER (Matches Prayer Screen Tick Dial)
// ---------------------------------------------------------------------------
class _TasbihTickDialPainter extends CustomPainter {
  final double progress;

  _TasbihTickDialPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 14;
    const totalTicks = 66;
    const startAngle = math.pi; // 180 degrees (left)
    const sweepAngle = math.pi; // 180 degree semicircle to right

    final activeTicks = (totalTicks * progress.clamp(0.0, 1.0)).round();

    for (int i = 0; i <= totalTicks; i++) {
      final angle = startAngle + (i / totalTicks) * sweepAngle;
      final isMajor = i % 6 == 0;
      final tickLength = isMajor ? 13.0 : 7.0;

      final innerPoint = Offset(
        center.dx + (radius - tickLength) * math.cos(angle),
        center.dy + (radius - tickLength) * math.sin(angle),
      );
      final outerPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      final isActive = i <= activeTicks && progress > 0;
      final paint = Paint()
        ..color = isActive
            ? AppColors.primaryEmerald
            : AppColors.divider.withOpacity(0.7)
        ..strokeWidth = isMajor ? 2.0 : 1.2
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(innerPoint, outerPoint, paint);
    }

    // Glowing position handle
    final currentAngle = startAngle + progress.clamp(0.0, 1.0) * sweepAngle;
    final handleCenter = Offset(
      center.dx + (radius - 4) * math.cos(currentAngle),
      center.dy + (radius - 4) * math.sin(currentAngle),
    );

    if (progress > 0) {
      final glowPaint = Paint()
        ..color = AppColors.primaryEmerald.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(handleCenter, 8, glowPaint);

      final handlePaint = Paint()
        ..color = AppColors.primaryEmerald
        ..style = PaintingStyle.fill;
      canvas.drawCircle(handleCenter, 4.5, handlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TasbihTickDialPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
