import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/community_models.dart';

class CommunityState {
  final List<NoticeModel> notices;
  final List<CommitteeMember> committee;
  final NoticeCategory? selectedFilter;

  const CommunityState({
    required this.notices,
    required this.committee,
    this.selectedFilter,
  });

  CommunityState copyWith({
    List<NoticeModel>? notices,
    List<CommitteeMember>? committee,
    NoticeCategory? selectedFilter,
  }) {
    return CommunityState(
      notices: notices ?? this.notices,
      committee: committee ?? this.committee,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  List<NoticeModel> get filteredNotices {
    if (selectedFilter == null) return notices;
    return notices.where((n) => n.category == selectedFilter).toList();
  }
}

final communityProvider = StateNotifierProvider<CommunityNotifier, CommunityState>((ref) {
  return CommunityNotifier();
});

class CommunityNotifier extends StateNotifier<CommunityState> {
  CommunityNotifier()
      : super(
          CommunityState(
            notices: [
              NoticeModel(
                id: 'not_01',
                titleEn: 'Friday Khutbah Topic: "Preserving Moral Values in the Digital Age"',
                titleMl: 'വെള്ളിയാഴ്ച ഖുതുബ: "ഡിജിറ്റൽ യുഗത്തിലെ ധാർമ്മിക കാവൽ"',
                contentEn: 'This Friday Juma\'ah sermon will be delivered by Chief Imam Ustad Ahmad Kabeer Baqavi. All members are requested to attend before 12:45 PM.',
                contentMl: 'ഈ വെള്ളിയാഴ്ച ജുമുഅ ഖുതുബ മുഖ്യ ഇമാം ഉസ്താദ് അഹ്മദ് കബീർ ബാഖവി നിർവഹിക്കും. ഉച്ചക്ക് 12:45 ന് മുൻപായി എല്ലാവരും പള്ളിയിലെത്താൻ അഭ്യർത്ഥിക്കുന്നു.',
                category: NoticeCategory.khutbah,
                author: 'Mahal Committee',
                createdAt: DateTime.now().subtract(const Duration(hours: 3)),
                isImportant: true,
                eventDate: 'Friday, 12:45 PM',
              ),
              NoticeModel(
                id: 'not_02',
                titleEn: 'Janaza Announcement: K. Moideen Kutty Haji (78)',
                titleMl: 'മരണ വിവരം: കെ. മൊയ്തീൻ കുട്ടി ഹാജി (78, പറമ്പിൽ വീട്)',
                contentEn: 'With deep grief, we inform the demise of K. Moideen Kutty Haji (Parambil House). Janaza prayer will be held today after Asr prayer at Ekarool Juma Masjid Qabarstan.',
                contentMl: 'പറമ്പിൽ കെ. മൊയ്തീൻ കുട്ടി ഹാജി നിര്യാതനായി. ജനാസ നമസ്കാരം ഇന്ന് അസ്വർ നമസ്കാരത്തിന് ശേഷം ഏകരൂൽ ജുമാ മസ്ജിദ് ഖബർസ്ഥാനിൽ നടക്കും.',
                category: NoticeCategory.janaza,
                author: 'Secretary, Mahal Committee',
                createdAt: DateTime.now().subtract(const Duration(hours: 5)),
                isImportant: true,
                eventDate: 'Today after Asr',
              ),
              NoticeModel(
                id: 'not_03',
                titleEn: 'Annual Madrasa Talent Fest & Exhibition',
                titleMl: 'വാർഷിക മദ്റസ സർഗ്ഗോത്സവവും എക്സിബിഷനും',
                contentEn: 'The annual cultural and Quran recitation competitions of Noorul Islam Madrasa will commence this Sunday from 9:00 AM onwards. Lunch provided.',
                contentMl: 'നൂറുൽ ഇസ്ലാം മദ്റസയിലെ വാർഷിക കലാ-സാഹിത്യ മത്സരങ്ങൾ ഈ ഞായറാഴ്ച രാവിലെ 9:00 മുതൽ നടക്കും. മുഴുവൻ രക്ഷിതാക്കളും പങ്കെടുക്കുക.',
                category: NoticeCategory.event,
                author: 'Madrasa Management',
                createdAt: DateTime.now().subtract(const Duration(days: 1)),
                imageUrl: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=600',
                eventDate: 'Sunday, 9:00 AM',
                rsvpCount: 84,
                hasRsvp: false,
              ),
              NoticeModel(
                id: 'not_04',
                titleEn: 'Ramadan Community Iftar Volunteer Registration',
                titleMl: 'റമദാൻ ഇഫ്താർ സേവന വളണ്ടിയർ രജിസ്ട്രേഷൻ',
                contentEn: 'Youth members interested in serving during daily Mahal community iftar are invited to register their names with the youth wing coordinator.',
                contentMl: 'ദിവസേനയുള്ള മഹല്ല് ഇഫ്താർ സേവനങ്ങളിൽ പങ്കാളികളാകാൻ താല്പര്യമുള്ള യുവാക്കൾ യൂത്ത് വിങ് കോർഡിനേറ്ററുമായി ബന്ധപ്പെടുക.',
                category: NoticeCategory.announcement,
                author: 'Mahal Youth Wing',
                createdAt: DateTime.now().subtract(const Duration(days: 2)),
                rsvpCount: 32,
              ),
            ],
            committee: const [
              CommitteeMember(
                name: 'K.P. Ahmad Haji',
                roleEn: 'President',
                roleMl: 'പ്രസിഡണ്ട്',
                phone: '+91 94471 23456',
                houseName: 'Kallada House',
                avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
              ),
              CommitteeMember(
                name: 'C.V. Musthafa Master',
                roleEn: 'General Secretary',
                roleMl: 'ജനറൽ സെക്രട്ടറി',
                phone: '+91 98472 34567',
                houseName: 'Rose Manzil',
                avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
              ),
              CommitteeMember(
                name: 'P.K. Abdul Majeed',
                roleEn: 'Treasurer',
                roleMl: 'ട്രഷറർ',
                phone: '+91 94473 45678',
                houseName: 'Baitul Falah',
                avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
              ),
              CommitteeMember(
                name: 'Ustad Ahmad Kabeer Baqavi',
                roleEn: 'Chief Imam & Khatib',
                roleMl: 'ഖത്തീബ് & മുഖ്യ ഇമാം',
                phone: '+91 98474 56789',
                houseName: 'Masjid Quarters',
                avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150',
              ),
            ],
          ),
        );

  void setFilter(NoticeCategory? filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void toggleRsvp(String noticeId) {
    final updated = state.notices.map((n) {
      if (n.id == noticeId) {
        final newHasRsvp = !n.hasRsvp;
        return n.copyWith(
          hasRsvp: newHasRsvp,
          rsvpCount: newHasRsvp ? n.rsvpCount + 1 : n.rsvpCount - 1,
        );
      }
      return n;
    }).toList();

    state = state.copyWith(notices: updated);
  }

  void addNotice({
    required String titleEn,
    required String titleMl,
    required String contentEn,
    required String contentMl,
    required NoticeCategory category,
    required String author,
    String? eventDate,
    bool isImportant = false,
  }) {
    final newNotice = NoticeModel(
      id: 'not_${DateTime.now().millisecondsSinceEpoch}',
      titleEn: titleEn,
      titleMl: titleMl,
      contentEn: contentEn,
      contentMl: contentMl,
      category: category,
      author: author,
      createdAt: DateTime.now(),
      eventDate: eventDate,
      isImportant: isImportant,
    );

    state = state.copyWith(notices: [newNotice, ...state.notices]);
  }
}

