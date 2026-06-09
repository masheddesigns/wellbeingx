import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/services/permission_service.dart';
import '../../data/repositories/usage_repository.dart';
import '../shared/widgets/glass_card.dart';

final _ingestDiagnosticsProvider =
    FutureProvider<({Duration sevenDay, Duration lifetime})>((ref) async {
  final repo = ref.watch(usageRepositoryProvider);
  final last7 = await repo.rangeStats(7);
  final week = last7.fold<Duration>(
    Duration.zero,
    (a, d) => a + d.screenTime,
  );
  final lifetime = await repo.lifetimeScreenTime();
  return (sevenDay: week, lifetime: lifetime);
});

class ReliabilityScreen extends ConsumerWidget {
  const ReliabilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perms = ref.watch(permissionsProvider);
    final diag = ref.watch(_ingestDiagnosticsProvider);
    final manufacturer = _detectManufacturer();
    final oemTip = _oemAdvice(manufacturer);
    final confidence = _confidenceScore(perms, diag);

    return Scaffold(
      appBar: AppBar(title: const Text('Reliability')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
        children: <Widget>[
          GlassCard(
            borderColor: confidence >= 80
                ? WxColors.accent.withValues(alpha: 0.3)
                : confidence >= 50
                    ? WxColors.amber.withValues(alpha: 0.3)
                    : WxColors.crimson.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'DATA CONFIDENCE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: WxColors.textMuted,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text('$confidence',
                        style: WxTypography.mono(
                            size: 48,
                            weight: FontWeight.w800,
                            color: confidence >= 80
                                ? WxColors.accent
                                : confidence >= 50
                                    ? WxColors.amber
                                    : WxColors.crimson)),
                    const SizedBox(width: 6),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text('/100',
                          style: TextStyle(
                              fontSize: 14, color: WxColors.textMuted)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  confidence >= 80
                      ? 'Solid signal. Numbers should match Settings closely.'
                      : confidence >= 50
                          ? 'Some gaps. OEM may be throttling — see tips below.'
                          : 'Weak signal. Permissions or OEM aggression are blocking ingest.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: WxColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _SectionTitle('PERMISSIONS'),
          GlassCard(
            child: Column(
              children: <Widget>[
                _PermissionRow(
                  label: 'Usage access',
                  ok: perms.usageAccess,
                  required_: true,
                  onTap: () =>
                      ref.read(permissionsProvider.notifier).openUsageAccess(),
                ),
                const Divider(height: 16),
                _PermissionRow(
                  label: 'Accessibility (blocking)',
                  ok: perms.accessibility,
                  required_: false,
                  onTap: () => ref
                      .read(permissionsProvider.notifier)
                      .openAccessibility(),
                ),
                const Divider(height: 16),
                _PermissionRow(
                  label: 'Notification listener',
                  ok: perms.notifications,
                  required_: false,
                  onTap: () => ref
                      .read(permissionsProvider.notifier)
                      .openNotificationListener(),
                ),
                const Divider(height: 16),
                _PermissionRow(
                  label: 'Battery optimization disabled',
                  ok: perms.batteryOptimisationsIgnored,
                  required_: false,
                  onTap: () => ref
                      .read(permissionsProvider.notifier)
                      .requestBatteryOpt(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _SectionTitle('INGEST'),
          GlassCard(
            child: diag.when(
              loading: () => const SizedBox(
                height: 60,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('$e',
                  style: const TextStyle(color: WxColors.crimson)),
              data: (d) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _DiagRow(
                    label: 'Last 7 days tracked',
                    value: d.sevenDay.inMinutes == 0
                        ? '—'
                        : '${d.sevenDay.inHours}h ${d.sevenDay.inMinutes.remainder(60)}m',
                  ),
                  const SizedBox(height: 8),
                  _DiagRow(
                    label: 'Lifetime in DB',
                    value: '${d.lifetime.inHours}h ${d.lifetime.inMinutes.remainder(60)}m',
                  ),
                  const SizedBox(height: 8),
                  _DiagRow(label: 'Device', value: manufacturer),
                ],
              ),
            ),
          ),
          if (oemTip != null) ...<Widget>[
            const SizedBox(height: 16),
            const _SectionTitle('YOUR DEVICE'),
            GlassCard(
              borderColor: WxColors.amber.withValues(alpha: 0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(Icons.tips_and_updates_outlined,
                          color: WxColors.amber),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          oemTip.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: WxColors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    oemTip.body,
                    style: const TextStyle(
                      fontSize: 13,
                      color: WxColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (final step in oemTip.steps)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Icon(Icons.chevron_right,
                              size: 16, color: WxColors.textMuted),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              step,
                              style: const TextStyle(
                                fontSize: 13,
                                color: WxColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh diagnostics'),
            onPressed: () => ref.invalidate(_ingestDiagnosticsProvider),
          ),
        ],
      ),
    );
  }

  String _detectManufacturer() {
    if (!Platform.isAndroid) return 'Other';
    // Best-effort: read from environment if a hint is available later.
    // For now we rely on package-level env. The OEM-aware advice below covers
    // the common Chinese manufacturers regardless of branding.
    return 'Android';
  }

  ({String title, String body, List<String> steps})? _oemAdvice(String oem) {
    return (
      title: 'Keep WellbeingX awake',
      body:
          'Many Android devices (especially Vivo, MIUI/Xiaomi, ColorOS/Oppo, '
          'OnePlus, Realme, Honor) aggressively kill background apps. Without '
          'these settings, your stats can lag or miss days.',
      steps: <String>[
        'Settings → Battery → Background battery usage → Allow for WellbeingX.',
        'Settings → Apps → WellbeingX → Battery → Don\'t optimize.',
        'On Vivo: enable "High background power consumption" for WellbeingX.',
        'On MIUI: Battery saver → No restrictions, and lock WellbeingX in recents.',
        'Disable any "auto-start manager" restriction for WellbeingX.',
      ],
    );
  }

  int _confidenceScore(PermissionsState perms,
      AsyncValue<({Duration sevenDay, Duration lifetime})> diag) {
    int score = 0;
    if (perms.usageAccess) score += 50;
    if (perms.accessibility) score += 10;
    if (perms.notifications) score += 10;
    if (perms.batteryOptimisationsIgnored) score += 10;
    final week = diag.asData?.value.sevenDay ?? Duration.zero;
    if (week.inMinutes >= 30) score += 10;
    if (week.inMinutes >= 240) score += 10;
    return score.clamp(0, 100);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);
  final String label;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: WxColors.textMuted,
          letterSpacing: 1.6,
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.label,
    required this.ok,
    required this.required_,
    required this.onTap,
  });
  final String label;
  final bool ok;
  final bool required_;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: ok ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: <Widget>[
            Icon(
              ok ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 18,
              color: ok ? WxColors.accent : WxColors.textMuted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: WxColors.textPrimary,
                ),
              ),
            ),
            if (required_ && !ok)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Text(
                  'REQUIRED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: WxColors.amber,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            const Icon(Icons.arrow_forward_ios,
                size: 12, color: WxColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _DiagRow extends StatelessWidget {
  const _DiagRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: WxColors.textPrimary),
          ),
        ),
        Text(value, style: WxTypography.mono(size: 13)),
      ],
    );
  }
}

