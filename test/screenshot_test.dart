import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/src/google_fonts_base.dart' as gfonts;
import 'package:http/http.dart' as http;
import 'package:mahal/core/theme/app_theme.dart';
import 'package:mahal/core/widgets/animated_loader_screen.dart';
import 'package:mahal/core/widgets/shimmer_skeleton.dart';
import 'package:mahal/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:mahal/features/auth/presentation/login_screen.dart';
import 'package:mahal/features/auth/presentation/splash_screen.dart';
import 'package:mahal/features/community/presentation/community_screen.dart';
import 'package:mahal/features/home/presentation/main_shell_layout.dart';
import 'package:mahal/features/payments/presentation/payments_screen.dart';
import 'package:mahal/features/payments/presentation/zakat_calculator_screen.dart';
import 'package:mahal/features/prayer/presentation/prayer_screen.dart';
import 'package:mahal/features/prayer/presentation/qibla_compass_screen.dart';
import 'package:mahal/features/certificates/domain/certificate_models.dart';
import 'package:mahal/features/certificates/presentation/apply_certificate_screen.dart';
import 'package:mahal/features/certificates/presentation/certificate_portal_screen.dart';
import 'package:mahal/features/certificates/presentation/digital_certificate_view_screen.dart';
import 'package:mahal/features/profile/presentation/profile_screen.dart';
import 'package:mahal/features/quran/data/quran_repository.dart';
import 'package:mahal/features/quran/presentation/duas_screen.dart';
import 'package:mahal/features/quran/presentation/quran_screen.dart';
import 'package:mahal/features/quran/presentation/surah_reader_screen.dart';
import 'package:mahal/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1x1 transparent PNG
final List<int> _transparentPng = [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];

class _SilentFontClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(
      Stream.value(Uint8List.fromList([0, 1, 0, 0, 0, 0, 0, 0])),
      200,
      request: request,
    );
  }
}

class _MockHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpRequest();

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async => _MockHttpRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpRequest implements HttpClientRequest {
  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async => _MockHttpResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpResponse extends StreamView<List<int>> implements HttpClientResponse {
  _MockHttpResponse() : super(const Stream<List<int>>.empty());

  @override
  int get statusCode => 404;

  @override
  int get contentLength => 0;

  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) => _MockHttpClient();
}

Future<void> _captureScreen({
  required WidgetTester tester,
  required Widget widget,
  required String filename,
}) async {
  final repaintKey = GlobalKey();

  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: RepaintBoundary(
            key: repaintKey,
            child: widget,
          ),
        ),
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  tester.takeException();

  await tester.runAsync(() async {
    final boundary = repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final outDir = Directory('screenshots');
    if (!outDir.existsSync()) {
      outDir.createSync(recursive: true);
    }

    final file = File('screenshots/$filename');
    await file.writeAsBytes(bytes);
  });
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    gfonts.httpClient = _SilentFontClient();
    SharedPreferences.setMockInitialValues({});
    HttpOverrides.global = _TestHttpOverrides();
    ui.PlatformDispatcher.instance.onError = (error, stack) {
      if (error.toString().contains('google_fonts') ||
          error.toString().contains('font') ||
          error.toString().contains('Failed to load font')) {
        return true;
      }
      return false;
    };
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('google_fonts') ||
          details.exception.toString().contains('font') ||
          details.library == 'services library') {
        return; // Suppress headless font loader fallback warnings
      }
      FlutterError.presentError(details);
    };
  });

  testWidgets('Capture Splash Screen', (WidgetTester tester) async {
    await _captureScreen(
      tester: tester,
      widget: const SplashScreen(),
      filename: 'splash_screen.png',
    );
  });

  testWidgets('Capture Home Screen', (WidgetTester tester) async {
    await _captureScreen(
      tester: tester,
      widget: const MainShellLayout(),
      filename: 'home_screen.png',
    );
  });

  testWidgets('Capture Prayer Screen', (WidgetTester tester) async {
    await _captureScreen(
      tester: tester,
      widget: const PrayerScreen(),
      filename: 'prayer_screen.png',
    );
  });

  testWidgets('Capture Quran Screen', (WidgetTester tester) async {
    await _captureScreen(
      tester: tester,
      widget: const QuranScreen(),
      filename: 'quran_screen.png',
    );
  });

  testWidgets('Capture Surah Reader Screen', (WidgetTester tester) async {
    await _captureScreen(
      tester: tester,
      widget: SurahReaderScreen(surah: QuranRepository.sampleSurahs.first),
      filename: 'surah_reader_screen.png',
    );
  });

  testWidgets('Capture Duas Screen', (WidgetTester tester) async {
    await _captureScreen(
      tester: tester,
      widget: const DuasScreen(),
      filename: 'duas_screen.png',
    );
  });

  testWidgets('Capture Payments Screen', (WidgetTester tester) async {
    await _captureScreen(
      tester: tester,
      widget: const PaymentsScreen(),
      filename: 'payments_screen.png',
    );
  });

  testWidgets('Capture Profile Screen', (WidgetTester tester) async {
    await _captureScreen(
      tester: tester,
      widget: const ProfileScreen(),
      filename: 'profile_screen.png',
    );
  });

  testWidgets('Capture Login Screen', (WidgetTester tester) async {
    await _captureScreen(
      tester: tester,
      widget: const LoginScreen(),
      filename: 'login_screen.png',
    );
  });

  testWidgets('Capture Admin Screen', (WidgetTester tester) async {
    await _captureScreen(
      tester: tester,
      widget: const AdminDashboardScreen(),
      filename: 'admin_screen.png',
    );
  });

  testWidgets('Capture Community Screen', (WidgetTester tester) async {
    await _captureScreen(
      tester: tester,
      widget: const CommunityScreen(),
      filename: 'community_screen.png',
    );
  });

  testWidgets('Capture Qibla Compass Screen', (WidgetTester tester) async {
    await _captureScreen(
      tester: tester,
      widget: const QiblaCompassScreen(),
      filename: 'qibla_compass_screen.png',
    );
  });

  testWidgets('Capture Zakat Calculator Screen', (WidgetTester tester) async {
    await _captureScreen(
      tester: tester,
      widget: const ZakatCalculatorScreen(),
      filename: 'zakat_calculator_screen.png',
    );
  });

  testWidgets('Capture Certificate Portal Screen', (WidgetTester tester) async {
    await _captureScreen(
      tester: tester,
      widget: const CertificatePortalScreen(),
      filename: 'certificate_portal_screen.png',
    );
  });

  testWidgets('Capture Apply Certificate Screen', (WidgetTester tester) async {
    await _captureScreen(
      tester: tester,
      widget: const ApplyCertificateScreen(),
      filename: 'apply_certificate_screen.png',
    );
  });

  testWidgets('Capture Digital Certificate View Screen', (WidgetTester tester) async {
    final sampleCert = CertificateRequestModel(
      id: 'CERT-2026-081',
      userId: 'usr_001',
      applicantName: 'Abdul Rahman',
      applicantPhone: '+91 98470 12345',
      applicantEmail: 'abdul.rahman@gmail.com',
      type: CertificateType.marriage,
      primaryPersonName: 'Abdul Rahman (Groom)',
      secondaryPersonName: 'Fathima Suhara (Bride)',
      eventDate: '12 January 2026',
      placeOfEvent: 'Ekarool Central Juma Masjid',
      documentFileName: 'nikkah_register_copy.pdf',
      documentFileSize: '1.8 MB',
      status: CertificateStatus.approved,
      appliedAt: DateTime.now().subtract(const Duration(days: 45)),
      approvedAt: DateTime.now().subtract(const Duration(days: 43)),
      mahalRegistrationNo: 'EKRL/NIKKAH/2026/014',
      remarks: 'Verified against Mahal Nikkah Register Vol IV, Page 88.',
    );

    await _captureScreen(
      tester: tester,
      widget: DigitalCertificateViewScreen(certificate: sampleCert),
      filename: 'digital_certificate_view_screen.png',
    );
  });

  testWidgets('Capture Animated Loader Screen', (WidgetTester tester) async {
    await _captureScreen(
      tester: tester,
      widget: const AnimatedLoaderScreen(
        duration: Duration(seconds: 5),
      ),
      filename: 'animated_loader_screen.png',
    );
  });

  testWidgets('Capture Shimmer Loading Fallback Screen', (WidgetTester tester) async {
    await _captureScreen(
      tester: tester,
      widget: Scaffold(
        backgroundColor: const Color(0xFFF4F5F7),
        body: SafeArea(
          child: ShimmerSkeleton.homeScreen(),
        ),
      ),
      filename: 'shimmer_loading_fallback.png',
    );
  });
}
