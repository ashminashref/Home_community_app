import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/glass_back_button.dart';
import '../../../core/widgets/pill_button.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class JoinMahalScreen extends ConsumerStatefulWidget {
  const JoinMahalScreen({super.key});

  @override
  ConsumerState<JoinMahalScreen> createState() => _JoinMahalScreenState();
}

class _JoinMahalScreenState extends ConsumerState<JoinMahalScreen> {
  final _codeController = TextEditingController(text: AppConfig.defaultMahalCode);
  bool _isScanning = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _codeController.text.trim();
    if (code.isNotEmpty) {
      ref.read(authProvider.notifier).joinMahalWithCode(code);
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isMalayalam = locale.languageCode == 'ml';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: AppSpacing.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Back button
              GlassBackButton(
                iconColor: AppColors.primaryEmerald,
                onPressed: () => context.go('/'),
              ),
              const SizedBox(height: AppSpacing.s24),

              // Title & Subtitle
              Text(
                l10n.joinMahal,
                style: AppTextStyles.displayHero(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  isMalayalam: isMalayalam,
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Text(
                'Enter the unique code given by your Mahal committee or scan the invite QR code at the mosque notice board.',
                style: AppTextStyles.bodyText(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  isMalayalam: isMalayalam,
                ),
              ),
              const SizedBox(height: AppSpacing.s32),

              // Card containing code input & QR trigger
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.enterMahalCode,
                      style: AppTextStyles.cardTitle(
                        fontSize: 14,
                        isMalayalam: isMalayalam,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    TextField(
                      controller: _codeController,
                      style: AppTextStyles.cardTitle(
                        fontSize: 16,
                        color: AppColors.primaryEmerald,
                      ),
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: l10n.mahalCodeHint,
                        prefixIcon: const Icon(Icons.tag_rounded, color: AppColors.primaryEmeraldLight),
                        filled: true,
                        fillColor: AppColors.cardSurfaceMuted,
                        border: OutlineInputBorder(
                          borderRadius: AppRadii.buttonBorder,
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s20),

                    // Divider with "OR"
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.divider)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            'OR',
                            style: AppTextStyles.bodyText(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppColors.divider)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s20),

                    // QR Scan Option
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isScanning = !_isScanning;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _isScanning
                                  ? 'Point camera at Mahal QR code'
                                  : 'Scanned Ekarool Juma Masjid Mahal',
                            ),
                            backgroundColor: AppColors.primaryEmerald,
                          ),
                        );
                        if (!_isScanning) {
                          _codeController.text = AppConfig.defaultMahalCode;
                        }
                      },
                      icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primaryEmerald),
                      label: Text(
                        l10n.scanQr,
                        style: AppTextStyles.buttonText(
                          color: AppColors.primaryEmerald,
                          isMalayalam: isMalayalam,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: AppRadii.buttonBorder),
                        side: const BorderSide(color: AppColors.divider, width: 1.5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s32),

              // Join Button
              PillButton(
                label: l10n.joinButton,
                variant: PillButtonVariant.primary,
                fullWidth: true,
                height: 54,
                isMalayalam: isMalayalam,
                icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                onPressed: _submit,
              ),

              const SizedBox(height: AppSpacing.s24),

              // Demo preset chips
              Center(
                child: Wrap(
                  spacing: 8,
                  children: [
                    ActionChip(
                      label: const Text('EKRL01 (Ekarool Mahal)'),
                      backgroundColor: AppColors.mintMist,
                      labelStyle: AppTextStyles.bodyText(
                        color: AppColors.primaryEmerald,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      onPressed: () {
                        _codeController.text = 'EKRL01';
                        _submit();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

