import 'package:flutter/material.dart';

class TimerPreset {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int workMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int sessionsBeforeLongBreak;
  final bool isBuiltIn;

  const TimerPreset({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.workMinutes,
    required this.shortBreakMinutes,
    required this.longBreakMinutes,
    required this.sessionsBeforeLongBreak,
    this.isBuiltIn = true,
  });

  TimerPreset copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    int? workMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? sessionsBeforeLongBreak,
    bool? isBuiltIn,
  }) {
    return TimerPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      workMinutes: workMinutes ?? this.workMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      sessionsBeforeLongBreak: sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    );
  }
}

class TimerPresetsService {
  static final List<TimerPreset> _builtInPresets = [
    const TimerPreset(
      id: 'classic_pomodoro',
      name: 'Classic Pomodoro',
      description: 'The traditional 25/5 technique',
      icon: Icons.timer,
      color: Colors.red,
      workMinutes: 25,
      shortBreakMinutes: 5,
      longBreakMinutes: 15,
      sessionsBeforeLongBreak: 4,
    ),
    const TimerPreset(
      id: 'deep_work',
      name: 'Deep Work',
      description: 'Extended focus for complex tasks',
      icon: Icons.psychology,
      color: Colors.indigo,
      workMinutes: 90,
      shortBreakMinutes: 15,
      longBreakMinutes: 30,
      sessionsBeforeLongBreak: 2,
    ),
    const TimerPreset(
      id: 'study_session',
      name: 'Study Session',
      description: 'Optimized for learning',
      icon: Icons.school,
      color: Colors.blue,
      workMinutes: 50,
      shortBreakMinutes: 10,
      longBreakMinutes: 20,
      sessionsBeforeLongBreak: 3,
    ),
    const TimerPreset(
      id: 'quick_sprint',
      name: 'Quick Sprint',
      description: 'Short bursts for small tasks',
      icon: Icons.flash_on,
      color: Colors.orange,
      workMinutes: 15,
      shortBreakMinutes: 3,
      longBreakMinutes: 10,
      sessionsBeforeLongBreak: 4,
    ),
    const TimerPreset(
      id: 'ultra_focus',
      name: 'Ultra Focus',
      description: 'Maximum productivity session',
      icon: Icons.rocket_launch,
      color: Colors.purple,
      workMinutes: 60,
      shortBreakMinutes: 10,
      longBreakMinutes: 25,
      sessionsBeforeLongBreak: 3,
    ),
    const TimerPreset(
      id: 'creative_flow',
      name: 'Creative Flow',
      description: 'Balanced time for creative work',
      icon: Icons.palette,
      color: Colors.pink,
      workMinutes: 45,
      shortBreakMinutes: 15,
      longBreakMinutes: 30,
      sessionsBeforeLongBreak: 2,
    ),
    const TimerPreset(
      id: 'beginner',
      name: 'Beginner',
      description: 'Start small, build up',
      icon: Icons.emoji_people,
      color: Colors.green,
      workMinutes: 10,
      shortBreakMinutes: 2,
      longBreakMinutes: 5,
      sessionsBeforeLongBreak: 4,
    ),
    const TimerPreset(
      id: 'meeting_prep',
      name: 'Meeting Prep',
      description: 'Quick prep before meetings',
      icon: Icons.groups,
      color: Colors.teal,
      workMinutes: 20,
      shortBreakMinutes: 5,
      longBreakMinutes: 10,
      sessionsBeforeLongBreak: 3,
    ),
    const TimerPreset(
      id: 'reading',
      name: 'Reading Session',
      description: 'Perfect for focused reading',
      icon: Icons.menu_book,
      color: Colors.brown,
      workMinutes: 30,
      shortBreakMinutes: 5,
      longBreakMinutes: 15,
      sessionsBeforeLongBreak: 4,
    ),
    const TimerPreset(
      id: 'coding',
      name: 'Coding Sprint',
      description: 'Optimized for programming',
      icon: Icons.code,
      color: Colors.cyan,
      workMinutes: 45,
      shortBreakMinutes: 10,
      longBreakMinutes: 20,
      sessionsBeforeLongBreak: 3,
    ),
  ];

  static final List<TimerPreset> _customPresets = [];

  static List<TimerPreset> get builtInPresets => _builtInPresets;

  static List<TimerPreset> get customPresets => _customPresets;

  static List<TimerPreset> get allPresets => [..._builtInPresets, ..._customPresets];

  static void addCustomPreset(TimerPreset preset) {
    _customPresets.add(preset);
  }

  static void removeCustomPreset(String id) {
    _customPresets.removeWhere((p) => p.id == id);
  }

  static void updateCustomPreset(TimerPreset preset) {
    final index = _customPresets.indexWhere((p) => p.id == preset.id);
    if (index != -1) {
      _customPresets[index] = preset;
    }
  }

  static TimerPreset? getPresetById(String id) {
    try {
      return allPresets.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static TimerPreset get defaultPreset => _builtInPresets.first;
}
