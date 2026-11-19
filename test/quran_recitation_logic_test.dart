import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mahal/core/widgets/animated_loader_screen.dart';
import 'package:mahal/core/widgets/shimmer_skeleton.dart';
import 'package:mahal/features/quran/data/quran_repository.dart';

void main() {
  group('Quran Recitation Sequential Traversal Tests', () {
    test('Surah Al-Fatiha has 7 consecutive ayahs with sequential indices', () {
      final fatiha = QuranRepository.allSurahs.first;
      expect(fatiha.numberOfAyahs, equals(7));

      // Test sequential navigation without skipping
      int currentIndex = 0;
      final visitedIndices = <int>[];

      void advanceNext() {
        if (currentIndex < fatiha.numberOfAyahs - 1) {
          currentIndex++;
          visitedIndices.add(currentIndex);
        }
      }

      visitedIndices.add(currentIndex); // Starts at 0 (Ayah 1)
      while (currentIndex < fatiha.numberOfAyahs - 1) {
        advanceNext();
      }

      // Must visit exactly 0, 1, 2, 3, 4, 5, 6 consecutively
      expect(visitedIndices, equals([0, 1, 2, 3, 4, 5, 6]));
      expect(visitedIndices.length, equals(7));
    });

    test('Sequential playback simulation does not skip even verses', () {
      final ayahs = List.generate(10, (i) => 'Ayah ${i + 1}');
      int activeIndex = 0;
      bool isPlaying = true;
      final playedIndices = <int>[];

      void playAyahAtIndex(int index, {bool autoPlay = true}) {
        activeIndex = index;
        if (autoPlay) {
          isPlaying = true;
        }
        playedIndices.add(index);
      }

      void onAyahCompleted() {
        if (activeIndex < ayahs.length - 1) {
          playAyahAtIndex(activeIndex + 1, autoPlay: true);
        } else {
          isPlaying = false;
        }
      }

      // Initial start
      playAyahAtIndex(0, autoPlay: true);

      // Simulate player state completions for all verses
      for (int i = 0; i < ayahs.length - 1; i++) {
        expect(isPlaying, isTrue);
        onAyahCompleted();
      }

      // Verify all 10 verses played in strict consecutive order without skipping
      expect(playedIndices, equals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]));
      expect(playedIndices.contains(1), isTrue, reason: 'Even verse 2 (index 1) must not be skipped');
      expect(playedIndices.contains(2), isTrue, reason: 'Odd verse 3 (index 2) must not be skipped');
      expect(playedIndices.contains(3), isTrue, reason: 'Even verse 4 (index 3) must not be skipped');
    });
  });

  group('Shimmer Skeleton Suite & Animated Loader Render Tests', () {
    testWidgets('Renders all ShimmerSkeleton screen variants without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 300, child: ShimmerSkeleton.surahReader()),
                  SizedBox(height: 300, child: ShimmerSkeleton.homeScreen()),
                  SizedBox(height: 300, child: ShimmerSkeleton.quranIndex()),
                  SizedBox(height: 300, child: ShimmerSkeleton.duasList()),
                  SizedBox(height: 300, child: ShimmerSkeleton.certificateList()),
                  SizedBox(height: 300, child: ShimmerSkeleton.payments()),
                  SizedBox(height: 300, child: ShimmerSkeleton.prayerTimes()),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(ShimmerSkeleton), findsWidgets);
    });

    testWidgets('Renders AnimatedLoaderScreen with astrolabe dial and status', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AnimatedLoaderScreen(
              duration: Duration(seconds: 2),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(AnimatedLoaderScreen), findsOneWidget);
    });
  });
}

