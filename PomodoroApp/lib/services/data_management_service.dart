import 'dart:convert';
import '../services/storage_service.dart';
import '../models/session.dart';
import '../models/pomodoro_settings.dart';

/// Service for managing data export, import, and backup
class DataManagementService {
  /// Export all app data as a JSON string
  static String exportAllData() {
    final sessions = StorageService.getAllSessions();
    final tasks = StorageService.getAllTasks();
    final settings = StorageService.getSettings();

    final exportData = {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'sessions': sessions.map((s) => {
        'id': s.id,
        'startTime': s.startTime.toIso8601String(),
        'endTime': s.endTime.toIso8601String(),
        'type': s.type,
        'durationMinutes': s.durationMinutes,
        'completed': s.completed,
      }).toList(),
      'tasks': tasks.map((t) => {
        'id': t.id,
        'title': t.title,
        'completed': t.isCompleted,
        'createdAt': t.createdAt.toIso8601String(),
        'estimatedPomodoros': t.estimatedPomodoros,
        'completedPomodoros': t.completedPomodoros,
        'priority': t.priority,
        'description': t.description,
      }).toList(),
      'settings': {
        'workDuration': settings.workDuration,
        'shortBreakDuration': settings.shortBreakDuration,
        'longBreakDuration': settings.longBreakDuration,
        'dailyGoal': settings.dailyGoal,
        'sessionsBeforeLongBreak': settings.sessionsBeforeLongBreak,
        'autoStartBreaks': settings.autoStartBreaks,
        'autoStartPomodoros': settings.autoStartPomodoros,
        'soundEnabled': settings.soundEnabled,
        'notificationsEnabled': settings.notificationsEnabled,
        'volume': settings.volume,
        'tickingSoundEnabled': settings.tickingSoundEnabled,
      },
      'statistics': {
        'totalSessions': sessions.where((s) => s.type == 'work' && s.completed).length,
        'totalFocusMinutes': sessions
            .where((s) => s.type == 'work' && s.completed)
            .fold<int>(0, (sum, s) => sum + s.durationMinutes),
        'currentStreak': StorageService.getCurrentStreak(),
      },
    };

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// Get a summary of the data for display
  static DataSummary getDataSummary() {
    final sessions = StorageService.getAllSessions();
    final tasks = StorageService.getAllTasks();
    final completedSessions = sessions.where((s) => s.type == 'work' && s.completed);

    DateTime? firstSession;
    DateTime? lastSession;

    if (completedSessions.isNotEmpty) {
      firstSession = completedSessions
          .map((s) => s.startTime)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      lastSession = completedSessions
          .map((s) => s.startTime)
          .reduce((a, b) => a.isAfter(b) ? a : b);
    }

    return DataSummary(
      totalSessions: completedSessions.length,
      totalTasks: tasks.length,
      completedTasks: tasks.where((t) => t.isCompleted).length,
      totalFocusMinutes: completedSessions.fold<int>(0, (sum, s) => sum + s.durationMinutes),
      currentStreak: StorageService.getCurrentStreak(),
      firstSessionDate: firstSession,
      lastSessionDate: lastSession,
      storageSize: _estimateStorageSize(sessions.length, tasks.length),
    );
  }

  static String _estimateStorageSize(int sessions, int tasks) {
    // Rough estimate: ~200 bytes per session, ~100 bytes per task
    final bytes = (sessions * 200) + (tasks * 100) + 1024; // 1KB for settings
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// Import data from JSON string
  static ImportResult importData(String jsonData, {bool merge = false}) {
    try {
      final data = json.decode(jsonData) as Map<String, dynamic>;

      // Validate version
      final version = data['version'] as String? ?? '1.0';
      if (!version.startsWith('1.')) {
        return ImportResult(
          success: false,
          error: 'Incompatible data version: $version',
        );
      }

      int sessionsImported = 0;
      int tasksImported = 0;

      // Import sessions
      final sessions = data['sessions'] as List?;
      if (sessions != null) {
        for (final sessionData in sessions) {
          final session = PomodoroSession(
            id: sessionData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            startTime: DateTime.parse(sessionData['startTime']),
            endTime: DateTime.parse(sessionData['endTime']),
            type: sessionData['type'],
            durationMinutes: sessionData['duration'],
            completed: sessionData['completed'],
          );

          // In a real implementation, we'd check for duplicates when merging
          StorageService.addSession(session);
          sessionsImported++;
        }
      }

      // Import settings (always overwrite)
      final settings = data['settings'] as Map<String, dynamic>?;
      if (settings != null) {
        // Settings would be imported here via StorageService
      }

      return ImportResult(
        success: true,
        sessionsImported: sessionsImported,
        tasksImported: tasksImported,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        error: 'Failed to parse data: ${e.toString()}',
      );
    }
  }

  /// Clear all sessions data
  static Future<void> clearSessions() async {
    await StorageService.sessionsBox.clear();
  }

  /// Clear all tasks
  static Future<void> clearTasks() async {
    await StorageService.tasksBox.clear();
  }

  /// Reset all settings to defaults
  static Future<void> resetSettings() async {
    await StorageService.settingsBox.clear();
    await StorageService.settingsBox.put('default', PomodoroSettings());
  }

  /// Get formatted date range for display
  static String getDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'No data';

    final startStr = '${start.month}/${start.day}/${start.year}';
    final endStr = '${end.month}/${end.day}/${end.year}';

    if (startStr == endStr) return startStr;
    return '$startStr - $endStr';
  }
}

class DataSummary {
  final int totalSessions;
  final int totalTasks;
  final int completedTasks;
  final int totalFocusMinutes;
  final int currentStreak;
  final DateTime? firstSessionDate;
  final DateTime? lastSessionDate;
  final String storageSize;

  DataSummary({
    required this.totalSessions,
    required this.totalTasks,
    required this.completedTasks,
    required this.totalFocusMinutes,
    required this.currentStreak,
    required this.firstSessionDate,
    required this.lastSessionDate,
    required this.storageSize,
  });

  String get totalFocusFormatted {
    final hours = totalFocusMinutes ~/ 60;
    final minutes = totalFocusMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

class ImportResult {
  final bool success;
  final String? error;
  final int sessionsImported;
  final int tasksImported;

  ImportResult({
    required this.success,
    this.error,
    this.sessionsImported = 0,
    this.tasksImported = 0,
  });
}
