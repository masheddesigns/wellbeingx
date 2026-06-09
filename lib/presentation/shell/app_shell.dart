import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../core/services/haptics.dart';
import '../../core/services/permission_service.dart';
import '../dashboard/dashboard_state.dart';

/// When true, the bottom nav fades out — a screen has entered "immersion
/// mode" (Insights narrative is the canonical caller). The shell still owns
/// the route, but it visually steps aside so the screen can take over.
final shellImmersionProvider = StateProvider<bool>((_) => false);

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  Timer? _periodicTicker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Periodic ingest scoped to the shell — fires across every tab so
    // Insights / Replay / History stay fresh, not just the dashboard. The
    // 90-second cadence matches the previous dashboard-local timer; data
    // providers that watch [lastIngestProvider] will react automatically.
    _periodicTicker = Timer.periodic(
      const Duration(seconds: 90),
      (_) {
        if (mounted) runBackgroundIngest(ref);
      },
    );
  }

  @override
  void dispose() {
    _periodicTicker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh permissions + run an ingest whenever the app returns to the
      // foreground. Coming back after using other apps is the moment new
      // screen-time data becomes available, so we want to pull immediately.
      ref.read(permissionsProvider.notifier).refresh();
      runBackgroundIngest(ref);
    }
  }

  static const _tabs = <_NavItem>[
    _NavItem(
      label: 'Home',
      icon: Icons.home_rounded,
      route: '/home',
    ),
    _NavItem(
      label: 'History',
      icon: Icons.calendar_month_rounded,
      route: '/history',
    ),
    _NavItem(
      label: 'Focus',
      icon: Icons.timer_outlined,
      route: '/focus',
    ),
    _NavItem(
      label: 'Insights',
      icon: Icons.auto_awesome_outlined,
      route: '/insights-hub',
    ),
    _NavItem(
      label: 'You',
      icon: Icons.person_outline_rounded,
      route: '/profile',
    ),
  ];

  int _currentIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final i = _tabs.indexWhere((t) => loc.startsWith(t.route));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final idx = _currentIndex(context);
    final immersion = ref.watch(shellImmersionProvider);
    return Scaffold(
      backgroundColor: WxColors.void_,
      extendBody: true,
      body: widget.child,
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        offset: immersion ? const Offset(0, 1.2) : Offset.zero,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          opacity: immersion ? 0.0 : 1.0,
          child: IgnorePointer(
            ignoring: immersion,
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: WxColors.hairline, width: 0.5),
                ),
                color: WxColors.surface0,
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: <Widget>[
                    for (var i = 0; i < _tabs.length; i++)
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Haptics.tabSwitch();
                            context.go(_tabs[i].route);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 4),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 220),
                                  curve: Curves.easeOutCubic,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: i == idx ? 12 : 6,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: i == idx
                                        ? WxColors.accent
                                            .withValues(alpha: 0.10)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Icon(
                                    _tabs[i].icon,
                                    size: 20,
                                    color: i == idx
                                        ? WxColors.accent
                                        : WxColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                AnimatedDefaultTextStyle(
                                  duration:
                                      const Duration(milliseconds: 220),
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: i == idx
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: i == idx
                                        ? WxColors.accent
                                        : WxColors.textMuted,
                                  ),
                                  child: Text(_tabs[i].label),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  const _NavItem(
      {required this.label, required this.icon, required this.route});
}
