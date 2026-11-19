import 'package:go_router/go_router.dart';
import '../core/widgets/animated_loader_screen.dart';
import '../features/admin/presentation/admin_dashboard_screen.dart';
import '../features/auth/presentation/join_mahal_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/certificates/presentation/apply_certificate_screen.dart';
import '../features/certificates/presentation/certificate_portal_screen.dart';
import '../features/home/presentation/main_shell_layout.dart';
import '../features/payments/presentation/payments_screen.dart';
import '../features/payments/presentation/zakat_calculator_screen.dart';
import '../features/prayer/presentation/prayer_screen.dart';
import '../features/prayer/presentation/qibla_compass_screen.dart';
import '../features/quran/presentation/duas_screen.dart';
import '../features/quran/presentation/quran_screen.dart';
import '../features/tracking/presentation/recitation_studio_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/loader',
      builder: (context, state) {
        final next = state.uri.queryParameters['next'] ?? '/home';
        return AnimatedLoaderScreen(
          duration: const Duration(milliseconds: 2200),
          onCompleted: () => context.go(next),
        );
      },
    ),
    GoRoute(
      path: '/join',
      builder: (context, state) => const JoinMahalScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainShellLayout(),
    ),
    GoRoute(
      path: '/prayer',
      builder: (context, state) => const PrayerScreen(),
    ),
    GoRoute(
      path: '/qibla',
      builder: (context, state) => const QiblaCompassScreen(),
    ),
    GoRoute(
      path: '/quran',
      builder: (context, state) => const QuranScreen(),
    ),
    GoRoute(
      path: '/duas',
      builder: (context, state) => const DuasScreen(),
    ),
    GoRoute(
      path: '/payments',
      builder: (context, state) => const PaymentsScreen(),
    ),
    GoRoute(
      path: '/zakat',
      builder: (context, state) => const ZakatCalculatorScreen(),
    ),
    GoRoute(
      path: '/certificates',
      builder: (context, state) => const CertificatePortalScreen(),
    ),
    GoRoute(
      path: '/certificates/apply',
      builder: (context, state) => const ApplyCertificateScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/recitation',
      builder: (context, state) => const RecitationStudioScreen(),
    ),
  ],
);
