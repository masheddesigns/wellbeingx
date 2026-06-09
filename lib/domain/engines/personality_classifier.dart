import '../models/app_category.dart';
import '../models/daily_stats.dart';
import '../models/personality_type.dart';

class PersonalityClassifier {
  const PersonalityClassifier();

  PersonalityType classify(List<DailyStats> last7Days) {
    if (last7Days.isEmpty) return PersonalityType.balanced;

    final byCat = <AppCategory, Duration>{};
    Duration nightMs = Duration.zero;
    Duration totalMs = Duration.zero;
    int shortUnlocks = 0;

    for (final d in last7Days) {
      d.byCategory.forEach((k, v) {
        byCat.update(k, (cur) => cur + v, ifAbsent: () => v);
      });
      totalMs += d.screenTime;
      shortUnlocks += d.shortUnlocks;
      d.hourBuckets.forEach((h, dur) {
        if (h >= 22 || h < 2) nightMs += dur;
      });
    }

    if (totalMs.inMinutes == 0) return PersonalityType.balanced;

    final social = byCat[AppCategory.social] ?? Duration.zero;
    final entertainment = byCat[AppCategory.entertainment] ?? Duration.zero;
    final productive = (byCat[AppCategory.productivity] ?? Duration.zero) +
        (byCat[AppCategory.education] ?? Duration.zero);
    final communication = byCat[AppCategory.communication] ?? Duration.zero;

    final socialPct = social.inMinutes / totalMs.inMinutes;
    final entertainmentPct = entertainment.inMinutes / totalMs.inMinutes;
    final productivePct = productive.inMinutes / totalMs.inMinutes;
    final commPct = communication.inMinutes / totalMs.inMinutes;
    final nightPct = nightMs.inMinutes / totalMs.inMinutes;
    final shortUnlockRate =
        shortUnlocks / (last7Days.length == 0 ? 1 : last7Days.length);

    // Order matters — strongest signal wins.
    if (nightPct >= 0.30) return PersonalityType.nightOwl;
    if (shortUnlockRate >= 25 || (socialPct + entertainmentPct) >= 0.55) {
      return PersonalityType.doomScroller;
    }
    if (productivePct >= 0.40 && (socialPct + entertainmentPct) <= 0.20) {
      return PersonalityType.focusedMonk;
    }
    if (productivePct >= 0.25 && commPct >= 0.20) {
      return PersonalityType.hustler;
    }
    if (commPct + socialPct >= 0.45) return PersonalityType.socialButterfly;
    return PersonalityType.balanced;
  }
}
