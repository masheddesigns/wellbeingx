import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/services/onboarding_service.dart';
import '../../core/utils/duration_format.dart';
import '../../data/repositories/usage_repository.dart';
import '../shared/widgets/glass_card.dart';
import '../shared/widgets/section_header.dart';

final _lifetimeProvider = FutureProvider<({Duration total, int days})>((ref) async {
  final repo = ref.watch(usageRepositoryProvider);
  final total = await repo.lifetimeScreenTime();
  final install = ref.watch(installControllerProvider);
  final days = DateTime.now().difference(install.installedAt).inDays + 1;
  return (total: total, days: days);
});

class LifetimeScreen extends ConsumerWidget {
  const LifetimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(_lifetimeProvider);
    final install = ref.watch(installControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Lifetime')),
      body: view.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (v) {
          final mins = v.total.inMinutes;
          final daysOnPhone = (mins / 60 / 24);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Color(0xFF12161F), Color(0xFF0B0E14)],
                  ),
                  border: Border.all(color: WxColors.hairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'TIME ON DEVICE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: WxColors.textMuted,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      v.total.formatHm(),
                      style: WxTypography.mono(
                          size: 56, weight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      v.days == 0
                          ? 'no data yet'
                          : '${(mins / v.days).round()} min/day average across ${v.days} day${v.days == 1 ? '' : 's'} of tracking',
                      style: const TextStyle(
                        fontSize: 13,
                        color: WxColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _LifetimeTile(
                      label: 'DAYS ON PHONE',
                      value: daysOnPhone.toStringAsFixed(2),
                      caption: '24h equivalent',
                      accent: WxColors.violet,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _LifetimeTile(
                      label: 'TRACKING SINCE',
                      value: DateFormat('d MMM').format(install.installedAt),
                      caption: DateFormat('yyyy').format(install.installedAt),
                      accent: WxColors.cyan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const SectionHeader(title: 'PROJECTIONS'),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _ProjectionRow(
                      label: 'In a year',
                      value: Duration(minutes: (mins / v.days * 365).round())
                          .formatHm(),
                    ),
                    const Divider(height: 24),
                    _ProjectionRow(
                      label: 'In 5 years',
                      value: Duration(minutes: (mins / v.days * 365 * 5).round())
                          .formatHm(),
                    ),
                    const Divider(height: 24),
                    _ProjectionRow(
                      label: 'In a decade',
                      value: Duration(minutes: (mins / v.days * 365 * 10).round())
                          .formatHm(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                borderColor: WxColors.amber.withValues(alpha: 0.25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    Text(
                      'NUMBERS, NOT JUDGEMENT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: WxColors.amber,
                        letterSpacing: 1.6,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'A phone is a tool. Tracking is just the mirror. What you do with the reflection is the part that matters.',
                      style: TextStyle(
                        fontSize: 14,
                        color: WxColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LifetimeTile extends StatelessWidget {
  const _LifetimeTile({
    required this.label,
    required this.value,
    required this.caption,
    required this.accent,
  });
  final String label;
  final String value;
  final String caption;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: accent.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: accent,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(value, style: WxTypography.mono(size: 22)),
          const SizedBox(height: 4),
          Text(
            caption,
            style: const TextStyle(
              fontSize: 11,
              color: WxColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectionRow extends StatelessWidget {
  const _ProjectionRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: WxColors.textPrimary,
            ),
          ),
        ),
        Text(value, style: WxTypography.mono(size: 16)),
      ],
    );
  }
}
