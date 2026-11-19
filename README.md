# Mahal (മഹല്ല്) - Muslim Masjid & Community Mobile App

A production-quality Flutter mobile application built for Kerala's Muslim Mahal and Juma Masjid communities. Designed to be multi-tenant, community-centric, warm, and visually identical to the provided design system.

---

## 📸 Screen Showcase

The visual theme matches the reference design with high fidelity:
- **Splash / Onboarding**: Deep emerald canvas (`#0E3E2E`), intricate pointed mihrab arch contour, layered misty billowing clouds rising around a silhouetted mosque with minarets and grand dome, hanging ornate lanterns at the top corners, crescent moon, and full-width white pill CTA button (`Start Now`).
- **Main Home Screen**: Ultra-clean `#F5F6F8` canvas, circular user avatar with "Assalamualaikum!" in an expressive display serif, Mahal pin location, notification bell with red badge, horizontal story carousel with `LIVE` Friday Khutbah badge, Ramadan Moments feature card with primary emerald action pill, mosque architectural graphic, community post card, and the horizontal ruler-style tick slider.
- **Prayer Times Screen**: Atmospheric sky gradient header with circular frosted glass back button, animated semicircular tick dial with glowing needle handle, large bold time display (`03:55 AM`), sunrise/sunset flanking cards, and an elevated white bottom sheet featuring custom celestial icons (sunrise, midday sun, afternoon sun, twilight sunset, night moon), Mahal congregation (Jama'ath) times, and adhan reminders.
- **Holy Quran & Duas**: Uthmani Arabic script (`Amiri`) with toggleable Malayalam & English translations, line-height tuned to prevent Malayalam glyph clipping, audio playback per ayah, categorized daily supplications, and interactive digital Tasbih.
- **Chanda & Payments**: Monthly contribution (Varisankhya) dues ledger, Razorpay UPI integration, community donation campaigns with goal progress bars, and official downloadable PDF receipts.
- **Committee Admin Console**: Financial health summary, live Jama'ath schedule updater, notice & Janaza publisher, offline cash verification, and CSV reporting.

---

## 🎨 Design Tokens

All design tokens are strictly centralized in `lib/core/theme/` to prevent magic numbers:

### Hex Colors (`AppColors`)
- `primaryEmerald`: `#0E3E2E` (Splash background, brand accents, active navigation pill)
- `primaryEmeraldLight`: `#14523D` (Buttons, action icons, active story borders)
- `primaryEmeraldDark`: `#09281E` (Splash deepest tones and contrast borders)
- `emeraldAccent`: `#10B981` (Indicators, active tick markers, success badges)
- `mintMist`: `#E8F3EE` (Subtle chip backgrounds, avatar placeholders)
- `mintText`: `#B4D3C5` (Secondary text on deep emerald backgrounds)
- `background`: `#F5F6F8` (Canvas background for all main screens)
- `cardSurface`: `#FFFFFF` (Pure white cards with soft diffused elevation)
- `textPrimary`: `#1A202C` (Headings, titles, high contrast)
- `textSecondary`: `#718096` (Body copy, timestamps, locations)
- `skyGradientStart`: `#6CA4C8` & `skyGradientEnd`: `#3A7CA5` (Prayer header sky)
- `goldenSun`: `#F59E0B` & `sunsetCoral`: `#F97316` (Celestial icons)
- `badgeRed`: `#EF4444` (Live broadcast badge)

### Corner Radii (`AppRadii`)
- `radiusPill` (`999.0`): CTA buttons, badges, floating bottom bar, story rings
- `radiusSheet` (`32.0`): Top corners of the prayer timeline sheet
- `radiusCard` (`24.0`): Content cards, hero cards, ruler slider cards
- `radiusInnerImage` (`16.0`): Media thumbnails inside cards
- `radiusButton` (`14.0`): Secondary buttons, dialog actions
- `radiusSmall` (`10.0`): Input fields, filter chips

### Typography (`AppTextStyles`)
- **Display Serif**: `Playfair Display` / `Cinzel` for hero titles and greetings ("Assalamualaikum!")
- **Primary UI Sans**: `Poppins` (Google Fonts)
- **Malayalam**: `Noto Sans Malayalam` / `Manjari` with explicit `height: 1.5 - 1.6` to avoid glyph clipping (ൂ, ൃ, ൈ, ്, ്ര)
- **Arabic**: `Amiri` (authentic Uthmani Quranic script) with `height: 1.8 - 2.1` and `TextDirection.rtl`

---

## ⚙️ Renaming the App

The app's working name is configured in a single constant:
```dart
// lib/app/config.dart
class AppConfig {
  static const String appName = 'Mahal'; // Change here to rename app-wide
  static const String currency = '₹';
  static const String defaultMahalCode = 'EKRL01';
  static const String defaultMahalName = 'Ekarool Juma Masjid Mahal';
}
```

---

## 🌐 Localization (English & മലയാളം)

The app supports English and Malayalam with zero hardcoded strings. Localized using `flutter_localizations` + `intl`:
- English ARB: `lib/l10n/app_en.arb`
- Malayalam ARB: `lib/l10n/app_ml.arb`
- Generated classes: `lib/l10n/app_localizations.dart`

To re-generate after adding keys:
```bash
flutter gen-l10n
```

---

## 🔒 Firebase Backend Setup

### 1. Project Creation
1. Go to [Firebase Console](https://console.firebase.google.com/) and create a project named `mahal-community`.
2. Enable **Authentication** -> **Phone** provider.
3. Enable **Cloud Firestore** in `asia-south1` (Mumbai, India for lowest latency in Kerala).
4. Enable **Cloud Storage** for community post media and audio files.
5. Enable **Cloud Messaging** for committee push notifications.

### 2. Firestore Security Rules
Production-grade multi-tenant security rules have been written in [`firestore.rules`](file:///c:/Users/mobil/Desktop/ekarool%20mahal/firestore.rules).
To deploy:
```bash
firebase deploy --only firestore:rules
```

**Key Security Guarantees:**
- Multi-tenant tenant isolation: `/mahals/{mahalId}/...`
- Role-based gates: Members can only access their own chanda records and read public notices. Committee admins (`role == 'committeeAdmin'`) can publish notices, alter Jama'ath times, and mark cash payments.
- Field-level validation on currency amounts, timestamps, and non-empty strings.

---

## 💳 Razorpay & UPI Payments Setup

1. Sign up on [Razorpay Dashboard](https://dashboard.razorpay.com/) and complete KYC.
2. Generate **Key ID** and **Key Secret** in Test Mode.
3. Update the Razorpay initialization inside `lib/features/payments/presentation/payments_screen.dart`:
```dart
final razorpayOptions = {
  'key': 'rzp_test_YOUR_KEY_HERE',
  'amount': (record.amount * 100).toInt(),
  'name': mahal.name,
  'description': 'Monthly Chanda (${record.monthNameEn})',
  'prefill': {
    'contact': user?.phone,
    'name': user?.name,
  },
  'theme': {
    'color': '#0E3E2E',
  }
};
```
4. Upon successful payment verification, the app generates an official downloadable PDF receipt signed by the General Secretary and Treasurer using `ReceiptPdfService`.

---

## 📁 Project Architecture

```
lib/
├── app/
│   ├── app.dart                   # MaterialApp.router with l10n, theme, routes
│   ├── config.dart                # AppConfig (appName, currency, defaults)
│   └── routes.dart                # go_router configuration with shell navigation
├── core/
│   ├── services/
│   │   ├── prayer_service.dart    # Adhan calculation + Jama'ath overrides
│   │   └── receipt_pdf_service.dart # Official PDF receipt generator
│   ├── theme/
│   │   ├── app_colors.dart        # Hex color tokens
│   │   ├── app_radii.dart         # BorderRadius tokens
│   │   ├── app_shadows.dart       # Diffused elevation tokens
│   │   ├── app_spacing.dart       # 8pt scale tokens
│   │   ├── app_text_styles.dart   # Poppins + Display + Malayalam + Arabic
│   │   └── app_theme.dart         # ThemeData
│   └── widgets/
│       ├── app_card.dart          # 24px pure white card
│       ├── app_loader.dart        # Crescent moon & rotating ring branded loader
│       ├── celestial_prayer_icon.dart # Custom painted sun & moon prayer icons
│       ├── custom_nav_bar.dart    # Floating rounded pill bar with active emerald pill
│       ├── glass_back_button.dart # Frosted glass back button
│       ├── mosque_misty_graphic.dart # Arched mihrab, hanging lanterns & misty clouds
│       ├── pill_button.dart       # Animated pill action button
│       ├── prayer_row.dart        # Timeline row with adhan reminder toggle
│       ├── ruler_slider.dart      # Horizontal ruler-style tick slider
│       ├── section_header.dart    # Clean section header
│       ├── shimmer_skeleton.dart  # Soft skeleton loaders
│       ├── story_avatar.dart      # Story ring with LIVE badge
│       └── tick_dial.dart         # Semicircular tick dial with glowing needle
├── features/
│   ├── admin/                     # Financial metrics, jama'ath time updater, notice publisher, CSV export
│   ├── auth/                      # Splash, language selector, OTP login, Mahal code/QR join
│   ├── community/                 # Notices, Janaza announcements, Khutbah topics, Committee directory
│   ├── home/                      # Dashboard, story carousel, hero card, ruler habit slider
│   ├── payments/                  # Monthly chanda dues, donation campaigns, UPI, PDF receipts
│   ├── prayer/                    # Prayer dial, timeline, Qibla compass
│   ├── profile/                   # Member profile, language switcher, role switch, mahal switch
│   ├── quran/                     # Surah index, reader (Uthmani + Malayalam + Audio), daily duas, tasbih
│   └── tracking/                  # Recitation studio with audio waveform, ruler goals
└── l10n/
    ├── app_en.arb                 # English ARB translations
    └── app_ml.arb                 # Malayalam ARB translations
```

---

## 🧪 Testing & Verification

Run tests:
```bash
flutter test
```

Generate screenshots:
```bash
flutter test test/screenshot_test.dart
```

Run static analysis:
```bash
flutter analyze
```
Result: **No issues found!**
