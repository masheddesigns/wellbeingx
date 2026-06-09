import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/onboarding_service.dart';
import '../../core/utils/date_utils.dart';
import 'gamification_repository.dart';

const _kDailyRewardKey = 'wx_daily_reward_lastClaimedDay';

class DailyReward {
  final int dayInStreak;
  final int xp;
  final int coins;
  final String emoji;
  final String message;
  const DailyReward({
    required this.dayInStreak,
    required this.xp,
    required this.coins,
    required this.emoji,
    required this.message,
  });
}

class DailyRewardController extends Notifier<DailyReward?> {
  @override
  DailyReward? build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final lastDay = prefs.getInt(_kDailyRewardKey);
    final today = WxDates.dayEpoch(DateTime.now());
    if (lastDay == today) return null;
    // Streak position estimated from gap to last claim.
    final gap = lastDay == null ? 0 : today - lastDay;
    final dayInStreak = (gap == 1)
        ? ((prefs.getInt('wx_daily_reward_streak') ?? 0) + 1)
        : 1;
    final reward = _ladder[((dayInStreak - 1) % _ladder.length)];
    return DailyReward(
      dayInStreak: dayInStreak,
      xp: reward.xp,
      coins: reward.coins,
      emoji: reward.emoji,
      message: reward.message,
    );
  }

  Future<void> claim() async {
    final reward = state;
    if (reward == null) return;
    final prefs = await SharedPreferences.getInstance();
    final today = WxDates.dayEpoch(DateTime.now());
    await prefs.setInt(_kDailyRewardKey, today);
    await prefs.setInt('wx_daily_reward_streak', reward.dayInStreak);
    final gami = ref.read(gamificationRepositoryProvider);
    await gami.awardXp(reward.xp);
    await gami.awardCoins(reward.coins);
    state = null;
    ref.invalidate(gamificationStateProvider);
  }
}

final dailyRewardProvider =
    NotifierProvider<DailyRewardController, DailyReward?>(
  DailyRewardController.new,
);

const List<DailyReward> _ladder = <DailyReward>[
  DailyReward(dayInStreak: 1, xp: 25, coins: 2, emoji: '🌱', message: 'Day 1. Plant the streak.'),
  DailyReward(dayInStreak: 2, xp: 35, coins: 3, emoji: '🪴', message: 'Two in a row. Roots forming.'),
  DailyReward(dayInStreak: 3, xp: 50, coins: 5, emoji: '🔥', message: 'Three. The chain is real.'),
  DailyReward(dayInStreak: 4, xp: 70, coins: 7, emoji: '⚡', message: 'Four. Momentum stacking.'),
  DailyReward(dayInStreak: 5, xp: 95, coins: 9, emoji: '🌟', message: 'Five. You are the kind of person who shows up.'),
  DailyReward(dayInStreak: 6, xp: 130, coins: 12, emoji: '🚀', message: 'Six. One day from the weekly arc.'),
  DailyReward(dayInStreak: 7, xp: 200, coins: 20, emoji: '💎', message: 'Week locked. Bonus drop.'),
];
