import '../services/storage_service.dart';
import '../utils/constants.dart';

/// Service for analyzing productivity patterns and providing insights
class ProductivityInsightsService {
  /// Get comprehensive productivity analysis
  static ProductivityAnalysis analyzeProductivity() {
    final sessions = StorageService.getAllSessions();
    final completedWork = sessions.where((s) =>
      s.type == AppConstants.stateWork && s.completed
    ).toList();

    if (completedWork.isEmpty) {
      return ProductivityAnalysis.empty();
    }

    return ProductivityAnalysis(
      bestFocusHours: _getBestFocusHours(completedWork),
      bestFocusDays: _getBestFocusDays(completedWork),
      optimalSessionLength: _getOptimalSessionLength(completedWork),
      weeklyTrend: _getWeeklyTrend(sessions),
      suggestions: _generateSuggestions(completedWork, sessions),
      streakAnalysis: _analyzeStreak(),
      focusDistribution: _getFocusDistribution(completedWork),
    );
  }

  static List<HourlyProductivity> _getBestFocusHours(List sessions) {
    final hourStats = <int, _HourStats>{};

    for (final session in sessions) {
      final hour = session.startTime.hour;
      hourStats[hour] ??= _HourStats();
      hourStats[hour]!.completed++;
      hourStats[hour]!.totalMinutes += session.duration as int;
    }

    // Add skipped sessions
    final allWork = StorageService.getAllSessions().where((s) =>
      s.type == AppConstants.stateWork
    ).toList();

    for (final session in allWork) {
      if (!session.completed) {
        final hour = session.startTime.hour;
        hourStats[hour] ??= _HourStats();
        hourStats[hour]!.skipped++;
      }
    }

    final result = <HourlyProductivity>[];
    hourStats.forEach((hour, stats) {
      final total = stats.completed + stats.skipped;
      result.add(HourlyProductivity(
        hour: hour,
        completedSessions: stats.completed,
        completionRate: total > 0 ? stats.completed / total : 0,
        totalMinutes: stats.totalMinutes,
      ));
    });

    result.sort((a, b) => b.completionRate.compareTo(a.completionRate));
    return result.take(5).toList();
  }

  static List<DailyProductivity> _getBestFocusDays(List sessions) {
    final dayStats = <int, _DayStats>{};
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (final session in sessions) {
      final weekday = session.startTime.weekday;
      dayStats[weekday] ??= _DayStats();
      dayStats[weekday]!.completed++;
      dayStats[weekday]!.totalMinutes += session.duration as int;
    }

    final result = <DailyProductivity>[];
    dayStats.forEach((day, stats) {
      result.add(DailyProductivity(
        dayName: dayNames[day - 1],
        dayNumber: day,
        completedSessions: stats.completed,
        totalMinutes: stats.totalMinutes,
        averageMinutes: stats.completed > 0
            ? stats.totalMinutes / stats.completed
            : 0,
      ));
    });

    result.sort((a, b) => b.completedSessions.compareTo(a.completedSessions));
    return result;
  }

  static OptimalSessionLength _getOptimalSessionLength(List sessions) {
    if (sessions.isEmpty) {
      return OptimalSessionLength(
        recommendedMinutes: 25,
        reason: 'Classic Pomodoro technique',
        completionRateByLength: {},
      );
    }

    final lengthStats = <int, _LengthStats>{};

    for (final session in sessions) {
      final duration = session.duration as int;
      final bucket = (duration / 10).round() * 10; // Round to nearest 10
      lengthStats[bucket] ??= _LengthStats();
      lengthStats[bucket]!.completed++;
    }

    // Add skipped sessions
    final allWork = StorageService.getAllSessions().where((s) =>
      s.type == AppConstants.stateWork
    ).toList();

    for (final session in allWork) {
      if (!session.completed) {
        final duration = session.duration as int;
        final bucket = (duration / 10).round() * 10;
        lengthStats[bucket] ??= _LengthStats();
        lengthStats[bucket]!.skipped++;
      }
    }

    final completionRates = <int, double>{};
    int bestLength = 25;
    double bestRate = 0;

    lengthStats.forEach((length, stats) {
      final total = stats.completed + stats.skipped;
      if (total >= 3) { // Need at least 3 sessions for reliable data
        final rate = stats.completed / total;
        completionRates[length] = rate;
        if (rate > bestRate) {
          bestRate = rate;
          bestLength = length;
        }
      }
    });

    String reason;
    if (bestRate >= 0.9) {
      reason = 'You have excellent completion at this length';
    } else if (bestRate >= 0.7) {
      reason = 'Good balance of focus and completion';
    } else {
      reason = 'Based on your session patterns';
    }

    return OptimalSessionLength(
      recommendedMinutes: bestLength,
      reason: reason,
      completionRateByLength: completionRates,
    );
  }

  static WeeklyTrend _getWeeklyTrend(List sessions) {
    final now = DateTime.now();
    final weeklyData = <int, int>{};

    // Get last 4 weeks
    for (int week = 0; week < 4; week++) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (week * 7)));
      final weekEnd = weekStart.add(const Duration(days: 7));

      final count = sessions.where((s) =>
        s.type == AppConstants.stateWork &&
        s.completed &&
        s.startTime.isAfter(weekStart) &&
        s.startTime.isBefore(weekEnd)
      ).length;

      weeklyData[week] = count;
    }

    final thisWeek = weeklyData[0] ?? 0;
    final lastWeek = weeklyData[1] ?? 0;

    TrendDirection direction;
    double percentChange;

    if (lastWeek == 0) {
      direction = thisWeek > 0 ? TrendDirection.up : TrendDirection.stable;
      percentChange = thisWeek > 0 ? 100 : 0;
    } else {
      percentChange = ((thisWeek - lastWeek) / lastWeek) * 100;
      if (percentChange > 10) {
        direction = TrendDirection.up;
      } else if (percentChange < -10) {
        direction = TrendDirection.down;
      } else {
        direction = TrendDirection.stable;
      }
    }

    return WeeklyTrend(
      direction: direction,
      percentChange: percentChange,
      weeklySessionCounts: weeklyData,
      thisWeekTotal: thisWeek,
      lastWeekTotal: lastWeek,
    );
  }

  static List<ProductivitySuggestion> _generateSuggestions(
    List completed,
    List all,
  ) {
    final suggestions = <ProductivitySuggestion>[];

    // Check completion rate
    final workSessions = all.where((s) => s.type == AppConstants.stateWork);
    final completedCount = completed.length;
    final totalCount = workSessions.length;

    if (totalCount > 0) {
      final completionRate = completedCount / totalCount;
      if (completionRate < 0.7) {
        suggestions.add(ProductivitySuggestion(
          icon: '💡',
          title: 'Try shorter sessions',
          description: 'Your completion rate is ${(completionRate * 100).round()}%. Consider trying 15-20 minute sessions.',
          priority: SuggestionPriority.high,
        ));
      }
    }

    // Check consistency
    final now = DateTime.now();
    final lastWeekStart = now.subtract(const Duration(days: 7));
    final daysWithSessions = <int>{};

    for (final session in completed) {
      if (session.startTime.isAfter(lastWeekStart)) {
        daysWithSessions.add(session.startTime.weekday);
      }
    }

    if (daysWithSessions.length < 4) {
      suggestions.add(ProductivitySuggestion(
        icon: '📅',
        title: 'Build consistency',
        description: 'You focused on ${daysWithSessions.length} days last week. Try to focus at least 4-5 days.',
        priority: SuggestionPriority.medium,
      ));
    }

    // Check session timing
    final bestHours = _getBestFocusHours(completed);
    if (bestHours.isNotEmpty) {
      final topHour = bestHours.first;
      if (topHour.completionRate >= 0.8) {
        suggestions.add(ProductivitySuggestion(
          icon: '⏰',
          title: 'Your best focus time',
          description: 'You\'re most productive around ${_formatHour(topHour.hour)}. Schedule important work then!',
          priority: SuggestionPriority.low,
        ));
      }
    }

    // Streak suggestion
    final streak = StorageService.getCurrentStreak();
    if (streak > 0 && streak < 7) {
      suggestions.add(ProductivitySuggestion(
        icon: '🔥',
        title: 'Keep your streak going!',
        description: 'You\'re on a $streak day streak. ${7 - streak} more days until a week streak!',
        priority: SuggestionPriority.medium,
      ));
    }

    return suggestions;
  }

  static StreakAnalysis _analyzeStreak() {
    final currentStreak = StorageService.getCurrentStreak();
    final sessions = StorageService.getAllSessions();

    // Calculate longest streak (simplified)
    int longestStreak = currentStreak;

    // Calculate average sessions per streak day
    final now = DateTime.now();
    final streakDays = <String, int>{};

    for (final session in sessions) {
      if (session.type == AppConstants.stateWork && session.completed) {
        final dateKey = '${session.startTime.year}-${session.startTime.month}-${session.startTime.day}';
        streakDays[dateKey] = (streakDays[dateKey] ?? 0) + 1;
      }
    }

    final avgSessionsPerDay = streakDays.isNotEmpty
        ? streakDays.values.reduce((a, b) => a + b) / streakDays.length
        : 0.0;

    return StreakAnalysis(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      averageSessionsPerStreakDay: avgSessionsPerDay,
      streakDates: streakDays.keys.toList(),
    );
  }

  static Map<String, int> _getFocusDistribution(List sessions) {
    final distribution = <String, int>{
      'Morning (6-12)': 0,
      'Afternoon (12-17)': 0,
      'Evening (17-21)': 0,
      'Night (21-6)': 0,
    };

    for (final session in sessions) {
      final hour = session.startTime.hour;
      if (hour >= 6 && hour < 12) {
        distribution['Morning (6-12)'] = distribution['Morning (6-12)']! + 1;
      } else if (hour >= 12 && hour < 17) {
        distribution['Afternoon (12-17)'] = distribution['Afternoon (12-17)']! + 1;
      } else if (hour >= 17 && hour < 21) {
        distribution['Evening (17-21)'] = distribution['Evening (17-21)']! + 1;
      } else {
        distribution['Night (21-6)'] = distribution['Night (21-6)']! + 1;
      }
    }

    return distribution;
  }

  static String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour == 12) return '12 PM';
    if (hour < 12) return '$hour AM';
    return '${hour - 12} PM';
  }
}

// Helper classes
class _HourStats {
  int completed = 0;
  int skipped = 0;
  int totalMinutes = 0;
}

class _DayStats {
  int completed = 0;
  int totalMinutes = 0;
}

class _LengthStats {
  int completed = 0;
  int skipped = 0;
}

// Data classes
class ProductivityAnalysis {
  final List<HourlyProductivity> bestFocusHours;
  final List<DailyProductivity> bestFocusDays;
  final OptimalSessionLength optimalSessionLength;
  final WeeklyTrend weeklyTrend;
  final List<ProductivitySuggestion> suggestions;
  final StreakAnalysis streakAnalysis;
  final Map<String, int> focusDistribution;

  ProductivityAnalysis({
    required this.bestFocusHours,
    required this.bestFocusDays,
    required this.optimalSessionLength,
    required this.weeklyTrend,
    required this.suggestions,
    required this.streakAnalysis,
    required this.focusDistribution,
  });

  factory ProductivityAnalysis.empty() {
    return ProductivityAnalysis(
      bestFocusHours: [],
      bestFocusDays: [],
      optimalSessionLength: OptimalSessionLength(
        recommendedMinutes: 25,
        reason: 'Start with classic Pomodoro',
        completionRateByLength: {},
      ),
      weeklyTrend: WeeklyTrend(
        direction: TrendDirection.stable,
        percentChange: 0,
        weeklySessionCounts: {},
        thisWeekTotal: 0,
        lastWeekTotal: 0,
      ),
      suggestions: [
        ProductivitySuggestion(
          icon: '🚀',
          title: 'Get started!',
          description: 'Complete your first focus session to unlock insights.',
          priority: SuggestionPriority.high,
        ),
      ],
      streakAnalysis: StreakAnalysis(
        currentStreak: 0,
        longestStreak: 0,
        averageSessionsPerStreakDay: 0,
        streakDates: [],
      ),
      focusDistribution: {},
    );
  }
}

class HourlyProductivity {
  final int hour;
  final int completedSessions;
  final double completionRate;
  final int totalMinutes;

  HourlyProductivity({
    required this.hour,
    required this.completedSessions,
    required this.completionRate,
    required this.totalMinutes,
  });
}

class DailyProductivity {
  final String dayName;
  final int dayNumber;
  final int completedSessions;
  final int totalMinutes;
  final double averageMinutes;

  DailyProductivity({
    required this.dayName,
    required this.dayNumber,
    required this.completedSessions,
    required this.totalMinutes,
    required this.averageMinutes,
  });
}

class OptimalSessionLength {
  final int recommendedMinutes;
  final String reason;
  final Map<int, double> completionRateByLength;

  OptimalSessionLength({
    required this.recommendedMinutes,
    required this.reason,
    required this.completionRateByLength,
  });
}

class WeeklyTrend {
  final TrendDirection direction;
  final double percentChange;
  final Map<int, int> weeklySessionCounts;
  final int thisWeekTotal;
  final int lastWeekTotal;

  WeeklyTrend({
    required this.direction,
    required this.percentChange,
    required this.weeklySessionCounts,
    required this.thisWeekTotal,
    required this.lastWeekTotal,
  });
}

enum TrendDirection { up, down, stable }

class ProductivitySuggestion {
  final String icon;
  final String title;
  final String description;
  final SuggestionPriority priority;

  ProductivitySuggestion({
    required this.icon,
    required this.title,
    required this.description,
    required this.priority,
  });
}

enum SuggestionPriority { high, medium, low }

class StreakAnalysis {
  final int currentStreak;
  final int longestStreak;
  final double averageSessionsPerStreakDay;
  final List<String> streakDates;

  StreakAnalysis({
    required this.currentStreak,
    required this.longestStreak,
    required this.averageSessionsPerStreakDay,
    required this.streakDates,
  });
}
