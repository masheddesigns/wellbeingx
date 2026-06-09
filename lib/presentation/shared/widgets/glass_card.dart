import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';

/// Quiet card with a hairline border and a subtle gradient sheen.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.borderColor,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WxColors.surface1,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: WxColors.accent.withValues(alpha: 0.06),
        highlightColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient ??
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    WxColors.surface1,
                    WxColors.surface1.withValues(alpha: 0.85),
                  ],
                ),
            border: Border.all(
              color: borderColor ?? WxColors.hairline,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Tiny pill — for category labels, status flags, etc.
class WxPill extends StatelessWidget {
  const WxPill({
    super.key,
    required this.label,
    this.color,
    this.icon,
  });
  final String label;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = color ?? WxColors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: c.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 11, color: c),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}
