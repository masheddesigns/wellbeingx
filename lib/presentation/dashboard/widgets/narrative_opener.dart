import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../core/services/adaptive_palette.dart';
import '../../../core/utils/safe_nav.dart';
import '../../../domain/models/narrative.dart';

/// Top-of-dashboard "intelligent" sentence. Color follows adaptive palette so
/// the whole feel of the dashboard shifts with the user's state.
class NarrativeOpener extends StatelessWidget {
  const NarrativeOpener({
    super.key,
    required this.opener,
    required this.palette,
  });

  final Narrative opener;
  final AdaptivePalette palette;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[palette.heroFrom, palette.heroTo],
        ),
        border: Border.all(color: palette.glow.withValues(alpha: 0.18)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: palette.glow.withValues(alpha: 0.08),
            blurRadius: 32,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (opener.emoji != null)
                Text(opener.emoji!, style: const TextStyle(fontSize: 22)),
              if (opener.emoji != null) const SizedBox(width: 8),
              Text(
                palette.mood.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: palette.glow,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            opener.headline,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: WxColors.textPrimary,
              height: 1.2,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            opener.body,
            style: const TextStyle(
              fontSize: 14,
              color: WxColors.textSecondary,
              height: 1.45,
            ),
          ),
          if (opener.cta != null && opener.route != null) ...<Widget>[
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(99),
              onTap: () => context.wxNavigate(opener.route!),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: palette.glow.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      opener.cta!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: palette.glow,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, color: palette.glow, size: 14),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class MilestoneCard extends StatelessWidget {
  const MilestoneCard({super.key, required this.milestone});
  final Narrative milestone;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF1E2A22), Color(0xFF0B0E14)],
        ),
        border: Border.all(color: WxColors.accent.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: <Widget>[
          if (milestone.emoji != null)
            Text(milestone.emoji!, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  milestone.headline,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: WxColors.accent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  milestone.body,
                  style: const TextStyle(
                    fontSize: 12,
                    color: WxColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
