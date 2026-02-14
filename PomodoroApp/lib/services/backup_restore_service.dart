import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../models/pomodoro_settings.dart';
import '../models/session.dart';
import '../models/task.dart';
import 'storage_service.dart';

/// Service for backup and restore operations with file handling.
/// Provides complete data export to JSON files and import from user-selected files.
class BackupRestoreService {
  static const String _backupVersion = '2.0';
  static const String _backupFilePrefix = 'pomodoro_backup_';

  // ═══════════════════════════════════════════════════════════════════════════
  // EXPORT / BACKUP
  // ═══════════════════════════════════════════════════════════════════════════

  /// Export all app data to a JSON file and share it.
  /// Returns true if backup was initiated successfully.
  static Future<BackupResult> exportAndShare() async {
    try {
      // Generate the backup JSON
      final jsonData = _generateBackupJson();

      // Create temp file with timestamped name
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final fileName = '$_backupFilePrefix$timestamp.json';

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);

      await file.writeAsString(jsonData);

      // Share the file
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Pomodoro Timer Backup',
        text: 'My Pomodoro Timer backup from ${DateTime.now().toLocal()}',
      );

      return BackupResult(
        success: true,
        filePath: filePath,
        fileName: fileName,
        shareStatus: result.status,
      );
    } catch (e) {
      debugPrint('BackupRestoreService: Export failed: $e');
      return BackupResult(
        success: false,
        error: 'Failed to create backup: ${e.toString()}',
      );
    }
  }

  /// Export backup to a specific directory (for desktop).
  /// Returns the file path if successful.
  static Future<BackupResult> exportToFile() async {
    try {
      final jsonData = _generateBackupJson();

      // Let user pick save location
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final fileName = '$_backupFilePrefix$timestamp.json';

      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup File',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) {
        return BackupResult(
          success: false,
          error: 'Save cancelled by user',
        );
      }

      final file = File(result);
      await file.writeAsString(jsonData);

      return BackupResult(
        success: true,
        filePath: result,
        fileName: fileName,
      );
    } catch (e) {
      debugPrint('BackupRestoreService: Export to file failed: $e');
      return BackupResult(
        success: false,
        error: 'Failed to save backup: ${e.toString()}',
      );
    }
  }

  /// Generate the complete backup JSON string.
  static String _generateBackupJson() {
    final sessions = StorageService.getAllSessions();
    final tasks = StorageService.getAllTasks();
    final settings = StorageService.getSettings();

    final backupData = {
      'version': _backupVersion,
      'appName': 'Pomodoro Timer',
      'exportDate': DateTime.now().toIso8601String(),
      'deviceInfo': {
        'platform': _getPlatformName(),
        'exportedAt': DateTime.now().toUtc().toIso8601String(),
      },
      'data': {
        'settings': _settingsToJson(settings),
        'sessions': sessions.map((s) => _sessionToJson(s)).toList(),
        'tasks': tasks.map((t) => _taskToJson(t)).toList(),
      },
      'statistics': {
        'totalWorkSessions': sessions.where((s) => s.type == 'work' && s.completed).length,
        'totalFocusMinutes': sessions
            .where((s) => s.type == 'work' && s.completed)
            .fold<int>(0, (sum, s) => sum + s.durationMinutes),
        'totalTasks': tasks.length,
        'completedTasks': tasks.where((t) => t.isCompleted).length,
        'currentStreak': StorageService.getCurrentStreak(),
      },
    };

    return const JsonEncoder.withIndent('  ').convert(backupData);
  }

  static String _getPlatformName() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  static Map<String, dynamic> _settingsToJson(PomodoroSettings settings) {
    return {
      'workDuration': settings.workDuration,
      'shortBreakDuration': settings.shortBreakDuration,
      'longBreakDuration': settings.longBreakDuration,
      'sessionsBeforeLongBreak': settings.sessionsBeforeLongBreak,
      'autoStartBreaks': settings.autoStartBreaks,
      'autoStartPomodoros': settings.autoStartPomodoros,
      'soundEnabled': settings.soundEnabled,
      'notificationsEnabled': settings.notificationsEnabled,
      'tickingSoundEnabled': settings.tickingSoundEnabled,
      'volume': settings.volume,
      'dailyGoal': settings.dailyGoal,
      'languageCode': settings.languageCode,
      'totalCoins': settings.totalCoins,
    };
  }

  static Map<String, dynamic> _sessionToJson(PomodoroSession session) {
    return {
      'id': session.id,
      'startTime': session.startTime.toIso8601String(),
      'endTime': session.endTime.toIso8601String(),
      'type': session.type,
      'durationMinutes': session.durationMinutes,
      'completed': session.completed,
      'taskId': session.taskId,
      'taskTitle': session.taskTitle,
    };
  }

  static Map<String, dynamic> _taskToJson(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'estimatedPomodoros': task.estimatedPomodoros,
      'completedPomodoros': task.completedPomodoros,
      'isCompleted': task.isCompleted,
      'createdAt': task.createdAt.toIso8601String(),
      'completedAt': task.completedAt?.toIso8601String(),
      'priority': task.priority,
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // IMPORT / RESTORE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Import data from a user-selected JSON file.
  /// [merge] - If true, merges with existing data. If false, replaces all data.
  /// Returns the import result with details.
  static Future<RestoreResult> importFromFile({bool merge = false}) async {
    try {
      // Let user pick a JSON file
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select Backup File',
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return RestoreResult(
          success: false,
          error: 'No file selected',
        );
      }

      final file = result.files.first;
      String jsonData;

      // Handle web vs native file reading
      if (kIsWeb) {
        if (file.bytes == null) {
          return RestoreResult(
            success: false,
            error: 'Failed to read file bytes',
          );
        }
        jsonData = utf8.decode(file.bytes!);
      } else {
        if (file.path == null) {
          return RestoreResult(
            success: false,
            error: 'Invalid file path',
          );
        }
        final fileHandle = File(file.path!);
        jsonData = await fileHandle.readAsString();
      }

      // Parse and restore the data
      return await _restoreFromJson(jsonData, merge: merge);
    } catch (e) {
      debugPrint('BackupRestoreService: Import failed: $e');
      return RestoreResult(
        success: false,
        error: 'Failed to import backup: ${e.toString()}',
      );
    }
  }

  /// Restore data from a JSON string.
  static Future<RestoreResult> _restoreFromJson(String jsonData, {bool merge = false}) async {
    try {
      final backup = json.decode(jsonData) as Map<String, dynamic>;

      // Validate backup structure
      final validation = _validateBackup(backup);
      if (!validation.isValid) {
        return RestoreResult(
          success: false,
          error: validation.error,
        );
      }

      final data = backup['data'] as Map<String, dynamic>;
      int sessionsRestored = 0;
      int tasksRestored = 0;
      bool settingsRestored = false;

      // Clear existing data if not merging
      if (!merge) {
        await StorageService.sessionsBox.clear();
        await StorageService.tasksBox.clear();
      }

      // Restore settings (always overwrite)
      final settingsData = data['settings'] as Map<String, dynamic>?;
      if (settingsData != null) {
        await _restoreSettings(settingsData);
        settingsRestored = true;
      }

      // Restore sessions
      final sessionsData = data['sessions'] as List?;
      if (sessionsData != null) {
        for (final sessionJson in sessionsData) {
          final session = _sessionFromJson(sessionJson as Map<String, dynamic>);
          if (session != null) {
            // Check for duplicates when merging
            if (merge) {
              final existing = StorageService.sessionsBox.get(session.id);
              if (existing != null) continue;
            }
            await StorageService.addSession(session);
            sessionsRestored++;
          }
        }
      }

      // Restore tasks
      final tasksData = data['tasks'] as List?;
      if (tasksData != null) {
        for (final taskJson in tasksData) {
          final task = _taskFromJson(taskJson as Map<String, dynamic>);
          if (task != null) {
            // Check for duplicates when merging
            if (merge) {
              final existing = StorageService.tasksBox.get(task.id);
              if (existing != null) continue;
            }
            await StorageService.addTask(task);
            tasksRestored++;
          }
        }
      }

      return RestoreResult(
        success: true,
        sessionsRestored: sessionsRestored,
        tasksRestored: tasksRestored,
        settingsRestored: settingsRestored,
        backupDate: DateTime.tryParse(backup['exportDate'] ?? ''),
      );
    } catch (e) {
      debugPrint('BackupRestoreService: Restore from JSON failed: $e');
      return RestoreResult(
        success: false,
        error: 'Failed to parse backup data: ${e.toString()}',
      );
    }
  }

  static _ValidationResult _validateBackup(Map<String, dynamic> backup) {
    // Check required fields
    if (!backup.containsKey('version')) {
      return _ValidationResult(false, 'Missing version field');
    }
    if (!backup.containsKey('data')) {
      return _ValidationResult(false, 'Missing data field');
    }

    // Check version compatibility
    final version = backup['version'] as String;
    if (!version.startsWith('1.') && !version.startsWith('2.')) {
      return _ValidationResult(false, 'Incompatible backup version: $version');
    }

    return _ValidationResult(true, null);
  }

  static Future<void> _restoreSettings(Map<String, dynamic> data) async {
    final settings = PomodoroSettings(
      workDuration: data['workDuration'] ?? 25,
      shortBreakDuration: data['shortBreakDuration'] ?? 5,
      longBreakDuration: data['longBreakDuration'] ?? 15,
      sessionsBeforeLongBreak: data['sessionsBeforeLongBreak'] ?? 4,
      autoStartBreaks: data['autoStartBreaks'] ?? false,
      autoStartPomodoros: data['autoStartPomodoros'] ?? false,
      soundEnabled: data['soundEnabled'] ?? true,
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      tickingSoundEnabled: data['tickingSoundEnabled'] ?? false,
      volume: (data['volume'] as num?)?.toDouble() ?? 0.7,
      dailyGoal: data['dailyGoal'] ?? 8,
      languageCode: data['languageCode'],
      totalCoins: data['totalCoins'] ?? 0,
    );

    await StorageService.saveSettings(settings);
  }

  static PomodoroSession? _sessionFromJson(Map<String, dynamic> data) {
    try {
      return PomodoroSession(
        id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: DateTime.parse(data['startTime']),
        endTime: DateTime.parse(data['endTime']),
        type: data['type'] ?? 'work',
        durationMinutes: data['durationMinutes'] ?? data['duration'] ?? 25,
        completed: data['completed'] ?? true,
        taskId: data['taskId'],
        taskTitle: data['taskTitle'],
      );
    } catch (e) {
      debugPrint('BackupRestoreService: Failed to parse session: $e');
      return null;
    }
  }

  static Task? _taskFromJson(Map<String, dynamic> data) {
    try {
      return Task(
        id: data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: data['title'] ?? 'Untitled Task',
        description: data['description'],
        estimatedPomodoros: data['estimatedPomodoros'] ?? 1,
        completedPomodoros: data['completedPomodoros'] ?? 0,
        isCompleted: data['isCompleted'] ?? data['completed'] ?? false,
        createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
        completedAt: data['completedAt'] != null
            ? DateTime.tryParse(data['completedAt'])
            : null,
        priority: data['priority'] ?? 1,
      );
    } catch (e) {
      debugPrint('BackupRestoreService: Failed to parse task: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UTILITIES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get a preview of what's in a backup file without importing.
  static Future<BackupPreview?> previewBackupFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select Backup File to Preview',
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;
      String jsonData;

      if (kIsWeb) {
        if (file.bytes == null) return null;
        jsonData = utf8.decode(file.bytes!);
      } else {
        if (file.path == null) return null;
        final fileHandle = File(file.path!);
        jsonData = await fileHandle.readAsString();
      }

      final backup = json.decode(jsonData) as Map<String, dynamic>;
      final data = backup['data'] as Map<String, dynamic>?;
      final stats = backup['statistics'] as Map<String, dynamic>?;

      return BackupPreview(
        version: backup['version'] as String? ?? 'unknown',
        exportDate: DateTime.tryParse(backup['exportDate'] ?? ''),
        sessionsCount: (data?['sessions'] as List?)?.length ?? 0,
        tasksCount: (data?['tasks'] as List?)?.length ?? 0,
        totalFocusMinutes: stats?['totalFocusMinutes'] as int? ?? 0,
        currentStreak: stats?['currentStreak'] as int? ?? 0,
        platform: (backup['deviceInfo'] as Map<String, dynamic>?)?['platform'] as String?,
      );
    } catch (e) {
      debugPrint('BackupRestoreService: Preview failed: $e');
      return null;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RESULT CLASSES
// ═══════════════════════════════════════════════════════════════════════════

class BackupResult {
  final bool success;
  final String? error;
  final String? filePath;
  final String? fileName;
  final ShareResultStatus? shareStatus;

  BackupResult({
    required this.success,
    this.error,
    this.filePath,
    this.fileName,
    this.shareStatus,
  });
}

class RestoreResult {
  final bool success;
  final String? error;
  final int sessionsRestored;
  final int tasksRestored;
  final bool settingsRestored;
  final DateTime? backupDate;

  RestoreResult({
    required this.success,
    this.error,
    this.sessionsRestored = 0,
    this.tasksRestored = 0,
    this.settingsRestored = false,
    this.backupDate,
  });

  String get summary {
    if (!success) return error ?? 'Import failed';
    final parts = <String>[];
    if (settingsRestored) parts.add('Settings');
    if (sessionsRestored > 0) parts.add('$sessionsRestored sessions');
    if (tasksRestored > 0) parts.add('$tasksRestored tasks');
    return parts.isEmpty ? 'No data imported' : 'Restored: ${parts.join(', ')}';
  }
}

class BackupPreview {
  final String version;
  final DateTime? exportDate;
  final int sessionsCount;
  final int tasksCount;
  final int totalFocusMinutes;
  final int currentStreak;
  final String? platform;

  BackupPreview({
    required this.version,
    this.exportDate,
    required this.sessionsCount,
    required this.tasksCount,
    required this.totalFocusMinutes,
    required this.currentStreak,
    this.platform,
  });

  String get focusTimeFormatted {
    final hours = totalFocusMinutes ~/ 60;
    final minutes = totalFocusMinutes % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}

class _ValidationResult {
  final bool isValid;
  final String? error;

  _ValidationResult(this.isValid, this.error);
}
