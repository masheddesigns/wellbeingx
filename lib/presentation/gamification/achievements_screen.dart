import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../data/repositories/gamification_repository.dart';
import '../../domain/models/gamification.dart';
import '../shared/widgets/glass_card.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref.watch(achievementsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: unlocked.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (rows) {
          final unlockedCodes = rows.map((r) => r.code).toSet();
          final unlockedCount = unlockedCodes.length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: <Widget>[
              GlassCard(
                child: Row(
                  children: <Widget>[
                    Text(
                      '$unlockedCount',
                      style: WxTypography.mono(size: 36, color: WxColors.amber),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      ' / ${kAchievements.length}',
                      style: WxTypography.mono(size: 22, color: WxColors.textMuted),
                    ),
                    const Spacer(),
                    const Icon(Icons.emoji_events,
                        color: WxColors.amber, size: 32),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              for (final a in kAchievements)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AchievementTile(
                    def: a,
                    unlocked: unlockedCodes.contains(a.code),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.def, required this.unlocked});
  final AchievementDef def;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: unlocked
          ? WxColors.amber.withValues(alpha: 0.3)
          : WxColors.hairline,
      child: Row(
        children: <Widget>[
          Opacity(
            opacity: unlocked ? 1.0 : 0.35,
            child: Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: WxColors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(def.emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  def.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: unlocked
                        ? WxColors.textPrimary
                        : WxColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  def.description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: WxColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '+${def.xp} XP · +${def.coins} coins',
                  style: WxTypography.mono(
                    size: 11,
                    color: unlocked ? WxColors.amber : WxColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (unlocked)
            const Icon(Icons.check_circle, color: WxColors.amber, size: 22),
        ],
      ),
    );
  }
}
