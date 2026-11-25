import 'package:flutter/material.dart';
import '../../services/theme_provider.dart';

class FinalOnboardingStep extends StatefulWidget {
  final ValueChanged<ThemeMode>? onThemeChanged;
  final VoidCallback onEnterHome;

  const FinalOnboardingStep({
    super.key,
    this.onThemeChanged,
    required this.onEnterHome,
  });

  @override
  State<FinalOnboardingStep> createState() => _FinalOnboardingStepState();
}

class _FinalOnboardingStepState extends State<FinalOnboardingStep> {
  ThemeMode _selectedTheme = ThemeMode.system;

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 5 of 5 • App Appearance'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Your Theme Appearance',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick how you want the app to look before jumping into the home screen.',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),

              // Theme Options
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      activeColor: primaryColor,
                      title: const Text('Light Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Bright & clean romantic look'),
                      secondary: const Icon(Icons.light_mode_rounded, color: Colors.amber),
                      value: ThemeMode.light,
                      groupValue: _selectedTheme,
                      onChanged: (val) => _updateTheme(val!),
                    ),
                    Divider(height: 1, color: isDark ? Colors.white12 : Colors.grey.shade200),
                    RadioListTile<ThemeMode>(
                      activeColor: primaryColor,
                      title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Midnight luxe deep obsidian theme'),
                      secondary: const Icon(Icons.dark_mode_rounded, color: Color(0xFFFF2E55)),
                      value: ThemeMode.dark,
                      groupValue: _selectedTheme,
                      onChanged: (val) => _updateTheme(val!),
                    ),
                    Divider(height: 1, color: isDark ? Colors.white12 : Colors.grey.shade200),
                    RadioListTile<ThemeMode>(
                      activeColor: primaryColor,
                      title: const Text('System Default', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Match device light/dark appearance'),
                      secondary: const Icon(Icons.brightness_auto_rounded, color: Colors.blueAccent),
                      value: ThemeMode.system,
                      groupValue: _selectedTheme,
                      onChanged: (val) => _updateTheme(val!),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
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
            ],
          ),
        ),
      ),
    );
  }
}
