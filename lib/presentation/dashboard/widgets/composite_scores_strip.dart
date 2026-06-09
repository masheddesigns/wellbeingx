import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../core/services/haptics.dart';
import '../../../domain/models/composite_score.dart';
import '../../shared/widgets/glass_card.dart';

class CompositeScoresStrip extends StatelessWidget {
  const CompositeScoresStrip({super.key, required this.scores});
  final ScorePack scores;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 124,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: scores.all.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _ScoreTile(score: scores.all[i]),
          ),
        ),
      ],
    );
  }
}

class _ScoreTile extends StatelessWidget {
  const _ScoreTile({required this.score});
  final CompositeScore score;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: GlassCard(
        borderColor: score.color.withValues(alpha: 0.25),
        padding: const EdgeInsets.all(14),
        onTap: () {
          Haptics.tap();
          context.push('/insights');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              score.label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: score.color,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  '${score.value}',
                  style: WxTypography.mono(
                    size: 30,
                    weight: FontWeight.w800,
                    color: score.color,
                  ),
                ),
                const SizedBox(width: 4),
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text(
                    '/100',
                    style: TextStyle(
                      fontSize: 11,
                      color: WxColors.textMuted,
                    ),
                  ),
                ),
                const Spacer(),
                if (score.delta != 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: score.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '${score.delta > 0 ? '+' : ''}${score.delta}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: score.color,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                score.headline,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: WxColors.textSecondary,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
