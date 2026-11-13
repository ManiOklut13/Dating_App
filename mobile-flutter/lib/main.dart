import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/chat/chat_tab_screen.dart';
import 'screens/profile/profile_tab_screen.dart';
import 'services/theme_service.dart';
import 'services/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: YoUnMeApp()));
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
            themeMode: _themeProvider.themeMode,
            // ─── Light Mode ThemeData ───
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              scaffoldBackgroundColor: AppColors.lightBackground,
              cardColor: AppColors.lightCard,
              dividerColor: AppColors.lightBorder,
              colorScheme: const ColorScheme.light(
                primary: AppColors.flamePink,
                secondary: AppColors.cyanAccent,
                surface: AppColors.lightSurface,
                tertiary: AppColors.goldAccent,
                onSurface: AppColors.lightTextPrimary,
                outline: AppColors.lightBorder,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.lightSurface,
                foregroundColor: AppColors.lightTextPrimary,
                elevation: 0,
              ),
              bottomSheetTheme: const BottomSheetThemeData(
                backgroundColor: AppColors.lightSurface,
                surfaceTintColor: Colors.transparent,
              ),
              dividerTheme: const DividerThemeData(
                color: AppColors.lightBorder,
                thickness: 1,
              ),
              extensions: const [YoUnMeThemeExtension.light],
            ),
            // ─── Dark Mode ThemeData ───
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: AppColors.darkBackground,
              cardColor: AppColors.darkCard,
              dividerColor: AppColors.darkBorder,
              colorScheme: const ColorScheme.dark(
                primary: AppColors.flamePink,
                secondary: AppColors.cyanAccent,
                surface: AppColors.darkSurface,
                tertiary: AppColors.goldAccent,
                onSurface: AppColors.darkTextPrimary,
                outline: AppColors.darkBorder,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.darkSurface,
                foregroundColor: AppColors.darkTextPrimary,
                elevation: 0,
              ),
              bottomSheetTheme: const BottomSheetThemeData(
                backgroundColor: AppColors.darkSurface,
                surfaceTintColor: Colors.transparent,
              ),
              dividerTheme: const DividerThemeData(
                color: AppColors.darkBorder,
                thickness: 1,
              ),
              extensions: const [YoUnMeThemeExtension.dark],
            ),
            home: const MainShellScreen(),
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
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 2; // Default to Chat tab for immediate verification

  // Placeholder body widgets for unimplemented tabs
  Widget _placeholder(String label, YoUnMeThemeExtension theme) => Center(
        child: Text(
          label,
          style: TextStyle(fontSize: 18, color: theme.textMuted),
        ),
      );

  Widget _buildBody(YoUnMeThemeExtension theme) {
    switch (_currentIndex) {
      case 0:
        return _placeholder('🏠 Home Deck & Radar', theme);
      case 1:
        return _placeholder('❤️ Connect & \'Likes You\' Stack', theme);
      case 2:
        // ── Fully implemented theme-aware Chat tab ──
        return const ChatTabScreen();
      case 3:
        // ── Fully implemented theme-aware Profile tab ──
        return const ProfileTabScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Chat tab renders its own full-bleed reference-design header,
      // so the shell AppBar is hidden while it is active.
      appBar: _currentIndex == 2 ? null : _buildShellAppBar(theme, isDark),
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

  PreferredSizeWidget _buildShellAppBar(
    YoUnMeThemeExtension theme,
    bool isDark,
  ) {
    final themeProvider = YoUnMeThemeScope.of(context);
    return AppBar(
      backgroundColor: theme.bgSurface,
      elevation: 0,
      titleSpacing: 18,
      title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.flameGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_fire_department,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'YoUnMe',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: -0.5,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '· ${_kTabLabels[_currentIndex]}',
              style: TextStyle(
                fontSize: 14,
                color: theme.textMuted,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          // Theme quick toggle in AppBar
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: isDark ? AppColors.goldAccent : AppColors.flamePurple,
              size: 20,
            ),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () {
              themeProvider.toggleTheme();
            },
          ),

          // Coin balance chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: isDark ? 0.15 : 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text(
                  '250',
                  style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
        ],
      );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Floating bottom navigation bar (reference design: rounded dark bar with a
  // pink underline indicator under the active tab)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildFloatingNavBar(YoUnMeThemeExtension theme) {
    final icons = <IconData, IconData>{
      Icons.home_outlined: Icons.home,
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
          color: context.isDarkMode ? const Color(0xFF1D1526) : theme.bgSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: context.isDarkMode
                ? const Color(0x24FFFFFF)
                : theme.borderSubtle,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.flamePink.withValues(alpha: 0.10),
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
                      color: active ? AppColors.flamePink : theme.textMuted,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _kTabLabels[i],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active
                            ? AppColors.flamePink
                            : theme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 5),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 3,
                      width: active ? 30 : 0,
                      decoration: BoxDecoration(
                        gradient: AppColors.flameGradient,
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
