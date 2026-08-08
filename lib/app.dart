import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'constants/app_theme.dart';
import 'providers/app_providers.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/onboarding/auth_screen.dart';
import 'screens/onboarding/otp_screen.dart';
import 'screens/onboarding/location_screen.dart';
import 'screens/onboarding/age_screen.dart';
import 'screens/onboarding/marital_status_screen.dart';
import 'screens/onboarding/last_period_screen.dart';
import 'screens/onboarding/cycle_length_screen.dart';
import 'screens/onboarding/notification_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/calendar/history_screen.dart';
import 'screens/log/symptom_log_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/settings_screen.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

class GirlsApp extends ConsumerWidget {
  const GirlsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(notificationSyncProvider);
    final isDarkMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Girls',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('bn'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: ref.watch(routerProvider),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
      GoRoute(
        path: '/otp',
        builder: (_, state) => OtpScreen(
          mobileNumber: state.extra as String? ?? '',
        ),
      ),
      GoRoute(path: '/onboarding/location', builder: (_, __) => const LocationScreen()),
      GoRoute(path: '/onboarding/age', builder: (_, __) => const AgeScreen()),
      GoRoute(path: '/onboarding/marital', builder: (_, __) => const MaritalStatusScreen()),
      GoRoute(path: '/onboarding/last-period', builder: (_, __) => const LastPeriodScreen()),
      GoRoute(path: '/onboarding/cycle-length', builder: (_, __) => const CycleLengthScreen()),
      GoRoute(path: '/onboarding/notifications', builder: (_, __) => const NotificationScreen()),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/calendar', builder: (_, __) => const CalendarScreen()),
          GoRoute(path: '/history', builder: (_, __) => const HistoryScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(path: '/log-symptoms', builder: (_, __) => const SymptomLogScreen()),
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
    ],
  );
});

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  final List<String> _routes = ['/home', '/calendar', '/history', '/profile'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_rounded, label: context.l10n.navHome, index: 0, currentIndex: _currentIndex, onTap: _onTap),
                _NavItem(icon: Icons.calendar_month_rounded, label: context.l10n.navCalendar, index: 1, currentIndex: _currentIndex, onTap: _onTap),
                _NavItem(icon: Icons.bar_chart_rounded, label: context.l10n.navHistory, index: 2, currentIndex: _currentIndex, onTap: _onTap),
                _NavItem(icon: Icons.person_rounded, label: context.l10n.navProfile, index: 3, currentIndex: _currentIndex, onTap: _onTap),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(int index) {
    setState(() => _currentIndex = index);
    context.go(_routes[index]);
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = index == currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // WCAG AA compliant colors for active and inactive states
    final activeColor = isDark ? Theme.of(context).colorScheme.primary : const Color(0xFFB33966);
    final inactiveColor = isDark ? const Color(0xFFB0B0B0) : const Color(0xFF6B6B6B);
    
    final color = selected ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primary.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11, // Slightly larger for better legibility
                fontWeight: FontWeight.w600, // Consistent weight for active/inactive
                color: color,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
