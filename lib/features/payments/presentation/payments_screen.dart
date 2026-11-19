import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/config.dart';
import '../../../core/services/receipt_pdf_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/glass_back_button.dart';
import '../../../core/widgets/mosque_misty_graphic.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/payment_models.dart';
import '../providers/payment_provider.dart';
import 'zakat_calculator_screen.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  final int initialTab;

  const PaymentsScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  late int _selectedTab;
  final Map<String, int> _selectedDonationAmounts = {};
  final Map<String, bool> _anonymousDonations = {};

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
  }

  void _showRazorpaySheet({
    required BuildContext context,
    required String title,
    required String subtitle,
    required double amount,
    required Future<void> Function() onPay,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        bool isProcessing = false;

        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadii.sheetBorder,
                boxShadow: AppShadows.floating,
              ),
              padding: const EdgeInsets.fromLTRB(AppSpacing.s24, AppSpacing.s12, AppSpacing.s24, AppSpacing.s32),
              child: isProcessing
                  ? SizedBox(
                      height: 240,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const AppLoader(),
                            const SizedBox(height: AppSpacing.s16),
                            Text(
                              'Processing UPI Payment...',
                              style: AppTextStyles.cardTitle(fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Please complete the transaction in your UPI app',
                              style: AppTextStyles.bodyText(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Top Handle Notch
                        Center(
                          child: Container(
                            width: 38,
                            height: 4.5,
                            margin: const EdgeInsets.only(bottom: AppSpacing.s16),
                            decoration: BoxDecoration(
                              color: AppColors.divider,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),

                        // Header with Secure UPI shield
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                color: AppColors.mintMist,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.shield_outlined, color: AppColors.primaryEmerald, size: 22),
                            ),
                            const SizedBox(width: AppSpacing.s12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Secure UPI Gateway',
                                    style: AppTextStyles.cardTitle(fontSize: 16),
                                  ),
                                  Text(
                                    'NPCI • Razorpay 256-bit Encrypted',
                                    style: AppTextStyles.bodyText(color: AppColors.textSecondary, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.s16),

                        // Amount Card
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.s16),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurfaceMuted,
                            borderRadius: AppRadii.cardInnerBorder,
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: AppTextStyles.cardTitle(fontSize: 14),
                                  ),
                                  Text(
                                    subtitle,
                                    style: AppTextStyles.bodyText(color: AppColors.textSecondary, fontSize: 11.5),
                                  ),
                                ],
                              ),
                              Text(
                                '${AppConfig.currency} ${amount.toStringAsFixed(0)}',
                                style: AppTextStyles.greetingHeading(
                                  color: AppColors.primaryEmerald,
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.s20),

                        Text(
                          'Select Payment Method',
                          style: AppTextStyles.cardTitle(fontSize: 13),
                        ),
                        const SizedBox(height: AppSpacing.s10),

                        // UPI Apps Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildUpiOption('Google Pay', Icons.account_balance_wallet_outlined),
                            _buildUpiOption('PhonePe', Icons.payments_outlined),
                            _buildUpiOption('Paytm UPI', Icons.qr_code_2_rounded),
                            _buildUpiOption('Any UPI', Icons.send_to_mobile_rounded),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.s24),

                        // Pay Button
                        PillButton(
                          label: 'Pay ${AppConfig.currency} ${amount.toStringAsFixed(0)} via UPI',
                          variant: PillButtonVariant.primary,
                          fullWidth: true,
                          height: 48,
                          icon: const Icon(Icons.lock_outline, color: Colors.white, size: 16),
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            setSheetState(() => isProcessing = true);
                            await Future.delayed(const Duration(milliseconds: 900));
                            await onPay();
                            if (ctx.mounted) {
                              Navigator.of(ctx).pop();
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Jazakallah Khair! Payment confirmed and receipt issued.'),
                                  backgroundColor: AppColors.primaryEmerald,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildUpiOption(String name, IconData icon) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: AppShadows.subtle,
          ),
          child: Icon(icon, color: AppColors.primaryEmerald, size: 22),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: AppTextStyles.bodyText(fontSize: 10.5, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  void _downloadReceipt(ChandaMonthRecord record) async {
    final authState = ref.read(authProvider);
    final user = authState.user;
    final mahal = authState.currentMahal;

    await ReceiptPdfService.shareOrPrintReceipt(
      mahalName: mahal.name,
      mahalLocation: mahal.location,
      receiptNo: record.receiptNo ?? 'RCP-2026-PREVIEW',
      memberName: user?.name ?? 'Mahal Member',
      houseName: user?.houseName ?? 'Baitul Noor',
      familyId: user?.familyId ?? 'EK-FAM-142',
      purpose: 'Monthly Chanda (${record.monthNameEn})',
      amount: record.amount,
      date: record.paymentDate ?? DateTime.now(),
      paymentMode: record.paymentMode ?? 'Online UPI',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isMalayalam = locale.languageCode == 'ml';
    final paymentState = ref.watch(paymentProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: paymentState.isLoading
          ? ShimmerSkeleton.payments()
          : RefreshIndicator(
              color: AppColors.primaryEmerald,
              onRefresh: () => ref.read(paymentProvider.notifier).refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                slivers: [
                  // 1. EMERALD HERO ZONE (Reference Signature)
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // Emerald background with misty graphic
                Container(
                  height: 250,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryEmerald,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(AppRadii.sheetRadius),
                      bottomRight: Radius.circular(AppRadii.sheetRadius),
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Misty mosque silhouette
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 160,
                        child: Opacity(
                          opacity: 0.25,
                          child: const MosqueMistyGraphic(height: 160),
                        ),
                      ),
                      // Hanging lanterns at top
                      Positioned(
                        top: 40,
                        left: 20,
                        child: Opacity(
                          opacity: 0.35,
                          child: Icon(Icons.flare_outlined, color: AppColors.mintText, size: 28),
                        ),
                      ),
                      Positioned(
                        top: 36,
                        right: 24,
                        child: Opacity(
                          opacity: 0.35,
                          child: Icon(Icons.nightlight_round, color: AppColors.mintText, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),

                // In-content Header Controls
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GlassBackButton(
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(width: AppSpacing.s16),
                            Expanded(
                              child: Text(
                                isMalayalam ? 'വരിസംഖ്യയും ഫണ്ടുകളും' : 'Chanda & Donations',
                                style: AppTextStyles.cardTitle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  isMalayalam: isMalayalam,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            PillButton(
                              label: isMalayalam ? 'സകാത്ത്' : 'Zakat Calc',
                              variant: PillButtonVariant.white,
                              height: 32,
                              isMalayalam: isMalayalam,
                              icon: const Icon(Icons.calculate_outlined, color: AppColors.primaryEmerald, size: 14),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const ZakatCalculatorScreen()),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.s16),

                        // Floating Stats Header Card
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.all(AppSpacing.s18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppRadii.cardBorder,
                            boxShadow: AppShadows.floating,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isMalayalam ? 'പ്രതിമാസ കുടിശ്ശിക' : 'Monthly Due Status',
                                          style: AppTextStyles.bodyText(
                                            color: AppColors.textSecondary,
                                            fontSize: 11.5,
                                            isMalayalam: isMalayalam,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${AppConfig.currency} ${paymentState.totalPendingDue.toStringAsFixed(0)}',
                                          style: AppTextStyles.displayHero(
                                            color: paymentState.pendingMonthsCount > 0
                                                ? AppColors.sunsetCoral
                                                : AppColors.primaryEmerald,
                                            fontSize: 28,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.s12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: paymentState.pendingMonthsCount > 0
                                          ? const Color(0xFFFFF1F2)
                                          : AppColors.mintMist,
                                      borderRadius: AppRadii.pillBorder,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          paymentState.pendingMonthsCount > 0
                                              ? Icons.info_outline_rounded
                                              : Icons.check_circle_rounded,
                                          size: 14,
                                          color: paymentState.pendingMonthsCount > 0
                                              ? AppColors.sunsetCoral
                                              : AppColors.primaryEmeraldLight,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          paymentState.pendingMonthsCount > 0
                                              ? '${paymentState.pendingMonthsCount} Pending'
                                              : 'All Cleared',
                                          style: AppTextStyles.buttonText(
                                            color: paymentState.pendingMonthsCount > 0
                                              ? AppColors.sunsetCoral
                                              : AppColors.primaryEmeraldLight,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.s10),
                              Text(
                                'Fixed monthly varisankhya rate is ${AppConfig.currency} 250 as set by Mahal General Body.',
                                style: AppTextStyles.bodyText(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. SEGMENTED PILL SWITCH
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.s24, AppSpacing.s16, AppSpacing.s24, AppSpacing.s12),
              child: Container(
                height: 46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.cardSurfaceMuted,
                  borderRadius: AppRadii.pillBorder,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedTab = 0);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0 ? AppColors.primaryEmerald : Colors.transparent,
                            borderRadius: AppRadii.pillBorder,
                            boxShadow: _selectedTab == 0 ? AppShadows.subtle : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isMalayalam ? 'വരിസംഖ്യ' : 'Monthly Chanda',
                            style: AppTextStyles.buttonText(
                              color: _selectedTab == 0 ? Colors.white : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: _selectedTab == 0 ? FontWeight.w600 : FontWeight.w500,
                              isMalayalam: isMalayalam,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedTab = 1);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1 ? AppColors.primaryEmerald : Colors.transparent,
                            borderRadius: AppRadii.pillBorder,
                            boxShadow: _selectedTab == 1 ? AppShadows.subtle : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isMalayalam ? 'റിലീഫ് ഫണ്ടുകൾ' : 'Donation Relief',
                            style: AppTextStyles.buttonText(
                              color: _selectedTab == 1 ? Colors.white : AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: _selectedTab == 1 ? FontWeight.w600 : FontWeight.w500,
                              isMalayalam: isMalayalam,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. TAB CONTENT
          if (_selectedTab == 0)
            _buildChandaTimelineSliver(context, isMalayalam, l10n, paymentState)
          else
            _buildCampaignsSliver(context, isMalayalam, l10n, paymentState),

          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: CONNECTED VERTICAL TIMELINE FOR CHANDA HISTORY
  // ---------------------------------------------------------------------------
  Widget _buildChandaTimelineSliver(
    BuildContext context,
    bool isMalayalam,
    AppLocalizations l10n,
    PaymentState paymentState,
  ) {
    final records = paymentState.chandaHistory;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final rec = records[index];
            final isPaid = rec.status == ChandaStatus.paid;
            final isFirst = index == 0;
            final isLast = index == records.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Vertical Timeline Stem + Glowing Node
                  SizedBox(
                    width: 32,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        // Connecting vertical stem line
                        if (!isLast)
                          Positioned(
                            top: 24,
                            bottom: 0,
                            width: 2,
                            child: Container(
                              color: isPaid ? AppColors.primaryEmeraldLight.withValues(alpha: 0.3) : AppColors.divider,
                            ),
                          ),
                        if (!isFirst)
                          Positioned(
                            top: 0,
                            height: 24,
                            width: 2,
                            child: Container(
                              color: AppColors.primaryEmeraldLight.withValues(alpha: 0.3),
                            ),
                          ),

                        // Timeline Node Dot
                        Positioned(
                          top: 14,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isPaid ? AppColors.primaryEmerald : const Color(0xFFF59E0B),
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: (isPaid ? AppColors.primaryEmerald : const Color(0xFFF59E0B)).withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: isPaid
                                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                                  : Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: AppSpacing.s12),

                  // Month Record Card
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.s14),
                      child: AppCard(
                        padding: const EdgeInsets.all(AppSpacing.s16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          isMalayalam ? rec.monthNameMl : rec.monthNameEn,
                                          style: AppTextStyles.cardTitle(
                                            fontSize: 15,
                                            isMalayalam: isMalayalam,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isPaid ? AppColors.mintMist : const Color(0xFFFEF3C7),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          isPaid ? (rec.paymentMode ?? "UPI") : "Pending",
                                          style: TextStyle(
                                            color: isPaid ? AppColors.primaryEmeraldLight : const Color(0xFFD97706),
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${AppConfig.currency} ${rec.amount.toStringAsFixed(0)} • ${isPaid ? (rec.receiptNo ?? "Paid") : "Due by end of month"}',
                                    style: AppTextStyles.bodyText(
                                      color: AppColors.textSecondary,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Action: Pay Now Pill or Download PDF Receipt
                            if (!isPaid)
                              PillButton(
                                label: l10n.payNow,
                                variant: PillButtonVariant.primary,
                                height: 34,
                                isMalayalam: isMalayalam,
                                onPressed: () {
                                  _showRazorpaySheet(
                                    context: context,
                                    title: 'Monthly Chanda (${rec.monthNameEn})',
                                    subtitle: 'Mahal Monthly Varisankhya',
                                    amount: rec.amount,
                                    onPay: () => ref.read(paymentProvider.notifier).payChandaMonth(rec.id),
                                  );
                                },
                              )
                            else
                              IconButton(
                                icon: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.cardSurfaceMuted,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.picture_as_pdf_outlined,
                                    color: AppColors.primaryEmeraldLight,
                                    size: 17,
                                  ),
                                ),
                                tooltip: l10n.downloadReceipt,
                                onPressed: () => _downloadReceipt(rec),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          childCount: records.length,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: DONATION CAMPAIGNS WITH PROGRESS BAR & QUICK CHIPS
  // ---------------------------------------------------------------------------
  Widget _buildCampaignsSliver(
    BuildContext context,
    bool isMalayalam,
    AppLocalizations l10n,
    PaymentState paymentState,
  ) {
    final quickAmounts = [250, 500, 1000, 2500];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final camp = paymentState.campaigns[index];
            final selectedAmount = _selectedDonationAmounts[camp.id] ?? 500;
            final isAnonymous = _anonymousDonations[camp.id] ?? false;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s18),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Cover photo banner with category pill
                    if (camp.bannerUrl != null) ...[
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: AppRadii.innerImageBorder,
                            child: Image.network(
                              camp.bannerUrl!,
                              height: 130,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: AppRadii.pillBorder,
                              ),
                              child: Text(
                                camp.category,
                                style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          if (camp.isUrgent)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.badgeRed,
                                  borderRadius: AppRadii.pillBorder,
                                ),
                                child: const Text(
                                  'URGENT',
                                  style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s12),
                    ],

                    // Title & Description
                    Text(
                      isMalayalam ? camp.titleMl : camp.titleEn,
                      style: AppTextStyles.cardTitle(
                        fontSize: 16,
                        isMalayalam: isMalayalam,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isMalayalam ? camp.descriptionMl : camp.descriptionEn,
                      style: AppTextStyles.bodyText(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        isMalayalam: isMalayalam,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.s14),

                    // Custom Linear Progress Bar with glowing indicator
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: AppRadii.pillBorder,
                          child: Container(
                            height: 8,
                            color: AppColors.divider,
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: camp.progress.clamp(0.0, 1.0),
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: AppColors.emeraldGradient,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${l10n.raised}: ${AppConfig.currency} ${(camp.raisedAmount / 1000).toStringAsFixed(0)}k (${(camp.progress * 100).toInt()}%)',
                              style: AppTextStyles.bodyText(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryEmeraldLight,
                              ),
                            ),
                            Text(
                              '${l10n.target}: ${AppConfig.currency} ${(camp.targetAmount / 1000).toStringAsFixed(0)}k',
                              style: AppTextStyles.bodyText(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.s14),

                    // Quick Donation Amount Chips
                    Text(
                      isMalayalam ? 'തുക തിരഞ്ഞെടുക്കുക' : 'Select Amount',
                      style: AppTextStyles.bodyText(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        isMalayalam: isMalayalam,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: quickAmounts.map((amt) {
                        final isChosen = selectedAmount == amt;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _selectedDonationAmounts[camp.id] = amt;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: isChosen ? AppColors.primaryEmerald : AppColors.cardSurfaceMuted,
                              borderRadius: AppRadii.pillBorder,
                              border: Border.all(
                                color: isChosen ? AppColors.primaryEmerald : AppColors.cardBorder,
                              ),
                            ),
                            child: Text(
                              '${AppConfig.currency} $amt',
                              style: AppTextStyles.buttonText(
                                color: isChosen ? Colors.white : AppColors.textPrimary,
                                fontSize: 11.5,
                                fontWeight: isChosen ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppSpacing.s12),

                    // Anonymous Donation Toggle
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: isAnonymous,
                            activeColor: AppColors.primaryEmerald,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) {
                              setState(() {
                                _anonymousDonations[camp.id] = val ?? false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isMalayalam ? 'രഹസ്യ സംഭാവനയായി നൽകുക' : 'Donate anonymously',
                          style: AppTextStyles.bodyText(fontSize: 11.5, isMalayalam: isMalayalam),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.s14),

                    // Donate Button
                    PillButton(
                      label: '${l10n.donate} ${AppConfig.currency} $selectedAmount (UPI)',
                      variant: PillButtonVariant.primary,
                      fullWidth: true,
                      height: 42,
                      isMalayalam: isMalayalam,
                      icon: const Icon(Icons.favorite_rounded, color: Colors.white, size: 16),
                      onPressed: () {
                        _showRazorpaySheet(
                          context: context,
                          title: isMalayalam ? camp.titleMl : camp.titleEn,
                          subtitle: isAnonymous ? 'Anonymous Contribution' : 'Community Relief Fund',
                          amount: selectedAmount.toDouble(),
                          onPay: () => ref.read(paymentProvider.notifier).donateToCampaign(
                                camp.id,
                                selectedAmount.toDouble(),
                              ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: paymentState.campaigns.length,
          ),
        ),
      );
    }
}
