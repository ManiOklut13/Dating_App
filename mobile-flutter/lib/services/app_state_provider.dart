import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthScreen { splash, signin, onboarding }

class AppState {
  final bool isAuthenticated;
  final AuthScreen authScreen;
  final int rubyBalance;
  final int streakDays;
  final String activeSubPage;
  final bool showRubyBoostToast;

  const AppState({
    this.isAuthenticated = false,
    this.authScreen = AuthScreen.splash,
    this.rubyBalance = 290,
    this.streakDays = 4,
    this.activeSubPage = 'discovery',
    this.showRubyBoostToast = false,
  });

  AppState copyWith({
    bool? isAuthenticated,
    AuthScreen? authScreen,
    int? rubyBalance,
    int? streakDays,
    String? activeSubPage,
    bool? showRubyBoostToast,
  }) {
    return AppState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      authScreen: authScreen ?? this.authScreen,
      rubyBalance: rubyBalance ?? this.rubyBalance,
      streakDays: streakDays ?? this.streakDays,
      activeSubPage: activeSubPage ?? this.activeSubPage,
      showRubyBoostToast: showRubyBoostToast ?? this.showRubyBoostToast,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState());

  void setAuthenticated(bool v) => state = state.copyWith(isAuthenticated: v);
  void setAuthScreen(AuthScreen s) => state = state.copyWith(authScreen: s);
  void setRubyBalance(int v) => state = state.copyWith(rubyBalance: v);
  void addRubies(int v) => state = state.copyWith(rubyBalance: state.rubyBalance + v);
  void setStreakDays(int v) => state = state.copyWith(streakDays: v);
  void setActiveSubPage(String v) => state = state.copyWith(activeSubPage: v);
  void triggerDailyRubyBoost() {
    state = state.copyWith(rubyBalance: state.rubyBalance + 50, showRubyBoostToast: true);
  }
  void dismissRubyBoostToast() => state = state.copyWith(showRubyBoostToast: false);
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) => AppStateNotifier());