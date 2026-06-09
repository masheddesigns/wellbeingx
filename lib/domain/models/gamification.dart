import 'package:equatable/equatable.dart';

/// XP curve: each level needs (level * 100) XP. Simple & legible.
class LevelMath {
  static int xpForLevel(int level) => level * 100;
  static int totalXpForLevel(int level) {
    int total = 0;
    for (int l = 1; l < level; l++) {
      total += xpForLevel(l);
    }
    return total;
  }

  static int levelFromXp(int xp) {
    int level = 1;
    int remaining = xp;
    while (remaining >= xpForLevel(level)) {
      remaining -= xpForLevel(level);
      level++;
    }
    return level;
  }

  /// Returns [progressXp, nextXp] within current level.
  static (int, int) progressInLevel(int xp) {
    int level = 1;
    int remaining = xp;
    while (remaining >= xpForLevel(level)) {
      remaining -= xpForLevel(level);
      level++;
    }
    return (remaining, xpForLevel(level));
  }
}

class GamificationState extends Equatable {
  final int xp;
  final int coins;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDay;

  const GamificationState({
    required this.xp,
    required this.coins,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActiveDay,
  });

  factory GamificationState.initial() => const GamificationState(
        xp: 0,
        coins: 0,
        currentStreak: 0,
        longestStreak: 0,
        lastActiveDay: null,
      );

  int get level => LevelMath.levelFromXp(xp);
  (int, int) get levelProgress => LevelMath.progressInLevel(xp);

  GamificationState copyWith({
    int? xp,
    int? coins,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDay,
  }) =>
      GamificationState(
        xp: xp ?? this.xp,
        coins: coins ?? this.coins,
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        lastActiveDay: lastActiveDay ?? this.lastActiveDay,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'xp': xp,
        'coins': coins,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastActiveDay': lastActiveDay?.millisecondsSinceEpoch,
      };

  factory GamificationState.fromJson(Map<String, dynamic> j) =>
      GamificationState(
        xp: (j['xp'] as num?)?.toInt() ?? 0,
        coins: (j['coins'] as num?)?.toInt() ?? 0,
        currentStreak: (j['currentStreak'] as num?)?.toInt() ?? 0,
        longestStreak: (j['longestStreak'] as num?)?.toInt() ?? 0,
        lastActiveDay: j['lastActiveDay'] is int
            ? DateTime.fromMillisecondsSinceEpoch(j['lastActiveDay'] as int)
            : null,
      );

  @override
  List<Object?> get props =>
      <Object?>[xp, coins, currentStreak, longestStreak, lastActiveDay];
}

class AchievementDef {
  final String code;
  final String title;
  final String description;
  final String emoji;
  final int xp;
  final int coins;
  final int target;

  const AchievementDef({
    required this.code,
    required this.title,
    required this.description,
    required this.emoji,
    required this.xp,
    required this.coins,
    this.target = 1,
  });
}

/// Focus leagues — long-term identity tier. Reset monthly.
enum FocusLeague {
  drift('Drift', 'Just starting to take control.', '🌫️', 0),
  bronze('Bronze', 'Showing up. The hardest part.', '🥉', 300),
  silver('Silver', 'Steady focus, real momentum.', '🥈', 800),
  gold('Gold', 'In the zone, most days.', '🥇', 1800),
  platinum('Platinum', 'Distraction is the exception.', '💎', 4000),
  diamond('Diamond', 'Top of the focus game.', '🪩', 8000);

  final String label;
  final String description;
  final String emoji;
  final int xpRequired;
  const FocusLeague(this.label, this.description, this.emoji, this.xpRequired);

  static FocusLeague fromXp(int xp) {
    FocusLeague last = FocusLeague.drift;
    for (final l in FocusLeague.values) {
      if (xp >= l.xpRequired) last = l;
    }
    return last;
  }

  FocusLeague? get next {
    final i = FocusLeague.values.indexOf(this);
    return i + 1 < FocusLeague.values.length
        ? FocusLeague.values[i + 1]
        : null;
  }
}

const List<AchievementDef> kAchievements = <AchievementDef>[
  AchievementDef(
    code: 'first_focus',
    title: 'First Step',
    description: 'Complete your first focus session.',
    emoji: '🌱',
    xp: 50,
    coins: 5,
  ),
  AchievementDef(
    code: 'streak_3',
    title: 'On a Roll',
    description: '3-day focus streak.',
    emoji: '🔥',
    xp: 100,
    coins: 10,
    target: 3,
  ),
  AchievementDef(
    code: 'streak_7',
    title: 'Week of Will',
    description: '7-day focus streak.',
    emoji: '💪',
    xp: 250,
    coins: 25,
    target: 7,
  ),
  AchievementDef(
    code: 'streak_30',
    title: 'Iron Mind',
    description: '30-day focus streak.',
    emoji: '🧠',
    xp: 1000,
    coins: 100,
    target: 30,
  ),
  AchievementDef(
    code: 'deep_work_2h',
    title: 'In the Zone',
    description: '2-hour deep work session.',
    emoji: '🎯',
    xp: 200,
    coins: 20,
  ),
  AchievementDef(
    code: 'zero_unlock_morning',
    title: 'Mindful Morning',
    description: 'Zero unlocks for an hour after waking.',
    emoji: '☀️',
    xp: 80,
    coins: 8,
  ),
  AchievementDef(
    code: 'social_under_30',
    title: 'Quiet Day',
    description: 'Stay under 30m of social media.',
    emoji: '🍃',
    xp: 120,
    coins: 12,
  ),
  AchievementDef(
    code: 'pomodoros_10',
    title: 'Tomato Farmer',
    description: 'Complete 10 Pomodoro sessions.',
    emoji: '🍅',
    xp: 150,
    coins: 15,
    target: 10,
  ),
  AchievementDef(
    code: 'phone_free_day',
    title: 'Off Grid',
    description: 'Under 1 hour of total screen time in a day.',
    emoji: '🏔️',
    xp: 300,
    coins: 30,
  ),
  AchievementDef(
    code: 'ghost_week_complete',
    title: 'Ghost Week',
    description: 'Complete a 7-day silent observation.',
    emoji: '👻',
    xp: 200,
    coins: 20,
  ),
  // --- Hidden / surprise achievements ---
  AchievementDef(
    code: 'before_sunrise',
    title: 'Before Sunrise',
    description: 'Complete a focus session before 7am.',
    emoji: '🌅',
    xp: 120,
    coins: 12,
  ),
  AchievementDef(
    code: 'no_doomscroll_week',
    title: 'Spell Broken',
    description: 'A full week without a single doomscroll session.',
    emoji: '🪞',
    xp: 400,
    coins: 40,
  ),
  AchievementDef(
    code: 'comeback_streak',
    title: 'Phoenix',
    description: 'Recovered a focus streak after losing one.',
    emoji: '🪶',
    xp: 200,
    coins: 20,
  ),
  AchievementDef(
    code: 'silent_evening',
    title: 'Silent Evening',
    description: 'Zero unlocks between 22:00 and midnight.',
    emoji: '🌌',
    xp: 180,
    coins: 18,
  ),
  AchievementDef(
    code: 'no_overrides_week',
    title: 'Iron Willed',
    description: 'A full week with zero Stay-Away overrides.',
    emoji: '🛡️',
    xp: 300,
    coins: 30,
  ),
  AchievementDef(
    code: 'morning_ritual_5',
    title: 'Morning Ritual',
    description: '5 mornings in a row without checking distractions before 9am.',
    emoji: '☕',
    xp: 200,
    coins: 20,
    target: 5,
  ),
  AchievementDef(
    code: 'session_tagger',
    title: 'Tag Master',
    description: 'Tag 10 focus sessions with intent.',
    emoji: '🏷️',
    xp: 100,
    coins: 10,
    target: 10,
  ),
];
