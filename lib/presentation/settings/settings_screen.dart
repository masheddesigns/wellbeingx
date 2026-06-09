import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/theme/colors.dart';
import '../../core/services/onboarding_service.dart';
import '../../core/services/permission_service.dart';
import '../shared/widgets/glass_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final install = ref.watch(installControllerProvider);
    final perms = ref.watch(permissionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: <Widget>[
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'INSTALL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: WxColors.textMuted,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tracking since ${DateFormat('d MMM yyyy').format(install.installedAt)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: WxColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            onTap: () => context.push('/permissions'),
            child: Row(
              children: <Widget>[
                const Icon(Icons.shield_outlined, color: WxColors.cyan),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Permissions',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: WxColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  perms.usageAccess ? 'OK' : 'Setup',
                  style: TextStyle(
                    color: perms.usageAccess
                        ? WxColors.accent
                        : WxColors.amber,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios,
                    color: WxColors.textMuted, size: 14),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            onTap: () => context.push('/themes'),
            child: Row(
              children: const <Widget>[
                Icon(Icons.palette_outlined, color: WxColors.violet),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Themes',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: WxColors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: WxColors.textMuted, size: 14),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            onTap: () => context.push('/reliability'),
            child: Row(
              children: const <Widget>[
                Icon(Icons.health_and_safety_outlined, color: WxColors.amber),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Reliability & data confidence',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: WxColors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: WxColors.textMuted, size: 14),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            onTap: () => context.push('/diagnostics'),
            child: Row(
              children: const <Widget>[
                Icon(Icons.bug_report_outlined, color: WxColors.crimson),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Diagnostics & repair',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: WxColors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: WxColors.textMuted, size: 14),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            onTap: () => context.push('/lifetime'),
            child: Row(
              children: const <Widget>[
                Icon(Icons.history_outlined, color: WxColors.cyan),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Lifetime stats',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: WxColors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    color: WxColors.textMuted, size: 14),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Row(
                  children: <Widget>[
                    Text('👻', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 10),
                    Text(
                      'Ghost Week',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: WxColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Track silently for 7 days. We hide stats; you get one big reveal.',
                  style: TextStyle(fontSize: 13, color: WxColors.textSecondary),
                ),
                const SizedBox(height: 12),
                if (install.ghostMode &&
                    install.ghostUntil != null &&
                    install.ghostUntil!.isAfter(DateTime.now())) ...<Widget>[
                  Text(
                    'Reveal drops ${DateFormat('d MMM, HH:mm').format(install.ghostUntil!)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: WxColors.violet,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () =>
                        ref.read(installControllerProvider.notifier).endGhostWeek(),
                    child: const Text('End early'),
                  ),
                ] else
                  FilledButton(
                    onPressed: () =>
                        ref.read(installControllerProvider.notifier).startGhostWeek(),
                    child: const Text('Start Ghost Week'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            borderColor: WxColors.crimson.withValues(alpha: 0.3),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Reset all data?'),
                  content: const Text(
                    'Wipes all stored stats, focus history, achievements, and settings. Cannot be undone.',
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await ref.read(installControllerProvider.notifier).resetAllData();
                if (context.mounted) context.go('/onboarding');
              }
            },
            child: Row(
              children: const <Widget>[
                Icon(Icons.delete_forever_outlined, color: WxColors.crimson),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Reset all data',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: WxColors.crimson,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'WellbeingX · v0.1\nOffline. Private. Local-only.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: WxColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
