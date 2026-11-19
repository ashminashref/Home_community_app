import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_nav_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../community/presentation/community_screen.dart';
import '../../prayer/presentation/prayer_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../quran/presentation/quran_screen.dart';
import 'home_screen.dart';

class MainShellLayout extends ConsumerStatefulWidget {
  const MainShellLayout({super.key});

  @override
  ConsumerState<MainShellLayout> createState() => _MainShellLayoutState();
}

class _MainShellLayoutState extends ConsumerState<MainShellLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    PrayerScreen(),
    QuranScreen(),
    CommunityScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);
    final isMalayalam = locale.languageCode == 'ml';

    final navItems = [
      CustomNavBarItem(
        icon: Icons.mosque_outlined,
        label: isMalayalam ? 'ഹോം' : 'Home',
      ),
      CustomNavBarItem(
        icon: Icons.access_time_rounded,
        label: l10n.prayerTimes,
      ),
      CustomNavBarItem(
        icon: Icons.menu_book_rounded,
        label: isMalayalam ? 'ഖുർആൻ' : 'Quran',
      ),
      CustomNavBarItem(
        icon: Icons.groups_outlined,
        label: l10n.community,
      ),
      CustomNavBarItem(
        icon: Icons.person_outline_rounded,
        label: l10n.profile,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Current active screen
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),

          // Floating rounded white pill navigation bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: CustomNavBar(
                currentIndex: _currentIndex,
                items: navItems,
                isMalayalam: isMalayalam,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
