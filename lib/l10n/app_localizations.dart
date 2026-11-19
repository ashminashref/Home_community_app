import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ml.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ml'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Mahal'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Stay Connected with Mahal'**
  String get tagline;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Never miss a prayer or community update. Accurate prayer times, chanda payments and mahal services in one place.'**
  String get splashSubtitle;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get startNow;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an Account?'**
  String get alreadyHaveAccount;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @malayalam.
  ///
  /// In en, this message translates to:
  /// **'മലയാളം'**
  String get malayalam;

  /// No description provided for @joinMahal.
  ///
  /// In en, this message translates to:
  /// **'Join Mahal'**
  String get joinMahal;

  /// No description provided for @enterMahalCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Mahal Code'**
  String get enterMahalCode;

  /// No description provided for @mahalCodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. EKRL01'**
  String get mahalCodeHint;

  /// No description provided for @scanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQr;

  /// No description provided for @enterValidCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid Mahal code'**
  String get enterValidCode;

  /// No description provided for @joinButton.
  ///
  /// In en, this message translates to:
  /// **'Join Community'**
  String get joinButton;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number to receive an OTP'**
  String get loginSubtitle;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'98765 43210'**
  String get phoneHint;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Get OTP'**
  String get sendOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit OTP sent to'**
  String get enterOtp;

  /// No description provided for @verifyAndProceed.
  ///
  /// In en, this message translates to:
  /// **'Verify & Continue'**
  String get verifyAndProceed;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Assalamualaikum'**
  String get greeting;

  /// No description provided for @defaultLocation.
  ///
  /// In en, this message translates to:
  /// **'Kozhikode, Kerala'**
  String get defaultLocation;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @ramadanMoments.
  ///
  /// In en, this message translates to:
  /// **'Ramadan Moments'**
  String get ramadanMoments;

  /// No description provided for @ramadanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Embrace faith, patience, gratitude, and spiritual growth daily.'**
  String get ramadanSubtitle;

  /// No description provided for @ramadanSpecial.
  ///
  /// In en, this message translates to:
  /// **'Ramadan Special'**
  String get ramadanSpecial;

  /// No description provided for @payChanda.
  ///
  /// In en, this message translates to:
  /// **'Pay Chanda'**
  String get payChanda;

  /// No description provided for @donate.
  ///
  /// In en, this message translates to:
  /// **'Donate'**
  String get donate;

  /// No description provided for @quran.
  ///
  /// In en, this message translates to:
  /// **'Holy Quran'**
  String get quran;

  /// No description provided for @duas.
  ///
  /// In en, this message translates to:
  /// **'Daily Duas'**
  String get duas;

  /// No description provided for @doYouFastToday.
  ///
  /// In en, this message translates to:
  /// **'Do You Fast Today?'**
  String get doYouFastToday;

  /// No description provided for @fastingHabitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Build a spiritual habit with daily tracking'**
  String get fastingHabitSubtitle;

  /// No description provided for @prayerTimes.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayerTimes;

  /// No description provided for @nextPrayer.
  ///
  /// In en, this message translates to:
  /// **'Next Prayer'**
  String get nextPrayer;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @sunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// No description provided for @dhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// No description provided for @iftar.
  ///
  /// In en, this message translates to:
  /// **'Iftar'**
  String get iftar;

  /// No description provided for @jamaath.
  ///
  /// In en, this message translates to:
  /// **'Jama\'ath'**
  String get jamaath;

  /// No description provided for @fajrTime.
  ///
  /// In en, this message translates to:
  /// **'Fajr Time'**
  String get fajrTime;

  /// No description provided for @qiblaDirection.
  ///
  /// In en, this message translates to:
  /// **'Qibla Compass'**
  String get qiblaDirection;

  /// No description provided for @calculationMethod.
  ///
  /// In en, this message translates to:
  /// **'Calculation Method'**
  String get calculationMethod;

  /// No description provided for @monthlyContribution.
  ///
  /// In en, this message translates to:
  /// **'Monthly Contribution (Chanda)'**
  String get monthlyContribution;

  /// No description provided for @varisankhya.
  ///
  /// In en, this message translates to:
  /// **'Varisankhya'**
  String get varisankhya;

  /// No description provided for @dueThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Due this month'**
  String get dueThisMonth;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @viewReceipt.
  ///
  /// In en, this message translates to:
  /// **'View Receipt'**
  String get viewReceipt;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get paymentHistory;

  /// No description provided for @donationCampaigns.
  ///
  /// In en, this message translates to:
  /// **'Donation Campaigns'**
  String get donationCampaigns;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @raised.
  ///
  /// In en, this message translates to:
  /// **'Raised'**
  String get raised;

  /// No description provided for @anonymousDonation.
  ///
  /// In en, this message translates to:
  /// **'Donate anonymously'**
  String get anonymousDonation;

  /// No description provided for @customAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter custom amount'**
  String get customAmount;

  /// No description provided for @payViaUpi.
  ///
  /// In en, this message translates to:
  /// **'Pay via UPI'**
  String get payViaUpi;

  /// No description provided for @community.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// No description provided for @notices.
  ///
  /// In en, this message translates to:
  /// **'Notices & Announcements'**
  String get notices;

  /// No description provided for @janazaNotices.
  ///
  /// In en, this message translates to:
  /// **'Janaza Announcements'**
  String get janazaNotices;

  /// No description provided for @fridayKhutbah.
  ///
  /// In en, this message translates to:
  /// **'Friday Khutbah'**
  String get fridayKhutbah;

  /// No description provided for @upcomingEvents.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Events'**
  String get upcomingEvents;

  /// No description provided for @committee.
  ///
  /// In en, this message translates to:
  /// **'Committee Members'**
  String get committee;

  /// No description provided for @contactCommittee.
  ///
  /// In en, this message translates to:
  /// **'Contact Committee'**
  String get contactCommittee;

  /// No description provided for @recordRecitation.
  ///
  /// In en, this message translates to:
  /// **'Recitation Studio'**
  String get recordRecitation;

  /// No description provided for @startRecording.
  ///
  /// In en, this message translates to:
  /// **'Tap to Record'**
  String get startRecording;

  /// No description provided for @stopRecording.
  ///
  /// In en, this message translates to:
  /// **'Stop Recording'**
  String get stopRecording;

  /// No description provided for @playback.
  ///
  /// In en, this message translates to:
  /// **'Play Recitation'**
  String get playback;

  /// No description provided for @dailyRecitationGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Quran Goal'**
  String get dailyRecitationGoal;

  /// No description provided for @pages.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get pages;

  /// No description provided for @dhikrCounter.
  ///
  /// In en, this message translates to:
  /// **'Digital Tasbih'**
  String get dhikrCounter;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @count.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminPanel;

  /// No description provided for @publishNotice.
  ///
  /// In en, this message translates to:
  /// **'Publish Notice'**
  String get publishNotice;

  /// No description provided for @updateJamaath.
  ///
  /// In en, this message translates to:
  /// **'Update Jama\'ath Times'**
  String get updateJamaath;

  /// No description provided for @collectionSummary.
  ///
  /// In en, this message translates to:
  /// **'Collection Summary'**
  String get collectionSummary;

  /// No description provided for @markOfflinePayment.
  ///
  /// In en, this message translates to:
  /// **'Record Cash Payment'**
  String get markOfflinePayment;

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export Report (CSV)'**
  String get exportCsv;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @switchMahal.
  ///
  /// In en, this message translates to:
  /// **'Switch Mahal'**
  String get switchMahal;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search Surah, Dua or Notice'**
  String get search;

  /// No description provided for @surah.
  ///
  /// In en, this message translates to:
  /// **'Surah'**
  String get surah;

  /// No description provided for @juz.
  ///
  /// In en, this message translates to:
  /// **'Juz'**
  String get juz;

  /// No description provided for @ayah.
  ///
  /// In en, this message translates to:
  /// **'Ayah'**
  String get ayah;

  /// No description provided for @translation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translation;

  /// No description provided for @audioRecitation.
  ///
  /// In en, this message translates to:
  /// **'Recitation Audio'**
  String get audioRecitation;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @downloadReceipt.
  ///
  /// In en, this message translates to:
  /// **'Download Receipt (PDF)'**
  String get downloadReceipt;

  /// No description provided for @committeePresident.
  ///
  /// In en, this message translates to:
  /// **'President'**
  String get committeePresident;

  /// No description provided for @committeeSecretary.
  ///
  /// In en, this message translates to:
  /// **'General Secretary'**
  String get committeeSecretary;

  /// No description provided for @treasurer.
  ///
  /// In en, this message translates to:
  /// **'Treasurer'**
  String get treasurer;

  /// No description provided for @khatib.
  ///
  /// In en, this message translates to:
  /// **'Chief Imam & Khatib'**
  String get khatib;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ml'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ml':
      return AppLocalizationsMl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
