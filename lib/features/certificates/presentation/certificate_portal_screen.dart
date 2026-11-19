import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/glass_back_button.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../core/widgets/shimmer_skeleton.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/certificate_models.dart';
import '../providers/certificate_provider.dart';
import 'apply_certificate_screen.dart';
import 'digital_certificate_view_screen.dart';

class CertificatePortalScreen extends ConsumerWidget {
  const CertificatePortalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isMalayalam = locale.languageCode == 'ml';
    final certState = ref.watch(certificateProvider);
    final notifier = ref.read(certificateProvider.notifier);
    final requests = certState.filteredRequests;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // In-content Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s12),
              child: Row(
                children: [
                  GlassBackButton(iconColor: AppColors.primaryEmerald),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMalayalam ? 'മഹല്ല് സർട്ടിഫിക്കറ്റുകൾ' : 'Mahal Certificates',
                          style: AppTextStyles.cardTitle(fontSize: 18, isMalayalam: isMalayalam),
                        ),
                        Text(
                          isMalayalam ? 'വിവാഹം • ജനനം • മരണം' : 'Marriage • Birth • Death Records',
                          style: AppTextStyles.bodyText(color: AppColors.textSecondary, fontSize: 12, isMalayalam: isMalayalam),
                        ),
                      ],
                    ),
                  ),
                  PillButton(
                    label: isMalayalam ? '+ അപേക്ഷിക്കുക' : '+ Apply',
                    variant: PillButtonVariant.primary,
                    height: 38,
                    isMalayalam: isMalayalam,
                    icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ApplyCertificateScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(
              child: certState.isLoading
                  ? ShimmerSkeleton.certificateList()
                  : RefreshIndicator(
                      color: AppColors.primaryEmerald,
                      onRefresh: () => notifier.refresh(),
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        slivers: [
                          // Overview Stats Row
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.s20, AppSpacing.s8, AppSpacing.s20, AppSpacing.s16),
                      child: Row(
                        children: [
                          _buildStatCard(
                            label: 'Total Requests',
                            count: certState.requests.length.toString(),
                            color: AppColors.textPrimary,
                            icon: Icons.folder_shared_outlined,
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          _buildStatCard(
                            label: 'Approved & Issued',
                            count: certState.approvedCount.toString(),
                            color: AppColors.primaryEmerald,
                            icon: Icons.verified_user_outlined,
                          ),
                          const SizedBox(width: AppSpacing.s12),
                          _buildStatCard(
                            label: 'Under Review',
                            count: certState.pendingCount.toString(),
                            color: const Color(0xFFD97706),
                            icon: Icons.hourglass_top_outlined,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Filter Segment Pills
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
                        children: [
                          _buildFilterPill(
                            label: 'All (എല്ലാം)',
                            isSelected: certState.typeFilter == null,
                            onTap: () => notifier.setTypeFilter(null),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterPill(
                            label: 'Marriage (നികാഹ്)',
                            isSelected: certState.typeFilter == CertificateType.marriage,
                            onTap: () => notifier.setTypeFilter(CertificateType.marriage),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterPill(
                            label: 'Birth (ജനനം)',
                            isSelected: certState.typeFilter == CertificateType.birth,
                            onTap: () => notifier.setTypeFilter(CertificateType.birth),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterPill(
                            label: 'Death (മരണം)',
                            isSelected: certState.typeFilter == CertificateType.death,
                            onTap: () => notifier.setTypeFilter(CertificateType.death),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s16)),

                  // Certificate Cards List
                  if (requests.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.s32),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.description_outlined, size: 54, color: AppColors.textMuted),
                              const SizedBox(height: AppSpacing.s12),
                              Text(
                                'No certificate records found',
                                style: AppTextStyles.cardTitle(fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Apply for Marriage, Birth or Death certificate from Mahal.',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyText(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = requests[index];
                            return _buildCertificateCard(context, item, isMalayalam);
                          },
                          childCount: requests.length,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s16)),

                  // Guidance & Guidelines Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: const BoxDecoration(
                                    color: AppColors.mintMist,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.info_outline_rounded, color: AppColors.primaryEmerald, size: 18),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.s12),
                                Expanded(
                                  child: Text(
                                    isMalayalam ? 'മഹല്ല് സർട്ടിഫിക്കറ്റ് മാർഗ്ഗനിർദ്ദേശങ്ങൾ' : 'Mahal Certificate Guidelines',
                                    style: AppTextStyles.cardTitle(fontSize: 13.5, isMalayalam: isMalayalam),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.s12),
                            _buildGuidelineRow(
                              title: 'Marriage Certificate (നികാഹ്)',
                              desc: 'Nikkah solemnized at Masjid or by approved Qazi with register extract.',
                            ),
                            const SizedBox(height: 6),
                            _buildGuidelineRow(
                              title: 'Birth Certificate (ജനനം)',
                              desc: 'Official hospital birth memo with parent mahal family membership number.',
                            ),
                            const SizedBox(height: 6),
                            _buildGuidelineRow(
                              title: 'Death Certificate (മരണം)',
                              desc: 'Doctor\'s demise declaration and Mahal Qabarsthan burial entry acknowledgment.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 90)),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String count,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              count,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryEmerald : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryEmerald : AppColors.borderLight,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(color: Color(0x180E3E2E), blurRadius: 6, offset: Offset(0, 2)),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCertificateCard(BuildContext context, CertificateRequestModel item, bool isMalayalam) {
    IconData typeIcon;
    Color typeColor;

    switch (item.type) {
      case CertificateType.marriage:
        typeIcon = Icons.favorite_rounded;
        typeColor = const Color(0xFFE11D48);
        break;
      case CertificateType.birth:
        typeIcon = Icons.child_care_rounded;
        typeColor = const Color(0xFF0284C7);
        break;
      case CertificateType.death:
        typeIcon = Icons.nights_stay_rounded;
        typeColor = const Color(0xFF475569);
        break;
    }

    final isApproved = item.isApproved;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Type, Reg No, Status
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Icon(typeIcon, color: typeColor, size: 20)),
                ),
                const SizedBox(width: AppSpacing.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMalayalam ? item.type.nameMl : item.type.nameEn,
                        style: AppTextStyles.cardTitle(fontSize: 14, isMalayalam: isMalayalam),
                      ),
                      Text(
                        item.mahalRegistrationNo ?? 'Tracking: ${item.id}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isApproved ? AppColors.primaryEmerald : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isApproved
                        ? AppColors.primaryEmerald.withValues(alpha: 0.12)
                        : const Color(0xFFD97706).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isMalayalam ? item.status.labelMl : item.status.labelEn,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isApproved ? AppColors.primaryEmerald : const Color(0xFFD97706),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.s12),
            const Divider(color: AppColors.borderLight, height: 1),
            const SizedBox(height: AppSpacing.s10),

            // Particulars summary
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.type == CertificateType.marriage
                            ? 'Parties (ദമ്പതികൾ)'
                            : (item.type == CertificateType.birth ? 'Child & Parent' : 'Deceased & Kin'),
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.primaryPersonName} & ${item.secondaryPersonName}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.s12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Event Date',
                      style: TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.eventDate,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.s10),

            // Attached Document Pill
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
                      '${item.documentFileName} (${item.documentFileSize})',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Text('Proof Attached', style: TextStyle(fontSize: 10, color: AppColors.primaryEmerald, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.s12),

            // Card Action Buttons
            Row(
              children: [
                if (isApproved)
                  Expanded(
                    child: PillButton(
                      label: isMalayalam ? 'സർട്ടിഫിക്കറ്റ് കാണുക' : 'View Official Certificate',
                      variant: PillButtonVariant.primary,
                      height: 40,
                      isMalayalam: isMalayalam,
                      icon: const Icon(Icons.verified_rounded, size: 16, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DigitalCertificateViewScreen(certificate: item),
                          ),
                        );
                      },
                    ),
                  )
                else
                  Expanded(
                    child: PillButton(
                      label: isMalayalam ? 'സ്ഥിതി അറിയുക' : 'Track Verification Status',
                      variant: PillButtonVariant.secondary,
                      height: 40,
                      isMalayalam: isMalayalam,
                      icon: const Icon(Icons.pending_actions_rounded, size: 16, color: AppColors.primaryEmerald),
                      onPressed: () {
                        _showTrackingBottomSheet(context, item, isMalayalam);
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTrackingBottomSheet(BuildContext context, CertificateRequestModel item, bool isMalayalam) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.s24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: AppColors.mintMist, shape: BoxShape.circle),
                    child: const Icon(Icons.sync_rounded, color: AppColors.primaryEmerald, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Application Tracking: ${item.id}',
                          style: AppTextStyles.cardTitle(fontSize: 15),
                        ),
                        Text(
                          '${item.type.nameEn} • Submitted on ${item.appliedAt.day}/${item.appliedAt.month}/${item.appliedAt.year}',
                          style: AppTextStyles.bodyText(color: AppColors.textSecondary, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s20),

              _buildTrackingStep(
                title: 'Application Received & Logged',
                subtitle: 'Applicant details & documents uploaded to secure Mahal server.',
                isDone: true,
              ),
              _buildTrackingStep(
                title: 'Committee Register Verification',
                subtitle: 'Mahal Clerk verifying with official ledger book & records.',
                isDone: true,
              ),
              _buildTrackingStep(
                title: 'General Secretary Attestation & Seal',
                subtitle: 'Official registration number generation and committee signature.',
                isDone: false,
                isCurrent: true,
              ),
              _buildTrackingStep(
                title: 'Digital Certificate Issued',
                subtitle: 'Instant PDF download available with verifiable QR code.',
                isDone: false,
              ),

              const SizedBox(height: AppSpacing.s20),
              PillButton(
                label: 'Close',
                variant: PillButtonVariant.primary,
                fullWidth: true,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrackingStep({
    required String title,
    required String subtitle,
    required bool isDone,
    bool isCurrent = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone
                  ? AppColors.primaryEmerald
                  : (isCurrent ? const Color(0xFFD97706) : AppColors.borderLight),
            ),
            child: Icon(
              isDone ? Icons.check : (isCurrent ? Icons.circle : Icons.circle_outlined),
              size: 13,
              color: isDone || isCurrent ? Colors.white : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isDone || isCurrent ? FontWeight.w700 : FontWeight.w500,
                    color: isDone || isCurrent ? AppColors.textPrimary : AppColors.textMuted,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineRow({required String title, required String desc}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.primaryEmerald),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 11, color: AppColors.textPrimary, height: 1.45),
              children: [
                TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: desc, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
