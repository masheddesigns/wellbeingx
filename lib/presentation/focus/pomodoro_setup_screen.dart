import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/services/haptics.dart';
import '../../domain/models/pomodoro_preset.dart';
import '../shared/widgets/glass_card.dart';
import 'focus_controller.dart';

class PomodoroSetupScreen extends ConsumerStatefulWidget {
  const PomodoroSetupScreen({super.key});
  @override
  ConsumerState<PomodoroSetupScreen> createState() => _PomodoroSetupScreenState();
}

class _PomodoroSetupScreenState extends ConsumerState<PomodoroSetupScreen> {
  PomodoroPreset _preset = kPresets.first;
  String? _tag;
  final TextEditingController _custom = TextEditingController();

  static const List<String> _suggestedTags = <String>[
    'study', 'work', 'writing', 'coding', 'reading',
    'planning', 'learning', 'creative', 'workout', 'admin',
  ];

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set up focus')),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: <Widget>[
                  const Text(
                    'CHOOSE A MODE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: WxColors.textMuted,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.55,
                    ),
                    itemCount: kPresets.length,
                    itemBuilder: (_, i) {
                      final p = kPresets[i];
                      final selected = p.code == _preset.code;
                      return _PresetCard(
                        preset: p,
                        selected: selected,
                        onTap: () {
                          Haptics.tap();
                          setState(() => _preset = p);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'WHAT WILL YOU DO?',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: WxColors.textMuted,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      for (final t in _suggestedTags)
                        ChoiceChip(
                          label: Text(t),
                          selected: _tag == t,
                          onSelected: (_) {
                            Haptics.tap();
                            setState(() {
                              _tag = _tag == t ? null : t;
                              _custom.clear();
                            });
                          },
                          selectedColor: WxColors.accent,
                          backgroundColor: WxColors.surface2,
                          side: const BorderSide(color: WxColors.hairline),
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _tag == t
                                ? WxColors.void_
                                : WxColors.textPrimary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _custom,
                    onChanged: (v) => setState(() {
                      _tag = v.trim().isEmpty ? null : v.trim();
                    }),
                    decoration: const InputDecoration(
                      hintText: 'Custom intent (optional)',
                      filled: true,
                      fillColor: WxColors.surface1,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              decoration: const BoxDecoration(
                color: WxColors.surface0,
                border: Border(
                  top: BorderSide(color: WxColors.hairline),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('${_preset.work.inMinutes} min',
                            style: WxTypography.mono(size: 24)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: WxColors.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            '${_preset.xpMultiplier}× XP',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: WxColors.accent,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text('Start ${_preset.label}'),
                        onPressed: () {
                          Haptics.success();
                          // Capture the selection locally, navigate first,
                          // then mutate after the frame completes. Avoids
                          // Riverpod rebuilding mid-navigation.
                          final preset = _preset;
                          final tag = _tag;
                          context.pushReplacement('/focus-ritual');
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ref
                                .read(focusControllerProvider.notifier)
                                .selectPreset(preset, tag: tag);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.preset,
    required this.selected,
    required this.onTap,
  });
  final PomodoroPreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      borderColor:
          selected ? WxColors.accent.withValues(alpha: 0.6) : WxColors.hairline,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(preset.emoji, style: const TextStyle(fontSize: 20)),
              const Spacer(),
              if (preset.xpMultiplier > 1)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: WxColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${preset.xpMultiplier}×',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: WxColors.accent,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            preset.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: WxColors.textPrimary,
            ),
          ),
          Text(
            '${preset.work.inMinutes}m work · ${preset.shortBreak.inMinutes}m break',
            style: const TextStyle(
              fontSize: 11,
              color: WxColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
