import 'package:flutter/foundation.dart';
import 'logger.dart';

/// Performance monitoring utility for the Pomodoro App
///
/// Helps identify slow operations and potential performance issues
class PerformanceMonitor {
  static final Map<String, Stopwatch> _stopwatches = {};
  static final Map<String, List<int>> _measurements = {};

  /// Start timing an operation
  static void startTimer(String operationName) {
    if (!kDebugMode) return;

    _stopwatches[operationName] = Stopwatch()..start();
  }

  /// Stop timing an operation and log the result
  static void stopTimer(String operationName, {int warnThresholdMs = 100}) {
    if (!kDebugMode) return;

    final stopwatch = _stopwatches[operationName];
    if (stopwatch == null) {
      AppLogger.warning('Timer "$operationName" was not started');
      return;
    }

    stopwatch.stop();
    final elapsed = stopwatch.elapsedMilliseconds;

    // Store measurement for averaging
    _measurements.putIfAbsent(operationName, () => []);
    _measurements[operationName]!.add(elapsed);

    // Keep only last 100 measurements
    if (_measurements[operationName]!.length > 100) {
      _measurements[operationName]!.removeAt(0);
    }

    if (elapsed > warnThresholdMs) {
      AppLogger.warning('⚠️ Slow operation: "$operationName" took ${elapsed}ms (threshold: ${warnThresholdMs}ms)');
    } else {
      AppLogger.debug('✓ "$operationName" completed in ${elapsed}ms');
    }

    _stopwatches.remove(operationName);
  }

  /// Measure an async operation
  static Future<T> measureAsync<T>(
    String operationName,
    Future<T> Function() operation, {
    int warnThresholdMs = 100,
  }) async {
    startTimer(operationName);
    try {
      return await operation();
    } finally {
      stopTimer(operationName, warnThresholdMs: warnThresholdMs);
    }
  }

  /// Measure a sync operation
  static T measureSync<T>(
    String operationName,
    T Function() operation, {
    int warnThresholdMs = 100,
  }) {
    startTimer(operationName);
    try {
      return operation();
    } finally {
      stopTimer(operationName, warnThresholdMs: warnThresholdMs);
    }
  }

  /// Get average time for an operation
  static double getAverageTime(String operationName) {
    final measurements = _measurements[operationName];
    if (measurements == null || measurements.isEmpty) return 0;

    return measurements.reduce((a, b) => a + b) / measurements.length;
  }

  /// Get all performance stats
  static Map<String, PerformanceStats> getAllStats() {
    return _measurements.map((key, values) {
      if (values.isEmpty) {
        return MapEntry(key, PerformanceStats(
          operationName: key,
          count: 0,
          averageMs: 0,
          minMs: 0,
          maxMs: 0,
        ));
      }

      return MapEntry(key, PerformanceStats(
        operationName: key,
        count: values.length,
        averageMs: values.reduce((a, b) => a + b) / values.length,
        minMs: values.reduce((a, b) => a < b ? a : b).toDouble(),
        maxMs: values.reduce((a, b) => a > b ? a : b).toDouble(),
      ));
    });
  }

  /// Clear all measurements
  static void reset() {
    _stopwatches.clear();
    _measurements.clear();
  }

  /// Print a summary of all performance measurements
  static void printSummary() {
    if (!kDebugMode) return;

    AppLogger.info('=== Performance Summary ===');
    for (final entry in getAllStats().entries) {
      final stats = entry.value;
      AppLogger.info(
        '${stats.operationName}: '
        'avg=${stats.averageMs.toStringAsFixed(2)}ms, '
        'min=${stats.minMs.toStringAsFixed(2)}ms, '
        'max=${stats.maxMs.toStringAsFixed(2)}ms, '
        'count=${stats.count}'
      );
    }
    AppLogger.info('===========================');
  }
}

/// Statistics for a measured operation
class PerformanceStats {
  final String operationName;
  final int count;
  final double averageMs;
  final double minMs;
  final double maxMs;

  PerformanceStats({
    required this.operationName,
    required this.count,
    required this.averageMs,
    required this.minMs,
    required this.maxMs,
  });

  @override
  String toString() {
    return 'PerformanceStats($operationName: avg=${averageMs}ms, count=$count)';
  }
}

/// Extension for easy performance measurement
extension PerformanceFuture<T> on Future<T> {
  /// Measure the time taken by this future
  Future<T> measured(String operationName, {int warnThresholdMs = 100}) {
    return PerformanceMonitor.measureAsync(
      operationName,
      () => this,
      warnThresholdMs: warnThresholdMs,
    );
  }
}
