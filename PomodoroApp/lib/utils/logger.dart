import 'package:flutter/foundation.dart';

/// Centralized logging utility for the Pomodoro App
///
/// Provides consistent logging with different severity levels
/// and only outputs in debug mode to avoid performance issues.
class AppLogger {
  static const String _tag = 'PomodoroApp';

  /// Log an info message
  static void info(String message, {String? tag}) {
    _log('INFO', tag ?? _tag, message);
  }

  /// Log a debug message
  static void debug(String message, {String? tag}) {
    _log('DEBUG', tag ?? _tag, message);
  }

  /// Log a warning message
  static void warning(String message, {String? tag}) {
    _log('WARNING', tag ?? _tag, message);
  }

  /// Log an error message with optional stack trace
  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    _log('ERROR', tag ?? _tag, message);
    if (error != null) {
      _log('ERROR', tag ?? _tag, 'Error: $error');
    }
    if (stackTrace != null) {
      _log('ERROR', tag ?? _tag, 'StackTrace: $stackTrace');
    }
  }

  /// Log a timer-related event
  static void timer(String message) {
    _log('TIMER', 'Timer', message);
  }

  /// Log a storage-related event
  static void storage(String message) {
    _log('STORAGE', 'Storage', message);
  }

  /// Log a notification-related event
  static void notification(String message) {
    _log('NOTIFICATION', 'Notification', message);
  }

  /// Log an analytics event
  static void analytics(String event, {Map<String, dynamic>? parameters}) {
    if (parameters != null) {
      _log('ANALYTICS', 'Analytics', '$event: $parameters');
    } else {
      _log('ANALYTICS', 'Analytics', event);
    }
  }

  static void _log(String level, String tag, String message) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      // Using debugPrint to avoid dropping messages when there's too many
      debugPrint('[$timestamp] [$level] [$tag] $message');
    }
  }
}

/// Mixin for classes that need logging capabilities
mixin Loggable {
  String get logTag => runtimeType.toString();

  void logInfo(String message) => AppLogger.info(message, tag: logTag);
  void logDebug(String message) => AppLogger.debug(message, tag: logTag);
  void logWarning(String message) => AppLogger.warning(message, tag: logTag);
  void logError(String message, {Object? error, StackTrace? stackTrace}) =>
      AppLogger.error(message, error: error, stackTrace: stackTrace, tag: logTag);
}
