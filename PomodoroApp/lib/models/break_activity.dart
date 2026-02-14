class BreakActivity {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int durationSeconds;
  final BreakType type;

  const BreakActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.durationSeconds = 60,
    required this.type,
  });

  static const stretch = BreakActivity(
    id: 'stretch',
    title: 'Stretch Your Body',
    description: 'Stand up and do some gentle stretches',
    emoji: '🤸',
    durationSeconds: 120,
    type: BreakType.physical,
  );

  static const water = BreakActivity(
    id: 'water',
    title: 'Hydrate',
    description: 'Drink a glass of water',
    emoji: '💧',
    durationSeconds: 30,
    type: BreakType.health,
  );

  static const eyeRest = BreakActivity(
    id: 'eye_rest',
    title: '20-20-20 Rule',
    description: 'Look at something 20 feet away for 20 seconds',
    emoji: '👁️',
    durationSeconds: 20,
    type: BreakType.health,
  );

  static const breathe = BreakActivity(
    id: 'breathe',
    title: 'Deep Breathing',
    description: 'Take 5 deep breaths',
    emoji: '🧘',
    durationSeconds: 60,
    type: BreakType.mental,
  );

  static const walk = BreakActivity(
    id: 'walk',
    title: 'Take a Walk',
    description: 'Walk around for a few minutes',
    emoji: '🚶',
    durationSeconds: 300,
    type: BreakType.physical,
  );

  static const snack = BreakActivity(
    id: 'snack',
    title: 'Healthy Snack',
    description: 'Eat some fruit or nuts',
    emoji: '🍎',
    durationSeconds: 180,
    type: BreakType.health,
  );

  static const music = BreakActivity(
    id: 'music',
    title: 'Listen to Music',
    description: 'Play your favorite relaxing song',
    emoji: '🎵',
    durationSeconds: 240,
    type: BreakType.mental,
  );

  static const meditation = BreakActivity(
    id: 'meditation',
    title: 'Quick Meditation',
    description: 'Close your eyes and relax',
    emoji: '🕉️',
    durationSeconds: 180,
    type: BreakType.mental,
  );

  static const window = BreakActivity(
    id: 'window',
    title: 'Look Outside',
    description: 'Gaze out the window, rest your mind',
    emoji: '🪟',
    durationSeconds: 60,
    type: BreakType.mental,
  );

  static const posture = BreakActivity(
    id: 'posture',
    title: 'Check Posture',
    description: 'Adjust your sitting position',
    emoji: '🪑',
    durationSeconds: 30,
    type: BreakType.physical,
  );

  static List<BreakActivity> get shortBreakActivities => [
        water,
        eyeRest,
        breathe,
        stretch,
        posture,
        window,
      ];

  static List<BreakActivity> get longBreakActivities => [
        walk,
        snack,
        meditation,
        music,
        stretch,
        breathe,
      ];

  static List<BreakActivity> get all => [
        water,
        eyeRest,
        breathe,
        stretch,
        walk,
        snack,
        music,
        meditation,
        window,
        posture,
      ];
}

enum BreakType {
  physical,
  mental,
  health,
}
