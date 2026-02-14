import 'package:hive_flutter/hive_flutter.dart';
import '../models/pomodoro_settings.dart';
import '../models/task.dart';
import '../models/session.dart';
import '../utils/constants.dart';

/// Singleton service for all Hive database operations.
///
/// Must be initialized before use by calling [init] in main().
class StorageService {
  static late Box<PomodoroSettings> settingsBox;
  static late Box<Task> tasksBox;
  static late Box<PomodoroSession> sessionsBox;
  static late Box<dynamic> timerStateBox; // For timer persistence (Feature 1)

  /// Initializes Hive and opens all required boxes.
  ///
  /// Registers type adapters and creates default settings if needed.
  /// Must be called once during app startup before accessing any data.
  static Future<void> init() async {
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PomodoroSettingsAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(PomodoroSessionAdapter());
    }

    // Open boxes
    settingsBox = await Hive.openBox<PomodoroSettings>(AppConstants.settingsBox);
    tasksBox = await Hive.openBox<Task>(AppConstants.tasksBox);
    sessionsBox = await Hive.openBox<PomodoroSession>(AppConstants.sessionsBox);
    timerStateBox = await Hive.openBox<dynamic>('timer_state'); // General key-value box

    // Initialize default settings if not exists
    if (settingsBox.isEmpty) {
      await settingsBox.put('default', PomodoroSettings());
    }
  }

  // Settings
  static PomodoroSettings getSettings() {
    return settingsBox.get('default') ?? PomodoroSettings();
  }

  static Future<void> saveSettings(PomodoroSettings settings) async {
    await settingsBox.put('default', settings);
  }

  // Tasks
  static List<Task> getAllTasks() {
    return tasksBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<Task> getActiveTasks() {
    return tasksBox.values
        .where((task) => !task.isCompleted)
        .toList()
      ..sort((a, b) {
        // Sort by priority first, then by creation date
        if (a.priority != b.priority) {
          return b.priority.compareTo(a.priority);
        }
        return b.createdAt.compareTo(a.createdAt);
      });
  }

  static List<Task> getCompletedTasks() {
    return tasksBox.values
        .where((task) => task.isCompleted)
        .toList()
      ..sort((a, b) => (b.completedAt ?? b.createdAt)
          .compareTo(a.completedAt ?? a.createdAt));
  }

  static Future<void> addTask(Task task) async {
    await tasksBox.put(task.id, task);
  }

  static Future<void> updateTask(Task task) async {
    await task.save();
  }

  static Future<void> deleteTask(String taskId) async {
    await tasksBox.delete(taskId);
  }

  static Task? getTask(String taskId) {
    return tasksBox.get(taskId);
  }

  // Sessions
  static List<PomodoroSession> getAllSessions() {
    return sessionsBox.values.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  static List<PomodoroSession> getSessionsByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return sessionsBox.values
        .where((session) =>
            session.startTime.isAfter(startOfDay) &&
            session.startTime.isBefore(endOfDay))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  static List<PomodoroSession> getSessionsInRange(
      DateTime start, DateTime end) {
    return sessionsBox.values
        .where((session) =>
            session.startTime.isAfter(start) &&
            session.startTime.isBefore(end))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  static Future<void> addSession(PomodoroSession session) async {
    await sessionsBox.put(session.id, session);
  }

  static Future<void> deleteSession(String sessionId) async {
    await sessionsBox.delete(sessionId);
  }

  static int getTodayWorkSessionCount() {
    final today = DateTime.now();
    final sessions = getSessionsByDate(today);
    return sessions.where((s) => s.type == AppConstants.stateWork && s.completed).length;
  }

  static int getCurrentStreak() {
    final sessions = getAllSessions();
    if (sessions.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();

    for (int i = 0; i < 30; i++) {
      final sessionsOnDate = getSessionsByDate(currentDate);
      final workSessions = sessionsOnDate.where(
        (s) => s.type == AppConstants.stateWork && s.completed
      ).length;

      if (workSessions > 0) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else if (i > 0) {
        break; // Streak is broken
      } else {
        // First day has no sessions, check yesterday
        currentDate = currentDate.subtract(const Duration(days: 1));
      }
    }

    return streak;
  }

  // Clear all data (for testing or reset)
  static Future<void> clearAllData() async {
    await tasksBox.clear();
    await sessionsBox.clear();
  }
}
