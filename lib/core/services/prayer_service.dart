import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';

class PrayerTimingInfo {
  final String key;
  final String nameEn;
  final String nameMl;
  final DateTime time;
  final String formattedTime;
  final String formattedRange;
  final String? jamaathTime;
  final bool isCurrent;

  PrayerTimingInfo({
    required this.key,
    required this.nameEn,
    required this.nameMl,
    required this.time,
    required this.formattedTime,
    required this.formattedRange,
    this.jamaathTime,
    this.isCurrent = false,
  });
}

class PrayerScheduleResult {
  final List<PrayerTimingInfo> prayers;
  final PrayerTimingInfo? currentPrayer;
  final PrayerTimingInfo? nextPrayer;
  final DateTime sunrise;
  final DateTime sunset;
  final double currentProgress; // 0.0 to 1.0 along the daytime arc

  PrayerScheduleResult({
    required this.prayers,
    this.currentPrayer,
    this.nextPrayer,
    required this.sunrise,
    required this.sunset,
    required this.currentProgress,
  });
}

class PrayerService {
  PrayerService._();

  /// Coordinates for Kerala default (Kozhikode: 11.2588, 75.7804)
  static const double defaultLat = 11.2588;
  static const double defaultLng = 75.7804;

  static PrayerScheduleResult calculateTodayTimes({
    double lat = defaultLat,
    double lng = defaultLng,
    Map<String, String>? jamaathOverrides,
  }) {
    final coordinates = Coordinates(lat, lng);
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi; // Shafi school is predominant in Kerala

    final now = DateTime.now();
    final dateComponents = DateComponents.from(now);
    final prayerTimes = PrayerTimes(coordinates, dateComponents, params);

    final timeFormat = DateFormat('hh:mm a');

    // Safe range calculation helpers
    String makeRange(DateTime start, DateTime end) {
      return '${timeFormat.format(start)} - ${timeFormat.format(end)}';
    }

    final fajrTime = prayerTimes.fajr;
    final sunriseTime = prayerTimes.sunrise;
    final dhuhrTime = prayerTimes.dhuhr;
    final asrTime = prayerTimes.asr;
    final maghribTime = prayerTimes.maghrib;
    final ishaTime = prayerTimes.isha;

    final prayersList = [
      PrayerTimingInfo(
        key: 'fajr',
        nameEn: 'Fajr',
        nameMl: 'സുബ്ഹി',
        time: fajrTime,
        formattedTime: timeFormat.format(fajrTime),
        formattedRange: makeRange(fajrTime, sunriseTime),
        jamaathTime: jamaathOverrides?['fajr'] ?? '05:15 AM',
      ),
      PrayerTimingInfo(
        key: 'dhuhr',
        nameEn: 'Dhuhr',
        nameMl: 'ളുഹ്ർ',
        time: dhuhrTime,
        formattedTime: timeFormat.format(dhuhrTime),
        formattedRange: makeRange(dhuhrTime, asrTime),
        jamaathTime: jamaathOverrides?['dhuhr'] ?? '01:30 PM',
      ),
      PrayerTimingInfo(
        key: 'asr',
        nameEn: 'Asr',
        nameMl: 'അസ്വർ',
        time: asrTime,
        formattedTime: timeFormat.format(asrTime),
        formattedRange: makeRange(asrTime, maghribTime),
        jamaathTime: jamaathOverrides?['asr'] ?? '04:45 PM',
      ),
      PrayerTimingInfo(
        key: 'maghrib',
        nameEn: 'Maghrib',
        nameMl: 'മഗ്‌രിബ്',
        time: maghribTime,
        formattedTime: timeFormat.format(maghribTime),
        formattedRange: makeRange(maghribTime, ishaTime),
        jamaathTime: jamaathOverrides?['maghrib'] ?? '06:30 PM',
      ),
      PrayerTimingInfo(
        key: 'isha',
        nameEn: 'Isha',
        nameMl: 'ഇശാഅ്',
        time: ishaTime,
        formattedTime: timeFormat.format(ishaTime),
        formattedRange: makeRange(ishaTime, fajrTime.add(const Duration(days: 1))),
        jamaathTime: jamaathOverrides?['isha'] ?? '08:15 PM',
      ),
    ];

    // Determine current prayer & next prayer
    final currentPrayerEnum = prayerTimes.currentPrayer();
    final nextPrayerEnum = prayerTimes.nextPrayer();

    String currentKey = 'fajr';
    switch (currentPrayerEnum) {
      case Prayer.fajr:
        currentKey = 'fajr';
        break;
      case Prayer.dhuhr:
        currentKey = 'dhuhr';
        break;
      case Prayer.asr:
        currentKey = 'asr';
        break;
      case Prayer.maghrib:
        currentKey = 'maghrib';
        break;
      case Prayer.isha:
        currentKey = 'isha';
        break;
      default:
        currentKey = 'fajr';
        break;
    }

    String nextKey = 'dhuhr';
    switch (nextPrayerEnum) {
      case Prayer.fajr:
        nextKey = 'fajr';
        break;
      case Prayer.sunrise:
      case Prayer.dhuhr:
        nextKey = 'dhuhr';
        break;
      case Prayer.asr:
        nextKey = 'asr';
        break;
      case Prayer.maghrib:
        nextKey = 'maghrib';
        break;
      case Prayer.isha:
        nextKey = 'isha';
        break;
      default:
        nextKey = 'fajr';
        break;
    }

    // Arc progress calculation (from Fajr to Maghrib daytime, or cyclic)
    final totalDayMinutes = maghribTime.difference(fajrTime).inMinutes;
    final elapsedMinutes = now.difference(fajrTime).inMinutes;
    double progress = (elapsedMinutes / (totalDayMinutes > 0 ? totalDayMinutes : 1)).clamp(0.0, 1.0);

    return PrayerScheduleResult(
      prayers: prayersList.map((p) {
        return PrayerTimingInfo(
          key: p.key,
          nameEn: p.nameEn,
          nameMl: p.nameMl,
          time: p.time,
          formattedTime: p.formattedTime,
          formattedRange: p.formattedRange,
          jamaathTime: p.jamaathTime,
          isCurrent: p.key == currentKey,
        );
      }).toList(),
      currentPrayer: prayersList.firstWhere((p) => p.key == currentKey, orElse: () => prayersList.first),
      nextPrayer: prayersList.firstWhere((p) => p.key == nextKey, orElse: () => prayersList[1]),
      sunrise: sunriseTime,
      sunset: maghribTime,
      currentProgress: progress,
    );
  }
}

