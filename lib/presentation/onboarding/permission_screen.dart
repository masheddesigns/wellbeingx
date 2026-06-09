import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../core/services/permission_service.dart';
import '../shared/widgets/glass_card.dart';

class PermissionScreen extends ConsumerStatefulWidget {
  const PermissionScreen({super.key});
  @override
  ConsumerState<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends ConsumerState<PermissionScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(permissionsProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(permissionsProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final perms = ref.watch(permissionsProvider);
    final ctrl = ref.read(permissionsProvider.notifier);

    return Scaffold(
      backgroundColor: WxColors.void_,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: <Widget>[
            const Text(
              'Set up access',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: WxColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'These permissions stay local. Nothing leaves the device.',
              style: TextStyle(
                fontSize: 14,
                color: WxColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _PermissionTile(
              required: true,
              granted: perms.usageAccess,
              icon: Icons.visibility_outlined,
              accent: WxColors.accent,
              title: 'Usage access',
              body: 'Required. Lets WellbeingX read which apps you opened and for how long. The OS shows you the consent prompt.',
              cta: 'Open settings',
              onTap: ctrl.openUsageAccess,
            ),
            const SizedBox(height: 12),
            _PermissionTile(
              required: false,
              granted: perms.accessibility,
              icon: Icons.shield_outlined,
              accent: WxColors.crimson,
              title: 'Accessibility (for Stay-Away)',
              body: 'Optional. Lets us detect when a blocked app comes to the foreground and gently bounce you out.',
              cta: 'Open accessibility',
              onTap: ctrl.openAccessibility,
            ),
            const SizedBox(height: 12),
            _PermissionTile(
              required: false,
              granted: perms.notifications,
              icon: Icons.notifications_outlined,
              accent: WxColors.cyan,
              title: 'Notification listener',
              body: 'Optional. Counts notifications per app for the notification-pressure score.',
              cta: 'Open settings',
              onTap: ctrl.openNotificationListener,
            ),
            const SizedBox(height: 12),
            _PermissionTile(
              required: false,
              granted: perms.batteryOptimisationsIgnored,
              icon: Icons.bolt_outlined,
              accent: WxColors.amber,
              title: 'Disable battery optimization',
              body: 'Optional but recommended. Keeps focus sessions accurate when the screen is off.',
              cta: 'Allow',
              onTap: ctrl.requestBatteryOpt,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => context.go('/home'),
              child: Text(
                perms.usageAccess ? 'Open WellbeingX' : 'Continue without (limited)',
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => ctrl.refresh(),
                child: const Text('Refresh status'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.required,
    required this.granted,
    required this.icon,
    required this.accent,
    required this.title,
    required this.body,
    required this.cta,
    required this.onTap,
  });
  final bool required;
  final bool granted;
  final IconData icon;
  final Color accent;
  final String title;
  final String body;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: granted
          ? WxColors.accent.withValues(alpha: 0.3)
          : accent.withValues(alpha: 0.18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: WxColors.textPrimary,
                  ),
                ),
              ),
              if (required)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: WxColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Text(
                    'REQUIRED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: WxColors.accent,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              color: WxColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              if (granted) ...<Widget>[
                const Icon(Icons.check_circle, color: WxColors.accent, size: 18),
                const SizedBox(width: 6),
                const Text(
                  'Granted',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: WxColors.accent,
                  ),
                ),
                const Spacer(),
              ] else ...<Widget>[
                const Icon(Icons.radio_button_unchecked,
                    color: WxColors.textMuted, size: 18),
                const SizedBox(width: 6),
                const Text('Not granted',
                    style: TextStyle(
                        fontSize: 13, color: WxColors.textMuted)),
                const Spacer(),
              ],
              TextButton(
                onPressed: onTap,
                child: Text(cta),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
