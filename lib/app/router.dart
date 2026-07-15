import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/services/onboarding_service.dart';
import '../presentation/analytics/analytics_screen.dart';
import '../presentation/analytics/lifetime_screen.dart';
import '../presentation/analytics/timeline_screen.dart';
import '../presentation/blocking/app_picker_screen.dart';
import '../presentation/blocking/stay_away_screen.dart';
import '../presentation/dashboard/dashboard_screen.dart';
import '../presentation/focus/focus_analytics_screen.dart';
import '../presentation/history/continuous_history_screen.dart';
import '../presentation/history/history_screen.dart';
import '../presentation/history/sleep_morning_screen.dart';
import '../presentation/history/unlock_history_screen.dart';
import '../presentation/insights/insights_hub_screen.dart';
import '../presentation/insights/narrative_insights_screen.dart';
import '../presentation/focus/focus_ritual_screen.dart';
import '../presentation/focus/focus_screen.dart';
import '../presentation/focus/pomodoro_screen.dart';
import '../presentation/focus/pomodoro_setup_screen.dart';
import '../presentation/gamification/achievements_screen.dart';
import '../presentation/gamification/profile_screen.dart';
import '../presentation/insights/app_details_screen.dart';
import '../presentation/insights/ghost_reveal_screen.dart';
import '../presentation/insights/insights_screen.dart';
import '../presentation/insights/notification_intelligence_screen.dart';
import '../presentation/insights/personality_screen.dart';
import '../presentation/insights/recommendations_screen.dart';
import '../presentation/insights/share_card_screen.dart';
import '../presentation/insights/simulator_screen.dart';
import '../presentation/insights/weekly_summary_screen.dart';
import '../presentation/onboarding/onboarding_screen.dart';
import '../presentation/onboarding/permission_screen.dart';
import '../presentation/replay/cinematic_replay_screen.dart';
import '../presentation/replay/replay_screen.dart';
import '../presentation/settings/diagnostics_screen.dart';
import '../presentation/settings/reliability_screen.dart';
import '../presentation/settings/settings_screen.dart';
import '../presentation/settings/themes_screen.dart';
import '../presentation/shell/app_shell.dart';
import '../presentation/wellness/mood_screen.dart';
import '../domain/models/app_category.dart';

final GlobalKey<NavigatorState> _rootKey = GlobalKey<NavigatorState>(
  debugLabel: 'wx-root',
);
final GlobalKey<NavigatorState> _shellKey = GlobalKey<NavigatorState>(
  debugLabel: 'wx-shell',
);

/// Non-shell screens use the root navigator (full-screen, no bottom nav).
GoRoute _root(String path, Widget Function() build) {
  return GoRoute(
    path: path,
    parentNavigatorKey: _rootKey,
    builder: (context, state) => build(),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final hasOnboarded = ref.watch(onboardingCompletedProvider);
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: hasOnboarded ? '/home' : '/onboarding',
    debugLogDiagnostics: false,
    routes: <RouteBase>[
      _root('/onboarding', () => const OnboardingScreen()),
      _root('/permissions', () => const PermissionScreen()),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/focus',
            builder: (context, state) => const FocusScreen(),
          ),
          GoRoute(
            path: '/insights-hub',
            builder: (context, state) => const InsightsHubScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      // Flat paths only — no prefix overlap. Each route name is unique so
      // go_router's auto-generated page keys can't collide.
      _root('/pomodoro', () => const PomodoroScreen()),
      _root('/focus-setup', () => const PomodoroSetupScreen()),
      _root('/focus-ritual', () => const FocusRitualScreen()),
      _root('/focus-analytics', () => const FocusAnalyticsScreen()),
      _root('/analytics', () => const AnalyticsScreen()),
      _root('/timeline', () => const TimelineScreen()),
      _root('/unlock-history', () => const UnlockHistoryScreen()),
      _root('/sleep-morning', () => const SleepMorningScreen()),
      _root('/continuous-history', () => const ContinuousHistoryScreen()),
      _root('/lifetime', () => const LifetimeScreen()),
      _root('/stay-away', () => const StayAwayScreen()),
      _root('/app-picker', () => const AppPickerScreen()),
      _root('/achievements', () => const AchievementsScreen()),
      _root('/insights', () => const InsightsScreen()),
      _root('/insights-classic', () => const InsightsHubScreen()),
      _root('/insights-narrative', () => const NarrativeInsightsScreen()),
      _root('/recommendations', () => const RecommendationsScreen()),
      _root(
        '/notification-intel',
        () => const NotificationIntelligenceScreen(),
      ),
      _root('/personality', () => const PersonalityScreen()),
      _root('/ghost-reveal', () => const GhostRevealScreen()),
      _root('/mood', () => const MoodScreen()),
      _root('/themes', () => const ThemesScreen()),
      _root('/reliability', () => const ReliabilityScreen()),
      _root('/diagnostics', () => const DiagnosticsScreen()),
      _root('/replay', () => const CinematicReplayScreen()),
      _root('/replay-classic', () => const ReplayScreen()),
      _root('/simulator', () => const SimulatorScreen()),
      _root('/weekly', () => const WeeklySummaryScreen()),
      _root('/share-card', () => const ShareCardScreen()),
      // App details — `/app/:pkg?name=&cat=`
      GoRoute(
        path: '/app/:pkg',
        parentNavigatorKey: _rootKey,
        builder: (context, state) {
          final pkg = Uri.decodeComponent(state.pathParameters['pkg'] ?? '');
          final name = Uri.decodeComponent(
            state.uri.queryParameters['name'] ?? pkg,
          );
          final cat = AppCategory.fromCode(state.uri.queryParameters['cat']);
          return AppDetailsScreen(
            packageName: pkg,
            displayName: name,
            category: cat,
          );
        },
      ),
      _root('/settings', () => const SettingsScreen()),
    ],
  );
});
