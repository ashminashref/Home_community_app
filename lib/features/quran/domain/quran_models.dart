class SurahModel {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String nameMalayalam;
  final int numberOfAyahs;
  final String revelationType; // Meccan / Medinan
  final int juzNumber;

  const SurahModel({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.nameMalayalam,
    required this.numberOfAyahs,
    required this.revelationType,
    this.juzNumber = 1,
  });
}

class AyahModel {
  final int surahNumber;
  final int ayahNumber;
  final String arabicText;
  final String englishText;
  final String malayalamText;
  final String audioUrl;

  const AyahModel({
    required this.surahNumber,
    required this.ayahNumber,
    required this.arabicText,
    required this.englishText,
    required this.malayalamText,
    required this.audioUrl,
  });
}

class JuzModel {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String startSurahName;
  final int startSurahNumber;
  final int startAyahNumber;
  final String endSurahName;
  final int endSurahNumber;
  final int endAyahNumber;

  const JuzModel({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.startSurahName,
    required this.startSurahNumber,
    required this.startAyahNumber,
    required this.endSurahName,
    required this.endSurahNumber,
    required this.endAyahNumber,
  });
}

class BookmarkedAyah {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String arabicText;
  final String translationText;
  final DateTime savedAt;

  const BookmarkedAyah({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.arabicText,
    required this.translationText,
    required this.savedAt,
  });
}

class DuaModel {
  final String id;
  final String titleEn;
  final String titleMl;
  final String categoryEn;
  final String categoryMl;
  final String arabic;
  final String transliteration;
  final String meaningEn;
  final String meaningMl;
  final String reference;
  final bool isFavorite;

  const DuaModel({
    required this.id,
    required this.titleEn,
    required this.titleMl,
    required this.categoryEn,
    required this.categoryMl,
    required this.arabic,
    required this.transliteration,
    required this.meaningEn,
    required this.meaningMl,
    required this.reference,
    this.isFavorite = false,
  });

  DuaModel copyWith({
    String? id,
    String? titleEn,
    String? titleMl,
    String? categoryEn,
    String? categoryMl,
    String? arabic,
    String? transliteration,
    String? meaningEn,
    String? meaningMl,
    String? reference,
    bool? isFavorite,
  }) {
    return DuaModel(
      id: id ?? this.id,
      titleEn: titleEn ?? this.titleEn,
      titleMl: titleMl ?? this.titleMl,
      categoryEn: categoryEn ?? this.categoryEn,
      categoryMl: categoryMl ?? this.categoryMl,
      arabic: arabic ?? this.arabic,
      transliteration: transliteration ?? this.transliteration,
      meaningEn: meaningEn ?? this.meaningEn,
      meaningMl: meaningMl ?? this.meaningMl,
      reference: reference ?? this.reference,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
