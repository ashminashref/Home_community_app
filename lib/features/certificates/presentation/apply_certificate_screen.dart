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
import '../providers/certificate_provider.dart';
import 'digital_certificate_view_screen.dart';

class ApplyCertificateScreen extends ConsumerStatefulWidget {
  final CertificateType initialType;

  const ApplyCertificateScreen({
    super.key,
    this.initialType = CertificateType.marriage,
  });

  @override
  ConsumerState<ApplyCertificateScreen> createState() => _ApplyCertificateScreenState();
}

class _ApplyCertificateScreenState extends ConsumerState<ApplyCertificateScreen> {
  late CertificateType _selectedType;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  late TextEditingController _primaryPersonController;
  late TextEditingController _secondaryPersonController;
  late TextEditingController _eventDateController;
  late TextEditingController _placeController;

  String? _attachedFileName;
  String? _attachedFileSize;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;

    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? 'Abdul Rahman');
    _phoneController = TextEditingController(text: user?.phone ?? '+91 98470 12345');
    _emailController = TextEditingController(text: user?.email ?? 'abdul.rahman@gmail.com');

    _primaryPersonController = TextEditingController();
    _secondaryPersonController = TextEditingController();
    _eventDateController = TextEditingController();
    _placeController = TextEditingController();

    _setDefaultPlaceAndDate();
  }

  void _setDefaultPlaceAndDate() {
    final now = DateTime.now();
    _eventDateController.text = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    switch (_selectedType) {
      case CertificateType.marriage:
        _placeController.text = 'Ekarool Central Juma Masjid';
        _attachedFileName = 'nikkah_signed_agreement.pdf';
        _attachedFileSize = '2.1 MB';
        break;
      case CertificateType.birth:
        _placeController.text = 'Aster MIMS Hospital, Calicut';
        _attachedFileName = 'hospital_birth_report.pdf';
        _attachedFileSize = '1.7 MB';
        break;
      case CertificateType.death:
        _placeController.text = 'Ekarool Mahal Qabarsthan (ഖബർസ്ഥാൻ)';
        _attachedFileName = 'hospital_death_declaration.pdf';
        _attachedFileSize = '1.4 MB';
        break;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _primaryPersonController.dispose();
    _secondaryPersonController.dispose();
    _eventDateController.dispose();
    _placeController.dispose();
    super.dispose();
  }

  void _selectDocumentFile() {
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
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              Text(
                'Upload Required Certificate Proof',
                style: AppTextStyles.cardTitle(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Select document format (PDF, JPG, PNG) up to 10MB',
                style: AppTextStyles.bodyText(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: AppSpacing.s16),

              _buildUploadOption(
                icon: Icons.upload_file_rounded,
                title: 'Choose PDF Document from Storage',
                subtitle: 'Government ID, Hospital card, or Registry extract',
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    switch (_selectedType) {
                      case CertificateType.marriage:
                        _attachedFileName = 'marriage_affidavit_scanned.pdf';
                        _attachedFileSize = '2.3 MB';
                        break;
                      case CertificateType.birth:
                        _attachedFileName = 'birth_declaration_slip.pdf';
                        _attachedFileSize = '1.9 MB';
                        break;
                      case CertificateType.death:
                        _attachedFileName = 'doctor_death_certificate.pdf';
                        _attachedFileSize = '1.6 MB';
                        break;
                    }
                  });
                },
              ),
              const SizedBox(height: AppSpacing.s12),
              _buildUploadOption(
                icon: Icons.camera_alt_rounded,
                title: 'Scan Document with Camera',
                subtitle: 'Take a clear photo of physical certificate',
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _attachedFileName = 'camera_scanned_document.jpg';
                    _attachedFileSize = '3.4 MB';
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.s12),
        decoration: BoxDecoration(
          color: AppColors.mintMist,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryEmerald.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(child: Icon(icon, color: AppColors.primaryEmerald, size: 22)),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.cardTitle(fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.bodyText(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.primaryEmerald),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_attachedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload the required proof document'),
          backgroundColor: AppColors.badgeRed,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final user = ref.read(authProvider).user;

    final created = await ref.read(certificateProvider.notifier).submitCertificateRequest(
          userId: user?.id ?? 'usr_current',
          applicantName: _nameController.text.trim(),
          applicantPhone: _phoneController.text.trim(),
          applicantEmail: _emailController.text.trim(),
          type: _selectedType,
          primaryPersonName: _primaryPersonController.text.trim(),
          secondaryPersonName: _secondaryPersonController.text.trim(),
          eventDate: _eventDateController.text.trim(),
          placeOfEvent: _placeController.text.trim(),
          documentFileName: _attachedFileName!,
          documentFileSize: _attachedFileSize ?? '2.0 MB',
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.mintMist,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.primaryEmerald, size: 40),
            ),
            const SizedBox(height: AppSpacing.s16),
            const Text(
              'Application Submitted!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Tracking ID: ${created.id}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryEmerald),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your certificate application and proof documents have been submitted to Ekarool Mahal Committee. You will receive an SMS and email notification upon approval.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.s20),
            Row(
              children: [
                Expanded(
                  child: PillButton(
                    label: 'View Details',
                    variant: PillButtonVariant.secondary,
                    height: 44,
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => DigitalCertificateViewScreen(certificate: created),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: PillButton(
                    label: 'Done',
                    variant: PillButtonVariant.primary,
                    height: 44,
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isMalayalam = locale.languageCode == 'ml';

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
                  GlassBackButton(iconColor: AppColors.primaryEmerald),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMalayalam ? 'സർട്ടിഫിക്കറ്റ് അപേക്ഷ' : 'Certificate Application',
                          style: AppTextStyles.cardTitle(fontSize: 18, isMalayalam: isMalayalam),
                        ),
                        Text(
                          isMalayalam ? 'മഹല്ല് രേഖകൾക്കും ആവശ്യങ്ങൾക്കും' : 'Official Mahal Jama\'ath Registry',
                          style: AppTextStyles.bodyText(color: AppColors.textSecondary, fontSize: 12, isMalayalam: isMalayalam),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Certificate Type Selector Pills
                      Text(
                        isMalayalam ? 'സർട്ടിഫിക്കറ്റ് തരം തിരഞ്ഞെടുക്കുക' : 'Select Certificate Type',
                        style: AppTextStyles.cardTitle(fontSize: 14, isMalayalam: isMalayalam),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      Row(
                        children: [
                          _buildTypeChip(CertificateType.marriage, 'Marriage', 'നികാഹ്', Icons.favorite_rounded),
                          const SizedBox(width: AppSpacing.s8),
                          _buildTypeChip(CertificateType.birth, 'Birth', 'ജനനം', Icons.child_care_rounded),
                          const SizedBox(width: AppSpacing.s8),
                          _buildTypeChip(CertificateType.death, 'Death', 'മരണം', Icons.event_busy_rounded),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.s20),

                      // Applicant Details Section
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person_outline_rounded, color: AppColors.primaryEmerald, size: 20),
                                const SizedBox(width: AppSpacing.s8),
                                Text(
                                  'Applicant Details (അപേക്ഷകന്റെ വിവരങ്ങൾ)',
                                  style: AppTextStyles.cardTitle(fontSize: 13.5),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.s12),

                            // Full Name
                            _buildInput(
                              label: 'Applicant Full Name',
                              controller: _nameController,
                              icon: Icons.badge_outlined,
                              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: AppSpacing.s12),

                            // Phone & Email in row
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInput(
                                    label: 'Phone Number',
                                    controller: _phoneController,
                                    icon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                    validator: (val) => val == null || val.length < 10 ? 'Valid phone required' : null,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.s8),
                                Expanded(
                                  child: _buildInput(
                                    label: 'Email Address',
                                    controller: _emailController,
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (val) => val == null || !val.contains('@') ? 'Valid email required' : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.s16),

                      // Event Particulars Section
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.article_outlined, color: AppColors.primaryEmerald, size: 20),
                                const SizedBox(width: AppSpacing.s8),
                                Text(
                                  _selectedType == CertificateType.marriage
                                      ? 'Marriage Details (നികാഹ് വിവരങ്ങൾ)'
                                      : (_selectedType == CertificateType.birth
                                          ? 'Birth Details (ജനന വിവരങ്ങൾ)'
                                          : 'Demise Particulars (മരണ വിവരങ്ങൾ)'),
                                  style: AppTextStyles.cardTitle(fontSize: 13.5),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.s12),

                            // Primary Person
                            _buildInput(
                              label: _selectedType == CertificateType.marriage
                                  ? 'Groom\'s Full Name (വരൻ)'
                                  : (_selectedType == CertificateType.birth
                                      ? 'Child\'s Full Name (കുട്ടി)'
                                      : 'Deceased Person\'s Full Name (മരണപ്പെട്ടയാൾ)'),
                              controller: _primaryPersonController,
                              icon: Icons.person,
                              hint: _selectedType == CertificateType.marriage
                                  ? 'e.g. Muhammed Shafiq'
                                  : (_selectedType == CertificateType.birth ? 'e.g. Rayan Ahmed' : 'e.g. Alavi Haji'),
                              validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                            ),
                            const SizedBox(height: AppSpacing.s12),

                            // Secondary Person
                            _buildInput(
                              label: _selectedType == CertificateType.marriage
                                  ? 'Bride\'s Full Name (വധു)'
                                  : (_selectedType == CertificateType.birth
                                      ? 'Mother\'s / Guardian\'s Name (മാതാവ്)'
                                      : 'Next of Kin / Relationship (ബന്ധു)'),
                              controller: _secondaryPersonController,
                              icon: Icons.people_outline,
                              hint: _selectedType == CertificateType.marriage
                                  ? 'e.g. Aisha Nasrin'
                                  : (_selectedType == CertificateType.birth ? 'e.g. Fathima Suhara' : 'e.g. Son / മകൻ'),
                              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: AppSpacing.s12),

                            // Date & Place
                            Row(
                              children: [
                                Expanded(
                                  child: _buildInput(
                                    label: _selectedType == CertificateType.marriage
                                        ? 'Date of Nikkah'
                                        : (_selectedType == CertificateType.birth ? 'Date of Birth' : 'Date of Demise'),
                                    controller: _eventDateController,
                                    icon: Icons.calendar_today_outlined,
                                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.s8),
                                Expanded(
                                  child: _buildInput(
                                    label: 'Venue / Place',
                                    controller: _placeController,
                                    icon: Icons.place_outlined,
                                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.s16),

                      // Document Upload Box (Users have to upload their certificates which the mahal need)
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.cloud_upload_outlined, color: AppColors.primaryEmerald, size: 20),
                                const SizedBox(width: AppSpacing.s8),
                                Text(
                                  'Upload Required Document Proof',
                                  style: AppTextStyles.cardTitle(fontSize: 13.5),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedType == CertificateType.marriage
                                  ? 'Upload Nikkah Register extract, marriage notice or ID proof.'
                                  : (_selectedType == CertificateType.birth
                                      ? 'Upload Hospital Birth Memo, Discharge summary or Panchayat receipt.'
                                      : 'Upload Doctor\'s Death certificate or Burial slip.'),
                              style: AppTextStyles.bodyText(color: AppColors.textSecondary, fontSize: 11),
                            ),
                            const SizedBox(height: AppSpacing.s12),

                            // Upload Container
                            InkWell(
                              onTap: _selectDocumentFile,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16, horizontal: AppSpacing.s12),
                                decoration: BoxDecoration(
                                  color: AppColors.mintMist,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _attachedFileName != null ? AppColors.primaryEmerald : AppColors.borderLight,
                                    width: 1.5,
                                  ),
                                ),
                                child: _attachedFileName != null
                                    ? Row(
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: AppColors.badgeRed.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(10),
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
                                                  _attachedFileName!,
                                                  style: AppTextStyles.cardTitle(fontSize: 12.5),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  '${_attachedFileSize ?? "2 MB"} • Document Ready',
                                                  style: const TextStyle(fontSize: 10.5, color: AppColors.primaryEmerald, fontWeight: FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: _selectDocumentFile,
                                            child: const Text('Change', style: TextStyle(color: AppColors.primaryEmerald, fontSize: 12)),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          const Icon(Icons.file_upload_outlined, size: 36, color: AppColors.primaryEmerald),
                                          const SizedBox(height: 6),
                                          const Text(
                                            'Tap to select & attach document',
                                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'PDF, PNG, JPG accepted (Max 10MB)',
                                            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.s24),

                      // Submit Button
                      PillButton(
                        label: _isSubmitting
                            ? 'Submitting to Committee...'
                            : (isMalayalam ? 'അപേക്ഷ സമർപ്പിക്കുക' : 'Submit Application'),
                        variant: PillButtonVariant.primary,
                        fullWidth: true,
                        isMalayalam: isMalayalam,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                        onPressed: _isSubmitting ? null : _submit,
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(CertificateType type, String labelEn, String labelMl, IconData icon) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
            _setDefaultPlaceAndDate();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryEmerald : AppColors.cardSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primaryEmerald : AppColors.borderLight,
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(color: Color(0x200E3E2E), blurRadius: 8, offset: Offset(0, 3)),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? Colors.white : AppColors.textSecondary, size: 20),
              const SizedBox(height: 4),
              Text(
                labelEn,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              Text(
                labelMl,
                style: TextStyle(
                  fontSize: 9.5,
                  height: 1.4,
                  color: isSelected ? Colors.white70 : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
