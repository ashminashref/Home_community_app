import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/glass_back_button.dart';
import '../../../core/widgets/pill_button.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/certificate_models.dart';

class DigitalCertificateViewScreen extends ConsumerWidget {
  final CertificateRequestModel certificate;

  const DigitalCertificateViewScreen({
    super.key,
    required this.certificate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isMalayalam = locale.languageCode == 'ml';

    final regNo = certificate.mahalRegistrationNo ?? 'EKRL/${certificate.type.codePrefix}/2026/PENDING';
    final issueDate = certificate.approvedAt != null
        ? '${certificate.approvedAt!.day.toString().padLeft(2, '0')}/${certificate.approvedAt!.month.toString().padLeft(2, '0')}/${certificate.approvedAt!.year}'
        : 'Under Committee Seal';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s12),
              child: Row(
                children: [
                  GlassBackButton(
                    iconColor: AppColors.primaryEmerald,
                  ),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMalayalam ? 'മഹല്ല് സർട്ടിഫിക്കറ്റ്' : 'Mahal Certificate',
                          style: AppTextStyles.cardTitle(
                            fontSize: 18,
                            isMalayalam: isMalayalam,
                          ),
                        ),
                        Text(
                          isMalayalam ? certificate.type.nameMl : certificate.type.nameEn,
                          style: AppTextStyles.bodyText(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            isMalayalam: isMalayalam,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: certificate.isApproved
                          ? AppColors.primaryEmerald.withValues(alpha: 0.12)
                          : const Color(0xFFD97706).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          certificate.isApproved ? Icons.verified_rounded : Icons.pending_actions_rounded,
                          size: 14,
                          color: certificate.isApproved ? AppColors.primaryEmerald : const Color(0xFFD97706),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          certificate.isApproved ? 'Official' : 'Draft',
                          style: TextStyle(
                            color: certificate.isApproved ? AppColors.primaryEmerald : const Color(0xFFD97706),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Certificate Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s8),
                child: Column(
                  children: [
                    // Certificate Document Canvas
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDFAF3), // Warm official parchment ivory
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFD7C297), width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x140E3E2E),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Subtle Islamic arch watermark
                          Positioned(
                            top: 80,
                            right: 0,
                            left: 0,
                            child: Center(
                              child: Opacity(
                                opacity: 0.05,
                                child: Icon(
                                  Icons.mosque_rounded,
                                  size: 260,
                                  color: AppColors.primaryEmerald,
                                ),
                              ),
                            ),
                          ),

                          // Inner Ornamental Border
                          Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.all(AppSpacing.s20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE6D6B8), width: 1),
                            ),
                            child: Column(
                              children: [
                                // Islamic Header Bismillah
                                const Text(
                                  'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ',
                                  style: TextStyle(
                                    fontFamily: 'NotoNaskhArabic',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryEmerald,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s8),

                                // Mahal Logo Crest
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primaryEmerald,
                                    border: Border.all(color: const Color(0xFFD7C297), width: 2),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.account_balance_rounded,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s8),

                                // Mahal Name & Header
                                const Text(
                                  'EKAROOL MUSLIM JAMA\'ATH',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.1,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'ഏകരൂൽ മുസ്‌ലിം ജമാഅത്ത് മഹല്ല് കമ്മിറ്റി',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Reg. No. KLM/786/1984 • Kozhikode Dist., Kerala',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                const SizedBox(height: AppSpacing.s12),
                                const Divider(color: Color(0xFFE2D4BC), thickness: 1),
                                const SizedBox(height: AppSpacing.s12),

                                // Title of Certificate
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryEmerald,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    certificate.type.nameEn.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s12),

                                // Reg Number and Date Bar
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'REGISTER NO.',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                        Text(
                                          regNo,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primaryEmerald,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'DATE OF ISSUE',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                        Text(
                                          issueDate,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: AppSpacing.s16),

                                // Official Attestation Text
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.s12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFFF1E6D0)),
                                  ),
                                  child: Text(
                                    isMalayalam
                                        ? 'ഈ മഹല്ല് റജിസ്റ്ററിലെ രേഖകൾ പരിശോധിച്ച് താഴെ പറയുന്ന വിവരങ്ങൾ പൂർണ്ണമായും ശരിയാണെന്ന് സാക്ഷ്യപ്പെടുത്തുന്നു.'
                                        : 'This is to certify that according to the records maintained in the register of Ekarool Muslim Jama\'ath Mahal, the following particulars are true and verified.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      height: 1.55,
                                      color: const Color(0xFF334155),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: AppSpacing.s16),

                                // Particulars Table
                                _buildParticularRow(
                                  label: certificate.type == CertificateType.marriage
                                      ? 'Groom (വരൻ)'
                                      : (certificate.type == CertificateType.birth ? 'Child (കുട്ടി)' : 'Deceased (മരണപ്പെട്ടയാൾ)'),
                                  value: certificate.primaryPersonName,
                                ),
                                _buildParticularRow(
                                  label: certificate.type == CertificateType.marriage
                                      ? 'Bride (വധു)'
                                      : (certificate.type == CertificateType.birth ? 'Mother/Guardian' : 'Applicant / Next of Kin'),
                                  value: certificate.secondaryPersonName,
                                ),
                                _buildParticularRow(
                                  label: certificate.type == CertificateType.marriage
                                      ? 'Nikkah Date'
                                      : (certificate.type == CertificateType.birth ? 'Date of Birth' : 'Date of Demise'),
                                  value: certificate.eventDate,
                                ),
                                _buildParticularRow(
                                  label: certificate.type == CertificateType.marriage
                                      ? 'Solemnized At'
                                      : (certificate.type == CertificateType.birth ? 'Place of Birth' : 'Burial Location'),
                                  value: certificate.placeOfEvent,
                                ),
                                _buildParticularRow(
                                  label: 'Applicant Name',
                                  value: '${certificate.applicantName} (${certificate.applicantPhone})',
                                ),
                                _buildParticularRow(
                                  label: 'Applicant Email',
                                  value: certificate.applicantEmail,
                                ),

                                const SizedBox(height: AppSpacing.s16),

                                // Seal & Signature Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    // QR Code Verification Box
                                    Container(
                                      width: 64,
                                      height: 64,
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFCBD5E1)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.qr_code_2_rounded, size: 40, color: AppColors.primaryEmerald),
                                          Text(
                                            'SCAN TO VERIFY',
                                            style: TextStyle(
                                              fontSize: 5.5,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Committee Stamp
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFF15803D), width: 1.5),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              'SEAL OF MAHAL',
                                              style: TextStyle(
                                                fontSize: 7,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF15803D),
                                              ),
                                            ),
                                            const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF15803D), size: 20),
                                            Text(
                                              certificate.isApproved ? 'VERIFIED' : 'PENDING',
                                              style: const TextStyle(
                                                fontSize: 8,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFF15803D),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Authorized Signatory
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 24,
                                          alignment: Alignment.center,
                                          child: Text(
                                            'P. K. Musthafa',
                                            style: TextStyle(
                                              fontFamily: 'Courier',
                                              fontSize: 13,
                                              fontStyle: FontStyle.italic,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primaryEmerald,
                                            ),
                                          ),
                                        ),
                                        Container(width: 80, height: 1, color: AppColors.textMuted),
                                        const SizedBox(height: 3),
                                        const Text(
                                          'General Secretary',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const Text(
                                          'Mahal Committee',
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.s16),

                    // Attached Document Verification Card
                    AppCard(
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.badgeRed.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Icon(Icons.picture_as_pdf_rounded, color: AppColors.badgeRed, size: 24),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  certificate.documentFileName,
                                  style: AppTextStyles.cardTitle(fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Attached Applicant Proof • ${certificate.documentFileSize}',
                                  style: AppTextStyles.bodyText(color: AppColors.textSecondary, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_red_eye_outlined, color: AppColors.primaryEmerald),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Viewing attached proof: ${certificate.documentFileName}'),
                                  backgroundColor: AppColors.primaryEmerald,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.s24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: PillButton(
                            label: isMalayalam ? 'ഡൗൺലോഡ് (PDF)' : 'Download PDF',
                            variant: PillButtonVariant.primary,
                            height: 48,
                            icon: const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                            isMalayalam: isMalayalam,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Downloading attested certificate: $regNo.pdf'),
                                  backgroundColor: AppColors.primaryEmerald,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s12),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(color: Color(0x0C000000), blurRadius: 10, offset: Offset(0, 3)),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.share_outlined, color: AppColors.primaryEmerald),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Sharing certificate $regNo link'),
                                  backgroundColor: AppColors.primaryEmerald,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticularRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          const Text(' :  ', style: TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
