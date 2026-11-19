import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/certificate_models.dart';

class CertificateState {
  final List<CertificateRequestModel> requests;
  final CertificateType? typeFilter;
  final CertificateStatus? statusFilter;
  final bool isLoading;

  const CertificateState({
    required this.requests,
    this.typeFilter,
    this.statusFilter,
    this.isLoading = false,
  });

  List<CertificateRequestModel> get filteredRequests {
    return requests.where((r) {
      if (typeFilter != null && r.type != typeFilter) return false;
      if (statusFilter != null && r.status != statusFilter) return false;
      return true;
    }).toList();
  }

  int get pendingCount => requests.where((r) => r.status == CertificateStatus.pending || r.status == CertificateStatus.underReview).length;
  int get approvedCount => requests.where((r) => r.status == CertificateStatus.approved).length;

  CertificateState copyWith({
    List<CertificateRequestModel>? requests,
    CertificateType? typeFilter,
    CertificateStatus? statusFilter,
    bool clearTypeFilter = false,
    bool clearStatusFilter = false,
    bool? isLoading,
  }) {
    return CertificateState(
      requests: requests ?? this.requests,
      typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final certificateProvider = StateNotifierProvider<CertificateNotifier, CertificateState>((ref) {
  return CertificateNotifier();
});

class CertificateNotifier extends StateNotifier<CertificateState> {
  static const _storageKey = 'mahal_persisted_certificates_v1';

  static final List<CertificateRequestModel> _initialSampleCertificates = [
    CertificateRequestModel(
      id: 'CERT-2026-081',
      userId: 'usr_001',
      applicantName: 'Abdul Rahman',
      applicantPhone: '+91 98470 12345',
      applicantEmail: 'abdul.rahman@gmail.com',
      type: CertificateType.marriage,
      primaryPersonName: 'Abdul Rahman (Groom / വരൻ)',
      secondaryPersonName: 'Fathima Suhara (Bride / വധു)',
      eventDate: '12 January 2026',
      placeOfEvent: 'Ekarool Central Juma Masjid',
      documentFileName: 'nikkah_register_copy.pdf',
      documentFileSize: '1.8 MB',
      status: CertificateStatus.approved,
      appliedAt: DateTime.now().subtract(const Duration(days: 45)),
      approvedAt: DateTime.now().subtract(const Duration(days: 43)),
      mahalRegistrationNo: 'EKRL/NIKKAH/2026/014',
      remarks: 'Verified against Mahal Nikkah Register Vol IV, Page 88.',
    ),
    CertificateRequestModel(
      id: 'CERT-2026-094',
      userId: 'usr_001',
      applicantName: 'Abdul Rahman',
      applicantPhone: '+91 98470 12345',
      applicantEmail: 'abdul.rahman@gmail.com',
      type: CertificateType.birth,
      primaryPersonName: 'Muhammed Rayan (Child / കുട്ടി)',
      secondaryPersonName: 'Fathima Suhara (Mother / മാതാവ്)',
      eventDate: '04 March 2026',
      placeOfEvent: 'Aster MIMS Hospital, Kozhikode',
      documentFileName: 'hospital_birth_memo.pdf',
      documentFileSize: '2.4 MB',
      status: CertificateStatus.pending,
      appliedAt: DateTime.now().subtract(const Duration(days: 2)),
      remarks: 'Awaiting birth register verification by Mahal General Secretary.',
    ),
    CertificateRequestModel(
      id: 'CERT-2025-112',
      userId: 'usr_001',
      applicantName: 'Abdul Rahman',
      applicantPhone: '+91 98470 12345',
      applicantEmail: 'abdul.rahman@gmail.com',
      type: CertificateType.death,
      primaryPersonName: 'Late Moideen Kutty Haji (മരണപ്പെട്ടയാൾ)',
      secondaryPersonName: 'Abdul Rahman (Son & Applicant)',
      eventDate: '18 November 2025',
      placeOfEvent: 'Ekarool Mahal Qabarsthan (ഖബർസ്ഥാൻ)',
      documentFileName: 'burial_record_entry.pdf',
      documentFileSize: '1.1 MB',
      status: CertificateStatus.approved,
      appliedAt: DateTime.now().subtract(const Duration(days: 120)),
      approvedAt: DateTime.now().subtract(const Duration(days: 118)),
      mahalRegistrationNo: 'EKRL/DEATH/2025/089',
      remarks: 'Burial verified in Mahal Qabarsthan Register Plot B-14.',
    ),
  ];

  CertificateNotifier()
      : super(CertificateState(requests: _initialSampleCertificates)) {
    _loadFromStorage();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 700));
    await _loadFromStorage();
    state = state.copyWith(isLoading: false);
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(_storageKey);
      if (savedData != null) {
        final List<dynamic> decoded = json.decode(savedData);
        final list = decoded.map((item) => CertificateRequestModel.fromMap(item as Map<String, dynamic>)).toList();
        state = state.copyWith(requests: list);
      }
    } catch (_) {}
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(state.requests.map((r) => r.toMap()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {}
  }

  // Submit new certificate application
  Future<CertificateRequestModel> submitCertificateRequest({
    required String userId,
    required String applicantName,
    required String applicantPhone,
    required String applicantEmail,
    required CertificateType type,
    required String primaryPersonName,
    required String secondaryPersonName,
    required String eventDate,
    required String placeOfEvent,
    required String documentFileName,
    required String documentFileSize,
  }) async {
    final newId = 'CERT-${DateTime.now().year}-${(state.requests.length + 101)}';
    final request = CertificateRequestModel(
      id: newId,
      userId: userId,
      applicantName: applicantName,
      applicantPhone: applicantPhone,
      applicantEmail: applicantEmail,
      type: type,
      primaryPersonName: primaryPersonName,
      secondaryPersonName: secondaryPersonName,
      eventDate: eventDate,
      placeOfEvent: placeOfEvent,
      documentFileName: documentFileName,
      documentFileSize: documentFileSize,
      status: CertificateStatus.pending,
      appliedAt: DateTime.now(),
      remarks: 'Submitted for verification by Mahal Committee.',
    );

    state = state.copyWith(requests: [request, ...state.requests]);
    await _saveToStorage();
    return request;
  }

  // Approve request (Committee Admin action)
  Future<void> approveRequest(String id, {String? customRemarks}) async {
    final index = state.requests.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final target = state.requests[index];
    final regNo = 'EKRL/${target.type.codePrefix}/${DateTime.now().year}/${(index + 10).toString().padLeft(3, '0')}';

    final updated = target.copyWith(
      status: CertificateStatus.approved,
      approvedAt: DateTime.now(),
      mahalRegistrationNo: regNo,
      remarks: customRemarks ?? 'Officially approved and attested by Mahal Committee.',
    );

    final list = List<CertificateRequestModel>.from(state.requests);
    list[index] = updated;
    state = state.copyWith(requests: list);
    await _saveToStorage();
  }

  // Reject / Request Correction (Committee Admin action)
  Future<void> rejectRequest(String id, String reason) async {
    final index = state.requests.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final target = state.requests[index];
    final updated = target.copyWith(
      status: CertificateStatus.rejected,
      remarks: reason,
    );

    final list = List<CertificateRequestModel>.from(state.requests);
    list[index] = updated;
    state = state.copyWith(requests: list);
    await _saveToStorage();
  }

  void setTypeFilter(CertificateType? type) {
    if (type == null) {
      state = state.copyWith(clearTypeFilter: true);
    } else {
      state = state.copyWith(typeFilter: type);
    }
  }

  void setStatusFilter(CertificateStatus? status) {
    if (status == null) {
      state = state.copyWith(clearStatusFilter: true);
    } else {
      state = state.copyWith(statusFilter: status);
    }
  }
}
