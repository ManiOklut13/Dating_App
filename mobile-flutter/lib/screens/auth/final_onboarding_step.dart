import 'package:flutter/material.dart';
import '../../services/theme_provider.dart';

class FinalOnboardingStep extends StatefulWidget {
  final ValueChanged<ThemeMode>? onThemeChanged;
  final ValueChanged<bool>? onPushNotificationsChanged;
  final VoidCallback onEnterHome;

  const FinalOnboardingStep({
    super.key,
    this.onThemeChanged,
    this.onPushNotificationsChanged,
    required this.onEnterHome,
  });

  @override
  State<FinalOnboardingStep> createState() => _FinalOnboardingStepState();
}

class _FinalOnboardingStepState extends State<FinalOnboardingStep> {
  ThemeMode _selectedTheme = ThemeMode.system;
  bool _pushNotificationsEnabled = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final scope = YoUnMeThemeScope.of(context);
      _selectedTheme = scope.themeMode;
    } catch (_) {}
  }

  void _updateTheme(ThemeMode mode) {
    setState(() => _selectedTheme = mode);
    widget.onThemeChanged?.call(mode);
    try {
      YoUnMeThemeScope.of(context).setThemeMode(mode);
    } catch (_) {}
  }

  void _togglePushNotifications(bool enabled) {
    setState(() => _pushNotificationsEnabled = enabled);
    widget.onPushNotificationsChanged?.call(enabled);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final borderColor = isDark ? Colors.white12 : Colors.grey.shade300;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 5 of 5 • Appearance & Notifications'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text(
                    'Theme Appearance',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pick how you want the app to look before jumping into the home screen.',
                    style: TextStyle(color: subtitleColor, fontSize: 14),
                  ),
                  const SizedBox(height: 18),

                  // Theme Options Card
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        RadioListTile<ThemeMode>(
                          activeColor: primaryColor,
                          title: const Text(
                            'Light Mode',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text('Bright & clean romantic look'),
                          secondary: const Icon(
                            Icons.light_mode_rounded,
                            color: Colors.amber,
                          ),
                          value: ThemeMode.light,
                          groupValue: _selectedTheme,
                          onChanged: (val) {
                            if (val != null) _updateTheme(val);
                          },
                        ),
                        Divider(
                          height: 1,
                          color: isDark ? Colors.white12 : Colors.grey.shade200,
                        ),
                        RadioListTile<ThemeMode>(
                          activeColor: primaryColor,
                          title: const Text(
                            'Dark Mode',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle:
                              const Text('Midnight luxe deep obsidian theme'),
                          secondary: const Icon(
                            Icons.dark_mode_rounded,
                            color: Color(0xFFFF2E55),
                          ),
                          value: ThemeMode.dark,
                          groupValue: _selectedTheme,
                          onChanged: (val) {
                            if (val != null) _updateTheme(val);
                          },
                        ),
                        Divider(
                          height: 1,
                          color: isDark ? Colors.white12 : Colors.grey.shade200,
                        ),
                        RadioListTile<ThemeMode>(
                          activeColor: primaryColor,
                          title: const Text(
                            'System Default',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle:
                              const Text('Match device light/dark appearance'),
                          secondary: const Icon(
                            Icons.brightness_auto_rounded,
                            color: Colors.blueAccent,
                          ),
                          value: ThemeMode.system,
                          groupValue: _selectedTheme,
                          onChanged: (val) {
                            if (val != null) _updateTheme(val);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Push Notifications Section
                  const Text(
                    'Push Notifications',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Stay updated on new likes, matches, sparks, and incoming messages.',
                    style: TextStyle(color: subtitleColor, fontSize: 14),
                  ),
                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeColor: primaryColor,
                      secondary: Icon(
                        _pushNotificationsEnabled
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_off_rounded,
                        color: _pushNotificationsEnabled
                            ? primaryColor
                            : subtitleColor,
                      ),
                      title: const Text(
                        'Enable Push Notifications',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        _pushNotificationsEnabled
                            ? 'Instant alerts turned on'
                            : 'Notifications paused (you can turn on anytime)',
                        style: TextStyle(color: subtitleColor, fontSize: 12.5),
                      ),
                      value: _pushNotificationsEnabled,
                      onChanged: _togglePushNotifications,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: widget.onEnterHome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF2E55),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Finish & Go to Home',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
