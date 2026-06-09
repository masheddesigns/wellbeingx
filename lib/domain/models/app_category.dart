enum AppCategory {
  social('social', 'Social'),
  entertainment('entertainment', 'Entertainment'),
  gaming('gaming', 'Gaming'),
  communication('communication', 'Communication'),
  productivity('productivity', 'Productivity'),
  education('education', 'Education'),
  utility('utility', 'Utility'),
  other('other', 'Other');

  final String code;
  final String label;
  const AppCategory(this.code, this.label);

  static AppCategory fromCode(String? code) {
    if (code == null) return AppCategory.other;
    return AppCategory.values.firstWhere(
      (c) => c.code == code,
      orElse: () => AppCategory.other,
    );
  }

  bool get isDistracting =>
      this == AppCategory.social ||
      this == AppCategory.entertainment ||
      this == AppCategory.gaming;

  bool get isProductive =>
      this == AppCategory.productivity || this == AppCategory.education;
}

/// Best-effort heuristic mapping by package-name prefix / hint substrings.
/// On Android we can also use ApplicationInfo.category — we feed both.
class CategoryHeuristics {
  CategoryHeuristics._();

  static const Map<AppCategory, List<String>> _hints = <AppCategory, List<String>>{
    AppCategory.social: <String>[
      'instagram', 'facebook', 'twitter', 'x.android', 'tiktok', 'snapchat',
      'reddit', 'pinterest', 'threads', 'bsky', 'tumblr', 'mastodon',
    ],
    AppCategory.entertainment: <String>[
      'youtube', 'netflix', 'primevideo', 'hulu', 'disney', 'spotify',
      'twitch', 'hotstar', 'crunchyroll',
    ],
    AppCategory.gaming: <String>[
      'pubg', 'roblox', 'minecraft', 'codm', 'fortnite', 'genshin', 'mobilelegends',
      'game', 'mihoyo',
    ],
    AppCategory.communication: <String>[
      'whatsapp', 'telegram', 'messenger', 'discord', 'signal', 'slack', 'mail',
      'gmail', 'outlook', 'phone', 'dialer', 'sms', 'mms', 'messaging',
    ],
    AppCategory.productivity: <String>[
      'docs', 'sheets', 'slides', 'keep', 'notion', 'todoist', 'evernote',
      'office', 'word', 'excel', 'outlook', 'asana', 'trello', 'linear',
      'github', 'gitlab', 'figma', 'canva', 'calendar',
    ],
    AppCategory.education: <String>[
      'duolingo', 'khan', 'coursera', 'udemy', 'edx', 'brilliant', 'anki',
      'quizlet', 'school', 'class', 'study',
    ],
    AppCategory.utility: <String>[
      'settings', 'launcher', 'systemui', 'maps', 'navigation', 'clock',
      'calculator', 'files', 'documents', 'photos', 'camera', 'weather',
      'wallet', 'pay', 'bank',
    ],
  };

  static AppCategory classify(String packageName, [String? appName]) {
    final pkg = packageName.toLowerCase();
    final name = appName?.toLowerCase() ?? '';
    for (final entry in _hints.entries) {
      for (final hint in entry.value) {
        if (pkg.contains(hint) || name.contains(hint)) return entry.key;
      }
    }
    return AppCategory.other;
  }
}
