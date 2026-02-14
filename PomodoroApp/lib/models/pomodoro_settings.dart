import 'package:hive/hive.dart';

part 'pomodoro_settings.g.dart';

/// User preferences for the Pomodoro Timer.
///
/// This class is persisted to Hive database and contains all
/// configurable settings for the timer behavior and UI.
@HiveType(typeId: 0)
class PomodoroSettings extends HiveObject {
  @HiveField(0)
  int workDuration; // in minutes

  @HiveField(1)
  int shortBreakDuration; // in minutes

  @HiveField(2)
  int longBreakDuration; // in minutes

  @HiveField(3)
  int sessionsBeforeLongBreak;

  @HiveField(4)
  bool autoStartBreaks;

  @HiveField(5)
  bool autoStartPomodoros;

  @HiveField(6)
  bool soundEnabled;

  @HiveField(7)
  bool notificationsEnabled;

  @HiveField(8)
  bool tickingSoundEnabled;

  @HiveField(9)
  double volume;

  @HiveField(10)
  int dailyGoal; // number of sessions

  @HiveField(11)
  String? languageCode; // null means system default

  @HiveField(12)
  int totalCoins; // Focus Economy: earned coins from completed sessions

  PomodoroSettings({
    this.workDuration = 25,
    this.shortBreakDuration = 5,
    this.longBreakDuration = 15,
    this.sessionsBeforeLongBreak = 4,
    this.autoStartBreaks = false,
    this.autoStartPomodoros = false,
    this.soundEnabled = true,
    this.notificationsEnabled = true,
    this.tickingSoundEnabled = false,
    this.volume = 0.7,
    this.dailyGoal = 8,
    this.languageCode,
    this.totalCoins = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'workDuration': workDuration,
      'shortBreakDuration': shortBreakDuration,
      'longBreakDuration': longBreakDuration,
      'sessionsBeforeLongBreak': sessionsBeforeLongBreak,
      'autoStartBreaks': autoStartBreaks,
      'autoStartPomodoros': autoStartPomodoros,
      'soundEnabled': soundEnabled,
      'notificationsEnabled': notificationsEnabled,
      'tickingSoundEnabled': tickingSoundEnabled,
      'volume': volume,
      'dailyGoal': dailyGoal,
      'languageCode': languageCode,
      'totalCoins': totalCoins,
    };
  }

  factory PomodoroSettings.fromJson(Map<String, dynamic> json) {
    return PomodoroSettings(
      workDuration: json['workDuration'] ?? 25,
      shortBreakDuration: json['shortBreakDuration'] ?? 5,
      longBreakDuration: json['longBreakDuration'] ?? 15,
      sessionsBeforeLongBreak: json['sessionsBeforeLongBreak'] ?? 4,
      autoStartBreaks: json['autoStartBreaks'] ?? false,
      autoStartPomodoros: json['autoStartPomodoros'] ?? false,
      soundEnabled: json['soundEnabled'] ?? true,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      tickingSoundEnabled: json['tickingSoundEnabled'] ?? false,
      volume: json['volume'] ?? 0.7,
      dailyGoal: json['dailyGoal'] ?? 8,
      totalCoins: json['totalCoins'] ?? 0,
    );
  }
}
