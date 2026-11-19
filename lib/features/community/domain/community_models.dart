enum NoticeCategory {
  announcement,
  janaza,
  khutbah,
  event,
}

class NoticeModel {
  final String id;
  final String titleEn;
  final String titleMl;
  final String contentEn;
  final String contentMl;
  final NoticeCategory category;
  final String author;
  final DateTime createdAt;
  final String? imageUrl;
  final String? eventDate;
  final bool isImportant;
  final int rsvpCount;
  final bool hasRsvp;

  const NoticeModel({
    required this.id,
    required this.titleEn,
    required this.titleMl,
    required this.contentEn,
    required this.contentMl,
    required this.category,
    required this.author,
    required this.createdAt,
    this.imageUrl,
    this.eventDate,
    this.isImportant = false,
    this.rsvpCount = 0,
    this.hasRsvp = false,
  });

  NoticeModel copyWith({
    int? rsvpCount,
    bool? hasRsvp,
  }) {
    return NoticeModel(
      id: id,
      titleEn: titleEn,
      titleMl: titleMl,
      contentEn: contentEn,
      contentMl: contentMl,
      category: category,
      author: author,
      createdAt: createdAt,
      imageUrl: imageUrl,
      eventDate: eventDate,
      isImportant: isImportant,
      rsvpCount: rsvpCount ?? this.rsvpCount,
      hasRsvp: hasRsvp ?? this.hasRsvp,
    );
  }
}

class CommitteeMember {
  final String name;
  final String roleEn;
  final String roleMl;
  final String phone;
  final String houseName;
  final String? avatarUrl;

  const CommitteeMember({
    required this.name,
    required this.roleEn,
    required this.roleMl,
    required this.phone,
    required this.houseName,
    this.avatarUrl,
  });
}

class KhatmJuzAssignment {
  final int juzNumber;
  final String juzNameArabic;
  final String? readerName;
  final bool isCompleted;
  final DateTime? completedAt;

  const KhatmJuzAssignment({
    required this.juzNumber,
    required this.juzNameArabic,
    this.readerName,
    this.isCompleted = false,
    this.completedAt,
  });

  KhatmJuzAssignment copyWith({
    String? readerName,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return KhatmJuzAssignment(
      juzNumber: juzNumber,
      juzNameArabic: juzNameArabic,
      readerName: readerName ?? this.readerName,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
