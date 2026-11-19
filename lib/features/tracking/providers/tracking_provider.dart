import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrackingState {
  final int fastedDays;
  final int quranPagesGoal;
  final int quranPagesReadToday;
  final int dhikrCount;
  final String activeDhikr;
  final bool isRecording;
  final bool isPlayingRecording;
  final int recordingDurationSeconds;
  final List<double> waveformPoints;
  final bool hasRecordedAudio;

  const TrackingState({
    this.fastedDays = 6,
    this.quranPagesGoal = 10,
    this.quranPagesReadToday = 4,
    this.dhikrCount = 33,
    this.activeDhikr = 'SubhanAllah (سبحان الله)',
    this.isRecording = false,
    this.isPlayingRecording = false,
    this.recordingDurationSeconds = 0,
    this.waveformPoints = const [0.3, 0.6, 0.8, 0.4, 0.9, 0.5, 0.7, 0.2, 0.6, 0.8],
    this.hasRecordedAudio = false,
  });

  TrackingState copyWith({
    int? fastedDays,
    int? quranPagesGoal,
    int? quranPagesReadToday,
    int? dhikrCount,
    String? activeDhikr,
    bool? isRecording,
    bool? isPlayingRecording,
    int? recordingDurationSeconds,
    List<double>? waveformPoints,
    bool? hasRecordedAudio,
  }) {
    return TrackingState(
      fastedDays: fastedDays ?? this.fastedDays,
      quranPagesGoal: quranPagesGoal ?? this.quranPagesGoal,
      quranPagesReadToday: quranPagesReadToday ?? this.quranPagesReadToday,
      dhikrCount: dhikrCount ?? this.dhikrCount,
      activeDhikr: activeDhikr ?? this.activeDhikr,
      isRecording: isRecording ?? this.isRecording,
      isPlayingRecording: isPlayingRecording ?? this.isPlayingRecording,
      recordingDurationSeconds: recordingDurationSeconds ?? this.recordingDurationSeconds,
      waveformPoints: waveformPoints ?? this.waveformPoints,
      hasRecordedAudio: hasRecordedAudio ?? this.hasRecordedAudio,
    );
  }
}

final trackingProvider = StateNotifierProvider<TrackingNotifier, TrackingState>((ref) {
  return TrackingNotifier();
});

class TrackingNotifier extends StateNotifier<TrackingState> {
  TrackingNotifier() : super(const TrackingState());

  void setFastedDays(int days) {
    state = state.copyWith(fastedDays: days);
  }

  void setQuranPagesGoal(int goal) {
    state = state.copyWith(quranPagesGoal: goal);
  }

  void incrementQuranPage() {
    if (state.quranPagesReadToday < state.quranPagesGoal) {
      state = state.copyWith(quranPagesReadToday: state.quranPagesReadToday + 1);
    }
  }

  void incrementDhikr() {
    state = state.copyWith(dhikrCount: state.dhikrCount + 1);
  }

  void resetDhikr() {
    state = state.copyWith(dhikrCount: 0);
  }

  void setActiveDhikr(String dhikr) {
    state = state.copyWith(activeDhikr: dhikr, dhikrCount: 0);
  }

  void startRecording() {
    state = state.copyWith(
      isRecording: true,
      recordingDurationSeconds: 0,
      hasRecordedAudio: false,
    );
  }

  void stopRecording() {
    state = state.copyWith(
      isRecording: false,
      hasRecordedAudio: true,
      waveformPoints: [0.3, 0.7, 0.4, 0.9, 0.8, 0.5, 0.95, 0.6, 0.4, 0.7, 0.8, 0.5],
    );
  }

  void togglePlayback() {
    state = state.copyWith(isPlayingRecording: !state.isPlayingRecording);
  }
}

