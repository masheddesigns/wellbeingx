import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/utils/duration_format.dart';
import '../../data/repositories/usage_repository.dart';
import '../../domain/engines/personality_classifier.dart';
import '../../domain/models/app_category.dart';
import '../../domain/models/daily_stats.dart';
import '../../domain/models/personality_type.dart';
import '../shared/widgets/glass_card.dart';

class _PersonalityView {
  final PersonalityType type;
  final List<DailyStats> last7;
  const _PersonalityView({required this.type, required this.last7});
}

final _personalityProvider = FutureProvider<_PersonalityView>((ref) async {
  final last7 = await ref.watch(usageRepositoryProvider).rangeStats(7);
  final type = const PersonalityClassifier().classify(last7);
  return _PersonalityView(type: type, last7: last7);
});

class PersonalityScreen extends ConsumerWidget {
  const PersonalityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(_personalityProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Digital personality')),
      body: view.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (v) {
          final p = v.type;
          final byCat = <AppCategory, Duration>{};
          for (final d in v.last7) {
            d.byCategory.forEach((k, v) {
              byCat.update(k, (cur) => cur + v, ifAbsent: () => v);
            });
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Color(0xFF1A1226),
                      Color(0xFF0B0E14),
                    ],
                  ),
                  border: Border.all(
                      color: WxColors.violet.withValues(alpha: 0.18)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(p.emoji, style: const TextStyle(fontSize: 56)),
                    const SizedBox(height: 16),
                    Text(
                      'YOU ARE A',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: WxColors.textMuted,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.label,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: WxColors.textPrimary,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      p.description,
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: WxColors.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'WEEKLY MIX',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: WxColors.textMuted,
                        letterSpacing: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final e in (byCat.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value))))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: WxColors.category[e.key.code],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                e.key.label,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: WxColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              e.value.formatHm(),
                              style: WxTypography.mono(size: 12),
                            ),
                          ],
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
