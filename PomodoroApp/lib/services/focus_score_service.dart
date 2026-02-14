import '../services/storage_service.dart';
import '../utils/constants.dart';

class FocusScoreService {
  /// Calculate comprehensive focus score (0-100)
  static FocusScoreData calculateFocusScore() {
    final sessions = StorageService.getAllSessions();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    // Get sessions from last 7 days
    final recentSessions = sessions.where((s) =>
      s.startTime.isAfter(weekAgo) &&
      s.type == AppConstants.stateWork
    ).toList();

    if (recentSessions.isEmpty) {
      return FocusScoreData(
        overallScore: 0,
        completionScore: 0,
        consistencyScore: 0,
        durationScore: 0,
        streakBonus: 0,
        trend: ScoreTrend.neutral,
        insights: ['Start your first focus session to build your score!'],
        level: FocusLevel.beginner,
        nextMilestone: 10,
      );
    }

    // 1. Completion Rate (0-30 points)
    final completedSessions = recentSessions.where((s) => s.completed).length;
    final totalSessions = recentSessions.length;
    final completionRate = totalSessions > 0 ? completedSessions / totalSessions : 0.0;
    final completionScore = (completionRate * 30).round();

    // 2. Consistency Score (0-25 points) - Based on daily activity
    final daysActive = _getActiveDaysCount(recentSessions);
    final consistencyScore = ((daysActive / 7) * 25).round();

    // 3. Duration Score (0-25 points) - Based on total focus time
    final totalMinutes = recentSessions
        .where((s) => s.completed)
        .fold<int>(0, (sum, s) => sum + s.durationMinutes);
    final targetMinutesPerWeek = 25 * 12; // 12 pomodoros per day = ~300 min
    final durationRate = (totalMinutes / targetMinutesPerWeek).clamp(0.0, 1.0);
    final durationScore = (durationRate * 25).round();

    // 4. Streak Bonus (0-20 points)
    final currentStreak = StorageService.getCurrentStreak();
    final streakBonus = (currentStreak.clamp(0, 10) * 2);

    // Calculate overall score
    final overallScore = (completionScore + consistencyScore + durationScore + streakBonus).clamp(0, 100);

    // Determine trend
    final trend = _calculateTrend(sessions);

    // Generate insights
    final insights = _generateInsights(
      completionRate: completionRate,
      daysActive: daysActive,
      totalMinutes: totalMinutes,
      currentStreak: currentStreak,
    );

    // Determine level
    final level = _determineLevel(overallScore);

    // Calculate next milestone
    final nextMilestone = _getNextMilestone(overallScore);

    return FocusScoreData(
      overallScore: overallScore,
      completionScore: completionScore,
      consistencyScore: consistencyScore,
      durationScore: durationScore,
      streakBonus: streakBonus,
      trend: trend,
      insights: insights,
      level: level,
      nextMilestone: nextMilestone,
    );
  }

  static int _getActiveDaysCount(List sessions) {
    final days = <String>{};
    for (final session in sessions) {
      final date = session.startTime;
      days.add('${date.year}-${date.month}-${date.day}');
    }
    return days.length;
  }

  static ScoreTrend _calculateTrend(List sessions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // This week's sessions
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final thisWeekSessions = sessions.where((s) =>
      s.startTime.isAfter(thisWeekStart) &&
      s.type == AppConstants.stateWork &&
      s.completed
    ).length;

    // Last week's sessions
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = thisWeekStart;
    final lastWeekSessions = sessions.where((s) =>
      s.startTime.isAfter(lastWeekStart) &&
      s.startTime.isBefore(lastWeekEnd) &&
      s.type == AppConstants.stateWork &&
      s.completed
    ).length;

    if (thisWeekSessions > lastWeekSessions) {
      return ScoreTrend.improving;
    } else if (thisWeekSessions < lastWeekSessions) {
      return ScoreTrend.declining;
    }
    return ScoreTrend.neutral;
  }

  static List<String> _generateInsights({
    required double completionRate,
    required int daysActive,
    required int totalMinutes,
    required int currentStreak,
  }) {
    final insights = <String>[];

    if (completionRate >= 0.9) {
      insights.add('🏆 Excellent completion rate! You finish what you start.');
    } else if (completionRate < 0.5) {
      insights.add('💡 Try shorter sessions to improve completion rate.');
    }

    if (daysActive >= 6) {
      insights.add('🔥 Amazing consistency! Keep up the daily habit.');
    } else if (daysActive < 3) {
      insights.add('📅 Try focusing at least 3-4 days per week.');
    }

    if (totalMinutes >= 200) {
      insights.add('⏱️ Great focus time this week!');
    } else if (totalMinutes < 60) {
      insights.add('🎯 Aim for at least 2-3 pomodoros per day.');
    }

    if (currentStreak >= 7) {
      insights.add('🌟 Week-long streak! You\'re building a powerful habit.');
    } else if (currentStreak >= 3) {
      insights.add('💪 Nice streak! Keep it going for bonus points.');
    }

    if (insights.isEmpty) {
      insights.add('📈 Keep focusing to unlock personalized insights!');
    }

    return insights;
  }

  static FocusLevel _determineLevel(int score) {
    if (score >= 90) return FocusLevel.master;
    if (score >= 75) return FocusLevel.expert;
    if (score >= 55) return FocusLevel.focused;
    if (score >= 35) return FocusLevel.developing;
    if (score >= 15) return FocusLevel.beginner;
    return FocusLevel.starter;
  }

  static int _getNextMilestone(int currentScore) {
    final milestones = [10, 25, 40, 55, 70, 85, 100];
    for (final milestone in milestones) {
      if (currentScore < milestone) return milestone;
    }
    return 100;
  }

  /// Get best focus hours based on historical data
  static List<int> getBestFocusHours() {
    final sessions = StorageService.getAllSessions();
    final completedWork = sessions.where((s) =>
      s.type == AppConstants.stateWork && s.completed
    ).toList();

    if (completedWork.isEmpty) return [9, 10, 14]; // Default suggestions

    final hourCounts = <int, int>{};
    for (final session in completedWork) {
      final hour = session.startTime.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }

    final sortedHours = hourCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedHours.take(3).map((e) => e.key).toList();
  }

  /// Get productivity patterns
  static ProductivityPatterns getProductivityPatterns() {
    final sessions = StorageService.getAllSessions();
    final completedWork = sessions.where((s) =>
      s.type == AppConstants.stateWork && s.completed
    ).toList();

    if (completedWork.isEmpty) {
      return ProductivityPatterns(
        mostProductiveDay: 'Monday',
        mostProductiveHour: '9:00 AM',
        averageSessionLength: 25,
        averageSessionsPerDay: 0,
        totalFocusTimeThisMonth: 0,
      );
    }

    // Most productive day
    final dayCounts = <int, int>{};
    for (final session in completedWork) {
      final weekday = session.startTime.weekday;
      dayCounts[weekday] = (dayCounts[weekday] ?? 0) + 1;
    }
    final topDay = dayCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b).key;
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    // Most productive hour
    final hourCounts = <int, int>{};
    for (final session in completedWork) {
      final hour = session.startTime.hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    final topHour = hourCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b).key;

    // Average session length
    final totalDuration = completedWork.fold<int>(0, (sum, s) => sum + s.durationMinutes);
    final avgLength = completedWork.isNotEmpty
        ? (totalDuration / completedWork.length).round()
        : 25;

    // Average sessions per day (last 30 days)
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    final lastMonthSessions = completedWork.where((s) =>
      s.startTime.isAfter(monthAgo)
    ).length;

    return ProductivityPatterns(
      mostProductiveDay: dayNames[topDay - 1],
      mostProductiveHour: _formatHour(topHour),
      averageSessionLength: avgLength,
      averageSessionsPerDay: (lastMonthSessions / 30 * 10).round() / 10,
      totalFocusTimeThisMonth: completedWork.where((s) =>
        s.startTime.isAfter(monthAgo)
      ).fold<int>(0, (sum, s) => sum + s.durationMinutes),
    );
  }

  static String _formatHour(int hour) {
    if (hour == 0) return '12:00 AM';
    if (hour == 12) return '12:00 PM';
    if (hour < 12) return '$hour:00 AM';
    return '${hour - 12}:00 PM';
  }
}

class FocusScoreData {
  final int overallScore;
  final int completionScore;
  final int consistencyScore;
  final int durationScore;
  final int streakBonus;
  final ScoreTrend trend;
  final List<String> insights;
  final FocusLevel level;
  final int nextMilestone;

  FocusScoreData({
    required this.overallScore,
    required this.completionScore,
    required this.consistencyScore,
    required this.durationScore,
    required this.streakBonus,
    required this.trend,
    required this.insights,
    required this.level,
    required this.nextMilestone,
  });
}

enum ScoreTrend { improving, neutral, declining }

enum FocusLevel {
  starter,
  beginner,
  developing,
  focused,
  expert,
  master,
}

extension FocusLevelExtension on FocusLevel {
  String get title {
    switch (this) {
      case FocusLevel.starter: return 'Starter';
      case FocusLevel.beginner: return 'Beginner';
      case FocusLevel.developing: return 'Developing';
      case FocusLevel.focused: return 'Focused';
      case FocusLevel.expert: return 'Expert';
      case FocusLevel.master: return 'Master';
    }
  }

  String get emoji {
    switch (this) {
      case FocusLevel.starter: return '🌱';
      case FocusLevel.beginner: return '🌿';
      case FocusLevel.developing: return '🌳';
      case FocusLevel.focused: return '🎯';
      case FocusLevel.expert: return '⭐';
      case FocusLevel.master: return '👑';
    }
  }
}

class ProductivityPatterns {
  final String mostProductiveDay;
  final String mostProductiveHour;
  final int averageSessionLength;
  final double averageSessionsPerDay;
  final int totalFocusTimeThisMonth;

  ProductivityPatterns({
    required this.mostProductiveDay,
    required this.mostProductiveHour,
    required this.averageSessionLength,
    required this.averageSessionsPerDay,
    required this.totalFocusTimeThisMonth,
  });
}
