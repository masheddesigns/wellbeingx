import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../core/services/onboarding_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const List<_Slide> _slides = <_Slide>[
    _Slide(
      eyebrow: '01 / WELCOME',
      title: 'Take your attention back.',
      body:
          'WellbeingX is a private, offline lens on your phone life — no account, no cloud, no ads.',
      emoji: '🌑',
    ),
    _Slide(
      eyebrow: '02 / WHAT YOU GET',
      title: 'See the patterns the apps don\'t want you to see.',
      body:
          'Unlocks, micro-checks, sleep misuse, app categories, peak distraction windows, and a focus score.',
      emoji: '📊',
    ),
    _Slide(
      eyebrow: '03 / TOOLS, NOT WALLS',
      title: 'Pomodoro. Stay-Away. Streaks. Coins.',
      body:
          'Block distractions, run focus sessions, level up, and earn rewards for staying intentional.',
      emoji: '⚡',
    ),
    _Slide(
      eyebrow: '04 / PRIVATE BY DESIGN',
      title: 'Everything stays on this device.',
      body:
          'Reset your data any time. Nothing is uploaded. Ever. You own the only copy.',
      emoji: '🔒',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WxColors.void_,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: <Widget>[
                  for (int i = 0; i < _slides.length; i++)
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i == _slides.length - 1 ? 0 : 6),
                        height: 3,
                        decoration: BoxDecoration(
                          color: i <= _index ? WxColors.accent : WxColors.surface3,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                children: <Widget>[
                  TextButton(
                    onPressed: _finish,
                    child: const Text('Skip'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      if (_index < _slides.length - 1) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                        );
                      } else {
                        _finish();
                      }
                    },
                    child: Text(_index < _slides.length - 1 ? 'Next' : "Let's go"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _finish() async {
    await ref.read(installControllerProvider.notifier).completeOnboarding();
    if (!mounted) return;
    context.go('/permissions');
  }
}

class _Slide {
  final String eyebrow;
  final String title;
  final String body;
  final String emoji;
  const _Slide({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.emoji,
  });
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            slide.emoji,
            style: const TextStyle(fontSize: 56),
          ),
          const SizedBox(height: 28),
          Text(
            slide.eyebrow,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: WxColors.accent,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            slide.title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: WxColors.textPrimary,
              height: 1.15,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            slide.body,
            style: const TextStyle(
              fontSize: 16,
              color: WxColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
