import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';

/// Replaces the default red-screen crash overlay with a calm, debuggable card.
/// Wired in [WellbeingXApp] via `ErrorWidget.builder`.
class WxErrorCard extends StatelessWidget {
  const WxErrorCard({super.key, required this.details});
  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    final summary =
        details.exceptionAsString().split('\n').first.trim();
    final library = details.library ?? 'unknown';
    return Material(
      color: WxColors.void_,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'WX_ERROR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: WxColors.crimson,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Something on this screen crashed.',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: WxColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                summary,
                style: WxTypography.mono(
                  size: 12,
                  color: WxColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'in $library',
                style: const TextStyle(
                  fontSize: 11,
                  color: WxColors.textMuted,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Use the back button to return.',
                style: const TextStyle(
                  fontSize: 13,
                  color: WxColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
