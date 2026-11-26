import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}

/// An InheritedNotifier providing app-wide theme controller access.
class YoUnMeThemeScope extends InheritedNotifier<ThemeProvider> {
  const YoUnMeThemeScope({
    super.key,
    required ThemeProvider notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ThemeProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<YoUnMeThemeScope>();
    assert(scope != null, 'No YoUnMeThemeScope found in context');
    return scope!.notifier!;
  }
}
