enum ChandaStatus {
  paid,
  pending,
  overdue,
}

class ChandaMonthRecord {
  final String id;
  final String monthNameEn;
  final String monthNameMl;
  final int year;
  final double amount;
  final ChandaStatus status;
  final String? receiptNo;
  final DateTime? paymentDate;
  final String? paymentMode;

  const ChandaMonthRecord({
    required this.id,
    required this.monthNameEn,
    required this.monthNameMl,
    required this.year,
    required this.amount,
    required this.status,
    this.receiptNo,
    this.paymentDate,
    this.paymentMode,
  });

  ChandaMonthRecord copyWith({
    ChandaStatus? status,
    String? receiptNo,
    DateTime? paymentDate,
    String? paymentMode,
  }) {
    return ChandaMonthRecord(
      id: id,
      monthNameEn: monthNameEn,
      monthNameMl: monthNameMl,
      year: year,
      amount: amount,
      status: status ?? this.status,
      receiptNo: receiptNo ?? this.receiptNo,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentMode: paymentMode ?? this.paymentMode,
    );
  }
}

class DonationCampaign {
  final String id;
  final String titleEn;
  final String titleMl;
  final String descriptionEn;
  final String descriptionMl;
  final double targetAmount;
  final double raisedAmount;
  final String category;
  final String? bannerUrl;
  final bool isUrgent;

  const DonationCampaign({
    required this.id,
    required this.titleEn,
    required this.titleMl,
    required this.descriptionEn,
    required this.descriptionMl,
    required this.targetAmount,
    required this.raisedAmount,
    required this.category,
    this.bannerUrl,
    this.isUrgent = false,
  });

  double get progress => (raisedAmount / (targetAmount > 0 ? targetAmount : 1)).clamp(0.0, 1.0);
}

