import 'package:flutter/material.dart';

class PomodoroPreset {
  final String code;
  final String label;
  final String emoji;
  final IconData icon;
  final Duration work;
  final Duration shortBreak;
  final Duration longBreak;
  final int xpMultiplier; // 1x..3x
  final String mode; // pomodoro|deep|study|coding|workout|custom

  const PomodoroPreset({
    required this.code,
    required this.label,
    required this.emoji,
    required this.icon,
    required this.work,
    required this.shortBreak,
    required this.longBreak,
    required this.xpMultiplier,
    required this.mode,
  });
}

const List<PomodoroPreset> kPresets = <PomodoroPreset>[
  PomodoroPreset(
    code: 'classic',
    label: 'Classic',
    emoji: '🍅',
    icon: Icons.timer_outlined,
    work: Duration(minutes: 25),
    shortBreak: Duration(minutes: 5),
    longBreak: Duration(minutes: 15),
    xpMultiplier: 1,
    mode: 'pomodoro',
  ),
  PomodoroPreset(
    code: 'deep_work',
    label: 'Deep Work',
    emoji: '🎯',
    icon: Icons.bolt_outlined,
    work: Duration(minutes: 90),
    shortBreak: Duration(minutes: 15),
    longBreak: Duration(minutes: 30),
    xpMultiplier: 3,
    mode: 'deep',
  ),
  PomodoroPreset(
    code: 'study',
    label: 'Study',
    emoji: '📚',
    icon: Icons.menu_book_outlined,
    work: Duration(minutes: 50),
    shortBreak: Duration(minutes: 10),
    longBreak: Duration(minutes: 20),
    xpMultiplier: 2,
    mode: 'study',
  ),
  PomodoroPreset(
    code: 'coding',
    label: 'Coding',
    emoji: '💻',
    icon: Icons.terminal_outlined,
    work: Duration(minutes: 60),
    shortBreak: Duration(minutes: 8),
    longBreak: Duration(minutes: 25),
    xpMultiplier: 2,
    mode: 'coding',
  ),
  PomodoroPreset(
    code: 'workout',
    label: 'Workout',
    emoji: '🏋️',
    icon: Icons.fitness_center_outlined,
    work: Duration(minutes: 45),
    shortBreak: Duration(minutes: 5),
    longBreak: Duration(minutes: 15),
    xpMultiplier: 2,
    mode: 'workout',
  ),
  PomodoroPreset(
    code: 'sprint',
    label: 'Sprint',
    emoji: '⚡',
    icon: Icons.flash_on_outlined,
    work: Duration(minutes: 15),
    shortBreak: Duration(minutes: 3),
    longBreak: Duration(minutes: 10),
    xpMultiplier: 1,
    mode: 'pomodoro',
  ),
];
