import 'package:flutter/material.dart';

class DailyPlan {
  final DateTime date;
  final String intention;
  final int plannedSessions;
  final List<PlannedTask> tasks;
  final int completedSessions;

  const DailyPlan({
    required this.date,
    required this.intention,
    required this.plannedSessions,
    required this.tasks,
    this.completedSessions = 0,
  });

  DailyPlan copyWith({
    DateTime? date,
    String? intention,
    int? plannedSessions,
    List<PlannedTask>? tasks,
    int? completedSessions,
  }) {
    return DailyPlan(
      date: date ?? this.date,
      intention: intention ?? this.intention,
      plannedSessions: plannedSessions ?? this.plannedSessions,
      tasks: tasks ?? this.tasks,
      completedSessions: completedSessions ?? this.completedSessions,
    );
  }

  double get progressPercent {
    if (plannedSessions == 0) return 0;
    return (completedSessions / plannedSessions).clamp(0.0, 1.0);
  }

  int get completedTasks => tasks.where((t) => t.isCompleted).length;
}

class PlannedTask {
  final String id;
  final String title;
  final int estimatedSessions;
  final String? category;
  final TimeOfDay? scheduledTime;
  final bool isCompleted;
  final int priority; // 1 = high, 2 = medium, 3 = low

  const PlannedTask({
    required this.id,
    required this.title,
    this.estimatedSessions = 1,
    this.category,
    this.scheduledTime,
    this.isCompleted = false,
    this.priority = 2,
  });

  PlannedTask copyWith({
    String? id,
    String? title,
    int? estimatedSessions,
    String? category,
    TimeOfDay? scheduledTime,
    bool? isCompleted,
    int? priority,
  }) {
    return PlannedTask(
      id: id ?? this.id,
      title: title ?? this.title,
      estimatedSessions: estimatedSessions ?? this.estimatedSessions,
      category: category ?? this.category,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
    );
  }

  Color get priorityColor {
    switch (priority) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String get priorityLabel {
    switch (priority) {
      case 1:
        return 'High';
      case 2:
        return 'Medium';
      case 3:
        return 'Low';
      default:
        return 'None';
    }
  }
}

class DailyPlanningService {
  static final Map<String, DailyPlan> _plans = {};

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static DailyPlan? getPlanForDate(DateTime date) {
    return _plans[_dateKey(date)];
  }

  static DailyPlan? get todaysPlan => getPlanForDate(DateTime.now());

  static void savePlan(DailyPlan plan) {
    _plans[_dateKey(plan.date)] = plan;
  }

  static void deletePlan(DateTime date) {
    _plans.remove(_dateKey(date));
  }

  static void incrementCompletedSessions(DateTime date) {
    final plan = getPlanForDate(date);
    if (plan != null) {
      _plans[_dateKey(date)] = plan.copyWith(
        completedSessions: plan.completedSessions + 1,
      );
    }
  }

  static void toggleTaskCompletion(DateTime date, String taskId) {
    final plan = getPlanForDate(date);
    if (plan != null) {
      final updatedTasks = plan.tasks.map((t) {
        if (t.id == taskId) {
          return t.copyWith(isCompleted: !t.isCompleted);
        }
        return t;
      }).toList();
      _plans[_dateKey(date)] = plan.copyWith(tasks: updatedTasks);
    }
  }

  static List<DailyPlan> getRecentPlans({int days = 7}) {
    final now = DateTime.now();
    final plans = <DailyPlan>[];
    for (var i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final plan = getPlanForDate(date);
      if (plan != null) {
        plans.add(plan);
      }
    }
    return plans;
  }

  static double getWeeklyCompletionRate() {
    final plans = getRecentPlans(days: 7);
    if (plans.isEmpty) return 0;

    int totalPlanned = 0;
    int totalCompleted = 0;

    for (final plan in plans) {
      totalPlanned += plan.plannedSessions;
      totalCompleted += plan.completedSessions;
    }

    if (totalPlanned == 0) return 0;
    return (totalCompleted / totalPlanned).clamp(0.0, 1.0);
  }

  static List<String> get intentionSuggestions => [
    'Complete my most important task first',
    'Stay focused and minimize distractions',
    'Make progress on my project',
    'Learn something new today',
    'Be productive but take proper breaks',
    'Finish what I started yesterday',
    'Deep work on challenging problems',
    'Clear my to-do list',
    'Prepare for tomorrow',
    'Quality over quantity today',
  ];
}
