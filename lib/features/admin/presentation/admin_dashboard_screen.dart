import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/glass_back_button.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../certificates/domain/certificate_models.dart';
import '../../certificates/presentation/digital_certificate_view_screen.dart';
import '../../certificates/providers/certificate_provider.dart';
import '../../community/domain/community_models.dart';
import '../../community/providers/community_provider.dart';
import '../../payments/domain/payment_models.dart';
import '../../payments/providers/payment_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isMalayalam = locale.languageCode == 'ml';
    final authState = ref.watch(authProvider);
    final mahal = authState.currentMahal;
    final certState = ref.watch(certificateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: AppSpacing.s12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  GlassBackButton(
                    iconColor: AppColors.primaryEmerald,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(
                    child: Text(
                      l10n.adminPanel,
                      style: AppTextStyles.cardTitle(
                        fontSize: 18,
                        isMalayalam: isMalayalam,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s20),

              // Collection Summary Card
              AppCard(
                backgroundColor: AppColors.primaryEmerald,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${mahal.name} • Admin Console',
                      style: AppTextStyles.bodyText(
                        color: AppColors.mintText,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.collectionSummary,
                      style: AppTextStyles.cardTitle(
                        color: Colors.white,
                        fontSize: 17,
                        isMalayalam: isMalayalam,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),
                    Row(
                      children: [
                        Expanded(child: _buildMetricCol('Families', '420')),
                        Expanded(child: _buildMetricCol('Collected', '${AppConfig.currency} 92.5k')),
                        Expanded(child: _buildMetricCol('Pending', '${AppConfig.currency} 12.5k')),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s24),

              Text(
                'Committee Quick Actions',
                style: AppTextStyles.cardTitle(
                  fontSize: 16,
                  isMalayalam: isMalayalam,
                ),
              ),
              const SizedBox(height: AppSpacing.s12),

              // Action 1: Update Jama'ath Times
              AppCard(
                onTap: () => _showUpdateJamaathDialog(context, ref),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: AppColors.mintMist,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.schedule_rounded, color: AppColors.primaryEmerald),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.updateJamaath,
                            style: AppTextStyles.cardTitle(fontSize: 14, isMalayalam: isMalayalam),
                          ),
                          Text(
                            'Override Fajr, Dhuhr, Asr, Maghrib, Isha congregation schedules',
                            style: AppTextStyles.bodyText(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s12),

              // Action 2: Post Notice / Janaza
              AppCard(
                onTap: () => _showPostNoticeDialog(context, ref),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEF3C7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.campaign_outlined, color: Color(0xFFD97706)),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.publishNotice,
                            style: AppTextStyles.cardTitle(fontSize: 14, isMalayalam: isMalayalam),
                          ),
                          Text(
                            'Post Juma\'ah khutbah, Janaza demise alerts, or general notices',
                            style: AppTextStyles.bodyText(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s12),

              // Action 3: Record Cash Offline Payment
              AppCard(
                onTap: () => _showRecordCashDialog(context, ref),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE0E7FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.payments_outlined, color: Color(0xFF4338CA)),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.markOfflinePayment,
                            style: AppTextStyles.cardTitle(fontSize: 14, isMalayalam: isMalayalam),
                          ),
                          Text(
                            'Mark chanda handed over directly to Secretary / Treasurer',
                            style: AppTextStyles.bodyText(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s12),

              // Action 4: Export CSV Report
              AppCard(
                onTap: () {
                  final csv = 'Month,Status,Amount,Member\nNovember 2026,Pending,250,Abdul Rahman\nOctober 2026,Paid,250,Abdul Rahman';
                  Share.share(csv, subject: 'Mahal_Chanda_Report.csv');
                },
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFFECFDF5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.download_rounded, color: Color(0xFF059669)),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.exportCsv,
                            style: AppTextStyles.cardTitle(fontSize: 14, isMalayalam: isMalayalam),
                          ),
                          Text(
                            'Share or download full collection spreadsheet for audit',
                            style: AppTextStyles.bodyText(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s12),

              // Action 5: Review Certificate Applications
              AppCard(
                onTap: () => _showCertificateReviewSheet(context, ref, isMalayalam),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: Color(0xFFCCFBF1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.assignment_turned_in_outlined, color: Color(0xFF0F766E)),
                    ),
                    const SizedBox(width: AppSpacing.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isMalayalam ? 'സർട്ടിഫിക്കറ്റ് അപേക്ഷകൾ' : 'Certificate Applications',
                            style: AppTextStyles.cardTitle(fontSize: 14, isMalayalam: isMalayalam),
                          ),
                          Text(
                            'Review Nikkah, Birth and Death document proofs & issue',
                            style: AppTextStyles.bodyText(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    if (certState.pendingCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD97706),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${certState.pendingCount} Pending',
                          style: const TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyText(color: AppColors.mintText, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.cardTitle(color: Colors.white, fontSize: 18),
        ),
      ],
    );
  }

  void _showUpdateJamaathDialog(BuildContext context, WidgetRef ref) {
    final fajrCtrl = TextEditingController(text: '05:15 AM');
    final dhuhrCtrl = TextEditingController(text: '01:30 PM');
    final asrCtrl = TextEditingController(text: '04:45 PM');
    final maghribCtrl = TextEditingController(text: '06:30 PM');
    final ishaCtrl = TextEditingController(text: '08:15 PM');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.sheetBorder),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Update Mahal Jama\'ath Schedule', style: AppTextStyles.cardTitle(fontSize: 16)),
              const SizedBox(height: 12),
              _buildTimeField('Fajr Jama\'ath', fajrCtrl),
              _buildTimeField('Dhuhr Jama\'ath', dhuhrCtrl),
              _buildTimeField('Asr Jama\'ath', asrCtrl),
              _buildTimeField('Maghrib Jama\'ath', maghribCtrl),
              _buildTimeField('Isha Jama\'ath', ishaCtrl),
              const SizedBox(height: 16),
              PillButton(
                label: 'Save & Broadcast Times',
                variant: PillButtonVariant.primary,
                fullWidth: true,
                onPressed: () {
                  ref.read(authProvider.notifier).updateJamaathTime('fajr', fajrCtrl.text);
                  ref.read(authProvider.notifier).updateJamaathTime('dhuhr', dhuhrCtrl.text);
                  ref.read(authProvider.notifier).updateJamaathTime('asr', asrCtrl.text);
                  ref.read(authProvider.notifier).updateJamaathTime('maghrib', maghribCtrl.text);
                  ref.read(authProvider.notifier).updateJamaathTime('isha', ishaCtrl.text);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Jama\'ath times updated for all Mahal members'),
                      backgroundColor: AppColors.primaryEmerald,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyText(color: AppColors.textPrimary)),
          SizedBox(
            width: 110,
            height: 36,
            child: TextField(
              controller: controller,
              style: AppTextStyles.bodyText(color: AppColors.primaryEmeraldLight, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.cardSurfaceMuted,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPostNoticeDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    NoticeCategory category = NoticeCategory.announcement;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.sheetBorder),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Compose Mahal Announcement', style: AppTextStyles.cardTitle(fontSize: 16)),
                  const SizedBox(height: 12),
                  DropdownButton<NoticeCategory>(
                    value: category,
                    isExpanded: true,
                    items: NoticeCategory.values.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c.name.toUpperCase()));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => category = val);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Title / വിഷയം'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: contentCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Content / വിവരങ്ങൾ'),
                  ),
                  const SizedBox(height: 16),
                  PillButton(
                    label: 'Publish Announcement',
                    variant: PillButtonVariant.primary,
                    fullWidth: true,
                    onPressed: () {
                      if (titleCtrl.text.isNotEmpty) {
                        ref.read(communityProvider.notifier).addNotice(
                              titleEn: titleCtrl.text,
                              titleMl: titleCtrl.text,
                              contentEn: contentCtrl.text,
                              contentMl: contentCtrl.text,
                              category: category,
                              author: 'Mahal Committee',
                            );
                        Navigator.of(ctx).pop();
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

  void _showRecordCashDialog(BuildContext context, WidgetRef ref) {
    final pendingRecords = ref
        .read(paymentProvider)
        .chandaHistory
        .where((c) => c.status != ChandaStatus.paid)
        .toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.sheetBorder),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Record Offline Cash Payment', style: AppTextStyles.cardTitle(fontSize: 16)),
              const SizedBox(height: 12),
              if (pendingRecords.isEmpty)
                const Text('All records for this member are currently paid.')
              else
                ...pendingRecords.map((r) {
                  return ListTile(
                    title: Text(r.monthNameEn),
                    subtitle: Text('${AppConfig.currency} ${r.amount.toStringAsFixed(0)}'),
                    trailing: PillButton(
                      label: 'Verify Cash',
                      variant: PillButtonVariant.primary,
                      height: 32,
                      onPressed: () {
                        ref.read(paymentProvider.notifier).recordCashOffline(r.id);
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cash payment verified and receipt generated!'),
                            backgroundColor: AppColors.primaryEmerald,
                          ),
                        );
                      },
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  void _showCertificateReviewSheet(BuildContext context, WidgetRef ref, bool isMalayalam) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Consumer(
          builder: (context, ref, _) {
            final certs = ref.watch(certificateProvider).requests;

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.all(AppSpacing.s24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isMalayalam ? 'സർട്ടിഫിക്കറ്റ് അപേക്ഷകൾ പരിശോധിക്കുക' : 'Certificate Applications Review',
                            style: AppTextStyles.cardTitle(fontSize: 16),
                          ),
                          const Text(
                            'Committee verification, seal & registration no. assignment',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryEmerald.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${certs.length} Applications',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryEmerald),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: certs.length,
                      itemBuilder: (context, index) {
                        final req = certs[index];
                        final isApproved = req.isApproved;

                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.s16),
                          padding: const EdgeInsets.all(AppSpacing.s16),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isApproved ? AppColors.primaryEmerald.withValues(alpha: 0.3) : AppColors.borderLight,
                            ),
                            boxShadow: const [
                              BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryEmerald,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      req.type.nameEn.toUpperCase(),
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      req.mahalRegistrationNo ?? 'Tracking: ${req.id}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isApproved ? AppColors.mintMist : const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isApproved ? 'Approved' : 'Pending Review',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isApproved ? AppColors.primaryEmerald : const Color(0xFFD97706),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Applicant: ${req.applicantName} (${req.applicantPhone})',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                              Text(
                                'Email: ${req.applicantEmail}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Subject: ${req.primaryPersonName} & ${req.secondaryPersonName}',
                                style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary),
                              ),
                              Text(
                                'Event: ${req.eventDate} at ${req.placeOfEvent}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 8),

                              // Attached Document Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.mintMist,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.picture_as_pdf_rounded, size: 16, color: AppColors.badgeRed),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Uploaded Proof: ${req.documentFileName} (${req.documentFileSize})',
                                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Action Row
                              Row(
                                children: [
                                  if (!isApproved) ...[
                                    Expanded(
                                      child: PillButton(
                                        label: 'Approve & Issue',
                                        variant: PillButtonVariant.primary,
                                        height: 36,
                                        icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
                                        onPressed: () {
                                          ref.read(certificateProvider.notifier).approveRequest(
                                                req.id,
                                                customRemarks: 'Verified against register by Committee Secretary.',
                                              );
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Certificate approved and assigned official Reg No.!'),
                                              backgroundColor: AppColors.primaryEmerald,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: PillButton(
                                        label: 'Correction',
                                        variant: PillButtonVariant.secondary,
                                        height: 36,
                                        onPressed: () {
                                          ref.read(certificateProvider.notifier).rejectRequest(
                                                req.id,
                                                'Please re-upload a clear scanned copy of the document.',
                                              );
                                        },
                                      ),
                                    ),
                                  ] else ...[
                                    Expanded(
                                      child: PillButton(
                                        label: 'View Certificate',
                                        variant: PillButtonVariant.primary,
                                        height: 36,
                                        icon: const Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 14),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => DigitalCertificateViewScreen(certificate: req),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
