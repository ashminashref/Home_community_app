import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/glass_back_button.dart';
import '../../../core/widgets/pill_button.dart';
import '../../auth/providers/auth_provider.dart';

class ZakatCalculatorScreen extends ConsumerStatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  ConsumerState<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends ConsumerState<ZakatCalculatorScreen> {
  // Kerala Gold default rate (approx ₹6,750/g 22K gold, 1 Pavan = 8g = ₹54,000)
  final double _goldRatePerGram = 6750.0;
  final double _silverRatePerGram = 90.0;

  // Toggle unit: true = Pavan (പവൻ), false = Grams (ഗ്രാം)
  bool _usePavan = true;

  final TextEditingController _goldController = TextEditingController(text: '12'); // 12 Pavan
  final TextEditingController _silverController = TextEditingController(text: '0');
  final TextEditingController _cashController = TextEditingController(text: '75000');
  final TextEditingController _businessController = TextEditingController(text: '50000');
  final TextEditingController _debtsController = TextEditingController(text: '20000');

  final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  // Nisab threshold: 85g gold * gold rate
  double get _nisabThreshold => 85.0 * _goldRatePerGram;

  double get _goldValue {
    final qty = double.tryParse(_goldController.text.trim()) ?? 0.0;
    final grams = _usePavan ? (qty * 8.0) : qty;
    return grams * _goldRatePerGram;
  }

  double get _silverValue {
    final grams = double.tryParse(_silverController.text.trim()) ?? 0.0;
    return grams * _silverRatePerGram;
  }

  double get _cashValue => double.tryParse(_cashController.text.trim()) ?? 0.0;
  double get _businessValue => double.tryParse(_businessController.text.trim()) ?? 0.0;
  double get _debtsValue => double.tryParse(_debtsController.text.trim()) ?? 0.0;

  double get _netWealth {
    final total = (_goldValue + _silverValue + _cashValue + _businessValue) - _debtsValue;
    return total > 0 ? total : 0.0;
  }

  bool get _isEligibleForZakat => _netWealth >= _nisabThreshold;

  double get _zakatPayable => _isEligibleForZakat ? (_netWealth * 0.025) : 0.0;

  @override
  void dispose() {
    _goldController.dispose();
    _silverController.dispose();
    _cashController.dispose();
    _businessController.dispose();
    _debtsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isMalayalam = locale.languageCode == 'ml';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s12),
              child: Row(
                children: [
                  GlassBackButton(
                    iconColor: AppColors.primaryEmerald,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: AppSpacing.s16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isMalayalam ? 'സകാത്ത് കാൽക്കുലേറ്റർ' : 'Kerala Zakat Calculator',
                          style: AppTextStyles.cardTitle(
                            fontSize: 18,
                            isMalayalam: isMalayalam,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          isMalayalam ? 'സ്വർണ്ണം (പവൻ/ഗ്രാം), പണം, നിസാബ് കണക്കുകൂട്ടൽ' : 'Gold (Pavan/Grams), Cash & Nisab Calculator',
                          style: AppTextStyles.bodyText(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            isMalayalam: isMalayalam,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                child: Column(
                  children: [
                    // Result Hero Card
                    AppCard(
                      backgroundColor: AppColors.primaryEmerald,
                      padding: const EdgeInsets.all(AppSpacing.s20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isMalayalam ? 'നൽകേണ്ട സകാത്ത് (2.5%)' : 'Net Zakat Payable (2.5%)',
                                style: AppTextStyles.bodyText(color: AppColors.mintText, fontSize: 12),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _isEligibleForZakat ? AppColors.emeraldAccent : Colors.white24,
                                  borderRadius: AppRadii.pillBorder,
                                ),
                                child: Text(
                                  _isEligibleForZakat
                                      ? (isMalayalam ? 'നിർബന്ധം (Eligible)' : 'Zakat Due')
                                      : (isMalayalam ? 'നിസാബിൽ എത്തിയിട്ടില്ല' : 'Below Nisab'),
                                  style: TextStyle(
                                    color: _isEligibleForZakat ? AppColors.primaryEmerald : Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currencyFormatter.format(_zakatPayable),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Divider(color: Colors.white.withOpacity(0.15), height: 1),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isMalayalam ? 'മൊത്തം സകാത്തർഹമായ സ്വത്ത്:' : 'Total Zakatable Wealth:',
                                style: AppTextStyles.bodyText(color: AppColors.mintText, fontSize: 11.5),
                              ),
                              Text(
                                currencyFormatter.format(_netWealth),
                                style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isMalayalam ? 'നിസാബ് പരിധി (85 ഗ്രാം സ്വർണ്ണം):' : 'Nisab Benchmark (85g Gold):',
                                style: AppTextStyles.bodyText(color: AppColors.mintText, fontSize: 11.5),
                              ),
                              Text(
                                currencyFormatter.format(_nisabThreshold),
                                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.s16),

                    // Inputs Card
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.s20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isMalayalam ? 'സ്വർണ്ണം (Gold Assets)' : 'Gold Assets',
                                style: AppTextStyles.cardTitle(fontSize: 14.5),
                              ),
                              // Pavan vs Grams toggle
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppColors.cardSurfaceMuted,
                                  borderRadius: AppRadii.pillBorder,
                                ),
                                child: Row(
                                  children: [
                                    _buildUnitToggle(label: 'പവൻ (Pavan)', isSelected: _usePavan, onTap: () {
                                      setState(() => _usePavan = true);
                                    }),
                                    _buildUnitToggle(label: 'ഗ്രാം (Grams)', isSelected: !_usePavan, onTap: () {
                                      setState(() => _usePavan = false);
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildNumberField(
                            controller: _goldController,
                            hint: _usePavan ? 'Enter Pavans (1 Pavan = 8g)' : 'Enter Grams',
                            suffix: _usePavan ? 'Pavan' : 'g',
                          ),

                          const SizedBox(height: AppSpacing.s14),

                          Text(isMalayalam ? 'വെള്ളി (Silver in Grams)' : 'Silver (Grams)', style: AppTextStyles.cardTitle(fontSize: 14.5)),
                          const SizedBox(height: 8),
                          _buildNumberField(controller: _silverController, hint: 'Grams of silver', suffix: 'g'),

                          const SizedBox(height: AppSpacing.s14),

                          Text(isMalayalam ? 'കൈവശമുള്ള പണവും ബാങ്ക് ബാലൻസും' : 'Cash in Hand & Bank Balances', style: AppTextStyles.cardTitle(fontSize: 14.5)),
                          const SizedBox(height: 8),
                          _buildNumberField(controller: _cashController, hint: '₹ Cash & Savings', prefix: '₹'),

                          const SizedBox(height: AppSpacing.s14),

                          Text(isMalayalam ? 'ബിസിനസ്സ് ചരക്കുകൾ / ആസ്തി' : 'Business Stock & Goods', style: AppTextStyles.cardTitle(fontSize: 14.5)),
                          const SizedBox(height: 8),
                          _buildNumberField(controller: _businessController, hint: '₹ Trade Goods value', prefix: '₹'),

                          const SizedBox(height: AppSpacing.s14),

                          Text(isMalayalam ? 'കുറക്കേണ്ട കടങ്ങൾ (Liabilities)' : 'Immediate Debts to Deduct', style: AppTextStyles.cardTitle(fontSize: 14.5)),
                          const SizedBox(height: 8),
                          _buildNumberField(controller: _debtsController, hint: '₹ Short-term debts', prefix: '₹'),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.s16),

                    // Direct Action: Pay Zakat to Mahal Fund
                    PillButton(
                      label: isMalayalam ? 'മഹല്ല് ഫണ്ടിലേക്ക് സകാത്ത് നൽകുക' : 'Pay Zakat to Mahal Fund',
                      variant: PillButtonVariant.primary,
                      height: 48,
                      isMalayalam: isMalayalam,
                      icon: const Icon(Icons.volunteer_activism_rounded, color: Colors.white, size: 18),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _zakatPayable > 0
                                  ? 'Proceeding to pay ${currencyFormatter.format(_zakatPayable)} Zakat to Mahal Relief Fund'
                                  : 'Calculated Zakat is ₹0. You can still make a voluntary Sadaqah.',
                            ),
                            backgroundColor: AppColors.primaryEmerald,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.s24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitToggle({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryEmerald : Colors.transparent,
          borderRadius: AppRadii.pillBorder,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String hint,
    String? prefix,
    String? suffix,
  }) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          if (prefix != null) ...[
            Text(prefix, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              style: AppTextStyles.cardTitle(fontSize: 14.5),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.bodyText(color: AppColors.textMuted, fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (suffix != null)
            Text(suffix, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
