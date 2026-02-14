class TimerPreset {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int workMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int sessionsBeforeLongBreak;
  final bool isCustom;

  const TimerPreset({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.workMinutes,
    required this.shortBreakMinutes,
    required this.longBreakMinutes,
    this.sessionsBeforeLongBreak = 4,
    this.isCustom = false,
  });

  // Built-in presets
  static const deepWork = TimerPreset(
    id: 'deep_work',
    name: 'Deep Work',
    description: 'For intense focus sessions',
    emoji: '🧠',
    workMinutes: 90,
    shortBreakMinutes: 15,
    longBreakMinutes: 30,
    sessionsBeforeLongBreak: 2,
  );

  static const studySession = TimerPreset(
    id: 'study',
    name: 'Study Session',
    description: 'Balanced learning periods',
    emoji: '📚',
    workMinutes: 50,
    shortBreakMinutes: 10,
    longBreakMinutes: 20,
    sessionsBeforeLongBreak: 3,
  );

  static const quickSprint = TimerPreset(
    id: 'quick_sprint',
    name: 'Quick Sprint',
    description: 'Ultra-short focus bursts',
    emoji: '⚡',
    workMinutes: 15,
    shortBreakMinutes: 3,
    longBreakMinutes: 10,
    sessionsBeforeLongBreak: 4,
  );

  static const flowState = TimerPreset(
    id: 'flow_state',
    name: 'Flow State',
    description: 'Extended focus time',
    emoji: '🌊',
    workMinutes: 120,
    shortBreakMinutes: 20,
    longBreakMinutes: 40,
    sessionsBeforeLongBreak: 2,
  );

  static const classicPomodoro = TimerPreset(
    id: 'classic',
    name: 'Classic Pomodoro',
    description: 'Traditional 25-5 technique',
    emoji: '🍅',
    workMinutes: 25,
    shortBreakMinutes: 5,
    longBreakMinutes: 15,
    sessionsBeforeLongBreak: 4,
  );

  static const creativeWork = TimerPreset(
    id: 'creative',
    name: 'Creative Work',
    description: 'For artistic flow',
    emoji: '🎨',
    workMinutes: 45,
    shortBreakMinutes: 15,
    longBreakMinutes: 30,
    sessionsBeforeLongBreak: 3,
  );

  static List<TimerPreset> get defaultPresets => [
        classicPomodoro,
        quickSprint,
        studySession,
        deepWork,
        flowState,
        creativeWork,
      ];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'emoji': emoji,
        'workMinutes': workMinutes,
        'shortBreakMinutes': shortBreakMinutes,
        'longBreakMinutes': longBreakMinutes,
        'sessionsBeforeLongBreak': sessionsBeforeLongBreak,
        'isCustom': isCustom,
      };

  factory TimerPreset.fromJson(Map<String, dynamic> json) => TimerPreset(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        emoji: json['emoji'],
        workMinutes: json['workMinutes'],
        shortBreakMinutes: json['shortBreakMinutes'],
        longBreakMinutes: json['longBreakMinutes'],
        sessionsBeforeLongBreak: json['sessionsBeforeLongBreak'] ?? 4,
        isCustom: json['isCustom'] ?? false,
      );
}
