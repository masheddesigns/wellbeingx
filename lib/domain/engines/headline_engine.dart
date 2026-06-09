import '../models/app_category.dart';
import '../models/daily_stats.dart';

/// One emotionally resonant sentence per day. Lives at the very top of the
/// hero. Deterministic — we want consistent feel, not random copy.
class HeroHeadline {
  final String headline;
  final String body;
  final HeadlineMood mood;
  const HeroHeadline({
    required this.headline,
    required this.body,
    required this.mood,
  });
}

enum HeadlineMood { calm, focused, slipping, lost, neutral }

class HeadlineEngine {
  const HeadlineEngine();

  HeroHeadline forToday({
    required DailyStats today,
    required DailyStats yesterday,
  }) {
    final hour = DateTime.now().hour;
    final mins = today.screenTime.inMinutes;
    final social = today.socialTime.inMinutes;
    final productive = today.productiveTime.inMinutes;
    final distract = today.distractionTime.inMinutes;
    final delta = mins - yesterday.screenTime.inMinutes;

    // Almost no usage today.
    if (mins <= 15) {
      return const HeroHeadline(
        headline: 'A quiet day so far.',
        body: 'The phone is barely in your hand. Keep it that way.',
        mood: HeadlineMood.calm,
      );
    }

    // Late night & lots of distraction.
    if (hour >= 22 || hour < 5) {
      if (distract >= 60) {
        return HeroHeadline(
          headline: 'The night took the screen.',
          body: 'Distractions caught ${_h(distract)} after dark today.',
          mood: HeadlineMood.lost,
        );
      }
      return const HeroHeadline(
        headline: 'Wind it down.',
        body: 'Sleep is louder than the feed.',
        mood: HeadlineMood.calm,
      );
    }

    // Morning.
    if (hour < 11) {
      if (today.unlocks <= 5 && mins < 60) {
        return const HeroHeadline(
          headline: 'You\'re winning the morning.',
          body: 'Lock it in — one focus block before email.',
          mood: HeadlineMood.focused,
        );
      }
      if (mins > 90) {
        return HeroHeadline(
          headline: 'A heavy start.',
          body: '${_h(mins)} on the phone before noon.',
          mood: HeadlineMood.slipping,
        );
      }
    }

    // Strongly productive day.
    final share = (productive + distract) == 0
        ? 0.0
        : productive / (productive + distract);
    if (share >= 0.65 && productive >= 60) {
      return HeroHeadline(
        headline: 'You routed the day toward work.',
        body: '${_h(productive)} on productive apps.',
        mood: HeadlineMood.focused,
      );
    }

    // Distraction leading.
    if (distract >= 120 && distract > productive * 2) {
      // Find the dominant category for color.
      AppCategory? top;
      Duration topDur = Duration.zero;
      today.byCategory.forEach((k, v) {
        if (k.isDistracting && v > topDur) {
          topDur = v;
          top = k;
        }
      });
      final cat = top?.label.toLowerCase() ?? 'short-form content';
      return HeroHeadline(
        headline: 'Today slipped away.',
        body: '${_h(distract)} disappeared into $cat.',
        mood: HeadlineMood.lost,
      );
    }

    // Social-heavy day.
    if (social >= 90) {
      return HeroHeadline(
        headline: 'The feeds had a strong day.',
        body: '${_h(social)} on social platforms so far.',
        mood: HeadlineMood.slipping,
      );
    }

    // Trend headline.
    if (yesterday.screenTime.inMinutes > 0) {
      if (delta <= -45) {
        return HeroHeadline(
          headline: 'Lighter than yesterday.',
          body: '${_h(-delta)} less screen time so far.',
          mood: HeadlineMood.focused,
        );
      }
      if (delta >= 60) {
        return HeroHeadline(
          headline: 'Heavier than yesterday.',
          body: '${_h(delta)} more screen time so far.',
          mood: HeadlineMood.slipping,
        );
      }
    }

    // Default — a steady, balanced read.
    return HeroHeadline(
      headline: 'A measured day.',
      body: '${_h(mins)} on the phone so far.',
      mood: HeadlineMood.neutral,
    );
  }

  String _h(int m) {
    if (m < 60) return '${m}m';
    final h = m ~/ 60;
    final r = m.remainder(60);
    if (r == 0) return '${h}h';
    return '${h}h ${r}m';
  }
}
