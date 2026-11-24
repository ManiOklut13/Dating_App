import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/app_data_service.dart';
import '../../services/app_state_provider.dart';
import '../../services/theme_provider.dart';
import '../../services/theme_service.dart';
import 'profile_models.dart';
import 'profile_settings_details.dart';

/// Full-screen settings hub opened from the gear icon in the Profile header.
/// Every row opens a local, working view — no decorative dead ends.
class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  void _shareProfileLink(BuildContext context) {
    final handle = AppDataService.instance.userProfile.name.toLowerCase();
    Clipboard.setData(ClipboardData(text: 'https://younme.app/u/$handle'));
    notify(context, 'Profile link copied to clipboard');
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final theme = context.appTheme;
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: theme.borderSubtle),
        ),
        title: const Text(
          'Log out?',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'You will need to sign in again to see your matches and chats.',
          style: TextStyle(
            fontSize: 13,
            height: 1.45,
            color: theme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: theme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: ProfilePalette.danger,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !context.mounted) return;

    // Existing auth state lives in app_state_provider; we only read it.
    ref.read(appStateProvider.notifier)
      ..setAuthenticated(false)
      ..setAuthScreen(AuthScreen.splash);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final isDark = context.isDarkMode;
    final themeProvider = YoUnMeThemeScope.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.textPrimary, size: 21),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: theme.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const SettingsSectionLabel('Appearance'),
          SettingsGroup(
            children: [
              SettingsRow(
                icon: Icons.dark_mode_outlined,
                color: ProfilePalette.purple,
                title: 'Dark Mode',
                subtitle: isDark
                    ? 'Cyber Luxe dark theme active'
                    : 'Warm cream light theme active',
                onTap: () => themeProvider.setThemeMode(
                  isDark ? ThemeMode.light : ThemeMode.dark,
                ),
                trailing: Switch(
                  value: isDark,
                  activeThumbColor: ProfilePalette.pink,
                  activeTrackColor:
                      ProfilePalette.pink.withValues(alpha: 0.45),
                  onChanged: (value) => themeProvider
                      .setThemeMode(value ? ThemeMode.dark : ThemeMode.light),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const SettingsSectionLabel('Profile'),
          SettingsGroup(
            children: [
              SettingsRow(
                icon: Icons.visibility_outlined,
                color: ProfilePalette.cyan,
                title: 'Preview Public Card',
                subtitle: 'See your profile as matches do',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PublicProfilePreviewScreen(),
                  ),
                ),
              ),
              const SettingsDivider(),
              SettingsRow(
                icon: Icons.share_outlined,
                color: ProfilePalette.gold,
                title: 'Share Profile Link',
                subtitle: 'Copy a link to your profile',
                onTap: () => _shareProfileLink(context),
              ),
              const SettingsDivider(),
              SettingsRow(
                icon: Icons.photo_library_outlined,
                color: ProfilePalette.pink,
                title: 'Photo Visibility',
                subtitle: 'Control who can see your photos',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PhotoVisibilityScreen(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const SettingsSectionLabel('Privacy & Account'),
          SettingsGroup(
            children: [
              SettingsRow(
                icon: Icons.lock_outline,
                color: ProfilePalette.pink,
                title: 'Privacy & Safety',
                subtitle: 'Blocking, reporting and safety tools',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PrivacySafetyScreen(),
                  ),
                ),
              ),
              const SettingsDivider(),
              SettingsRow(
                icon: Icons.notifications_outlined,
                color: ProfilePalette.purple,
                title: 'Notifications',
                subtitle: 'Matches, messages and date reminders',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationsSettingsScreen(),
                  ),
                ),
              ),
              const SettingsDivider(),
              SettingsRow(
                icon: Icons.security,
                color: ProfilePalette.green,
                title: 'Security & Account',
                subtitle: 'Login, devices and verification',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SecurityAccountScreen(),
                  ),
                ),
              ),
              const SettingsDivider(),
              SettingsRow(
                icon: Icons.help_outline,
                color: ProfilePalette.cyan,
                title: 'Help & Support',
                subtitle: 'FAQs and contact the YoUnMe team',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const HelpSupportScreen(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Logout sits on its own, below Help & Support.
          Container(
            decoration: BoxDecoration(
              color: ProfilePalette.danger.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: ProfilePalette.danger.withValues(alpha: 0.32),
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _confirmLogout(context, ref),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: ProfilePalette.danger.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color:
                              ProfilePalette.danger.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Icon(Icons.logout,
                          size: 17, color: ProfilePalette.danger),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: ProfilePalette.danger,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Sign out of your YoUnMe account',
                            style: TextStyle(
                              fontSize: 11,
                              color: ProfilePalette.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right,
                        size: 18,
                        color: ProfilePalette.danger.withValues(alpha: 0.8)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'YoUnMe · v1.0.0',
              style: TextStyle(fontSize: 11, color: theme.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
