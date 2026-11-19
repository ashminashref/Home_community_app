import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/payment_models.dart';

class PaymentState {
  final List<ChandaMonthRecord> chandaHistory;
  final List<DonationCampaign> campaigns;
  final double monthlyDueAmount;
  final bool isProcessing;
  final bool isLoading;

  const PaymentState({
    required this.chandaHistory,
    required this.campaigns,
    this.monthlyDueAmount = 250.0,
    this.isProcessing = false,
    this.isLoading = false,
  });

  PaymentState copyWith({
    List<ChandaMonthRecord>? chandaHistory,
    List<DonationCampaign>? campaigns,
    double? monthlyDueAmount,
    bool? isProcessing,
    bool? isLoading,
  }) {
    return PaymentState(
      chandaHistory: chandaHistory ?? this.chandaHistory,
      campaigns: campaigns ?? this.campaigns,
      monthlyDueAmount: monthlyDueAmount ?? this.monthlyDueAmount,
      isProcessing: isProcessing ?? this.isProcessing,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get pendingMonthsCount =>
      chandaHistory.where((c) => c.status != ChandaStatus.paid).length;

  double get totalPendingDue =>
      pendingMonthsCount * monthlyDueAmount;
}

final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  return PaymentNotifier();
});

class PaymentNotifier extends StateNotifier<PaymentState> {
  PaymentNotifier()
      : super(
          PaymentState(
            chandaHistory: [
              ChandaMonthRecord(
                id: 'ch_2026_11',
                monthNameEn: 'November 2026',
                monthNameMl: 'നവംബർ 2026',
                year: 2026,
                amount: 250.0,
                status: ChandaStatus.pending,
              ),
              ChandaMonthRecord(
                id: 'ch_2026_10',
                monthNameEn: 'October 2026',
                monthNameMl: 'ഒക്ടോബർ 2026',
                year: 2026,
                amount: 250.0,
                status: ChandaStatus.paid,
                receiptNo: 'EKRL-2026-1042',
                paymentDate: DateTime(2026, 10, 5),
                paymentMode: 'UPI (GPay)',
              ),
              ChandaMonthRecord(
                id: 'ch_2026_09',
                monthNameEn: 'September 2026',
                monthNameMl: 'സെപ്റ്റംബർ 2026',
                year: 2026,
                amount: 250.0,
                status: ChandaStatus.paid,
                receiptNo: 'EKRL-2026-0921',
                paymentDate: DateTime(2026, 9, 8),
                paymentMode: 'Cash (Office)',
              ),
              ChandaMonthRecord(
                id: 'ch_2026_08',
                monthNameEn: 'August 2026',
                monthNameMl: 'ഓഗസ്റ്റ് 2026',
                year: 2026,
                amount: 250.0,
                status: ChandaStatus.paid,
                receiptNo: 'EKRL-2026-0810',
                paymentDate: DateTime(2026, 8, 4),
                paymentMode: 'UPI (PhonePe)',
              ),
            ],
            campaigns: const [
              DonationCampaign(
                id: 'camp_ramadan_kit',
                titleEn: 'Ramadan Relief Food Kit 2026',
                titleMl: 'റമദാൻ റിലീഫ് ഫുഡ് കിറ്റ് 2026',
                descriptionEn: 'Providing comprehensive grocery kits to 150 deserving families in our Mahal community.',
                descriptionMl: 'നമ്മുടെ മഹല്ലിലെ അർഹരായ 150 കുടുംബങ്ങൾക്ക് അവശ്യ ഭക്ഷ്യധാന്യ കിറ്റുകൾ വിതരണം ചെയ്യുന്നു.',
                targetAmount: 350000.0,
                raisedAmount: 285000.0,
                category: 'Ramadan Kit',
                bannerUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600',
                isUrgent: true,
              ),
              DonationCampaign(
                id: 'camp_madrasa_smart',
                titleEn: 'Madrasa Smart Classroom Project',
                titleMl: 'മദ്റസ സ്മാർട്ട് ക്ലാസ്റൂം പദ്ധതി',
                descriptionEn: 'Upgrading 6 classrooms with digital screens and audio equipment for Islamic education.',
                descriptionMl: 'നമ്മുടെ കുട്ടികളുടെ ദീനി വിജ്ഞാന പഠനത്തിനായി 6 ക്ലാസ്റൂമുകൾ ഡിജിറ്റലൈസ് ചെയ്യുന്നു.',
                targetAmount: 500000.0,
                raisedAmount: 340000.0,
                category: 'Madrasa',
                bannerUrl: 'https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=600',
              ),
              DonationCampaign(
                id: 'camp_funeral_fund',
                titleEn: 'Janaza & Funeral Assistance Fund',
                titleMl: 'മയ്യിത്ത് പരിപാലന സഹായ ഫണ്ട്',
                descriptionEn: 'Supporting the burial expenses and family welfare during bereavement.',
                descriptionMl: 'മയ്യിത്ത് പരിപാലനവും കുടുംബ സഹായവും ഉറപ്പുവരുത്തുന്ന സ്ഥിരം ഫണ്ട്.',
                targetAmount: 200000.0,
                raisedAmount: 185000.0,
                category: 'Funeral Fund',
                bannerUrl: 'https://images.unsplash.com/photo-1519817650390-64a93db51149?w=600',
              ),
            ],
          ),
        );

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 650));
    state = state.copyWith(isLoading: false);
  }

  Future<void> payChandaMonth(String recordId) async {
    state = state.copyWith(isProcessing: true);
    await Future.delayed(const Duration(milliseconds: 1400));

    final updated = state.chandaHistory.map((rec) {
      if (rec.id == recordId) {
        return rec.copyWith(
          status: ChandaStatus.paid,
          receiptNo: 'EKRL-2026-${DateTime.now().millisecondsSinceEpoch % 10000}',
          paymentDate: DateTime.now(),
          paymentMode: 'UPI (Razorpay Verified)',
        );
      }
      return rec;
    }).toList();

    state = state.copyWith(
      chandaHistory: updated,
      isProcessing: false,
    );
  }

  Future<void> recordCashOffline(String recordId) async {
    final updated = state.chandaHistory.map((rec) {
      if (rec.id == recordId) {
        return rec.copyWith(
          status: ChandaStatus.paid,
          receiptNo: 'EKRL-CASH-${DateTime.now().millisecondsSinceEpoch % 10000}',
          paymentDate: DateTime.now(),
          paymentMode: 'Cash (Secretary Verified)',
        );
      }
      return rec;
    }).toList();

    state = state.copyWith(chandaHistory: updated);
  }

  Future<void> donateToCampaign(String campaignId, double amount) async {
    state = state.copyWith(isProcessing: true);
    await Future.delayed(const Duration(milliseconds: 1200));

    final updated = state.campaigns.map((camp) {
      if (camp.id == campaignId) {
        return DonationCampaign(
          id: camp.id,
          titleEn: camp.titleEn,
          titleMl: camp.titleMl,
          descriptionEn: camp.descriptionEn,
          descriptionMl: camp.descriptionMl,
          targetAmount: camp.targetAmount,
          raisedAmount: camp.raisedAmount + amount,
          category: camp.category,
          bannerUrl: camp.bannerUrl,
          isUrgent: camp.isUrgent,
        );
      }
      return camp;
    }).toList();

    state = state.copyWith(
      campaigns: updated,
      isProcessing: false,
    );
  }
}

