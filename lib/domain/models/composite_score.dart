import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../app/theme/colors.dart';

/// Premium composite scores. Each is 0..100 and exposes an emotional band
/// (color + caption) so the UI can feel adaptive without ever showing raw maths.
class CompositeScore extends Equatable {
  final String code;
  final String label;
  final int value; // 0..100
  final int delta; // +/- vs previous period
  final String headline; // one-line story
  final String detail; // why this number is what it is
  final ScoreBand band;

  const CompositeScore({
    required this.code,
    required this.label,
    required this.value,
    required this.delta,
    required this.headline,
    required this.detail,
    required this.band,
  });

  Color get color {
    switch (band) {
      case ScoreBand.calm:
        return WxColors.accent;
      case ScoreBand.steady:
        return WxColors.cyan;
      case ScoreBand.alert:
        return WxColors.amber;
      case ScoreBand.critical:
        return WxColors.crimson;
    }
  }

  @override
  List<Object?> get props =>
      <Object?>[code, label, value, delta, headline, detail, band];
}

enum ScoreBand { calm, steady, alert, critical }

/// Container of every composite + an overall "balance" indicator.
class ScorePack extends Equatable {
  final CompositeScore digitalBalance;
  final CompositeScore attentionFragmentation;
  final CompositeScore notificationAnxiety;
  final CompositeScore appDependency;
  final CompositeScore socialToxicity;

  const ScorePack({
    required this.digitalBalance,
    required this.attentionFragmentation,
    required this.notificationAnxiety,
    required this.appDependency,
    required this.socialToxicity,
  });

  List<CompositeScore> get all => <CompositeScore>[
        digitalBalance,
        attentionFragmentation,
        notificationAnxiety,
        appDependency,
        socialToxicity,
      ];

  @override
  List<Object?> get props => all;
}
