import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profiles_data.dart';
import '../features/plan_date/models/plan_date_model.dart';
import '../models/discovery_connect_models.dart';

enum AuthScreen { splash, signin, onboarding }

class AppState {
  final bool isAuthenticated;
  final AuthScreen authScreen;
  final int rubyBalance;
  final int streakDays;
  final String activeSubPage;
  final bool showRubyBoostToast;
  final ScheduledDateModel? scheduledDate;
  final PlanDate? plannedDate;

  bool get hasDatePlan => scheduledDate != null || plannedDate != null;

  const AppState({
    this.isAuthenticated = false,
    this.authScreen = AuthScreen.splash,
    this.rubyBalance = 290,
    this.streakDays = 4,
    this.activeSubPage = 'discovery',
    this.showRubyBoostToast = false,
    this.scheduledDate,
    this.plannedDate,
  });

  AppState copyWith({
    bool? isAuthenticated,
    AuthScreen? authScreen,
    int? rubyBalance,
    int? streakDays,
    String? activeSubPage,
    bool? showRubyBoostToast,
    ScheduledDateModel? scheduledDate,
    PlanDate? plannedDate,
    bool clearScheduledDate = false,
    bool clearPlannedDate = false,
  }) {
    return AppState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      authScreen: authScreen ?? this.authScreen,
      rubyBalance: rubyBalance ?? this.rubyBalance,
      streakDays: streakDays ?? this.streakDays,
      activeSubPage: activeSubPage ?? this.activeSubPage,
      showRubyBoostToast: showRubyBoostToast ?? this.showRubyBoostToast,
      scheduledDate: clearScheduledDate ? null : (scheduledDate ?? this.scheduledDate),
      plannedDate: clearPlannedDate ? null : (plannedDate ?? this.plannedDate),
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(AppState(scheduledDate: kDemoScheduledDate));

  void setAuthenticated(bool v) => state = state.copyWith(isAuthenticated: v);
  void setAuthScreen(AuthScreen s) => state = state.copyWith(authScreen: s);
  void setRubyBalance(int v) => state = state.copyWith(rubyBalance: v);
  void addRubies(int v) => state = state.copyWith(rubyBalance: state.rubyBalance + v);
  void setStreakDays(int v) => state = state.copyWith(streakDays: v);
  void setActiveSubPage(String v) => state = state.copyWith(activeSubPage: v);
  void setScheduledDate(ScheduledDateModel? d) => state = state.copyWith(
        scheduledDate: d,
        clearScheduledDate: d == null,
      );
  void setPlannedDate(PlanDate? p) => state = state.copyWith(
        plannedDate: p,
        clearPlannedDate: p == null,
      );
  void clearDatePlans() => state = state.copyWith(
        clearScheduledDate: true,
        clearPlannedDate: true,
      );
  void triggerDailyRubyBoost() {
    state = state.copyWith(rubyBalance: state.rubyBalance + 50, showRubyBoostToast: true);
  }
  void dismissRubyBoostToast() => state = state.copyWith(showRubyBoostToast: false);
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) => AppStateNotifier());