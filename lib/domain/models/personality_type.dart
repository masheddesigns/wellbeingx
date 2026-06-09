enum PersonalityType {
  nightOwl(
    'night_owl',
    'Night Owl',
    'You come alive after dark. Most of your screen time is between 10pm and 2am.',
    '🌙',
  ),
  doomScroller(
    'doom_scroller',
    'Doom Scroller',
    'Short-form content claims a big chunk of your day. The infinite feed has a strong grip.',
    '🌀',
  ),
  focusedMonk(
    'focused_monk',
    'Focused Monk',
    'You unlock with intent and stay there. Distraction apps barely show up in your stats.',
    '🧘',
  ),
  hustler(
    'hustler',
    'Hustler',
    'Productivity & communication apps dominate your screen time. You ship.',
    '⚡',
  ),
  socialButterfly(
    'social_butterfly',
    'Social Butterfly',
    'You spend serious time across messaging and social platforms staying connected.',
    '🦋',
  ),
  balanced(
    'balanced',
    'Balanced',
    'No one category runs your life. A healthy spread across work, rest, and play.',
    '⚖️',
  );

  final String code;
  final String label;
  final String description;
  final String emoji;
  const PersonalityType(this.code, this.label, this.description, this.emoji);
}
