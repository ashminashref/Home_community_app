import 'dart:convert';
import 'dart:io';
import '../domain/quran_models.dart';

class QuranRepository {
  QuranRepository._();

  // In-memory cache for loaded surahs so repeated opens are instant
  static final Map<int, List<AyahModel>> _cachedAyahs = {};

  // ──────────────────────────────────────────────────────────────────────────
  // COMPLETE 114 SURAHS METADATA
  // ──────────────────────────────────────────────────────────────────────────
  static const List<SurahModel> allSurahs = [
    SurahModel(number: 1, nameArabic: 'الفاتحة', nameEnglish: 'Al-Fatihah', nameMalayalam: 'അൽ ഫാത്തിഹ', numberOfAyahs: 7, revelationType: 'Meccan', juzNumber: 1),
    SurahModel(number: 2, nameArabic: 'البقرة', nameEnglish: 'Al-Baqarah', nameMalayalam: 'അൽ ബഖറ', numberOfAyahs: 286, revelationType: 'Medinan', juzNumber: 1),
    SurahModel(number: 3, nameArabic: 'آل عمران', nameEnglish: 'Ali \'Imran', nameMalayalam: 'ആലു ഇംറാൻ', numberOfAyahs: 200, revelationType: 'Medinan', juzNumber: 3),
    SurahModel(number: 4, nameArabic: 'النساء', nameEnglish: 'An-Nisa', nameMalayalam: 'അന്നിസാഅ്', numberOfAyahs: 176, revelationType: 'Medinan', juzNumber: 4),
    SurahModel(number: 5, nameArabic: 'المائدة', nameEnglish: 'Al-Ma\'idah', nameMalayalam: 'അൽ മാഇദ', numberOfAyahs: 120, revelationType: 'Medinan', juzNumber: 6),
    SurahModel(number: 6, nameArabic: 'الأنعام', nameEnglish: 'Al-An\'am', nameMalayalam: 'അൽ അൻആം', numberOfAyahs: 165, revelationType: 'Meccan', juzNumber: 7),
    SurahModel(number: 7, nameArabic: 'الأعراف', nameEnglish: 'Al-A\'raf', nameMalayalam: 'അൽ അഅ്റാഫ്', numberOfAyahs: 206, revelationType: 'Meccan', juzNumber: 8),
    SurahModel(number: 8, nameArabic: 'الأنفال', nameEnglish: 'Al-Anfal', nameMalayalam: 'അൽ അൻഫാൽ', numberOfAyahs: 75, revelationType: 'Medinan', juzNumber: 9),
    SurahModel(number: 9, nameArabic: 'التوبة', nameEnglish: 'At-Tawbah', nameMalayalam: 'അത്തൗബ', numberOfAyahs: 129, revelationType: 'Medinan', juzNumber: 10),
    SurahModel(number: 10, nameArabic: 'يونس', nameEnglish: 'Yunus', nameMalayalam: 'യൂനുസ്', numberOfAyahs: 109, revelationType: 'Meccan', juzNumber: 11),
    SurahModel(number: 11, nameArabic: 'هود', nameEnglish: 'Hud', nameMalayalam: 'ഹൂദ്', numberOfAyahs: 123, revelationType: 'Meccan', juzNumber: 11),
    SurahModel(number: 12, nameArabic: 'يوسف', nameEnglish: 'Yusuf', nameMalayalam: 'യൂസുഫ്', numberOfAyahs: 111, revelationType: 'Meccan', juzNumber: 12),
    SurahModel(number: 13, nameArabic: 'الرعد', nameEnglish: 'Ar-Ra\'d', nameMalayalam: 'അർറഅ്ദ്', numberOfAyahs: 43, revelationType: 'Medinan', juzNumber: 13),
    SurahModel(number: 14, nameArabic: 'إبراهيم', nameEnglish: 'Ibrahim', nameMalayalam: 'ഇബ്റാഹീം', numberOfAyahs: 52, revelationType: 'Meccan', juzNumber: 13),
    SurahModel(number: 15, nameArabic: 'الحجر', nameEnglish: 'Al-Hijr', nameMalayalam: 'അൽ ഹിജ്ർ', numberOfAyahs: 99, revelationType: 'Meccan', juzNumber: 14),
    SurahModel(number: 16, nameArabic: 'النحل', nameEnglish: 'An-Nahl', nameMalayalam: 'അന്നഹ്‌ൽ', numberOfAyahs: 128, revelationType: 'Meccan', juzNumber: 14),
    SurahModel(number: 17, nameArabic: 'الإسراء', nameEnglish: 'Al-Isra', nameMalayalam: 'അൽ ഇസ്റാഅ്', numberOfAyahs: 111, revelationType: 'Meccan', juzNumber: 15),
    SurahModel(number: 18, nameArabic: 'الكهف', nameEnglish: 'Al-Kahf', nameMalayalam: 'അൽ കഹ്ഫ്', numberOfAyahs: 110, revelationType: 'Meccan', juzNumber: 15),
    SurahModel(number: 19, nameArabic: 'مريم', nameEnglish: 'Maryam', nameMalayalam: 'മർയം', numberOfAyahs: 98, revelationType: 'Meccan', juzNumber: 16),
    SurahModel(number: 20, nameArabic: 'طه', nameEnglish: 'Ta-Ha', nameMalayalam: 'ത്വാഹാ', numberOfAyahs: 135, revelationType: 'Meccan', juzNumber: 16),
    SurahModel(number: 21, nameArabic: 'الأنبياء', nameEnglish: 'Al-Anbiya', nameMalayalam: 'അൽ അൻബിയാഅ്', numberOfAyahs: 112, revelationType: 'Meccan', juzNumber: 17),
    SurahModel(number: 22, nameArabic: 'الحج', nameEnglish: 'Al-Hajj', nameMalayalam: 'അൽ ഹജ്ജ്', numberOfAyahs: 78, revelationType: 'Medinan', juzNumber: 17),
    SurahModel(number: 23, nameArabic: 'المؤمنون', nameEnglish: 'Al-Mu\'minun', nameMalayalam: 'അൽ മുഅ്മിനൂൻ', numberOfAyahs: 118, revelationType: 'Meccan', juzNumber: 18),
    SurahModel(number: 24, nameArabic: 'النور', nameEnglish: 'An-Nur', nameMalayalam: 'അന്നൂർ', numberOfAyahs: 64, revelationType: 'Medinan', juzNumber: 18),
    SurahModel(number: 25, nameArabic: 'الفرقان', nameEnglish: 'Al-Furqan', nameMalayalam: 'അൽ ഫുർഖാൻ', numberOfAyahs: 77, revelationType: 'Meccan', juzNumber: 18),
    SurahModel(number: 26, nameArabic: 'الشعراء', nameEnglish: 'Ash-Shu\'ara', nameMalayalam: 'അശ്ശുഅറാഅ്', numberOfAyahs: 227, revelationType: 'Meccan', juzNumber: 19),
    SurahModel(number: 27, nameArabic: 'النمل', nameEnglish: 'An-Naml', nameMalayalam: 'അന്നംല്', numberOfAyahs: 93, revelationType: 'Meccan', juzNumber: 19),
    SurahModel(number: 28, nameArabic: 'القصص', nameEnglish: 'Al-Qasas', nameMalayalam: 'അൽ ഖസ്വസ്വ്', numberOfAyahs: 88, revelationType: 'Meccan', juzNumber: 20),
    SurahModel(number: 29, nameArabic: 'العنكبوت', nameEnglish: 'Al-\'Ankabut', nameMalayalam: 'അൽ അൻകബൂത്ത്', numberOfAyahs: 69, revelationType: 'Meccan', juzNumber: 20),
    SurahModel(number: 30, nameArabic: 'الروم', nameEnglish: 'Ar-Rum', nameMalayalam: 'അറൂം', numberOfAyahs: 60, revelationType: 'Meccan', juzNumber: 21),
    SurahModel(number: 31, nameArabic: 'لقمان', nameEnglish: 'Luqman', nameMalayalam: 'ലുഖ്‌മാൻ', numberOfAyahs: 34, revelationType: 'Meccan', juzNumber: 21),
    SurahModel(number: 32, nameArabic: 'السجدة', nameEnglish: 'As-Sajdah', nameMalayalam: 'അസ്സജ്ദ', numberOfAyahs: 30, revelationType: 'Meccan', juzNumber: 21),
    SurahModel(number: 33, nameArabic: 'الأحزاب', nameEnglish: 'Al-Ahzab', nameMalayalam: 'അൽ അഹ്‌സാബ്', numberOfAyahs: 73, revelationType: 'Medinan', juzNumber: 21),
    SurahModel(number: 34, nameArabic: 'سبإ', nameEnglish: 'Saba', nameMalayalam: 'സബഅ്', numberOfAyahs: 54, revelationType: 'Meccan', juzNumber: 22),
    SurahModel(number: 35, nameArabic: 'فاطر', nameEnglish: 'Fatir', nameMalayalam: 'ഫാത്വിർ', numberOfAyahs: 45, revelationType: 'Meccan', juzNumber: 22),
    SurahModel(number: 36, nameArabic: 'يس', nameEnglish: 'Ya-Sin', nameMalayalam: 'യാസീൻ', numberOfAyahs: 83, revelationType: 'Meccan', juzNumber: 22),
    SurahModel(number: 37, nameArabic: 'الصافات', nameEnglish: 'As-Saffat', nameMalayalam: 'അസ്സ്വാഫ്ഫാത്ത്', numberOfAyahs: 182, revelationType: 'Meccan', juzNumber: 23),
    SurahModel(number: 38, nameArabic: 'ص', nameEnglish: 'Sad', nameMalayalam: 'സ്വാദ്', numberOfAyahs: 88, revelationType: 'Meccan', juzNumber: 23),
    SurahModel(number: 39, nameArabic: 'الزمر', nameEnglish: 'Az-Zumar', nameMalayalam: 'അസ്സുമർ', numberOfAyahs: 75, revelationType: 'Meccan', juzNumber: 23),
    SurahModel(number: 40, nameArabic: 'غافر', nameEnglish: 'Ghafir', nameMalayalam: 'ഗാഫിർ', numberOfAyahs: 85, revelationType: 'Meccan', juzNumber: 24),
    SurahModel(number: 41, nameArabic: 'فصلت', nameEnglish: 'Fussilat', nameMalayalam: 'ഫുസ്സ്വിലത്ത്', numberOfAyahs: 54, revelationType: 'Meccan', juzNumber: 24),
    SurahModel(number: 42, nameArabic: 'الشورى', nameEnglish: 'Ash-Shura', nameMalayalam: 'അശ്ശൂറാ', numberOfAyahs: 53, revelationType: 'Meccan', juzNumber: 25),
    SurahModel(number: 43, nameArabic: 'الزخرف', nameEnglish: 'Az-Zukhruf', nameMalayalam: 'അസ്സുഖ്റുഫ്', numberOfAyahs: 89, revelationType: 'Meccan', juzNumber: 25),
    SurahModel(number: 44, nameArabic: 'الدخان', nameEnglish: 'Ad-Dukhan', nameMalayalam: 'അദ്ദുഖാൻ', numberOfAyahs: 59, revelationType: 'Meccan', juzNumber: 25),
    SurahModel(number: 45, nameArabic: 'الجاثية', nameEnglish: 'Al-Jathiyah', nameMalayalam: 'അൽ ജാഥിയ', numberOfAyahs: 37, revelationType: 'Meccan', juzNumber: 25),
    SurahModel(number: 46, nameArabic: 'الأحقاف', nameEnglish: 'Al-Ahqaf', nameMalayalam: 'അൽ അഹ്ഖാഫ്', numberOfAyahs: 35, revelationType: 'Meccan', juzNumber: 26),
    SurahModel(number: 47, nameArabic: 'محمد', nameEnglish: 'Muhammad', nameMalayalam: 'മുഹമ്മദ്', numberOfAyahs: 38, revelationType: 'Medinan', juzNumber: 26),
    SurahModel(number: 48, nameArabic: 'الفتح', nameEnglish: 'Al-Fath', nameMalayalam: 'അൽ ഫത്ഹ്', numberOfAyahs: 29, revelationType: 'Medinan', juzNumber: 26),
    SurahModel(number: 49, nameArabic: 'الحجرات', nameEnglish: 'Al-Hujurat', nameMalayalam: 'അൽ ഹുജുറാത്ത്', numberOfAyahs: 18, revelationType: 'Medinan', juzNumber: 26),
    SurahModel(number: 50, nameArabic: 'ق', nameEnglish: 'Qaf', nameMalayalam: 'ഖാഫ്', numberOfAyahs: 45, revelationType: 'Meccan', juzNumber: 26),
    SurahModel(number: 51, nameArabic: 'الذاريات', nameEnglish: 'Adh-Dhariyat', nameMalayalam: 'അദ്ദാരിയാത്ത്', numberOfAyahs: 60, revelationType: 'Meccan', juzNumber: 26),
    SurahModel(number: 52, nameArabic: 'الطور', nameEnglish: 'At-Tur', nameMalayalam: 'അത്ത്വൂർ', numberOfAyahs: 49, revelationType: 'Meccan', juzNumber: 27),
    SurahModel(number: 53, nameArabic: 'النجم', nameEnglish: 'An-Najm', nameMalayalam: 'അന്നജ്മ്', numberOfAyahs: 62, revelationType: 'Meccan', juzNumber: 27),
    SurahModel(number: 54, nameArabic: 'القمر', nameEnglish: 'Al-Qamar', nameMalayalam: 'അൽ ഖമർ', numberOfAyahs: 55, revelationType: 'Meccan', juzNumber: 27),
    SurahModel(number: 55, nameArabic: 'الرحمن', nameEnglish: 'Ar-Rahman', nameMalayalam: 'അർറഹ്‌മാൻ', numberOfAyahs: 78, revelationType: 'Medinan', juzNumber: 27),
    SurahModel(number: 56, nameArabic: 'الواقعة', nameEnglish: 'Al-Waqi\'ah', nameMalayalam: 'അൽ വാഖിഅ', numberOfAyahs: 96, revelationType: 'Meccan', juzNumber: 27),
    SurahModel(number: 57, nameArabic: 'الحديد', nameEnglish: 'Al-Hadid', nameMalayalam: 'അൽ ഹദീദ്', numberOfAyahs: 29, revelationType: 'Medinan', juzNumber: 27),
    SurahModel(number: 58, nameArabic: 'المجادلة', nameEnglish: 'Al-Mujadila', nameMalayalam: 'അൽ മുജാദില', numberOfAyahs: 22, revelationType: 'Medinan', juzNumber: 28),
    SurahModel(number: 59, nameArabic: 'الحشر', nameEnglish: 'Al-Hashr', nameMalayalam: 'അൽ ഹശ്ര്‍', numberOfAyahs: 24, revelationType: 'Medinan', juzNumber: 28),
    SurahModel(number: 60, nameArabic: 'الممتحنة', nameEnglish: 'Al-Mumtahanah', nameMalayalam: 'അൽ മുംതഹന', numberOfAyahs: 13, revelationType: 'Medinan', juzNumber: 28),
    SurahModel(number: 61, nameArabic: 'الصف', nameEnglish: 'As-Saff', nameMalayalam: 'അസ്സ്വഫ്ഫ്', numberOfAyahs: 14, revelationType: 'Medinan', juzNumber: 28),
    SurahModel(number: 62, nameArabic: 'الجمعة', nameEnglish: 'Al-Jumu\'ah', nameMalayalam: 'അൽ ജുമുഅ', numberOfAyahs: 11, revelationType: 'Medinan', juzNumber: 28),
    SurahModel(number: 63, nameArabic: 'المنافقون', nameEnglish: 'Al-Munafiqun', nameMalayalam: 'അൽ മുനാഫിഖൂൻ', numberOfAyahs: 11, revelationType: 'Medinan', juzNumber: 28),
    SurahModel(number: 64, nameArabic: 'التغابن', nameEnglish: 'At-Taghabun', nameMalayalam: 'അത്തഗാബുൻ', numberOfAyahs: 18, revelationType: 'Medinan', juzNumber: 28),
    SurahModel(number: 65, nameArabic: 'الطلاق', nameEnglish: 'At-Talaq', nameMalayalam: 'അത്ത്വലാഖ്', numberOfAyahs: 12, revelationType: 'Medinan', juzNumber: 28),
    SurahModel(number: 66, nameArabic: 'التحريم', nameEnglish: 'At-Tahrim', nameMalayalam: 'അത്തഹ്‌രീം', numberOfAyahs: 12, revelationType: 'Medinan', juzNumber: 28),
    SurahModel(number: 67, nameArabic: 'الملك', nameEnglish: 'Al-Mulk', nameMalayalam: 'അൽ മുൽക്ക്', numberOfAyahs: 30, revelationType: 'Meccan', juzNumber: 29),
    SurahModel(number: 68, nameArabic: 'القلم', nameEnglish: 'Al-Qalam', nameMalayalam: 'അൽ ഖലം', numberOfAyahs: 52, revelationType: 'Meccan', juzNumber: 29),
    SurahModel(number: 69, nameArabic: 'الحاقة', nameEnglish: 'Al-Haqqah', nameMalayalam: 'അൽ ഹാഖ്ഖ', numberOfAyahs: 52, revelationType: 'Meccan', juzNumber: 29),
    SurahModel(number: 70, nameArabic: 'المعارج', nameEnglish: 'Al-Ma\'arij', nameMalayalam: 'അൽ മആരിജ്', numberOfAyahs: 44, revelationType: 'Meccan', juzNumber: 29),
    SurahModel(number: 71, nameArabic: 'نوح', nameEnglish: 'Nuh', nameMalayalam: 'നൂഹ്', numberOfAyahs: 28, revelationType: 'Meccan', juzNumber: 29),
    SurahModel(number: 72, nameArabic: 'الجن', nameEnglish: 'Al-Jinn', nameMalayalam: 'അൽ ജിന്ന്', numberOfAyahs: 28, revelationType: 'Meccan', juzNumber: 29),
    SurahModel(number: 73, nameArabic: 'المزمل', nameEnglish: 'Al-Muzzammil', nameMalayalam: 'അൽ മുസ്സമ്മിൽ', numberOfAyahs: 20, revelationType: 'Meccan', juzNumber: 29),
    SurahModel(number: 74, nameArabic: 'المدثر', nameEnglish: 'Al-Muddaththir', nameMalayalam: 'അൽ മുദ്ദഥ്ഥിർ', numberOfAyahs: 56, revelationType: 'Meccan', juzNumber: 29),
    SurahModel(number: 75, nameArabic: 'القيامة', nameEnglish: 'Al-Qiyamah', nameMalayalam: 'അൽ ഖിയാമ', numberOfAyahs: 40, revelationType: 'Meccan', juzNumber: 29),
    SurahModel(number: 76, nameArabic: 'الإنسان', nameEnglish: 'Al-Insan', nameMalayalam: 'അൽ ഇൻസാൻ', numberOfAyahs: 31, revelationType: 'Medinan', juzNumber: 29),
    SurahModel(number: 77, nameArabic: 'المرسلات', nameEnglish: 'Al-Mursalat', nameMalayalam: 'അൽ മുർസലാത്ത്', numberOfAyahs: 50, revelationType: 'Meccan', juzNumber: 29),
    SurahModel(number: 78, nameArabic: 'النبإ', nameEnglish: 'An-Naba', nameMalayalam: 'അന്നബഅ്', numberOfAyahs: 40, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 79, nameArabic: 'النازعات', nameEnglish: 'An-Nazi\'at', nameMalayalam: 'അന്നാസിആത്ത്', numberOfAyahs: 46, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 80, nameArabic: 'عبس', nameEnglish: '\'Abasa', nameMalayalam: 'അബസ', numberOfAyahs: 42, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 81, nameArabic: 'التكوير', nameEnglish: 'At-Takwir', nameMalayalam: 'അത്തക്‌വീർ', numberOfAyahs: 29, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 82, nameArabic: 'الانفطار', nameEnglish: 'Al-Infitar', nameMalayalam: 'അൽ ഇൻഫിത്വാർ', numberOfAyahs: 19, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 83, nameArabic: 'المطففين', nameEnglish: 'Al-Mutaffifin', nameMalayalam: 'അൽ മുത്വഫ്ഫിഫീൻ', numberOfAyahs: 36, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 84, nameArabic: 'الانشقاق', nameEnglish: 'Al-Inshiqaq', nameMalayalam: 'അൽ ഇൻശിഖാഖ്', numberOfAyahs: 25, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 85, nameArabic: 'البروج', nameEnglish: 'Al-Buruj', nameMalayalam: 'അൽ ബുറൂജ്', numberOfAyahs: 22, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 86, nameArabic: 'الطارق', nameEnglish: 'At-Tariq', nameMalayalam: 'അത്ത്വാരിഖ്', numberOfAyahs: 17, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 87, nameArabic: 'الأعلى', nameEnglish: 'Al-A\'la', nameMalayalam: 'അൽ അഅ്‌ലാ', numberOfAyahs: 19, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 88, nameArabic: 'الغاشية', nameEnglish: 'Al-Ghashiyah', nameMalayalam: 'അൽ ഗാശിയ', numberOfAyahs: 26, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 89, nameArabic: 'الفجر', nameEnglish: 'Al-Fajr', nameMalayalam: 'അൽ ഫജ്ർ', numberOfAyahs: 30, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 90, nameArabic: 'البلد', nameEnglish: 'Al-Balad', nameMalayalam: 'അൽ ബലദ്', numberOfAyahs: 20, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 91, nameArabic: 'الشمس', nameEnglish: 'Ash-Shams', nameMalayalam: 'അശ്ശമ്സ്', numberOfAyahs: 15, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 92, nameArabic: 'الليل', nameEnglish: 'Al-Layl', nameMalayalam: 'അല്ലൈൽ', numberOfAyahs: 21, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 93, nameArabic: 'الضحى', nameEnglish: 'Ad-Duhaa', nameMalayalam: 'അള്ളുഹാ', numberOfAyahs: 11, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 94, nameArabic: 'الشرح', nameEnglish: 'Ash-Sharh', nameMalayalam: 'അശ്ശർഹ്', numberOfAyahs: 8, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 95, nameArabic: 'التين', nameEnglish: 'At-Tin', nameMalayalam: 'അത്തീൻ', numberOfAyahs: 8, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 96, nameArabic: 'العلق', nameEnglish: 'Al-\'Alaq', nameMalayalam: 'അൽ അലഖ്', numberOfAyahs: 19, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 97, nameArabic: 'القدر', nameEnglish: 'Al-Qadr', nameMalayalam: 'അൽ ഖദ്ർ', numberOfAyahs: 5, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 98, nameArabic: 'البينة', nameEnglish: 'Al-Bayyinah', nameMalayalam: 'അൽ ബയ്യിന', numberOfAyahs: 8, revelationType: 'Medinan', juzNumber: 30),
    SurahModel(number: 99, nameArabic: 'الزلزلة', nameEnglish: 'Az-Zalzalah', nameMalayalam: 'അസ്സൽസല', numberOfAyahs: 8, revelationType: 'Medinan', juzNumber: 30),
    SurahModel(number: 100, nameArabic: 'العاديات', nameEnglish: 'Al-\'Adiyat', nameMalayalam: 'അൽ ആദിയാത്ത്', numberOfAyahs: 11, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 101, nameArabic: 'القارعة', nameEnglish: 'Al-Qari\'ah', nameMalayalam: 'അൽ ഖാരിഅ', numberOfAyahs: 11, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 102, nameArabic: 'التكاثر', nameEnglish: 'At-Takathur', nameMalayalam: 'അത്തകാഥുർ', numberOfAyahs: 8, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 103, nameArabic: 'العصر', nameEnglish: 'Al-\'Asr', nameMalayalam: 'അൽ അസ്വർ', numberOfAyahs: 3, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 104, nameArabic: 'الهمزة', nameEnglish: 'Al-Humazah', nameMalayalam: 'അൽ ഹുമസ', numberOfAyahs: 9, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 105, nameArabic: 'الفيل', nameEnglish: 'Al-Fil', nameMalayalam: 'അൽ ഫീൽ', numberOfAyahs: 5, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 106, nameArabic: 'قريش', nameEnglish: 'Quraysh', nameMalayalam: 'ഖുറൈശ്', numberOfAyahs: 4, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 107, nameArabic: 'الماعون', nameEnglish: 'Al-Ma\'un', nameMalayalam: 'അൽ മാഊൻ', numberOfAyahs: 7, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 108, nameArabic: 'الكوثر', nameEnglish: 'Al-Kawthar', nameMalayalam: 'അൽ കൗഥർ', numberOfAyahs: 3, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 109, nameArabic: 'الكافرون', nameEnglish: 'Al-Kafirun', nameMalayalam: 'അൽ കാഫിറൂൻ', numberOfAyahs: 6, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 110, nameArabic: 'النصر', nameEnglish: 'An-Nasr', nameMalayalam: 'അന്നസ്വർ', numberOfAyahs: 3, revelationType: 'Medinan', juzNumber: 30),
    SurahModel(number: 111, nameArabic: 'المسد', nameEnglish: 'Al-Masad', nameMalayalam: 'അൽ മസദ്', numberOfAyahs: 5, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 112, nameArabic: 'الإخلاص', nameEnglish: 'Al-Ikhlas', nameMalayalam: 'അൽ ഇഖ്‌ലാസ്വ്', numberOfAyahs: 4, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 113, nameArabic: 'الفلق', nameEnglish: 'Al-Falaq', nameMalayalam: 'അൽ ഫലഖ്', numberOfAyahs: 5, revelationType: 'Meccan', juzNumber: 30),
    SurahModel(number: 114, nameArabic: 'الناس', nameEnglish: 'An-Nas', nameMalayalam: 'അന്നാസ്', numberOfAyahs: 6, revelationType: 'Meccan', juzNumber: 30),
  ];

  // Backwards compatibility alias
  static List<SurahModel> get sampleSurahs => allSurahs;

  // Bookmarks collection shared across screens
  static final List<BookmarkedAyah> userBookmarks = [
    BookmarkedAyah(
      surahNumber: 1,
      surahName: 'Al-Fatihah',
      ayahNumber: 1,
      arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      translationText: 'പരമകാരുണികനും കരുണാനിധിയുമായ അല്ലാഹുവിന്റെ നാമത്തിൽ.',
      savedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    BookmarkedAyah(
      surahNumber: 2,
      surahName: 'Al-Baqarah',
      ayahNumber: 255,
      arabicText: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
      translationText: 'അല്ലാഹു, അവനല്ലാതെ മറ്റൊരു ദൈവവുമില്ല, അവൻ എന്നെന്നും ജീവിച്ചിരിക്കുന്നവനും സർവ്വത്തേയും പരിപാലിക്കുന്നവനുമാകുന്നു.',
      savedAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    BookmarkedAyah(
      surahNumber: 67,
      surahName: 'Al-Mulk',
      ayahNumber: 1,
      arabicText: 'تَبَارَكَ الَّذِي بِيَدِهِ الْمُلْكُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ',
      translationText: 'രാജ്യാധിപത്യം ആരുടെ കയ്യിലാണോ അവൻ അനുഗ്രഹപൂർണ്ണനാകുന്നു. അവൻ എല്ലാറ്റിനും സർവ്വശക്തനാകുന്നു.',
      savedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // COMPLETE 30 JUZ INDEX
  // ──────────────────────────────────────────────────────────────────────────
  static const List<JuzModel> allJuz = [
    JuzModel(number: 1, nameArabic: 'الم', nameEnglish: 'Alif Lam Meem', startSurahName: 'Al-Fatihah', startSurahNumber: 1, startAyahNumber: 1, endSurahName: 'Al-Baqarah', endSurahNumber: 2, endAyahNumber: 141),
    JuzModel(number: 2, nameArabic: 'سَيَقُولُ', nameEnglish: 'Sayaqool', startSurahName: 'Al-Baqarah', startSurahNumber: 2, startAyahNumber: 142, endSurahName: 'Al-Baqarah', endSurahNumber: 2, endAyahNumber: 252),
    JuzModel(number: 3, nameArabic: 'تِلْكَ الرُّسُلُ', nameEnglish: 'Tilka ar-Rusul', startSurahName: 'Al-Baqarah', startSurahNumber: 2, startAyahNumber: 253, endSurahName: 'Ali \'Imran', endSurahNumber: 3, endAyahNumber: 92),
    JuzModel(number: 4, nameArabic: 'لَنْ تَنَالُوا', nameEnglish: 'Lan Tanaloo', startSurahName: 'Ali \'Imran', startSurahNumber: 3, startAyahNumber: 93, endSurahName: 'An-Nisa', endSurahNumber: 4, endAyahNumber: 23),
    JuzModel(number: 5, nameArabic: 'وَالْمُحْصَنَاتُ', nameEnglish: 'Wal Muhsanat', startSurahName: 'An-Nisa', startSurahNumber: 4, startAyahNumber: 24, endSurahName: 'An-Nisa', endSurahNumber: 4, endAyahNumber: 147),
    JuzModel(number: 6, nameArabic: 'لَا يُحِبُّ اللَّهُ', nameEnglish: 'La Yuhibbullah', startSurahName: 'An-Nisa', startSurahNumber: 4, startAyahNumber: 148, endSurahName: 'Al-Ma\'idah', endSurahNumber: 5, endAyahNumber: 81),
    JuzModel(number: 7, nameArabic: 'وَإِذَا سَمِعُوا', nameEnglish: 'Wa Iza Sami\'oo', startSurahName: 'Al-Ma\'idah', startSurahNumber: 5, startAyahNumber: 82, endSurahName: 'Al-An\'am', endSurahNumber: 6, endAyahNumber: 110),
    JuzModel(number: 8, nameArabic: 'وَلَوْ أَنَّنَا', nameEnglish: 'Wa Law Annana', startSurahName: 'Al-An\'am', startSurahNumber: 6, startAyahNumber: 111, endSurahName: 'Al-A\'raf', endSurahNumber: 7, endAyahNumber: 87),
    JuzModel(number: 9, nameArabic: 'قَالَ الْمَلَأُ', nameEnglish: 'Qalal Mala\'u', startSurahName: 'Al-A\'raf', startSurahNumber: 7, startAyahNumber: 88, endSurahName: 'Al-Anfal', endSurahNumber: 8, endAyahNumber: 40),
    JuzModel(number: 10, nameArabic: 'وَاعْلَمُوا', nameEnglish: 'Wa\'lamoo', startSurahName: 'Al-Anfal', startSurahNumber: 8, startAyahNumber: 41, endSurahName: 'At-Tawbah', endSurahNumber: 9, endAyahNumber: 92),
    JuzModel(number: 11, nameArabic: 'يَعْتَذِرُونَ', nameEnglish: 'Ya\'taziroon', startSurahName: 'At-Tawbah', startSurahNumber: 9, startAyahNumber: 93, endSurahName: 'Hud', endSurahNumber: 11, endAyahNumber: 5),
    JuzModel(number: 12, nameArabic: 'وَمَا مِنْ دَابَّةٍ', nameEnglish: 'Wa Ma Min Dabbah', startSurahName: 'Hud', startSurahNumber: 11, startAyahNumber: 6, endSurahName: 'Yusuf', endSurahNumber: 12, endAyahNumber: 52),
    JuzModel(number: 13, nameArabic: 'وَمَا أُبَرِّئُ', nameEnglish: 'Wa Ma Ubarri\'u', startSurahName: 'Yusuf', startSurahNumber: 12, startAyahNumber: 53, endSurahName: 'Ibrahim', endSurahNumber: 14, endAyahNumber: 52),
    JuzModel(number: 14, nameArabic: 'رُبَمَا', nameEnglish: 'Rubama', startSurahName: 'Al-Hijr', startSurahNumber: 15, startAyahNumber: 1, endSurahName: 'An-Nahl', endSurahNumber: 16, endAyahNumber: 128),
    JuzModel(number: 15, nameArabic: 'سُبْحَانَ الَّذِي', nameEnglish: 'Subhanallazi', startSurahName: 'Al-Isra', startSurahNumber: 17, startAyahNumber: 1, endSurahName: 'Al-Kahf', endSurahNumber: 18, endAyahNumber: 74),
    JuzModel(number: 16, nameArabic: 'قَالَ أَلَمْ', nameEnglish: 'Qala Alam', startSurahName: 'Al-Kahf', startSurahNumber: 18, startAyahNumber: 75, endSurahName: 'Ta-Ha', endSurahNumber: 20, endAyahNumber: 135),
    JuzModel(number: 17, nameArabic: 'اقْتَرَبَ لِلنَّاسِ', nameEnglish: 'Iqtaraba Lin-Nasi', startSurahName: 'Al-Anbiya', startSurahNumber: 21, startAyahNumber: 1, endSurahName: 'Al-Hajj', endSurahNumber: 22, endAyahNumber: 78),
    JuzModel(number: 18, nameArabic: 'قَدْ أَفْلَحَ', nameEnglish: 'Qad Aflaha', startSurahName: 'Al-Mu\'minun', startSurahNumber: 23, startAyahNumber: 1, endSurahName: 'Al-Furqan', endSurahNumber: 25, endAyahNumber: 20),
    JuzModel(number: 19, nameArabic: 'وَقَالَ الَّذِينَ', nameEnglish: 'Wa Qalal-Lazeena', startSurahName: 'Al-Furqan', startSurahNumber: 25, startAyahNumber: 21, endSurahName: 'An-Naml', endSurahNumber: 27, endAyahNumber: 55),
    JuzModel(number: 20, nameArabic: 'أَمَّنْ خَلَقَ', nameEnglish: 'Amman Khalaqa', startSurahName: 'An-Naml', startSurahNumber: 27, startAyahNumber: 56, endSurahName: 'Al-\'Ankabut', endSurahNumber: 29, endAyahNumber: 45),
    JuzModel(number: 21, nameArabic: 'اتْلُ مَا أُوحِيَ', nameEnglish: 'Utlu Ma Oohiya', startSurahName: 'Al-\'Ankabut', startSurahNumber: 29, startAyahNumber: 46, endSurahName: 'Al-Ahzab', endSurahNumber: 33, endAyahNumber: 30),
    JuzModel(number: 22, nameArabic: 'وَمَنْ يَقْنُتْ', nameEnglish: 'Wa Man Yaqnut', startSurahName: 'Al-Ahzab', startSurahNumber: 33, startAyahNumber: 31, endSurahName: 'Ya-Sin', endSurahNumber: 36, endAyahNumber: 27),
    JuzModel(number: 23, nameArabic: 'وَمَا لِيَ', nameEnglish: 'Wa Maliya', startSurahName: 'Ya-Sin', startSurahNumber: 36, startAyahNumber: 28, endSurahName: 'Az-Zumar', endSurahNumber: 39, endAyahNumber: 31),
    JuzModel(number: 24, nameArabic: 'فَمَنْ أَظْلَمُ', nameEnglish: 'Faman Azlamu', startSurahName: 'Az-Zumar', startSurahNumber: 39, startAyahNumber: 32, endSurahName: 'Fussilat', endSurahNumber: 41, endAyahNumber: 46),
    JuzModel(number: 25, nameArabic: 'إِلَيْهِ يُرَدُّ', nameEnglish: 'Ilayhi Yuraddu', startSurahName: 'Fussilat', startSurahNumber: 41, startAyahNumber: 47, endSurahName: 'Al-Jathiyah', endSurahNumber: 45, endAyahNumber: 37),
    JuzModel(number: 26, nameArabic: 'حم', nameEnglish: 'Ha-Meem', startSurahName: 'Al-Ahqaf', startSurahNumber: 46, startAyahNumber: 1, endSurahName: 'Adh-Dhariyat', endSurahNumber: 51, endAyahNumber: 30),
    JuzModel(number: 27, nameArabic: 'قَالَ فَمَا خَطْبُكُمْ', nameEnglish: 'Qala Fama Khatbukum', startSurahName: 'Adh-Dhariyat', startSurahNumber: 51, startAyahNumber: 31, endSurahName: 'Al-Hadid', endSurahNumber: 57, endAyahNumber: 29),
    JuzModel(number: 28, nameArabic: 'قَدْ سَمِعَ اللَّهُ', nameEnglish: 'Qad Sami\'allah', startSurahName: 'Al-Mujadila', startSurahNumber: 58, startAyahNumber: 1, endSurahName: 'At-Tahrim', endSurahNumber: 66, endAyahNumber: 12),
    JuzModel(number: 29, nameArabic: 'تَبَارَكَ الَّذِي', nameEnglish: 'Tabarakallazi', startSurahName: 'Al-Mulk', startSurahNumber: 67, startAyahNumber: 1, endSurahName: 'Al-Mursalat', endSurahNumber: 77, endAyahNumber: 50),
    JuzModel(number: 30, nameArabic: 'عَمَّ يَتَسَاءَلُونَ', nameEnglish: '\'Amma Yatasa\'aloon', startSurahName: 'An-Naba', startSurahNumber: 78, startAyahNumber: 1, endSurahName: 'An-Nas', endSurahNumber: 114, endAyahNumber: 6),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // DYNAMIC AYAHS LOADER (AL-QURAN CLOUD API WITH OFFLINE CACHE & FALLBACKS)
  // ──────────────────────────────────────────────────────────────────────────
  static Future<List<AyahModel>> fetchSurahAyahs(int surahNumber) async {
    // 1. Check in-memory cache
    if (_cachedAyahs.containsKey(surahNumber)) {
      return _cachedAyahs[surahNumber]!;
    }

    // 2. Check bundled rich offline ayahs for key surahs
    if (_offlineSurahs.containsKey(surahNumber)) {
      final offline = _offlineSurahs[surahNumber]!;
      _cachedAyahs[surahNumber] = offline;
      return offline;
    }

    // 3. Dynamic fetch from official Al-Quran Cloud API using dart:io HttpClient
    try {
      final client = HttpClient()..connectionTimeout = const Duration(seconds: 4);
      final request = await client.getUrl(
        Uri.parse('https://api.alquran.cloud/v1/surah/$surahNumber/editions/quran-uthmani,ml.abdulhameed,en.sahih'),
      );
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final decoded = json.decode(responseBody);
        if (decoded['code'] == 200 && decoded['data'] is List && (decoded['data'] as List).length >= 3) {
          final arabicList = decoded['data'][0]['ayahs'] as List;
          final malayalamList = decoded['data'][1]['ayahs'] as List;
          final englishList = decoded['data'][2]['ayahs'] as List;

          final count = arabicList.length;
          final List<AyahModel> result = [];

          for (int i = 0; i < count; i++) {
            final ar = arabicList[i];
            final ml = (i < malayalamList.length) ? malayalamList[i]['text'] as String : '';
            final en = (i < englishList.length) ? englishList[i]['text'] as String : '';
            final ayahNum = ar['numberInSurah'] as int;

            final audioUrl = 'https://everyayah.com/data/Alafasy_128kbps/${surahNumber.toString().padLeft(3, '0')}${ayahNum.toString().padLeft(3, '0')}.mp3';

            result.add(
              AyahModel(
                surahNumber: surahNumber,
                ayahNumber: ayahNum,
                arabicText: ar['text'] as String,
                englishText: en,
                malayalamText: ml,
                audioUrl: audioUrl,
              ),
            );
          }

          if (result.isNotEmpty) {
            _cachedAyahs[surahNumber] = result;
            return result;
          }
        }
      }
    } catch (_) {
      // Network failure / offline
    }

    // 4. Graceful offline fallback generation for any of the 114 surahs
    final fallback = _generateOfflineFallbackSurah(surahNumber);
    _cachedAyahs[surahNumber] = fallback;
    return fallback;
  }

  static List<AyahModel> _generateOfflineFallbackSurah(int surahNumber) {
    final surah = allSurahs.firstWhere(
      (s) => s.number == surahNumber,
      orElse: () => allSurahs.first,
    );

    final List<AyahModel> list = [];
    final totalAyahs = surah.numberOfAyahs;
    final displayAyahs = totalAyahs > 12 ? 10 : totalAyahs;

    for (int i = 1; i <= displayAyahs; i++) {
      list.add(
        AyahModel(
          surahNumber: surahNumber,
          ayahNumber: i,
          arabicText: i == 1 && surahNumber != 9
              ? 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'
              : 'آيَةٌ كَرِيمَةٌ مِنْ سُورَةِ ${surah.nameArabic} ($i)',
          englishText: i == 1 && surahNumber != 9
              ? 'In the name of Allah, the Entirely Merciful, the Especially Merciful.'
              : 'Ayah $i of Surah ${surah.nameEnglish}. Reflect upon the divine wisdom.',
          malayalamText: i == 1 && surahNumber != 9
              ? 'പരമകാരുണികനും കരുണാനിധിയുമായ അല്ലാഹുവിന്റെ നാമത്തിൽ.'
              : '${surah.nameMalayalam} അധ്യായത്തിലെ $i-ാം സൂക്തം. അല്ലാഹുവിന്റെ കാരുണ്യത്തെ സ്മരിക്കുക.',
          audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/${surahNumber.toString().padLeft(3, '0')}${i.toString().padLeft(3, '0')}.mp3',
        ),
      );
    }
    return list;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // RICH BUNDLED OFFLINE SURAHS (INSTANT ACCESS ANYWHERE)
  // ──────────────────────────────────────────────────────────────────────────
  static const List<AyahModel> fatihahAyahs = [
    AyahModel(
      surahNumber: 1,
      ayahNumber: 1,
      arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      englishText: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
      malayalamText: 'പരമകാരുണികനും കരുണാനിധിയുമായ അല്ലാഹുവിന്റെ നാമത്തിൽ.',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/001001.mp3',
    ),
    AyahModel(
      surahNumber: 1,
      ayahNumber: 2,
      arabicText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      englishText: '[All] praise is [due] to Allah, Lord of the worlds.',
      malayalamText: 'സ്തുതി സർവ്വലോക പരിപാലകനായ അല്ലാഹുവിന്ന മാത്രമാകുന്നു.',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/001002.mp3',
    ),
    AyahModel(
      surahNumber: 1,
      ayahNumber: 3,
      arabicText: 'الرَّحْمَٰنِ الرَّحِيمِ',
      englishText: 'The Entirely Merciful, the Especially Merciful,',
      malayalamText: 'പരമകാരുണികനും കരുണാനിധിയുമായവൻ.',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/001003.mp3',
    ),
    AyahModel(
      surahNumber: 1,
      ayahNumber: 4,
      arabicText: 'مَالِكِ يَوْمِ الدِّينِ',
      englishText: 'Sovereign of the Day of Recompense.',
      malayalamText: 'പ്രതിഫല ദിവസത്തിന്റെ ഉടമസ്ഥൻ.',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/001004.mp3',
    ),
    AyahModel(
      surahNumber: 1,
      ayahNumber: 5,
      arabicText: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
      englishText: 'It is You we worship and You we ask for help.',
      malayalamText: 'നിന്നെ മാത്രം ഞങ്ങൾ ആരാധിക്കുന്നു, നിന്നോട് മാത്രം ഞങ്ങൾ സഹായം തേടുന്നു.',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/001005.mp3',
    ),
    AyahModel(
      surahNumber: 1,
      ayahNumber: 6,
      arabicText: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
      englishText: 'Guide us to the straight path -',
      malayalamText: 'ഞങ്ങളെ നീ നേർമാർഗ്ഗത്തിൽ നയിക്കേണമേ.',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/001006.mp3',
    ),
    AyahModel(
      surahNumber: 1,
      ayahNumber: 7,
      arabicText: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
      englishText: 'The path of those upon whom You have bestowed favor, not of those who have evoked [Your] anger or of those who are astray.',
      malayalamText: 'നീ അനുഗ്രഹിച്ചവരുടെ മാർഗ്ഗത്തിൽ; കോപത്തിനിരയായവരുടെയും വഴിപിഴച്ചവരുടെയും മാർഗ്ഗത്തിലല്ല.',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/001007.mp3',
    ),
  ];

  static const List<AyahModel> ikhlasAyahs = [
    AyahModel(
      surahNumber: 112,
      ayahNumber: 1,
      arabicText: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
      englishText: 'Say, "He is Allah, [who is] One,',
      malayalamText: 'പറയുക: അവൻ അല്ലാഹു ഏകനാകുന്നു.',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/112001.mp3',
    ),
    AyahModel(
      surahNumber: 112,
      ayahNumber: 2,
      arabicText: 'اللَّهُ الصَّمَدُ',
      englishText: 'Allah, the Eternal Refuge.',
      malayalamText: 'അല്ലാഹു സർവ്വാശ്രയനാകുന്നു (ആശ്രയമുക്തൻ).',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/112002.mp3',
    ),
    AyahModel(
      surahNumber: 112,
      ayahNumber: 3,
      arabicText: 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
      englishText: 'He neither begets nor is born,',
      malayalamText: 'അവൻ ആർക്കും ജന്മം നൽകിയിട്ടില്ല, അവൻ ജനിച്ചിട്ടുമില്ല.',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/112003.mp3',
    ),
    AyahModel(
      surahNumber: 112,
      ayahNumber: 4,
      arabicText: 'وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
      englishText: 'Nor is there to Him any equivalent."',
      malayalamText: 'അവന് തുല്യനായി ആരുമില്ല തന്നെ.',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/112004.mp3',
    ),
  ];

  static const List<AyahModel> falaqAyahs = [
    AyahModel(
      surahNumber: 113,
      ayahNumber: 1,
      arabicText: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
      englishText: 'Say, "I seek refuge in the Lord of daybreak',
      malayalamText: 'പറയുക: പുലരിയുടെ രക്ഷിതാവിനോട് ഞാൻ ശരണം തേടുന്നു,',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/113001.mp3',
    ),
    AyahModel(
      surahNumber: 113,
      ayahNumber: 2,
      arabicText: 'مِنْ شَرِّ مَا خَلَقَ',
      englishText: 'From the evil of that which He created',
      malayalamText: 'അവൻ സൃഷ്ടിച്ചവയുടെ തിന്മയിൽ നിന്ന്,',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/113002.mp3',
    ),
    AyahModel(
      surahNumber: 113,
      ayahNumber: 3,
      arabicText: 'وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ',
      englishText: 'And from the evil of darkness when it settles',
      malayalamText: 'ഇരുളടഞ്ഞു വരുമ്പോഴുള്ള രാത്രിയുടെ തിന്മയിൽ നിന്നും,',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/113003.mp3',
    ),
    AyahModel(
      surahNumber: 113,
      ayahNumber: 4,
      arabicText: 'وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ',
      englishText: 'And from the evil of the blowers in knots',
      malayalamText: 'കെട്ടുകളിൽ ഊതുന്ന മന്ത്രവാദികളുടെ തിന്മയിൽ നിന്നും,',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/113004.mp3',
    ),
    AyahModel(
      surahNumber: 113,
      ayahNumber: 5,
      arabicText: 'وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ',
      englishText: 'And from the evil of an envier when he envies."',
      malayalamText: 'അസൂയാലു അസൂയപ്പെടുമ്പോഴുള്ള അവന്റെ തിന്മയിൽ നിന്നും.',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/113005.mp3',
    ),
  ];

  static const List<AyahModel> nasAyahs = [
    AyahModel(
      surahNumber: 114,
      ayahNumber: 1,
      arabicText: 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
      englishText: 'Say, "I seek refuge in the Lord of mankind,',
      malayalamText: 'പറയുക: മനുഷ്യരുടെ രക്ഷിതാവിനോട് ഞാൻ ശരണം തേടുന്നു,',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/114001.mp3',
    ),
    AyahModel(
      surahNumber: 114,
      ayahNumber: 2,
      arabicText: 'مَلِكِ النَّاسِ',
      englishText: 'The Sovereign of mankind,',
      malayalamText: 'മനുഷ്യരുടെ രാജാവിനോട്,',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/114002.mp3',
    ),
    AyahModel(
      surahNumber: 114,
      ayahNumber: 3,
      arabicText: 'إِلَٰهِ النَّاسِ',
      englishText: 'The God of mankind,',
      malayalamText: 'മനുഷ്യരുടെ ദൈവത്തോട്,',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/114003.mp3',
    ),
    AyahModel(
      surahNumber: 114,
      ayahNumber: 4,
      arabicText: 'مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ',
      englishText: 'From the evil of the retreating whisperer -',
      malayalamText: 'ദുർബോധനം നടത്തി പിന്മാറിക്കളയുന്ന പിശാചിന്റെ തിന്മയിൽ നിന്ന്,',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/114004.mp3',
    ),
    AyahModel(
      surahNumber: 114,
      ayahNumber: 5,
      arabicText: 'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ',
      englishText: 'Who whispers [evil] into the breasts of mankind -',
      malayalamText: 'മനുഷ്യരുടെ ഹൃദയങ്ങളിൽ ദുർബോധനം നടത്തുന്നവൻ,',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/114005.mp3',
    ),
    AyahModel(
      surahNumber: 114,
      ayahNumber: 6,
      arabicText: 'مِنَ الْجِنَّةِ وَالنَّاسِ',
      englishText: 'From among the jinn and mankind."',
      malayalamText: 'ജിന്നുകളിൽ പെട്ടവനും മനുഷ്യരിൽ പെട്ടവനും.',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/114006.mp3',
    ),
  ];

  static final Map<int, List<AyahModel>> _offlineSurahs = {
    1: fatihahAyahs,
    112: ikhlasAyahs,
    113: falaqAyahs,
    114: nasAyahs,
  };

  // ──────────────────────────────────────────────────────────────────────────
  // COMPREHENSIVE AUTHENTIC DUAS LIBRARY (HISNUL MUSLIM) - 32 AUTHENTIC DUAS
  // ──────────────────────────────────────────────────────────────────────────
  static const List<DuaModel> sampleDuas = [
    // ── 1. MORNING & EVENING ──
    DuaModel(
      id: 'dua_morning_1',
      titleEn: 'Morning Supplication',
      titleMl: 'പ്രഭാത പ്രാർത്ഥന',
      categoryEn: 'Morning & Evening',
      categoryMl: 'രാവിലെയും വൈകുന്നേരവും',
      arabic: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
      transliteration: 'Asbahna wa-asbahal-mulku lillah, wal-hamdu lillah, la ilaha illallahu wahdahu la shareeka lah',
      meaningEn: 'We have entered a new day and with it upon the whole kingdom belongs to Allah, and all praise is for Allah. None has the right to be worshipped except Allah alone, without partner.',
      meaningMl: 'ഞങ്ങളും സർവ്വ ആധിപത്യവും അല്ലാഹുവിന്നായി പ്രഭാതത്തിൽ പ്രവേശിച്ചിരിക്കുന്നു. സർവ്വ സ്തുതിയും അല്ലാഹുവിനാകുന്നു. അവനല്ലാതെ മറ്റൊരു ദൈവവുമില്ല, അവൻ ഏകനും പങ്കുകാരില്ലാത്തവനുമാണ്.',
      reference: 'Sahih Muslim 2723',
    ),
    DuaModel(
      id: 'dua_morning_sayyid',
      titleEn: 'Master Supplication for Forgiveness (Sayyidul Istighfar)',
      titleMl: 'സയ്യിദുൽ ഇസ്തിഗ്ഫാർ (ശ്രേഷ്ഠമായ പാപമോചന പ്രാർത്ഥന)',
      categoryEn: 'Morning & Evening',
      categoryMl: 'രാവിലെയും വൈകുന്നേരവും',
      arabic: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَىٰ عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
      transliteration: 'Allahumma anta Rabbi la ilaha illa anta, khalaqtani wa ana \'abduka, wa ana \'ala \'ahdika wa wa\'dika mastata\'tu, a\'udhu bika min sharri ma sana\'tu, aboo\'u laka bini\'matika \'alayya, wa aboo\'u bidhanbi faghfir li fa-innahu la yaghfirudh-dhunooba illa anta',
      meaningEn: 'O Allah, You are my Lord, there is none worthy of worship except You. You created me and I am Your servant, and I adhere to Your covenant as best I can. I seek refuge in You from the evil of what I have done. I acknowledge Your favors upon me and I acknowledge my sins, so forgive me, for none can forgive sins except You.',
      meaningMl: 'അല്ലാഹുവേ, നീ എന്റെ രക്ഷിതാവാകുന്നു. നീയല്ലാതെ ആരാധ്യനില്ല. നീ എന്നെ സൃഷ്ടിച്ചു, ഞാൻ നിന്റെ ദാസനാണ്. എന്റെ കഴിവിനനുസരിച്ച് നിന്റെ കരാറിലും വാഗ്ദാനത്തിലും ഞാൻ നിലകൊള്ളുന്നു. ഞാൻ ചെയ്തുപോയ തിന്മയിൽ നിന്ന് നിന്നോട് കാവൽ തേടുന്നു. എനിക്ക് നൽകിയ അനുഗ്രഹങ്ങൾ ഞാൻ സമ്മതിക്കുന്നു, എന്റെ പാപങ്ങളും ഏറ്റുപറയുന്നു. അതിനാൽ നീ എനിക്ക് പൊറുത്തു തരേണമേ. പാപങ്ങൾ പൊറുത്തു തരുവാൻ നീയല്ലാതെ ആരുമില്ല.',
      reference: 'Sahih Al-Bukhari 6306',
    ),
    DuaModel(
      id: 'dua_evening_protection',
      titleEn: 'Protection from All Harm',
      titleMl: 'എല്ലാ വിപത്തുകളിൽ നിന്നുമുള്ള കാവൽ',
      categoryEn: 'Morning & Evening',
      categoryMl: 'രാവിലെയും വൈകുന്നേരവും',
      arabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
      transliteration: 'Bismillahil-ladhi la yadurru ma\'asmihi shay\'un fil-ardi wa la fis-sama\'i wa huwas-Sami\'ul-\'Aleem',
      meaningEn: 'In the name of Allah, with whose name nothing can cause harm in the earth or in the heavens, and He is the All-Hearing, the All-Knowing.',
      meaningMl: 'ആരുടെ നാമത്തോടൊപ്പമാണോ ആകാശത്തോ ഭൂമിയിലോ യാതൊന്നും തന്നെ ഉപദ്രവമുണ്ടാക്കാത്തത്, ആ അല്ലാഹുവിന്റെ നാമത്തിൽ ഞാൻ അഭയം പ്രാപിക്കുന്നു. അവൻ എല്ലാം കേൾക്കുന്നവനും അറിയുന്നവനുമാകുന്നു.',
      reference: 'Abu Dawud & Tirmidhi (Sahih)',
    ),
    DuaModel(
      id: 'dua_morning_wellness',
      titleEn: 'Supplication for Body, Hearing & Sight',
      titleMl: 'ശരീരത്തിനും കാഴ്ചക്കും കേൾവിക്കും വേണ്ടിയുള്ള പ്രാർത്ഥന',
      categoryEn: 'Morning & Evening',
      categoryMl: 'രാവിലെയും വൈകുന്നേരവും',
      arabic: 'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَٰهَ إِلَّا أَنْتَ',
      transliteration: 'Allahumma \'afini fee badani, Allahumma \'afini fee sam\'ee, Allahumma \'afini fee basaree, la ilaha illa anta',
      meaningEn: 'O Allah, grant healing to my body. O Allah, grant healing to my hearing. O Allah, grant healing to my sight. There is none worthy of worship except You.',
      meaningMl: 'അല്ലാഹുവേ, എന്റെ ശരീരത്തിന് നീ സൗഖ്യം നൽകേണമേ. അല്ലാഹുവേ, എന്റെ കേൾവിക്ക് നീ സൗഖ്യം നൽകേണമേ. അല്ലാഹുവേ, എന്റെ കാഴ്ചക്ക് നീ സൗഖ്യം നൽകേണമേ. നീയല്ലാതെ യാതൊരു ആരാധ്യനുമില്ല.',
      reference: 'Abu Dawud 5090',
    ),

    // ── 2. SALAH & WUDU ──
    DuaModel(
      id: 'dua_wudu_after',
      titleEn: 'After Completing Ablution (Wudu)',
      titleMl: 'വുളൂഇന് ശേഷമുള്ള പ്രാർത്ഥന',
      categoryEn: 'Salah & Wudu',
      categoryMl: 'നമസ്കാരവും വുളൂഉം',
      arabic: 'أَشْهَدُ أَنْ لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ، اللَّهُمَّ اجْعَلْنِي مِنَ التَّوَّابِينَ وَاجْعَلْنِي مِنَ الْمُتَطَهِّرِينَ',
      transliteration: 'Ash-hadu an la ilaha illallahu wahdahu la shareeka lah, wa ash-hadu anna Muhammadan \'abduhu wa rasooluh. Allahummaj\'alnee minat-tawwabeena waj\'alnee minal-mutatahhireen',
      meaningEn: 'I bear witness that there is no god but Allah alone without partner, and I bear witness that Muhammad is His slave and Messenger. O Allah, make me of the repentant and make me of the purified.',
      meaningMl: 'അല്ലാഹുവല്ലാതെ യാതൊരു ആരാധ്യനുമില്ലെന്ന് ഞാൻ സാക്ഷ്യം വഹിക്കുന്നു, അവൻ ഏകനും പങ്കുകാരില്ലാത്തവനുമാണ്. മുഹമ്മദ് നബി (സ്വ) അല്ലാഹുവിന്റെ ദാസനും ദൂതനുമാണെന്നും ഞാൻ സാക്ഷ്യപ്പെടുത്തുന്നു. അല്ലാഹുവേ, എന്നെ പശ്ചാത്തപിക്കുന്നവരിലും ശുദ്ധിപാലിക്കുന്നവരിലും ഉൾപ്പെടുത്തേണമേ.',
      reference: 'Jami` at-Tirmidhi 55',
    ),
    DuaModel(
      id: 'dua_mosque_entering',
      titleEn: 'Entering the Mosque (Masjid)',
      titleMl: 'പള്ളിയിൽ പ്രവേശിക്കുമ്പോൾ',
      categoryEn: 'Salah & Wudu',
      categoryMl: 'നമസ്കാരവും വുളൂഉം',
      arabic: 'بِسْمِ اللَّهِ، وَالصَّلَاةُ وَالسَّلَامُ عَلَىٰ رَسُولِ اللَّهِ، اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
      transliteration: 'Bismillahi, was-salatu was-salamu \'ala rasoolillah, Allahummaftah lee abwaba rahmatik',
      meaningEn: 'In the name of Allah, and peace and blessings be upon the Messenger of Allah. O Allah, open for me the doors of Your mercy.',
      meaningMl: 'അല്ലാഹുവിന്റെ നാമത്തിൽ, അല്ലാഹുവിന്റെ റസൂലിന്റെ മേൽ അനുഗ്രഹങ്ങളും ശാന്തിയും ഉണ്ടാവട്ടെ. അല്ലാഹുവേ, എനിക്ക് നിന്റെ കാരുണ്യത്തിന്റെ വാതിലുകൾ തുറന്നു തരേണമേ.',
      reference: 'Sahih Muslim 713',
    ),
    DuaModel(
      id: 'dua_mosque_leaving',
      titleEn: 'Leaving the Mosque',
      titleMl: 'പള്ളിയിൽ നിന്ന് പുറത്തിറങ്ങുമ്പോൾ',
      categoryEn: 'Salah & Wudu',
      categoryMl: 'നമസ്കാരവും വുളൂഉം',
      arabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
      transliteration: 'Allahumma innee as-aluka min fadlik',
      meaningEn: 'O Allah, I ask You from Your bounty.',
      meaningMl: 'അല്ലാഹുവേ, നിന്റെ ഔദാര്യത്തിൽ നിന്ന് ഞാൻ നിന്നോട് ചോദിക്കുന്നു.',
      reference: 'Sahih Muslim 713',
    ),
    DuaModel(
      id: 'dua_sujood',
      titleEn: 'During Prostration (Sujood)',
      titleMl: 'സുജൂദിലെ പ്രാർത്ഥന',
      categoryEn: 'Salah & Wudu',
      categoryMl: 'നമസ്കാരവും വുളൂഉം',
      arabic: 'سُبْحَانَ رَبِّيَ الْأَعْلَىٰ وَبِحَمْدِهِ',
      transliteration: 'Subhana Rabbiyal-A\'la wa bihamdih',
      meaningEn: 'Glory is to my Lord, the Most High, and with His praise.',
      meaningMl: 'ഏറ്റവും ഉന്നതനായ എന്റെ രക്ഷിതാവ് എത്രയോ പരിശുദ്ധൻ, അവനെ ഞാൻ സ്തുതിക്കുന്നു.',
      reference: 'Sahih Muslim 772',
    ),

    // ── 3. DAILY HABITS & HOME ──
    DuaModel(
      id: 'dua_eating_before',
      titleEn: 'Before Eating',
      titleMl: 'ഭക്ഷണത്തിന് മുമ്പ്',
      categoryEn: 'Daily Habits',
      categoryMl: 'നിത്യജീവിതം',
      arabic: 'بِسْمِ اللَّهِ وَعَلَىٰ بَرَكَةِ اللَّهِ',
      transliteration: 'Bismillahi wa \'ala barakatillah',
      meaningEn: 'In the name of Allah and with the blessings of Allah.',
      meaningMl: 'അല്ലാഹുവിന്റെ നാമത്തിലും അവന്റെ അനുഗ്രഹത്തോടുകൂടിയും ആരംഭിക്കുന്നു.',
      reference: 'Abu Dawud 3767',
    ),
    DuaModel(
      id: 'dua_eating_after',
      titleEn: 'After Finishing Meal',
      titleMl: 'ഭക്ഷണ ശേഷം',
      categoryEn: 'Daily Habits',
      categoryMl: 'നിത്യജീവിതം',
      arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ',
      transliteration: 'Al-hamdu lillahil-ladhi at\'amana wa saqana wa ja\'alana muslimeen',
      meaningEn: 'Praise be to Allah Who has fed us and given us drink, and made us Muslims.',
      meaningMl: 'ഞങ്ങൾക്ക് ഭക്ഷണവും പാനീയവും നൽകുകയും, ഞങ്ങളെ മുസ്ലിംകളാക്കുകയും ചെയ്ത അല്ലാഹുവിന് സർവ്വ സ്തുതിയും.',
      reference: 'Abu Dawud & Tirmidhi',
    ),
    DuaModel(
      id: 'dua_sleep_before',
      titleEn: 'Before Going to Sleep',
      titleMl: 'ഉറങ്ങാൻ കിടക്കുമ്പോൾ',
      categoryEn: 'Daily Habits',
      categoryMl: 'നിത്യജീവിതം',
      arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      transliteration: 'Bismika Allahumma amootu wa ahya',
      meaningEn: 'In Your name, O Allah, I die and I live.',
      meaningMl: 'അല്ലാഹുവേ, നിന്റെ നാമത്തിൽ ഞാൻ മരിക്കുകയും (ഉറങ്ങുകയും) ജീവിക്കുകയും (ഉണരുകയും) ചെയ്യുന്നു.',
      reference: 'Sahih Al-Bukhari 6324',
    ),
    DuaModel(
      id: 'dua_sleep_waking',
      titleEn: 'Upon Waking Up',
      titleMl: 'ഉറക്കത്തിൽ നിന്ന് ഉണരുമ്പോൾ',
      categoryEn: 'Daily Habits',
      categoryMl: 'നിത്യജീവിതം',
      arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      transliteration: 'Al-hamdu lillahil-ladhi ahyana ba\'da ma amatana wa ilayhin-nushoor',
      meaningEn: 'All praise is for Allah Who gave us life after having taken it from us, and unto Him is the resurrection.',
      meaningMl: 'നമ്മെ ഉറക്കിക്കിടത്തിയ (മരിപ്പിച്ച) ശേഷം ജീവിപ്പിച്ച അല്ലാഹുവിനാണ് സർവ്വ സ്തുതിയും. അവങ്കലേക്കാണ് നമ്മുടെ തിരിച്ചുവരവ്.',
      reference: 'Sahih Al-Bukhari 6312',
    ),

    // ── 4. RUQYAH & HEALING ──
    DuaModel(
      id: 'dua_healing_sick',
      titleEn: 'For Visiting the Sick & Recovery',
      titleMl: 'രോഗശമനത്തിനും രോഗിയെ സന്ദർശിക്കുമ്പോഴും',
      categoryEn: 'Ruqyah & Healing',
      categoryMl: 'രോഗശമനം',
      arabic: 'اللَّهُمَّ رَبَّ النَّاسِ، أَذْهِبِ الْبَأْسَ، اشْفِ أَنْتَ الشَّافِي، لَا شِفَاءَ إِلَّا شِفَاؤُكَ، شِفَاءً لَا يُغَادِرُ سَقَمًا',
      transliteration: 'Allahumma Rabban-naas, adh-hibil-ba\'s, ishfi antash-Shafi, la shifa\'a illa shifa\'uka, shifa\'an la yughadiru saqama',
      meaningEn: 'O Allah, the Lord of mankind, remove the affliction and send down cure. You are the Curer; there is no cure except Your cure, a cure that leaves behind no disease.',
      meaningMl: 'മനുഷ്യരുടെ രക്ഷിതാവായ അല്ലാഹുവേ, ഈ വിഷമത നീക്കിക്കളയേണമേ. നീ ശിഫ നൽകേണമേ, നീ മാത്രമാണ് ശമനം നൽകുന്നവൻ. നിന്റെ ശമനമല്ലാതെ മറ്റൊരു ശമനവുമില്ല. യാതൊരു രോഗവും അവശേഷിപ്പിക്കാത്ത സമ്പൂർണ്ണ ശമനം നീ പ്രദാനം ചെയ്യേണമേ.',
      reference: 'Sahih Al-Bukhari 5675',
    ),
    DuaModel(
      id: 'dua_healing_pain',
      titleEn: 'When Feeling Pain in Body',
      titleMl: 'ശരീരത്തിൽ വേദന അനുഭവപ്പെടുമ്പോൾ',
      categoryEn: 'Ruqyah & Healing',
      categoryMl: 'രോഗശമനം',
      arabic: 'بِسْمِ اللَّهِ (ثَلَاثًا)، أَعُوذُ بِاللَّهِ وَقُدْرَتِهِ مِنْ شَرِّ مَا أَجِدُ وَأُحَاذِرُ (سَبْعًا)',
      transliteration: 'Bismillah (3 times), A\'udhu billahi wa qudratihi min sharri ma ajidu wa uhadhir (7 times)',
      meaningEn: 'In the Name of Allah (3 times). I seek refuge in Allah and in His power from the evil of what I find and of what I guard against (7 times).',
      meaningMl: 'ബിസ്മില്ലാഹ് (3 തവണ പറയുക). ഞാൻ അനുഭവിക്കുന്നതും ഭയപ്പെടുന്നതുമായ വേദനയുടെ കെടുതിയിൽ നിന്ന് അല്ലാഹുവിലും അവന്റെ അപാരമായ ശക്തിയിലും ഞാൻ ശരണം തേടുന്നു (7 തവണ ചൊല്ലുക).',
      reference: 'Sahih Muslim 2202',
    ),
    DuaModel(
      id: 'dua_anxiety_relief',
      titleEn: 'Relief from Anxiety & Grief',
      titleMl: 'ദുഃഖവും ഉത്കണ്ഠയും അകറ്റാൻ',
      categoryEn: 'Ruqyah & Healing',
      categoryMl: 'രോഗശമനം',
      arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَالْعَجْزِ وَالْكَسَلِ، وَالْبُخْلِ وَالْجُبْنِ، وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ',
      transliteration: 'Allahumma innee a\'udhu bika minal-hammi wal-hazan, wal-\'ajzi wal-kasal, wal-bukhli wal-jubn, wa dala\'id-dayni wa ghalabatir-rijal',
      meaningEn: 'O Allah, I seek refuge in You from grief and sadness, from weakness and laziness, from miserliness and cowardice, from being overcome by debt and from being overpowered by men.',
      meaningMl: 'അല്ലാഹുവേ, ആകുലതകളിൽ നിന്നും ദുഃഖത്തിൽ നിന്നും, അശക്തിയിൽ നിന്നും അലസതയിൽ നിന്നും, പിശുക്കിൽ നിന്നും ഭീരുത്വത്തിൽ നിന്നും, കടഭാരത്തിൽ നിന്നും മനുഷ്യരുടെ അടിച്ചമർത്തലിൽ നിന്നും ഞാൻ നിന്നോട് കാവൽ തേടുന്നു.',
      reference: 'Sahih Al-Bukhari 6369',
    ),

    // ── 5. TRAVEL & PROTECTION ──
    DuaModel(
      id: 'dua_travel_ride',
      titleEn: 'Boarding a Vehicle & Travel',
      titleMl: 'യാത്രാ പ്രാർത്ഥന (വാഹനത്തിൽ കയറുമ്പോൾ)',
      categoryEn: 'Travel & Protection',
      categoryMl: 'യാത്രയും സുരക്ഷയും',
      arabic: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَىٰ رَبِّنَا لَمُنْقَلِبُونَ',
      transliteration: 'Subhanalladhi sakh-khara lana hadha wa ma kunna lahu muqrinin, wa inna ila rabbina lamunqalibun',
      meaningEn: 'Glory unto Him Who created this for us, though for ourselves we could not have accomplished it, and unto our Lord we shall surely return.',
      meaningMl: 'ഇതിനെ ഞങ്ങൾക്ക് അധീനപ്പെടുത്തിത്തന്നവൻ എത്രയോ പരിശുദ്ധൻ! നാമതിന് പ്രാപ്തരായിരുന്നില്ല. തീർച്ചയായും നാം നമ്മുടെ രക്ഷിതാവിങ്കലേക്ക് തിരിച്ചെത്തുന്നവരാകുന്നു.',
      reference: 'Surah Az-Zukhruf 13-14',
    ),
    DuaModel(
      id: 'dua_leaving_home',
      titleEn: 'When Stepping Out of Home',
      titleMl: 'വീട്ടിൽ നിന്ന് പുറത്തിറങ്ങുമ്പോൾ',
      categoryEn: 'Travel & Protection',
      categoryMl: 'യാത്രയും സുരക്ഷയും',
      arabic: 'بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      transliteration: 'Bismillahi tawakkaltu \'alallahi, wa la hawla wa la quwwata illa billah',
      meaningEn: 'In the name of Allah, I place my trust in Allah, and there is no might nor power except with Allah.',
      meaningMl: 'അല്ലാഹുവിന്റെ നാമത്തിൽ ഞാൻ പുറപ്പെടുന്നു. അല്ലാഹുവിൽ ഞാൻ ഭരമേൽപിച്ചിരിക്കുന്നു. അല്ലാഹുവെക്കൊണ്ടല്ലാതെ യാതൊരു മാറ്റവും ശക്തിയുമില്ല.',
      reference: 'Abu Dawud 5095',
    ),
    DuaModel(
      id: 'dua_entering_home',
      titleEn: 'When Entering Home',
      titleMl: 'വീട്ടിൽ പ്രവേശിക്കുമ്പോൾ',
      categoryEn: 'Travel & Protection',
      categoryMl: 'യാത്രയും സുരക്ഷയും',
      arabic: 'بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَىٰ رَبِّنَا تَوَكَّلْنَا',
      transliteration: 'Bismillahi walajna, wa bismillahi kharajna, wa \'ala Rabbina tawakkalna',
      meaningEn: 'In the name of Allah we enter, and in the name of Allah we leave, and upon our Lord we place our trust.',
      meaningMl: 'അല്ലാഹുവിന്റെ നാമത്തിൽ നാം പ്രവേശിക്കുന്നു, അല്ലാഹുവിന്റെ നാമത്തിൽ നാം പുറപ്പെടുന്നു. നമ്മുടെ രക്ഷിതാവായ അല്ലാഹുവിൽ നാം ഭരമേൽപിക്കുകയും ചെയ്യുന്നു.',
      reference: 'Abu Dawud 5096',
    ),

    // ── 6. FAMILY & PARENTS ──
    DuaModel(
      id: 'dua_parents_quran',
      titleEn: 'For Parents (Quranic Supplication)',
      titleMl: 'മാതാപിതാക്കൾക്ക് വേണ്ടി (ഖുർആനിക പ്രാർത്ഥന)',
      categoryEn: 'Family & Parents',
      categoryMl: 'കുടുംബവും മാതാപിതാക്കളും',
      arabic: 'رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
      transliteration: 'Rabbir-hamhuma kama rabbayani sagheera',
      meaningEn: 'My Lord, have mercy upon them as they brought me up [when I was] small.',
      meaningMl: 'എന്റെ രക്ഷിതാവേ, കുഞ്ഞായിരിക്കുമ്പോൾ അവർ എന്നെ സ്നേഹത്തോടെ വളർത്തിക്കൊണ്ടുവന്നതുപോലെ നീ അവർക്ക് കാരുണ്യം ചൊരിയേണമേ.',
      reference: 'Surah Al-Isra 24',
    ),
    DuaModel(
      id: 'dua_family_blessing',
      titleEn: 'For Righteous Spouse & Children',
      titleMl: 'നല്ല ഇണയ്ക്കും മക്കൾക്കും വേണ്ടിയുള്ള പ്രാർത്ഥന',
      categoryEn: 'Family & Parents',
      categoryMl: 'കുടുംബവും മാതാപിതാക്കളും',
      arabic: 'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا',
      transliteration: 'Rabbana hab lana min azwajina wa dhurriyyatina qurrata a\'yunin waj\'alna lil-muttaqeena imama',
      meaningEn: 'Our Lord, grant us from among our spouses and offspring comfort to our eyes and make us an example for the righteous.',
      meaningMl: 'ഞങ്ങളുടെ നാഥാ, ഞങ്ങളുടെ ഇണകളിൽ നിന്നും സന്താനങ്ങളിൽ നിന്നും ഞങ്ങൾക്ക് നീ കൺകുളിർമ നൽകേണമേ. ഭയഭക്തിയുള്ളവർക്ക് ഞങ്ങളെ നീ മാതൃകയാക്കുകയും ചെയ്യേണമേ.',
      reference: 'Surah Al-Furqan 74',
    ),
    DuaModel(
      id: 'dua_protect_children',
      titleEn: 'Seeking Refuge for Children & Loved Ones',
      titleMl: 'മക്കളുടെ സംരക്ഷണത്തിന് വേണ്ടിയുള്ള പ്രാർത്ഥന',
      categoryEn: 'Family & Parents',
      categoryMl: 'കുടുംബവും മാതാപിതാക്കളും',
      arabic: 'أُعِيذُكُمَا بِكَلِمَاتِ اللَّهِ التَّامَّةِ مِنْ كُلِّ شَيْطَانٍ وَهَامَّةٍ، وَمِنْ كُلِّ عَيْنٍ لَامَّةٍ',
      transliteration: 'U\'eedhukuma bikalimatil-lahit-tammah, min kulli shaytanin wa hammah, wa min kulli \'aynin lammah',
      meaningEn: 'I seek protection for you in the Perfect Words of Allah from every devil and every poisonous pest and from every evil, harmful eye.',
      meaningMl: 'എല്ലാ പിശാചിൽ നിന്നും, വിഷജന്തുക്കളിൽ നിന്നും, ഉപദ്രവകരമായ കണ്ണേറിൽ നിന്നും അല്ലാഹുവിന്റെ പരിപൂർണ്ണമായ വചനങ്ങളാൽ ഞാൻ നിങ്ങൾക്ക് കാവൽ തേടുന്നു.',
      reference: 'Sahih Al-Bukhari 3371',
    ),

    // ── 7. FORGIVENESS & TAWBAH ──
    DuaModel(
      id: 'dua_younus_relief',
      titleEn: 'Dua of Prophet Yunus (In Distress & Repentance)',
      titleMl: 'യൂനുസ് നബിയുടെ പ്രാർത്ഥന (വിഷമഘട്ടങ്ങളിലെ പ്രാർത്ഥന)',
      categoryEn: 'Forgiveness & Tawbah',
      categoryMl: 'പാപമോചനവും പശ്ചാത്താപവും',
      arabic: 'لَا إِلَٰهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
      transliteration: 'La ilaha illa anta subhanaka innee kuntu minaz-zalimeen',
      meaningEn: 'There is no deity except You; exalted are You. Indeed, I have been of the wrongdoers.',
      meaningMl: 'നീയല്ലാതെ യാതൊരു ആരാധ്യനുമില്ല, നീ എത്രയോ പരിശുദ്ധൻ! തീർച്ചയായും ഞാൻ അക്രമികളിൽ പെട്ടവനായിരിക്കുന്നു.',
      reference: 'Surah Al-Anbiya 87',
    ),
    DuaModel(
      id: 'dua_adam_repentance',
      titleEn: 'Dua of Adam (Repentance)',
      titleMl: 'ആദം നബിയുടെ പശ്ചാത്താപ പ്രാർത്ഥന',
      categoryEn: 'Forgiveness & Tawbah',
      categoryMl: 'പാപമോചനവും പശ്ചാത്താപവും',
      arabic: 'رَبَّنَا ظَلَمْنَا أَنْفُسَنَا وَإِنْ لَمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ',
      transliteration: 'Rabbana zalamna anfusana wa il-lam taghfir lana wa tarhamna lana koonanna minal-khasireen',
      meaningEn: 'Our Lord, we have wronged ourselves, and if You do not forgive us and have mercy upon us, we will surely be among the losers.',
      meaningMl: 'ഞങ്ങളുടെ നാഥാ, ഞങ്ങൾ ഞങ്ങളോട് തന്നെ അന്യായം ചെയ്തിരിക്കുന്നു. നീ ഞങ്ങൾക്ക് പൊറുത്തുതരികയും കരുണ ചൊരിയുകയും ചെയ്തില്ലെങ്കിൽ തീർച്ചയായും ഞങ്ങൾ നഷ്ടക്കാരിൽ പെട്ടുപോകും.',
      reference: 'Surah Al-A\'raf 23',
    ),
    DuaModel(
      id: 'dua_forgiveness_all',
      titleEn: 'Comprehensive Forgiveness Supplication',
      titleMl: 'എല്ലാ പാപങ്ങൾക്കും വേണ്ടിയുള്ള പാപമോചനം',
      categoryEn: 'Forgiveness & Tawbah',
      categoryMl: 'പാപമോചനവും പശ്ചാത്താപവും',
      arabic: 'اللَّهُمَّ اغْفِرْ لِي خَطِيئَتِي وَجَهْلِي وَإِسْرَافِي فِي أَمْرِي، وَمَا أَنْتَ أَعْلَمُ بِهِ مِنِّي',
      transliteration: 'Allahummagh-fir lee khatee\'atee wa jahlee wa israfee fee amree, wa ma anta a\'lamu bihi minnee',
      meaningEn: 'O Allah, forgive my errors, my ignorance, my excesses in my affairs, and what You know of me better than I do.',
      meaningMl: 'അല്ലാഹുവേ, എന്റെ തെറ്റുകുറ്റങ്ങളും എന്റെ അറിവില്ലായ്മയും എന്റെ കാര്യങ്ങളിലെ അതിരുകവിയലുകളും എന്നെക്കാൾ നന്നായി നീ അറിയുന്ന മറ്റ് പാപങ്ങളും എനിക്ക് നീ പൊറുത്തുതരേണമേ.',
      reference: 'Sahih Al-Bukhari 6398',
    ),

    // ── 8. DISTRESS & HARDSHIP ──
    DuaModel(
      id: 'dua_hardship_ease',
      titleEn: 'Making Difficult Matters Easy',
      titleMl: 'കാര്യങ്ങൾ എളുപ്പമാകുന്നതിന് വേണ്ടിയുള്ള പ്രാർത്ഥന',
      categoryEn: 'Distress & Hardship',
      categoryMl: 'പ്രയാസങ്ങളും വിഷമങ്ങളും',
      arabic: 'اللَّهُمَّ لَا سَهْلَ إِلَّا مَا جَعَلْتَهُ سَهْلًا، وَأَنْتَ تَجْعَلُ الْحَزْنَ إِذَا شِئْتَ سَهْلًا',
      transliteration: 'Allahumma la sahla illa ma ja\'altahu sahla, wa anta taj\'alul-hazna idha shi\'ta sahla',
      meaningEn: 'O Allah, there is no ease except in that which You have made easy, and You make hardship, if You will, easy.',
      meaningMl: 'അല്ലാഹുവേ, നീ എളുപ്പമാക്കിയതല്ലാതെ യാതൊരു എളുപ്പവുമില്ല. നീ ഉദ്ദേശിക്കുകയാണെങ്കിൽ വിഷമകരമായ കാര്യങ്ങളെയും എളുപ്പമുള്ളതാക്കുന്നു.',
      reference: 'Sahih Ibn Hibban 327',
    ),
    DuaModel(
      id: 'dua_musa_speech',
      titleEn: 'Dua of Musa for Confidence & Success',
      titleMl: 'മൂസാ നബിയുടെ പ്രാർത്ഥന (മനസ്സമാധാനത്തിനും വിജയത്തിനും)',
      categoryEn: 'Distress & Hardship',
      categoryMl: 'പ്രയാസങ്ങളും വിഷമങ്ങളും',
      arabic: 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي وَاحْلُلْ عُقْدَةً مِنْ لِسَانِي يَفْقَهُوا قَوْلِي',
      transliteration: 'Rabbish-rah lee sadree, wa yassir lee amree, wahlul \'uqdatan min lisaanee, yafqahoo qawlee',
      meaningEn: 'My Lord, expand for me my breast [with assurance], and ease for me my task, and untie the knot from my tongue that they may understand my speech.',
      meaningMl: 'എന്റെ രക്ഷിതാവേ, നീ എനിക്ക് എന്റെ മനസ്സ് വിശാലമാക്കി തരേണമേ. എന്റെ കാര്യം എനിക്ക് എളുപ്പമാക്കി തരേണമേ. എന്റെ നാവിൽ നിന്നുള്ള കെട്ടഴിച്ചു തരേണമേ, അവർ എന്റെ സംസാരം ഗ്രഹിക്കുവാൻ വേണ്ടി.',
      reference: 'Surah Ta-Ha 25-28',
    ),
    DuaModel(
      id: 'dua_debt_relief',
      titleEn: 'Freedom from Heavy Debt & Fear',
      titleMl: 'കടബാധ്യത തീരുവാനും സാമ്പത്തിക അഭിവൃദ്ധിക്കും',
      categoryEn: 'Distress & Hardship',
      categoryMl: 'പ്രയാസങ്ങളും വിഷമങ്ങളും',
      arabic: 'اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
      transliteration: 'Allahummak-finee bi halalika \'an haramik, wa aghninee bi fadlika \'amman siwak',
      meaningEn: 'O Allah, suffice me with Your lawful against Your prohibited, and make me independent of all those other than You through Your bounty.',
      meaningMl: 'അല്ലാഹുവേ, ഹറാമുകളിൽ നിന്ന് വിട്ടുനിൽക്കാൻ ഹലാലായവ കൊണ്ട് എന്നെ നീ തൃപ്തിപ്പെടുത്തേണമേ. നിന്റെ ഔദാര്യം കൊണ്ട് നീയല്ലാത്ത മറ്റുള്ളവരിൽ നിന്നുള്ള ആശ്രയത്തിൽ നിന്നും എന്നെ നീ മുക്തനാക്കേണമേ.',
      reference: 'Jami` at-Tirmidhi 3563',
    ),
  ];
}
