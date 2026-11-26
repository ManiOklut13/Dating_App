import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/chat/chat_tab_screen.dart';
import 'screens/profile/profile_tab_screen.dart';
import 'screens/home/discovery_tab_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/connect/connect_tab_screen.dart';
import 'screens/connect/random_call_screen.dart';
import 'screens/auth/splash_landing_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/basic_profile_page.dart';
import 'screens/auth/basic_profile_step.dart';
import 'screens/auth/full_page_avatar_camera.dart';
import 'screens/auth/preferences_step.dart';
import 'screens/auth/relationship_goals_step.dart';
import 'screens/auth/categorized_interests_step.dart';
import 'screens/auth/final_onboarding_step.dart';
import 'screens/auth/landing_auth_screen.dart';
import 'screens/auth/sign_up_page.dart';
import 'screens/home/profile_swipe_deck_screen.dart';
import 'screens/auth/create_password_screen.dart';
import 'screens/auth/phone_entry_page.dart';
import 'services/app_theme.dart';
import 'services/theme_service.dart';
import 'services/theme_provider.dart';
import 'services/app_state_provider.dart';

void main() {
  runApp(const ProviderScope(child: YoUnMeApp()));
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class YoUnMeApp extends StatefulWidget {
  const YoUnMeApp({super.key});

  @override
  State<YoUnMeApp> createState() => _YoUnMeAppState();
}

class _YoUnMeAppState extends State<YoUnMeApp> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  void dispose() {
    _themeProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoUnMeThemeScope(
      notifier: _themeProvider,
      child: AnimatedBuilder(
        animation: _themeProvider,
        builder: (context, _) {
          return MaterialApp(
            title: 'YoUnMe Dating App',
            debugShowCheckedModeBanner: false,
            scrollBehavior: const AppScrollBehavior(),
            themeMode: _themeProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            routes: {
              '/home': (_) => const MainShellScreen(),
              '/home-screen': (_) => const HomeScreen(),
              '/random-call': (_) => const RandomCallScreen(),
              '/profile-setup': (_) => const BasicProfilePage(),
              '/landing-auth': (_) => const LandingAuthScreen(),
              '/signup': (_) => const SignUpPage(),
              '/profile-swipe-deck': (_) => const ProfileSwipeDeckScreen(),
              '/create-password': (ctx) {
                final args = ModalRoute.of(ctx)?.settings.arguments as Map<String, dynamic>?;
                return CreatePasswordScreen(
                  verifiedEmail: args?['email'] as String? ?? '',
                );
              },
              '/enter-mobile-number': (ctx) =>
                  const PhoneEntryPage(startedWithEmail: true),
              '/onboarding-step-2': (ctx) {
                final args = ModalRoute.of(ctx)?.settings.arguments as Map<String, dynamic>?;
                return BasicProfilePage(
                  initialEmail: args?['email'] as String?,
                  initialPhone: args?['mobile'] as String?,
                );
              },
              '/basic-profile-step': (ctx) => BasicProfileStep(
                    onContinue: () => Navigator.pushNamed(ctx, '/relationship-goals-step'),
                  ),
              '/full-page-avatar-camera': (_) => const FullPageAvatarCamera(),
              '/relationship-goals-step': (ctx) => RelationshipGoalsStep(
                    onContinue: () => Navigator.pushNamed(ctx, '/categorized-interests-step'),
                  ),
              '/preferences-step': (ctx) => PreferencesStep(
                    onContinue: () => Navigator.pushNamed(ctx, '/categorized-interests-step'),
                  ),
              '/categorized-interests-step': (ctx) => CategorizedInterestsStep(
                    onContinue: () => Navigator.pushNamed(ctx, '/final-onboarding-step'),
                  ),
              '/final-onboarding-step': (ctx) => FinalOnboardingStep(
                    onEnterHome: () => Navigator.pushNamedAndRemoveUntil(
                      ctx,
                      '/home',
                      (route) => false,
                    ),
                  ),
            },
            home: ProviderScope(child: const AuthGate()),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab labels & icons
// ─────────────────────────────────────────────────────────────────────────────
const _kTabLabels = [
  'Home',
  'Connect',
  'Chat',
  'Profile',
];

// ─────────────────────────────────────────────────────────────────────────────
// Main App Shell
// ─────────────────────────────────────────────────────────────────────────────
class MainShellScreen extends StatefulWidget {
  final bool showStreakOnEntry;

  const MainShellScreen({super.key, this.showStreakOnEntry = false});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0; // Default to Home tab per spec

  Widget _buildBody(YoUnMeThemeExtension theme) {
    switch (_currentIndex) {
      case 0:
        return DiscoveryTabScreen(
          showStreakOnEntry: widget.showStreakOnEntry,
          onNavigateToConnect: () => setState(() => _currentIndex = 1),
        );
      case 1:
        return const ConnectTabScreen();
      case 2:
        return const ChatTabScreen();
      case 3:
        return const ProfileTabScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final appTheme = Theme.of(context);

    return Scaffold(
      backgroundColor: appTheme.scaffoldBackgroundColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _buildBody(theme),
        ),
      ),
      bottomNavigationBar: _buildFloatingNavBar(theme),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Persistent Bottom Navigation Bar (4 Tabs): Home (flame), Connect (heart),
  // Chat (speech bubble), Profile (user). Active tab highlighted in #EC4899.
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildFloatingNavBar(YoUnMeThemeExtension theme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final icons = <IconData, IconData>{
      Icons.local_fire_department_outlined: Icons.local_fire_department,
      Icons.favorite_border: Icons.favorite,
      Icons.chat_bubble_outline: Icons.chat_bubble,
      Icons.person_outline: Icons.person,
    };
    final iconEntries = icons.entries.toList();

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF181A24) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: primary.withOpacity(0.14),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: List.generate(4, (i) {
            final active = _currentIndex == i;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _currentIndex = i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      active ? iconEntries[i].value : iconEntries[i].key,
                      size: 22,
                      color: active
                          ? primary
                          : (isDark ? const Color(0xFF9CA3AF) : Colors.grey.shade600),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _kTabLabels[i],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                        color: active
                            ? primary
                            : (isDark ? const Color(0xFF9CA3AF) : Colors.grey.shade600),
                      ),
                    ),
                    const SizedBox(height: 5),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 3,
                      width: active ? 30 : 0,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primary, const Color(0xFFEC4899)],
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final notifier = ref.read(appStateProvider.notifier);
    if (!appState.isAuthenticated) {
      switch (appState.authScreen) {
        case AuthScreen.splash:
          return SplashLandingScreen(
            onCreateAccount: () =>
                notifier.setAuthScreen(AuthScreen.onboarding),
            onSignIn: () => notifier.setAuthScreen(AuthScreen.signin),
            onComplete: (data) => notifier.setAuthenticated(true),
          );
        case AuthScreen.signin:
          return SignInScreen(
            onBack: () => notifier.setAuthScreen(AuthScreen.splash),
            onLogin: (id, pw) => notifier.setAuthenticated(true),
            onGoToSignUp: () => notifier.setAuthScreen(AuthScreen.splash),
          );
        case AuthScreen.onboarding:
          return const BasicProfilePage();
      }
    }
    return const MainShellScreen();
  }
}
