import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/services/permission_service.dart';
import '../../data/repositories/blocking_repository.dart';
import '../shared/widgets/glass_card.dart';

final _overridesTodayProvider = FutureProvider<int>((ref) async {
  return ref.watch(blockingRepositoryProvider).overridesToday();
});

class StayAwayScreen extends ConsumerWidget {
  const StayAwayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(activeBlockRulesProvider);
    final perms = ref.watch(permissionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Stay-Away')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: <Widget>[
          if (!perms.accessibility) ...<Widget>[
            GlassCard(
              borderColor: WxColors.crimson.withValues(alpha: 0.4),
              onTap: () =>
                  ref.read(permissionsProvider.notifier).openAccessibility(),
              child: Row(
                children: const <Widget>[
                  Icon(Icons.shield_moon_outlined, color: WxColors.crimson),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Accessibility is required for blocking. Tap to enable.',
                      style: TextStyle(color: WxColors.textPrimary),
                    ),
                  ),
                  Icon(Icons.arrow_forward, color: WxColors.crimson, size: 16),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          _AntiCheatCounter(),
          const SizedBox(height: 12),
          const _ModesExplained(),
          const SizedBox(height: 16),
          rules.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('$e'),
            data: (list) {
              if (list.isEmpty) {
                return const GlassCard(
                  child: Text(
                    'No active rules. Add an app to start blocking.',
                    style: TextStyle(color: WxColors.textSecondary),
                  ),
                );
              }
              return Column(
                children: <Widget>[
                  for (final r in list)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassCard(
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _modeColor(r.mode).withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                r.mode == 'extreme'
                                    ? Icons.lock
                                    : r.mode == 'hard'
                                        ? Icons.do_not_disturb_on_outlined
                                        : Icons.notifications_off_outlined,
                                color: _modeColor(r.mode),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    r.packageName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: WxColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${r.mode.toUpperCase()} · ${r.untilMs == null ? 'always' : 'until ${DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(r.untilMs!))}'}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: WxColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: WxColors.textMuted),
                              onPressed: () async {
                                await ref
                                    .read(blockingRepositoryProvider)
                                    .remove(r.id);
                                ref.invalidate(activeBlockRulesProvider);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.push('/app-picker'),
            icon: const Icon(Icons.add),
            label: const Text('Block an app'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(blockingRepositoryProvider).clearAll();
              ref.invalidate(activeBlockRulesProvider);
            },
            icon: const Icon(Icons.delete_sweep_outlined),
            label: const Text('Clear all rules'),
          ),
        ],
      ),
    );
  }

  Color _modeColor(String mode) {
    switch (mode) {
      case 'extreme':
        return WxColors.crimson;
      case 'hard':
        return WxColors.amber;
      default:
        return WxColors.cyan;
    }
  }
}

class _AntiCheatCounter extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.watch(_overridesTodayProvider);
    final count = n.asData?.value ?? 0;
    return GlassCard(
      borderColor: count >= 3
          ? WxColors.crimson.withValues(alpha: 0.35)
          : WxColors.hairline,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (count >= 3 ? WxColors.crimson : WxColors.amber)
                  .withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              count >= 3 ? Icons.report_outlined : Icons.shield_outlined,
              color: count >= 3 ? WxColors.crimson : WxColors.amber,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'OVERRIDES TODAY',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: count >= 3 ? WxColors.crimson : WxColors.amber,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  count == 0
                      ? "Iron will so far. Don't break the chain."
                      : count == 1
                          ? '1 break. XP forfeit applied.'
                          : '$count breaks. The bypass habit is forming.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: WxColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text('$count', style: WxTypography.mono(size: 22)),
        ],
      ),
    );
  }
}

class _ModesExplained extends StatelessWidget {
  const _ModesExplained();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Text(
            'BLOCKING MODES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: WxColors.textMuted,
              letterSpacing: 1.6,
            ),
          ),
          SizedBox(height: 12),
          _ModeRow(
            icon: Icons.notifications_off_outlined,
            color: WxColors.cyan,
            title: 'Soft',
            body: 'A gentle warning overlay when you open the app.',
          ),
          SizedBox(height: 10),
          _ModeRow(
            icon: Icons.do_not_disturb_on_outlined,
            color: WxColors.amber,
            title: 'Hard',
            body: 'Auto-bounces you back home. Override available with friction.',
          ),
          SizedBox(height: 10),
          _ModeRow(
            icon: Icons.lock_outline,
            color: WxColors.crimson,
            title: 'Extreme',
            body: 'No bypass. The block stays until your timer ends.',
          ),
        ],
      ),
    );
  }
}

class _ModeRow extends StatelessWidget {
  const _ModeRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: const TextStyle(
                  fontSize: 12,
                  color: WxColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
