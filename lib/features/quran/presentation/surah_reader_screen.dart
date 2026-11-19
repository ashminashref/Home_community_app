import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/glass_back_button.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../../auth/providers/auth_provider.dart';
import '../../tracking/presentation/recitation_studio_screen.dart';
import '../data/quran_repository.dart';
import '../domain/quran_models.dart';

class SurahReaderScreen extends ConsumerStatefulWidget {
  final SurahModel surah;
  final int initialAyahIndex;

  const SurahReaderScreen({
    super.key,
    required this.surah,
    this.initialAyahIndex = 0,
  });

  @override
  ConsumerState<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends ConsumerState<SurahReaderScreen> {
  late AudioPlayer _audioPlayer;
  final ScrollController _scrollController = ScrollController();
  List<AyahModel> _ayahs = [];
  bool _isLoading = true;
  int _currentAyahIndex = 0;
  bool _isPlaying = false;
  bool _isTransitioning = false;
  double _fontSize = 24.0;
  bool _showMalayalam = true;
  bool _showEnglish = true;
  bool _showHeader = true;

  @override
  void initState() {
    super.initState();
    _currentAyahIndex = widget.initialAyahIndex;
    _audioPlayer = AudioPlayer();

    // Player state subscription with robust auto-advance
    _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state.playing && state.processingState != ProcessingState.completed;
      });

      // Sequential Continuous Playback: advance to the next Ayah without skipping!
      if (state.processingState == ProcessingState.completed && !_isTransitioning) {
        if (_currentAyahIndex < _ayahs.length - 1) {
          _playAyahAtIndex(_currentAyahIndex + 1, autoPlay: true);
        } else {
          setState(() {
            _isPlaying = false;
            _currentAyahIndex = 0;
          });
        }
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.offset > 60 && _showHeader) {
        setState(() => _showHeader = false);
      } else if (_scrollController.offset <= 60 && !_showHeader) {
        setState(() => _showHeader = true);
      }
    });

    _loadSurahAyahs();
  }

  Future<void> _loadSurahAyahs() async {
    setState(() => _isLoading = true);
    final ayahs = await QuranRepository.fetchSurahAyahs(widget.surah.number);
    if (mounted) {
      setState(() {
        _ayahs = ayahs;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Load and play a specific Ayah cleanly
  Future<void> _playAyahAtIndex(int index, {bool autoPlay = true}) async {
    if (_ayahs.isEmpty || index < 0 || index >= _ayahs.length) return;
    if (_isTransitioning) return;
    _isTransitioning = true;

    setState(() {
      _currentAyahIndex = index;
    });

    try {
      final ayah = _ayahs[index];
      await _audioPlayer.stop();
      await _audioPlayer.setUrl(ayah.audioUrl);
      if (autoPlay) {
        await _audioPlayer.play();
      }
    } catch (_) {
      // Gracefully handle playback network issues
    } finally {
      _isTransitioning = false;
    }
  }

  /// Toggle play / pause on the current Ayah
  Future<void> _togglePlayPause() async {
    if (_ayahs.isEmpty) return;
    try {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      } else {
        if (_audioPlayer.processingState == ProcessingState.completed) {
          await _audioPlayer.seek(Duration.zero);
          await _audioPlayer.play();
        } else if (_audioPlayer.audioSource == null) {
          await _playAyahAtIndex(_currentAyahIndex, autoPlay: true);
        } else {
          await _audioPlayer.play();
        }
      }
    } catch (_) {}
  }

  /// Skip to next Ayah sequentially (never skipping every other verse)
  void _skipNextAyah() {
    if (_ayahs.isEmpty) return;
    if (_currentAyahIndex < _ayahs.length - 1) {
      _playAyahAtIndex(_currentAyahIndex + 1, autoPlay: true);
    }
  }

  /// Skip to previous Ayah
  void _skipPrevAyah() {
    if (_ayahs.isEmpty) return;
    if (_currentAyahIndex > 0) {
      _playAyahAtIndex(_currentAyahIndex - 1, autoPlay: true);
    }
  }

  void _openAyahActionSheet(AyahModel ayah, int ayahIndex) {
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
              // Sheet Handle Notch
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: AppRadii.pillBorder,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              Text(
                '${widget.surah.nameEnglish} • Verse ${ayah.ayahNumber}',
                style: AppTextStyles.cardTitle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.s16),
              _buildSheetAction(
                icon: Icons.play_circle_fill_rounded,
                title: 'Play Recitation from this Verse',
                onTap: () {
                  Navigator.of(ctx).pop();
                  _playAyahAtIndex(ayahIndex, autoPlay: true);
                },
              ),
              _buildSheetAction(
                icon: Icons.bookmark_add_rounded,
                title: 'Save Bookmark',
                onTap: () {
                  Navigator.of(ctx).pop();
                  QuranRepository.userBookmarks.removeWhere(
                    (b) => b.surahNumber == widget.surah.number && b.ayahNumber == ayah.ayahNumber,
                  );
                  QuranRepository.userBookmarks.insert(
                    0,
                    BookmarkedAyah(
                      surahNumber: widget.surah.number,
                      surahName: widget.surah.nameEnglish,
                      ayahNumber: ayah.ayahNumber,
                      arabicText: ayah.arabicText,
                      translationText: ayah.malayalamText.isNotEmpty ? ayah.malayalamText : ayah.englishText,
                      savedAt: DateTime.now(),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ayah saved to bookmarks'),
                      backgroundColor: AppColors.primaryEmerald,
                    ),
                  );
                },
              ),
              _buildSheetAction(
                icon: Icons.share_outlined,
                title: 'Share Ayah & Meaning',
                onTap: () {
                  Navigator.of(ctx).pop();
                  Share.share('${ayah.arabicText}\n\n${ayah.malayalamText}\n\n${ayah.englishText}\n(Quran ${widget.surah.number}:${ayah.ayahNumber})');
                },
              ),
              _buildSheetAction(
                icon: Icons.mic_none_rounded,
                title: 'Practice & Record Recitation',
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RecitationStudioScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSheetAction({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.mintMist,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryEmeraldLight, size: 20),
      ),
      title: Text(title, style: AppTextStyles.bodyText(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isMalayalam = locale.languageCode == 'ml';

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F3), // Warm paper-white reading canvas
      body: Stack(
        children: [
          // Ayahs Reading Flow or Shimmer Skeleton Fallback
          if (_isLoading)
            ShimmerSkeleton.surahReader()
          else
            ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(AppSpacing.s24, 110, AppSpacing.s24, 140),
              itemCount: _ayahs.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Surah Header Banner (Bismillah)
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 28.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryEmerald.withValues(alpha: 0.08),
                            borderRadius: AppRadii.pillBorder,
                          ),
                          child: Text(
                            '${widget.surah.revelationType.toUpperCase()} • ${widget.surah.numberOfAyahs} AYAHS • JUZ ${widget.surah.juzNumber}',
                            style: AppTextStyles.bodyText(
                              color: AppColors.primaryEmeraldLight,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (widget.surah.number != 9)
                          Text(
                            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                            style: AppTextStyles.arabicAyah(
                              fontSize: 26,
                              color: AppColors.primaryEmerald,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 12),
                        const Divider(color: Color(0xFFEADBCE), thickness: 1),
                      ],
                    ),
                  );
                }

                final ayahIdx = index - 1;
                final ayah = _ayahs[ayahIdx];
                final isCurrent = ayahIdx == _currentAyahIndex;

                return GestureDetector(
                  onTap: () => _openAyahActionSheet(ayah, ayahIdx),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isCurrent ? AppColors.mintMist.withValues(alpha: 0.5) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: isCurrent ? Border.all(color: AppColors.emeraldAccent.withValues(alpha: 0.5)) : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Arabic verse text with authentic end-of-ayah circular ornament
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: RichText(
                            textAlign: TextAlign.right,
                            text: TextSpan(
                              style: AppTextStyles.arabicAyah(
                                fontSize: _fontSize,
                                color: AppColors.textPrimary,
                              ),
                              children: [
                                TextSpan(text: '${ayah.arabicText} '),
                                TextSpan(
                                  text: '۝${ayah.ayahNumber}',
                                  style: TextStyle(
                                    color: AppColors.primaryEmeraldLight,
                                    fontSize: _fontSize * 0.85,
                                    fontFamily: 'Amiri',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Malayalam Meaning
                        if (_showMalayalam && ayah.malayalamText.isNotEmpty) ...[
                          Text(
                            ayah.malayalamText,
                            style: AppTextStyles.bodyText(
                              color: const Color(0xFF2D3748),
                              fontSize: 13.5,
                              isMalayalam: true,
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],

                        // English Meaning
                        if (_showEnglish && ayah.englishText.isNotEmpty)
                          Text(
                            ayah.englishText,
                            style: AppTextStyles.bodyText(
                              color: const Color(0xFF718096),
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

          // Floating Glass Header
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            top: _showHeader ? 0 : -100,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s8),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: AppRadii.pillBorder,
                  boxShadow: const [
                    BoxShadow(color: Color(0x0C000000), blurRadius: 16, offset: Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    GlassBackButton(
                      iconColor: AppColors.primaryEmerald,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isMalayalam ? widget.surah.nameMalayalam : widget.surah.nameEnglish,
                            style: AppTextStyles.cardTitle(fontSize: 15, isMalayalam: isMalayalam),
                          ),
                          Text(
                            '${widget.surah.nameArabic} • ${widget.surah.numberOfAyahs} Ayahs',
                            style: AppTextStyles.bodyText(color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.text_format_rounded, color: AppColors.primaryEmerald),
                      onPressed: _showTypographySheet,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Audio Player Pill at the Bottom
          Positioned(
            left: AppSpacing.s24,
            right: AppSpacing.s24,
            bottom: AppSpacing.s24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s12),
              decoration: BoxDecoration(
                color: AppColors.primaryEmerald,
                borderRadius: AppRadii.pillBorder,
                boxShadow: const [
                  BoxShadow(color: Color(0x330E3E2E), blurRadius: 20, offset: Offset(0, 8)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.emeraldAccent,
                    ),
                    child: const Icon(Icons.graphic_eq_rounded, color: AppColors.primaryEmerald, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mishary Rashid Alafasy',
                          style: AppTextStyles.cardTitle(color: Colors.white, fontSize: 13),
                        ),
                        Text(
                          _ayahs.isNotEmpty
                              ? 'Ayah ${_currentAyahIndex + 1} of ${_ayahs.length}'
                              : 'Loading Recitation...',
                          style: AppTextStyles.bodyText(color: AppColors.mintText, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 22),
                        onPressed: _skipPrevAyah,
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: AppColors.primaryEmerald,
                            size: 24,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 22),
                        onPressed: _skipNextAyah,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTypographySheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.sheetBorder),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                  Text('Reader Typography & Options', style: AppTextStyles.cardTitle(fontSize: 16)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Arabic Font Scale', style: AppTextStyles.bodyText()),
                      Text('${_fontSize.round()} pt', style: AppTextStyles.cardTitle(fontSize: 14)),
                    ],
                  ),
                  Slider(
                    value: _fontSize,
                    min: 18.0,
                    max: 36.0,
                    activeColor: AppColors.primaryEmeraldLight,
                    onChanged: (val) {
                      setModalState(() => _fontSize = val);
                      setState(() => _fontSize = val);
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Show Malayalam Translation', style: AppTextStyles.bodyText()),
                      Switch.adaptive(
                        value: _showMalayalam,
                        activeThumbColor: AppColors.primaryEmeraldLight,
                        activeTrackColor: AppColors.mintMist,
                        onChanged: (val) {
                          setModalState(() => _showMalayalam = val);
                          setState(() => _showMalayalam = val);
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Show English Translation', style: AppTextStyles.bodyText()),
                      Switch.adaptive(
                        value: _showEnglish,
                        activeThumbColor: AppColors.primaryEmeraldLight,
                        activeTrackColor: AppColors.mintMist,
                        onChanged: (val) {
                          setModalState(() => _showEnglish = val);
                          setState(() => _showEnglish = val);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
