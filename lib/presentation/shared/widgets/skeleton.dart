import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';

/// Quiet shimmering rectangle for loading states.
class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height = 14,
    this.radius = 6,
  });
  final double? width;
  final double height;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Color.lerp(
            WxColors.surface2,
            WxColors.surface3,
            _ctrl.value,
          ),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.height = 100});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: WxColors.surface1,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WxColors.hairline),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          Skeleton(width: 80, height: 10),
          SizedBox(height: 14),
          Skeleton(width: 160, height: 22),
          SizedBox(height: 10),
          Skeleton(width: 220, height: 12),
        ],
      ),
    );
  }
}

/// Fade + slight slide-up entry — the default reveal motion.
class FadeRise extends StatelessWidget {
  const FadeRise({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.distance = 12,
    this.duration = const Duration(milliseconds: 360),
  });

  final Widget child;
  final Duration delay;
  final double distance;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final totalDuration = duration + delay;
    final delayMs = delay.inMilliseconds;
    final totalMs = totalDuration.inMilliseconds;
    final durationMs = duration.inMilliseconds;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: totalDuration,
      curve: Curves.linear, // Use linear here so we can apply easeOutCubic curve manually on the active range
      builder: (_, raw, __) {
        final t = totalMs == 0 || durationMs == 0
            ? 1.0
            : ((raw * totalMs - delayMs) / durationMs).clamp(0.0, 1.0);
        final eased = Curves.easeOutCubic.transform(t);
        return Opacity(
          opacity: eased,
          child: Transform.translate(
            offset: Offset(0, (1 - eased) * distance),
            child: child,
          ),
        );
      },
    );
  }
}
