import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../core/services/haptics.dart';
import '../../core/services/theme_controller.dart';
import '../shared/widgets/glass_card.dart';

class ThemesScreen extends ConsumerWidget {
  const ThemesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Themes')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
        children: <Widget>[
          const Text(
            'Pick the surface. The accent stays cyan-mint either way.',
            style: TextStyle(color: WxColors.textSecondary),
          ),
          const SizedBox(height: 16),
          for (final v in WxThemeVariant.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ThemeTile(
                variant: v,
                selected: v == current,
                onTap: () {
                  Haptics.tap();
                  ref.read(themeControllerProvider.notifier).set(v);
                },
              ),
            ),
          const SizedBox(height: 18),
          GlassCard(
            borderColor: WxColors.amber.withValues(alpha: 0.25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  'COMING NEXT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: WxColors.amber,
                    letterSpacing: 1.6,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Per-theme accents, focus-mode-only palettes, and unlocked themes earned through streaks.',
                  style: TextStyle(
                    fontSize: 13,
                    color: WxColors.textSecondary,
                    height: 1.5,
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

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.variant,
    required this.selected,
    required this.onTap,
  });
  final WxThemeVariant variant;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      borderColor:
          selected ? WxColors.accent.withValues(alpha: 0.5) : WxColors.hairline,
      child: Row(
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: variant.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WxColors.hairline),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: WxColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  variant.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: WxColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  variant.description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: WxColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (selected)
            const Icon(Icons.check_circle, color: WxColors.accent, size: 22),
        ],
      ),
    );
  }
}
