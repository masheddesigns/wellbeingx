import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../domain/models/gamification.dart';

class StreakStrip extends StatelessWidget {
  const StreakStrip({super.key, required this.gami});
  final GamificationState gami;

  @override
  Widget build(BuildContext context) {
    final (progress, next) = gami.levelProgress;
    final pct = next == 0 ? 0.0 : progress / next;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => context.go('/profile'),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        decoration: BoxDecoration(
          color: WxColors.surface1,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: WxColors.hairline),
        ),
        child: Row(
          children: <Widget>[
            _Pill(
              icon: '🔥',
              label: '${gami.currentStreak}d',
              accent: WxColors.amber,
              caption: 'streak',
            ),
            const SizedBox(width: 12),
            _Pill(
              icon: '⚡',
              label: 'L${gami.level}',
              accent: WxColors.accent,
              caption: '$progress / $next xp',
            ),
            const SizedBox(width: 12),
            _Pill(
              icon: '🪙',
              label: '${gami.coins}',
              accent: WxColors.cyan,
              caption: 'focus coins',
            ),
            const Spacer(),
            SizedBox(
              width: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: pct.clamp(0.05, 1.0),
                  backgroundColor: WxColors.surface3,
                  minHeight: 4,
                  valueColor: const AlwaysStoppedAnimation<Color>(WxColors.accent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.accent,
    required this.caption,
  });
  final String icon;
  final String label;
  final Color accent;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(label, style: WxTypography.mono(size: 16, color: accent)),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          caption,
          style: const TextStyle(fontSize: 10, color: WxColors.textMuted),
        ),
      ],
    );
  }
}
