import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/app_state_provider.dart';
import '../../services/theme_provider.dart';
import '../../services/theme_service.dart';

class ProfileTabScreen extends ConsumerWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(appStateProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appTheme = context.appTheme;
    final cardBg = isDark ? const Color(0xFF1B1119) : Colors.white;
    final elevatedBg = isDark ? const Color(0xFF241822) : const Color(0xFFF3F4F6);
    final borderColor = isDark ? const Color(0xFF2E1E2B) : Colors.grey.shade200;
    final primaryText = isDark ? Colors.white : const Color(0xFF181A24);
    final secondaryText = isDark ? const Color(0xFFCBD5E1) : Colors.grey.shade700;
    final mutedText = isDark ? const Color(0xFF9CA3AF) : Colors.grey.shade600;

    ThemeMode currentThemeMode = ThemeMode.system;
    try {
      currentThemeMode = YoUnMeThemeScope.of(context).themeMode;
    } catch (_) {}

    final checklistItems = [
      'Phone Verification (Twilio WhatsApp OTP)',
      'Basic Identity & Bio',
      'Discovery Preferences',
      '6 Photos Uploaded',
      'Voice PIN Recording Sample',
      'Blink SDK Oval Face Liveness Test',
      'Anonymous Call Avatar Configured',
      'Contacts Sync & Privacy Shield',
      'GPS Location Precision Enabled',
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Profile Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.45 : 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFEC4899), width: 2.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x66EC4899),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(43),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=800&q=80',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Icon(Icons.person, size: 44, color: primaryText),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Arjun Mehta, 26',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: primaryText,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0x2638BDF8),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0x8038BDF8)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, size: 12, color: Color(0xFF38BDF8)),
                              SizedBox(width: 4),
                              Text(
                                'Blue Tick Verified',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF38BDF8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Building next-gen AI tech • Subko coffee addict • Mumbai (Bandra West)',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.5, color: secondaryText, height: 1.4),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: elevatedBg,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: borderColor),
                          ),
                          child: Text(
                            '📍 Bandra (19.0596° N, 72.8295° E)',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: mutedText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0x2622C55E),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0x8022C55E)),
                          ),
                          child: const Row(
                            children: [
                              Text('🎤', style: TextStyle(fontSize: 10)),
                              SizedBox(width: 4),
                              Text(
                                'Voice PIN Active',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF22C55E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Theme Appearance Switcher Card (Light / Dark / System Default)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.palette_outlined,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'App Appearance',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: primaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _themeOptionButton(
                          context: context,
                          label: 'Light',
                          icon: Icons.light_mode_rounded,
                          mode: ThemeMode.light,
                          selectedMode: currentThemeMode,
                          isDark: isDark,
                          appTheme: appTheme,
                        ),
                        const SizedBox(width: 8),
                        _themeOptionButton(
                          context: context,
                          label: 'Dark',
                          icon: Icons.dark_mode_rounded,
                          mode: ThemeMode.dark,
                          selectedMode: currentThemeMode,
                          isDark: isDark,
                          appTheme: appTheme,
                        ),
                        const SizedBox(width: 8),
                        _themeOptionButton(
                          context: context,
                          label: 'System',
                          icon: Icons.brightness_auto_rounded,
                          mode: ThemeMode.system,
                          selectedMode: currentThemeMode,
                          isDark: isDark,
                          appTheme: appTheme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Onboarding Progress Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Profile Verification Score',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: mutedText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Auto-awarded Blue Tick (>=70%)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF38BDF8),
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          '92%',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFEC4899),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        height: 8,
                        color: borderColor,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.92,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFE11D48), Color(0xFFEC4899)],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Two side-by-side action buttons
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        notifier.setAuthenticated(false);
                        notifier.setAuthScreen(AuthScreen.onboarding);
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: elevatedBg,
                          border: Border.all(color: borderColor),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Test Onboarding Wizard',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: primaryText,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        notifier.setAuthenticated(false);
                        notifier.setAuthScreen(AuthScreen.splash);
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: elevatedBg,
                          border: Border.all(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Log Out & Splash',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 9-Step Verification Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined,
                            color: Color(0xFF22C55E), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '9-Step Verification Status',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: primaryText,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          '9/9 Completed',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF22C55E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    ...List.generate(checklistItems.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0x2622C55E),
                              ),
                              child: const Icon(Icons.check,
                                  size: 13, color: Color(0xFF22C55E)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                checklistItems[index],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: primaryText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0x1A22C55E),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Done',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF22C55E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _themeOptionButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode selectedMode,
    required bool isDark,
    required YoUnMeThemeExtension appTheme,
  }) {
    final active = selectedMode == mode;
    final primary = Theme.of(context).colorScheme.primary;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          try {
            YoUnMeThemeScope.of(context).setThemeMode(mode);
          } catch (_) {}
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: active
                ? primary.withOpacity(0.14)
                : (isDark ? const Color(0xFF241822) : const Color(0xFFF3F4F6)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? primary : appTheme.borderSubtle,
              width: active ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: active
                    ? primary
                    : (isDark ? Colors.white70 : Colors.grey.shade700),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  color: active
                      ? primary
                      : (isDark ? Colors.white70 : Colors.grey.shade800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
