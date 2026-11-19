import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/glass_back_button.dart';
import '../../../core/widgets/mosque_misty_graphic.dart';
import '../../../core/widgets/pill_button.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final bool initialIsRegister;

  const LoginScreen({super.key, this.initialIsRegister = true});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late bool _isRegisterMode;

  final _nameController = TextEditingController(text: 'Abdul Rahman');
  final _phoneController = TextEditingController(text: '98470 12345');
  final _emailController = TextEditingController(text: 'abdul.rahman@gmail.com');

  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(text: '786110'[index]),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _otpSent = false;
  bool _loading = false;
  String? _errorMessage;
  int _resendSeconds = 45;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _isRegisterMode = widget.initialIsRegister;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _resendSeconds = 45;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        if (mounted) setState(() => _resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  void _handleSendOtp() {
    setState(() => _errorMessage = null);

    // Validation
    final cleanPhone = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.length < 10) {
      setState(() => _errorMessage = 'Please enter a valid 10-digit mobile number');
      return;
    }

    if (_isRegisterMode) {
      if (_nameController.text.trim().isEmpty) {
        setState(() => _errorMessage = 'Please enter your full name');
        return;
      }
      final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      if (!emailRegex.hasMatch(_emailController.text.trim())) {
        setState(() => _errorMessage = 'Please enter a valid email address');
        return;
      }
    }

    setState(() => _loading = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      ref.read(authProvider.notifier).sendOtp(_phoneController.text);
      setState(() {
        _loading = false;
        _otpSent = true;
      });
      _startResendTimer();
      _otpFocusNodes[0].requestFocus();
    });
  }

  void _handleVerifyOtp() {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      setState(() => _errorMessage = 'Please enter all 6 digits of the OTP');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;

      bool success;
      if (_isRegisterMode) {
        success = ref.read(authProvider.notifier).verifyOtpAndRegister(
              name: _nameController.text,
              phone: _phoneController.text,
              email: _emailController.text,
              otp: otp,
            );
      } else {
        success = ref.read(authProvider.notifier).verifyOtpAndLogin(
              phone: _phoneController.text,
              otp: otp,
            );
      }

      setState(() => _loading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isRegisterMode ? 'Registration verified successfully!' : 'Logged in successfully!',
            ),
            backgroundColor: AppColors.primaryEmerald,
          ),
        );
        context.go('/loader?next=/home');
      } else {
        final err = ref.read(authProvider).authError ?? 'Invalid OTP code. Enter 786110';
        setState(() => _errorMessage = err);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isMalayalam = locale.languageCode == 'ml';
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.primaryEmerald,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Emerald Pattern & Mosque Hero (Top 45%)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.45,
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.emeraldGradient,
                  ),
                ),
                // Misty mosque silhouette
                const Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 220,
                  child: MosqueMistyGraphic(height: 220),
                ),
                // Hanging lanterns
                Positioned(
                  top: 40,
                  left: 20,
                  child: Opacity(
                    opacity: 0.4,
                    child: Icon(Icons.flare_outlined, color: AppColors.mintText, size: 28),
                  ),
                ),
                Positioned(
                  top: 36,
                  right: 70,
                  child: Opacity(
                    opacity: 0.4,
                    child: Icon(Icons.nightlight_round, color: AppColors.mintText, size: 22),
                  ),
                ),
                // Glass Back Button & Language Switcher
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GlassBackButton(
                          onPressed: () {
                            if (_otpSent) {
                              setState(() {
                                _otpSent = false;
                                _errorMessage = null;
                              });
                            } else {
                              context.go('/');
                            }
                          },
                        ),
                        // Language switcher pill
                        GestureDetector(
                          onTap: () {
                            ref.read(localeProvider.notifier).toggleLocale();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.glassWhite,
                              borderRadius: AppRadii.pillBorder,
                              border: Border.all(color: AppColors.glassWhiteBorder, width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.language_rounded, size: 14, color: Colors.white),
                                const SizedBox(width: 5),
                                Text(
                                  isMalayalam ? 'English' : 'മലയാളം',
                                  style: AppTextStyles.buttonText(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Title
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConfig.appName,
                        style: AppTextStyles.displayHero(
                          color: Colors.white,
                          fontSize: 26,
                          isMalayalam: isMalayalam,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isRegisterMode
                            ? (isMalayalam ? 'പുതിയ അക്കൗണ്ട് രജിസ്ട്രേഷൻ' : 'Create Member Account')
                            : (isMalayalam ? 'അക്കൗണ്ടിലേക്ക് പ്രവേശിക്കുക' : 'Welcome Back'),
                        style: AppTextStyles.bodyText(
                          color: AppColors.mintText,
                          fontSize: 13,
                          isMalayalam: isMalayalam,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // White Rounded-Top Sheet (Bottom 60%)
          Positioned(
            top: size.height * 0.40,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadii.sheetRadius),
                  topRight: Radius.circular(AppRadii.sheetRadius),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x20000000),
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(AppSpacing.s24, AppSpacing.s16, AppSpacing.s24, AppSpacing.s24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sheet Handle Notch
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: AppRadii.pillBorder,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),

                    // Mode Switcher: Register vs Login
                    if (!_otpSent) ...[
                      Container(
                        height: 42,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurfaceMuted,
                          borderRadius: AppRadii.pillBorder,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  _isRegisterMode = true;
                                  _errorMessage = null;
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: _isRegisterMode ? AppColors.primaryEmerald : Colors.transparent,
                                    borderRadius: AppRadii.pillBorder,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    isMalayalam ? 'രജിസ്റ്റർ ചെയ്യുക' : 'Register',
                                    style: AppTextStyles.buttonText(
                                      color: _isRegisterMode ? Colors.white : AppColors.textSecondary,
                                      fontSize: 12.5,
                                      fontWeight: _isRegisterMode ? FontWeight.w700 : FontWeight.w500,
                                      isMalayalam: isMalayalam,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() {
                                  _isRegisterMode = false;
                                  _errorMessage = null;
                                }),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: !_isRegisterMode ? AppColors.primaryEmerald : Colors.transparent,
                                    borderRadius: AppRadii.pillBorder,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    isMalayalam ? 'ലോഗിൻ' : 'Login',
                                    style: AppTextStyles.buttonText(
                                      color: !_isRegisterMode ? Colors.white : AppColors.textSecondary,
                                      fontSize: 12.5,
                                      fontWeight: !_isRegisterMode ? FontWeight.w700 : FontWeight.w500,
                                      isMalayalam: isMalayalam,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                    ],

                    // Error Message Banner
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFDA4AF)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 16, color: Color(0xFFE11D48)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Color(0xFF9F1239), fontSize: 11.5, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),
                    ],

                    if (!_otpSent) ...[
                      // STEP 1: DETAILS FORM

                      // Name Field (Only in Register Mode)
                      if (_isRegisterMode) ...[
                        Text(
                          isMalayalam ? 'പൂർണ്ണ നാമം (Full Name)' : 'Full Name',
                          style: AppTextStyles.cardTitle(fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        _buildInputField(
                          controller: _nameController,
                          hint: isMalayalam ? 'നിങ്ങളുടെ പേര് നൽകുക' : 'Enter your full name',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: AppSpacing.s12),
                      ],

                      // Phone Field
                      Text(
                        isMalayalam ? 'മൊബൈൽ നമ്പർ (Mobile Number)' : 'Mobile Phone Number',
                        style: AppTextStyles.cardTitle(fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.cardSurfaceMuted,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          children: [
                            // Country Code Chip (+91)
                            Container(
                              margin: const EdgeInsets.all(4),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.cardSurface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '🇮🇳 +91',
                                    style: AppTextStyles.bodyText(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: AppTextStyles.cardTitle(fontSize: 14.5),
                                decoration: InputDecoration(
                                  hintText: '98470 12345',
                                  hintStyle: AppTextStyles.bodyText(color: AppColors.textMuted, fontSize: 13),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s12),

                      // Email Field (Only in Register Mode)
                      if (_isRegisterMode) ...[
                        Text(
                          isMalayalam ? 'ഇമെയിൽ വിലാസം (Email Address)' : 'Email Address',
                          style: AppTextStyles.cardTitle(fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        _buildInputField(
                          controller: _emailController,
                          hint: 'name@example.com',
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: AppSpacing.s16),
                      ] else ...[
                        const SizedBox(height: AppSpacing.s10),
                      ],

                      // Send OTP Button
                      PillButton(
                        label: isMalayalam ? 'ഒ.ടി.പി കോഡ് അയക്കുക' : 'Send Verification OTP',
                        variant: PillButtonVariant.primary,
                        height: 48,
                        isMalayalam: isMalayalam,
                        icon: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                        onPressed: _loading ? null : _handleSendOtp,
                      ),
                    ] else ...[
                      // STEP 2: OTP VERIFICATION

                      // Prompt info & Demo Code Helper Banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.mintMist,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryEmeraldLight.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user_outlined, color: AppColors.primaryEmerald, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'OTP sent to +91 ${_phoneController.text}',
                                    style: AppTextStyles.cardTitle(fontSize: 12.5, color: AppColors.primaryEmerald),
                                  ),
                                  const Text(
                                    'Demo Verification Code: 786110',
                                    style: TextStyle(
                                      color: AppColors.primaryEmeraldLight,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.s20),

                      // 6-box OTP Input
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return Container(
                            width: 44,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.cardSurfaceMuted,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _otpControllers[index].text.isNotEmpty
                                    ? AppColors.primaryEmerald
                                    : AppColors.cardBorder,
                                width: 1.5,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: TextField(
                              controller: _otpControllers[index],
                              focusNode: _otpFocusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryEmerald,
                              ),
                              decoration: const InputDecoration(
                                counterText: '',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 5) {
                                  _otpFocusNodes[index + 1].requestFocus();
                                } else if (value.isEmpty && index > 0) {
                                  _otpFocusNodes[index - 1].requestFocus();
                                }
                              },
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: AppSpacing.s20),

                      // Resend Countdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_resendSeconds > 0)
                            Text(
                              'Resend code in ${_resendSeconds}s',
                              style: AppTextStyles.bodyText(color: AppColors.textMuted, fontSize: 12),
                            )
                          else
                            GestureDetector(
                              onTap: _handleSendOtp,
                              child: Text(
                                'Resend OTP Now',
                                style: AppTextStyles.buttonText(
                                  color: AppColors.primaryEmerald,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.s16),

                      // Verify & Login/Register Button
                      PillButton(
                        label: _isRegisterMode
                            ? (isMalayalam ? 'പരിശോധിച്ച് രജിസ്റ്റർ ചെയ്യുക' : 'Verify & Complete Registration')
                            : (isMalayalam ? 'പരിശോധിച്ച് പ്രവേശിക്കുക' : 'Verify & Login'),
                        variant: PillButtonVariant.primary,
                        height: 48,
                        isMalayalam: isMalayalam,
                        icon: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
                        onPressed: _loading ? null : _handleVerifyOtp,
                      ),

                      const SizedBox(height: AppSpacing.s8),

                      // Change Number
                      Center(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _otpSent = false;
                              _errorMessage = null;
                            });
                          },
                          child: Text(
                            isMalayalam ? 'വിവരങ്ങൾ തിരുത്തുക' : 'Edit details / Change phone',
                            style: AppTextStyles.bodyText(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.s24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: AppTextStyles.cardTitle(fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.bodyText(color: AppColors.textMuted, fontSize: 13),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
