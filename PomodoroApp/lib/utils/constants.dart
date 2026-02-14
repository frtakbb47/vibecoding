import 'package:flutter/material.dart';

class AppConstants {
  // Timer Defaults (in minutes)
  static const int defaultWorkDuration = 25;
  static const int defaultShortBreakDuration = 5;
  static const int defaultLongBreakDuration = 15;
  static const int sessionsBeforeLongBreak = 4;

  // Storage Keys
  static const String settingsBox = 'settings';
  static const String tasksBox = 'tasks';
  static const String sessionsBox = 'sessions';

  // Notification IDs
  static const int timerCompleteNotificationId = 0;
  static const int breakCompleteNotificationId = 1;

  // Colors
  static const Color primaryRed = Color(0xFFE74C3C);
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color primaryBlue = Color(0xFF3498DB);
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color cardDark = Color(0xFF16213E);

  // Timer States
  static const String stateWork = 'work';
  static const String stateShortBreak = 'short_break';
  static const String stateLongBreak = 'long_break';

  // Goal Types
  static const int dailyGoalSessions = 8;
  static const int weeklyGoalSessions = 40;
}

class AppStrings {
  static const String appName = 'Pomodoro Timer';
  static const String workSession = 'Focus Time';
  static const String shortBreak = 'Short Break';
  static const String longBreak = 'Long Break';
  static const String start = 'Start';
  static const String pause = 'Pause';
  static const String resume = 'Resume';
  static const String reset = 'Reset';
  static const String skip = 'Skip';

  static const String workComplete = 'Great work! Time for a break.';
  static const String breakComplete = 'Break is over! Ready to focus?';
  static const String longBreakComplete = 'Long break finished! Feeling refreshed?';

  static const String tasks = 'Tasks';
  static const String statistics = 'Statistics';
  static const String settings = 'Settings';

  static const String noTasksYet = 'No tasks yet. Add one to get started!';
  static const String addTask = 'Add Task';
}
