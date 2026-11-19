import 'dart:convert';

enum CertificateType {
  marriage,
  birth,
  death,
}

enum CertificateStatus {
  pending,
  underReview,
  approved,
  rejected,
}

extension CertificateTypeExt on CertificateType {
  String get nameEn {
    switch (this) {
      case CertificateType.marriage:
        return 'Marriage Certificate';
      case CertificateType.birth:
        return 'Birth Certificate';
      case CertificateType.death:
        return 'Death Certificate';
    }
  }

  String get nameMl {
    switch (this) {
      case CertificateType.marriage:
        return 'വിവാഹ സർട്ടിഫിക്കറ്റ് (നികാഹ്)';
      case CertificateType.birth:
        return 'ജനന സർട്ടിഫിക്കറ്റ്';
      case CertificateType.death:
        return 'മരണ സർട്ടിഫിക്കറ്റ്';
    }
  }

  String get codePrefix {
    switch (this) {
      case CertificateType.marriage:
        return 'NIKKAH';
      case CertificateType.birth:
        return 'BIRTH';
      case CertificateType.death:
        return 'DEATH';
    }
  }
}

extension CertificateStatusExt on CertificateStatus {
  String get labelEn {
    switch (this) {
      case CertificateStatus.pending:
        return 'Pending Verification';
      case CertificateStatus.underReview:
        return 'Under Committee Review';
      case CertificateStatus.approved:
        return 'Approved & Issued';
      case CertificateStatus.rejected:
        return 'Correction Required';
    }
  }

  String get labelMl {
    switch (this) {
      case CertificateStatus.pending:
        return 'പരിശോധനയിലാണ്';
      case CertificateStatus.underReview:
        return 'കമ്മിറ്റി പരിഗണനയിൽ';
      case CertificateStatus.approved:
        return 'അംഗീകരിച്ചു നൽകി';
      case CertificateStatus.rejected:
        return 'തിരുത്തൽ ആവശ്യമുണ്ട്';
    }
  }
}

class CertificateRequestModel {
  final String id;
  final String userId;
  final String applicantName;
  final String applicantPhone;
  final String applicantEmail;
  final CertificateType type;
  final String primaryPersonName; // Groom / Child / Deceased
  final String secondaryPersonName; // Bride / Mother / Next of Kin
  final String eventDate; // Date of Marriage / Birth / Demise
  final String placeOfEvent; // Place / Hospital / Cemetery
  final String documentFileName;
  final String documentFileSize;
  final CertificateStatus status;
  final DateTime appliedAt;
  final DateTime? approvedAt;
  final String? mahalRegistrationNo;
  final String? remarks;

  const CertificateRequestModel({
    required this.id,
    required this.userId,
    required this.applicantName,
    required this.applicantPhone,
    required this.applicantEmail,
    required this.type,
    required this.primaryPersonName,
    required this.secondaryPersonName,
    required this.eventDate,
    required this.placeOfEvent,
    required this.documentFileName,
    required this.documentFileSize,
    required this.status,
    required this.appliedAt,
    this.approvedAt,
    this.mahalRegistrationNo,
    this.remarks,
  });

  bool get isApproved => status == CertificateStatus.approved;

  CertificateRequestModel copyWith({
    String? id,
    String? userId,
    String? applicantName,
    String? applicantPhone,
    String? applicantEmail,
    CertificateType? type,
    String? primaryPersonName,
    String? secondaryPersonName,
    String? eventDate,
    String? placeOfEvent,
    String? documentFileName,
    String? documentFileSize,
    CertificateStatus? status,
    DateTime? appliedAt,
    DateTime? approvedAt,
    String? mahalRegistrationNo,
    String? remarks,
  }) {
    return CertificateRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      applicantName: applicantName ?? this.applicantName,
      applicantPhone: applicantPhone ?? this.applicantPhone,
      applicantEmail: applicantEmail ?? this.applicantEmail,
      type: type ?? this.type,
      primaryPersonName: primaryPersonName ?? this.primaryPersonName,
      secondaryPersonName: secondaryPersonName ?? this.secondaryPersonName,
      eventDate: eventDate ?? this.eventDate,
      placeOfEvent: placeOfEvent ?? this.placeOfEvent,
      documentFileName: documentFileName ?? this.documentFileName,
      documentFileSize: documentFileSize ?? this.documentFileSize,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      mahalRegistrationNo: mahalRegistrationNo ?? this.mahalRegistrationNo,
      remarks: remarks ?? this.remarks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'applicantName': applicantName,
      'applicantPhone': applicantPhone,
      'applicantEmail': applicantEmail,
      'type': type.index,
      'primaryPersonName': primaryPersonName,
      'secondaryPersonName': secondaryPersonName,
      'eventDate': eventDate,
      'placeOfEvent': placeOfEvent,
      'documentFileName': documentFileName,
      'documentFileSize': documentFileSize,
      'status': status.index,
      'appliedAt': appliedAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'mahalRegistrationNo': mahalRegistrationNo,
      'remarks': remarks,
    };
  }

  factory CertificateRequestModel.fromMap(Map<String, dynamic> map) {
    return CertificateRequestModel(
      id: map['id'] as String,
      userId: map['userId'] as String? ?? 'usr_default',
      applicantName: map['applicantName'] as String? ?? '',
      applicantPhone: map['applicantPhone'] as String? ?? '',
      applicantEmail: map['applicantEmail'] as String? ?? '',
      type: CertificateType.values[map['type'] as int? ?? 0],
      primaryPersonName: map['primaryPersonName'] as String? ?? '',
      secondaryPersonName: map['secondaryPersonName'] as String? ?? '',
      eventDate: map['eventDate'] as String? ?? '',
      placeOfEvent: map['placeOfEvent'] as String? ?? '',
      documentFileName: map['documentFileName'] as String? ?? 'attachment.pdf',
      documentFileSize: map['documentFileSize'] as String? ?? '1.2 MB',
      status: CertificateStatus.values[map['status'] as int? ?? 0],
      appliedAt: DateTime.tryParse(map['appliedAt'] as String? ?? '') ?? DateTime.now(),
      approvedAt: map['approvedAt'] != null ? DateTime.tryParse(map['approvedAt'] as String) : null,
      mahalRegistrationNo: map['mahalRegistrationNo'] as String?,
      remarks: map['remarks'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory CertificateRequestModel.fromJson(String source) =>
      CertificateRequestModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

