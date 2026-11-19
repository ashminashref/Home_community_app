import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/config.dart';
import '../domain/user_model.dart';

// Locale Provider
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  static const _key = 'selected_locale';

  LocaleNotifier() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final langCode = prefs.getString(_key);
      if (langCode != null) {
        state = Locale(langCode);
      }
    } catch (_) {}
  }

  Future<void> setLocale(String languageCode) async {
    state = Locale(languageCode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, languageCode);
    } catch (_) {}
  }

  void toggleLocale() {
    if (state.languageCode == 'en') {
      setLocale('ml');
    } else {
      setLocale('en');
    }
  }
}

// Current User & Mahal State
class AuthState {
  final UserModel? user;
  final MahalModel currentMahal;
  final bool isAuthenticated;
  final bool isOnboarded;
  final String? activeOtpCode;
  final String? pendingOtpPhone;
  final String? authError;
  final bool isLoading;

  const AuthState({
    this.user,
    required this.currentMahal,
    this.isAuthenticated = true,
    this.isOnboarded = true,
    this.activeOtpCode,
    this.pendingOtpPhone,
    this.authError,
    this.isLoading = false,
  });

  AuthState copyWith({
    UserModel? user,
    MahalModel? currentMahal,
    bool? isAuthenticated,
    bool? isOnboarded,
    String? activeOtpCode,
    String? pendingOtpPhone,
    String? authError,
    bool? isLoading,
  }) {
    return AuthState(
      user: user ?? this.user,
      currentMahal: currentMahal ?? this.currentMahal,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      activeOtpCode: activeOtpCode ?? this.activeOtpCode,
      pendingOtpPhone: pendingOtpPhone ?? this.pendingOtpPhone,
      authError: authError,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  static const _userStorageKey = 'mahal_persisted_user_session';
  static const _isAuthKey = 'mahal_is_authenticated';

  static const _defaultMahal = MahalModel(
    id: 'mhl_ekrl_01',
    name: AppConfig.defaultMahalName,
    code: AppConfig.defaultMahalCode,
    district: 'Kozhikode',
    location: AppConfig.defaultLocation,
    president: 'K.P. Ahmad Haji',
    secretary: 'C.V. Musthafa Master',
    phone: '+91 495 2456789',
    jamaathOverrides: {
      'fajr': '05:15 AM',
      'dhuhr': '01:30 PM',
      'asr': '04:45 PM',
      'maghrib': '06:30 PM',
      'isha': '08:15 PM',
    },
  );

  AuthNotifier()
      : super(
          const AuthState(
            user: UserModel(
              id: 'usr_001',
              name: 'Abdul Rahman',
              phone: '+91 98470 12345',
              email: 'abdul.rahman@gmail.com',
              role: UserRole.committeeAdmin,
              houseName: 'Baitul Noor',
              familyId: 'EK-FAM-142',
              avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
            ),
            currentMahal: _defaultMahal,
            isAuthenticated: true,
            isOnboarded: true,
          ),
        ) {
    _loadPersistedUser();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 650));
    await _loadPersistedUser();
    state = state.copyWith(isLoading: false);
  }

  Future<void> _loadPersistedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userStorageKey);
      final isAuth = prefs.getBool(_isAuthKey);

      if (userJson != null) {
        final loadedUser = UserModel.fromJson(userJson);
        state = state.copyWith(
          user: loadedUser,
          isAuthenticated: isAuth ?? true,
        );
      }
    } catch (_) {}
  }

  Future<void> _persistUserSession(UserModel user, bool isAuth) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userStorageKey, user.toJson());
      await prefs.setBool(_isAuthKey, isAuth);
    } catch (_) {}
  }

  // Generate & Send OTP to phone number
  String sendOtp(String rawPhone) {
    final cleanPhone = rawPhone.replaceAll(RegExp(r'\s+'), '');
    const demoOtp = '786110'; // Standard secure predictable test verification OTP

    state = state.copyWith(
      activeOtpCode: demoOtp,
      pendingOtpPhone: cleanPhone,
      authError: null,
    );

    return demoOtp;
  }

  // Register with Name, Phone, Email - NO MAHAL ID REQUIRED
  bool verifyOtpAndRegister({
    required String name,
    required String phone,
    required String email,
    required String otp,
    String? houseName,
  }) {
    final trimmedName = name.trim();
    final trimmedEmail = email.trim();
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final cleanOtp = otp.replaceAll(RegExp(r'\s+'), '');

    if (trimmedName.isEmpty) {
      state = state.copyWith(authError: 'Please enter your full name');
      return false;
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(trimmedEmail)) {
      state = state.copyWith(authError: 'Please enter a valid email address');
      return false;
    }

    final phoneDigits = cleanPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (phoneDigits.length < 10) {
      state = state.copyWith(authError: 'Please enter a valid 10-digit mobile number');
      return false;
    }

    // Verify OTP code (matches standard demo 786110 or activeOtpCode)
    if (cleanOtp != '786110' && cleanOtp != state.activeOtpCode) {
      state = state.copyWith(authError: 'Invalid verification code. Enter 786110');
      return false;
    }

    final newUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: trimmedName,
      phone: cleanPhone.startsWith('+') ? cleanPhone : '+91 $cleanPhone',
      email: trimmedEmail,
      role: UserRole.member,
      houseName: (houseName != null && houseName.trim().isNotEmpty) ? houseName.trim() : 'Mahal Residence',
      familyId: 'EK-${phoneDigits.substring(phoneDigits.length - 4)}',
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      user: newUser,
      isAuthenticated: true,
      isOnboarded: true,
      activeOtpCode: null,
      pendingOtpPhone: null,
      authError: null,
    );

    _persistUserSession(newUser, true);
    return true;
  }

  // Login with Phone & OTP - NO MAHAL ID REQUIRED
  bool verifyOtpAndLogin({
    required String phone,
    required String otp,
  }) {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final cleanOtp = otp.replaceAll(RegExp(r'\s+'), '');

    final phoneDigits = cleanPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (phoneDigits.length < 10) {
      state = state.copyWith(authError: 'Please enter a valid 10-digit mobile number');
      return false;
    }

    if (cleanOtp != '786110' && cleanOtp != state.activeOtpCode) {
      state = state.copyWith(authError: 'Invalid verification code. Enter 786110');
      return false;
    }

    final existingUser = state.user;
    final loggedInUser = existingUser != null
        ? existingUser.copyWith(
            phone: cleanPhone.startsWith('+') ? cleanPhone : '+91 $cleanPhone',
          )
        : UserModel(
            id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
            name: 'Abdul Rahman',
            phone: cleanPhone.startsWith('+') ? cleanPhone : '+91 $cleanPhone',
            email: 'abdul.rahman@gmail.com',
            role: UserRole.committeeAdmin,
            houseName: 'Baitul Noor',
            familyId: 'EK-${phoneDigits.substring(phoneDigits.length - 4)}',
            createdAt: DateTime.now(),
          );

    state = state.copyWith(
      user: loggedInUser,
      isAuthenticated: true,
      isOnboarded: true,
      activeOtpCode: null,
      pendingOtpPhone: null,
      authError: null,
    );

    _persistUserSession(loggedInUser, true);
    return true;
  }

  // Logout & clear persisted credentials
  Future<void> logout() async {
    state = state.copyWith(
      isAuthenticated: false,
      authError: null,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isAuthKey, false);
    } catch (_) {}
  }

  // Update profile and persist
  Future<void> updateProfile({
    String? name,
    String? phone,
    String? email,
    String? houseName,
  }) async {
    if (state.user == null) return;
    final updated = state.user!.copyWith(
      name: name,
      phone: phone,
      email: email,
      houseName: houseName,
    );

    state = state.copyWith(user: updated);
    _persistUserSession(updated, state.isAuthenticated);
  }

  void toggleRole() {
    if (state.user == null) return;
    final newRole = state.user!.role == UserRole.committeeAdmin
        ? UserRole.member
        : UserRole.committeeAdmin;

    final updated = state.user!.copyWith(role: newRole);
    state = state.copyWith(user: updated);
    _persistUserSession(updated, state.isAuthenticated);
  }

  void updateJamaathTime(String prayerKey, String newTime) {
    final updatedMap = Map<String, String>.from(state.currentMahal.jamaathOverrides);
    updatedMap[prayerKey] = newTime;

    state = state.copyWith(
      currentMahal: MahalModel(
        id: state.currentMahal.id,
        name: state.currentMahal.name,
        code: state.currentMahal.code,
        district: state.currentMahal.district,
        location: state.currentMahal.location,
        president: state.currentMahal.president,
        secretary: state.currentMahal.secretary,
        phone: state.currentMahal.phone,
        jamaathOverrides: updatedMap,
      ),
    );
  }

  void joinMahalWithCode(String code) {
    state = state.copyWith(
      currentMahal: MahalModel(
        id: 'mhl_ekrl_01',
        name: code.toUpperCase() == 'EKRL01'
            ? 'Ekarool Juma Masjid Mahal'
            : '$code Community Mahal',
        code: code.toUpperCase(),
        district: 'Kozhikode',
        location: 'Kerala, India',
        president: 'K.P. Ahmad Haji',
        secretary: 'C.V. Musthafa Master',
        phone: '+91 495 2456789',
        jamaathOverrides: const {
          'fajr': '05:15 AM',
          'dhuhr': '01:30 PM',
          'asr': '04:45 PM',
          'maghrib': '06:30 PM',
          'isha': '08:15 PM',
        },
      ),
      isOnboarded: true,
    );
  }
}
