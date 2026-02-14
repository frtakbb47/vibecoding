import 'package:flutter_test/flutter_test.dart';
import 'package:pomodoro_app/models/task.dart';
import 'package:pomodoro_app/models/pomodoro_settings.dart';
import 'package:pomodoro_app/models/session.dart';

void main() {
  group('Task Model', () {
    test('creates task with default values', () {
      final task = Task(
        id: 'test-id',
        title: 'Test Task',
        createdAt: DateTime(2024, 1, 15),
      );

      expect(task.id, 'test-id');
      expect(task.title, 'Test Task');
      expect(task.estimatedPomodoros, 1);
      expect(task.completedPomodoros, 0);
      expect(task.isCompleted, false);
      expect(task.priority, 1);
    });

    test('progress calculation is correct', () {
      final task = Task(
        id: 'test-id',
        title: 'Test Task',
        estimatedPomodoros: 4,
        completedPomodoros: 2,
        createdAt: DateTime(2024, 1, 15),
      );

      expect(task.progress, 0.5);
    });

    test('progress is clamped to 1.0', () {
      final task = Task(
        id: 'test-id',
        title: 'Test Task',
        estimatedPomodoros: 2,
        completedPomodoros: 5,
        createdAt: DateTime(2024, 1, 15),
      );

      expect(task.progress, 1.0);
    });

    test('progress is 0 when estimatedPomodoros is 0', () {
      final task = Task(
        id: 'test-id',
        title: 'Test Task',
        estimatedPomodoros: 0,
        createdAt: DateTime(2024, 1, 15),
      );

      expect(task.progress, 0.0);
    });

    test('toJson and fromJson work correctly', () {
      final task = Task(
        id: 'test-id',
        title: 'Test Task',
        description: 'Test Description',
        estimatedPomodoros: 4,
        completedPomodoros: 2,
        isCompleted: false,
        createdAt: DateTime(2024, 1, 15),
        priority: 2,
      );

      final json = task.toJson();
      final restoredTask = Task.fromJson(json);

      expect(restoredTask.id, task.id);
      expect(restoredTask.title, task.title);
      expect(restoredTask.description, task.description);
      expect(restoredTask.estimatedPomodoros, task.estimatedPomodoros);
      expect(restoredTask.completedPomodoros, task.completedPomodoros);
      expect(restoredTask.isCompleted, task.isCompleted);
      expect(restoredTask.priority, task.priority);
    });

    test('toJson handles null completedAt', () {
      final task = Task(
        id: 'test-id',
        title: 'Test Task',
        createdAt: DateTime(2024, 1, 15),
        completedAt: null,
      );

      final json = task.toJson();
      expect(json['completedAt'], null);
    });
  });

  group('PomodoroSettings Model', () {
    test('creates settings with default values', () {
      final settings = PomodoroSettings();

      expect(settings.workDuration, 25);
      expect(settings.shortBreakDuration, 5);
      expect(settings.longBreakDuration, 15);
      expect(settings.sessionsBeforeLongBreak, 4);
      expect(settings.autoStartBreaks, false);
      expect(settings.autoStartPomodoros, false);
      expect(settings.soundEnabled, true);
      expect(settings.notificationsEnabled, true);
      expect(settings.tickingSoundEnabled, false);
      expect(settings.volume, 0.7);
      expect(settings.dailyGoal, 8);
      expect(settings.totalCoins, 0);
    });

    test('toJson and fromJson work correctly', () {
      final settings = PomodoroSettings(
        workDuration: 30,
        shortBreakDuration: 10,
        longBreakDuration: 20,
        sessionsBeforeLongBreak: 3,
        autoStartBreaks: true,
        soundEnabled: false,
        volume: 0.5,
        dailyGoal: 10,
        totalCoins: 100,
      );

      final json = settings.toJson();
      final restoredSettings = PomodoroSettings.fromJson(json);

      expect(restoredSettings.workDuration, settings.workDuration);
      expect(restoredSettings.shortBreakDuration, settings.shortBreakDuration);
      expect(restoredSettings.longBreakDuration, settings.longBreakDuration);
      expect(restoredSettings.sessionsBeforeLongBreak, settings.sessionsBeforeLongBreak);
      expect(restoredSettings.autoStartBreaks, settings.autoStartBreaks);
      expect(restoredSettings.soundEnabled, settings.soundEnabled);
      expect(restoredSettings.volume, settings.volume);
      expect(restoredSettings.dailyGoal, settings.dailyGoal);
      expect(restoredSettings.totalCoins, settings.totalCoins);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};
      final settings = PomodoroSettings.fromJson(json);

      expect(settings.workDuration, 25);
      expect(settings.shortBreakDuration, 5);
      expect(settings.soundEnabled, true);
    });
  });

  group('PomodoroSession Model', () {
    test('creates session correctly', () {
      final session = PomodoroSession(
        id: 'session-1',
        startTime: DateTime(2024, 1, 15, 10, 0),
        endTime: DateTime(2024, 1, 15, 10, 25),
        type: 'work',
        durationMinutes: 25,
      );

      expect(session.id, 'session-1');
      expect(session.type, 'work');
      expect(session.durationMinutes, 25);
      expect(session.completed, true);
    });

    test('duration getter calculates correctly', () {
      final session = PomodoroSession(
        id: 'session-1',
        startTime: DateTime(2024, 1, 15, 10, 0),
        endTime: DateTime(2024, 1, 15, 10, 25),
        type: 'work',
        durationMinutes: 25,
      );

      expect(session.duration, const Duration(minutes: 25));
    });

    test('toJson and fromJson work correctly', () {
      final session = PomodoroSession(
        id: 'session-1',
        startTime: DateTime(2024, 1, 15, 10, 0),
        endTime: DateTime(2024, 1, 15, 10, 25),
        type: 'work',
        durationMinutes: 25,
        completed: true,
        taskId: 'task-1',
        taskTitle: 'Study Flutter',
      );

      final json = session.toJson();
      final restoredSession = PomodoroSession.fromJson(json);

      expect(restoredSession.id, session.id);
      expect(restoredSession.type, session.type);
      expect(restoredSession.durationMinutes, session.durationMinutes);
      expect(restoredSession.completed, session.completed);
      expect(restoredSession.taskId, session.taskId);
      expect(restoredSession.taskTitle, session.taskTitle);
    });
  });
}
