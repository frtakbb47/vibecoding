import 'package:flutter/material.dart';

class AchievementsService {
  static final List<Achievement> achievements = [
    // Session milestones
    Achievement(
      id: 'first_session',
      name: 'First Steps',
      description: 'Complete your first focus session',
      emoji: '🎯',
      requirement: 1,
      type: AchievementType.sessions,
      tier: AchievementTier.bronze,
    ),
    Achievement(
      id: 'sessions_10',
      name: 'Getting Started',
      description: 'Complete 10 focus sessions',
      emoji: '🚀',
      requirement: 10,
      type: AchievementType.sessions,
      tier: AchievementTier.bronze,
    ),
    Achievement(
      id: 'sessions_50',
      name: 'Focused Mind',
      description: 'Complete 50 focus sessions',
      emoji: '🧠',
      requirement: 50,
      type: AchievementType.sessions,
      tier: AchievementTier.silver,
    ),
    Achievement(
      id: 'sessions_100',
      name: 'Century Club',
      description: 'Complete 100 focus sessions',
      emoji: '💯',
      requirement: 100,
      type: AchievementType.sessions,
      tier: AchievementTier.silver,
    ),
    Achievement(
      id: 'sessions_500',
      name: 'Focus Master',
      description: 'Complete 500 focus sessions',
      emoji: '🏆',
      requirement: 500,
      type: AchievementType.sessions,
      tier: AchievementTier.gold,
    ),
    Achievement(
      id: 'sessions_1000',
      name: 'Legendary Focus',
      description: 'Complete 1000 focus sessions',
      emoji: '👑',
      requirement: 1000,
      type: AchievementType.sessions,
      tier: AchievementTier.platinum,
    ),

    // Time milestones (in minutes)
    Achievement(
      id: 'time_1h',
      name: 'Hour Power',
      description: 'Accumulate 1 hour of focus time',
      emoji: '⏱️',
      requirement: 60,
      type: AchievementType.totalMinutes,
      tier: AchievementTier.bronze,
    ),
    Achievement(
      id: 'time_10h',
      name: 'Dedicated',
      description: 'Accumulate 10 hours of focus time',
      emoji: '⌛',
      requirement: 600,
      type: AchievementType.totalMinutes,
      tier: AchievementTier.bronze,
    ),
    Achievement(
      id: 'time_50h',
      name: 'Time Investor',
      description: 'Accumulate 50 hours of focus time',
      emoji: '📊',
      requirement: 3000,
      type: AchievementType.totalMinutes,
      tier: AchievementTier.silver,
    ),
    Achievement(
      id: 'time_100h',
      name: 'Century Hours',
      description: 'Accumulate 100 hours of focus time',
      emoji: '🎖️',
      requirement: 6000,
      type: AchievementType.totalMinutes,
      tier: AchievementTier.gold,
    ),
    Achievement(
      id: 'time_500h',
      name: 'Time Lord',
      description: 'Accumulate 500 hours of focus time',
      emoji: '⚡',
      requirement: 30000,
      type: AchievementType.totalMinutes,
      tier: AchievementTier.platinum,
    ),

    // Streak milestones
    Achievement(
      id: 'streak_3',
      name: 'Building Momentum',
      description: '3 day focus streak',
      emoji: '🔥',
      requirement: 3,
      type: AchievementType.streak,
      tier: AchievementTier.bronze,
    ),
    Achievement(
      id: 'streak_7',
      name: 'Week Warrior',
      description: '7 day focus streak',
      emoji: '📅',
      requirement: 7,
      type: AchievementType.streak,
      tier: AchievementTier.bronze,
    ),
    Achievement(
      id: 'streak_14',
      name: 'Fortnight Focus',
      description: '14 day focus streak',
      emoji: '💪',
      requirement: 14,
      type: AchievementType.streak,
      tier: AchievementTier.silver,
    ),
    Achievement(
      id: 'streak_30',
      name: 'Monthly Master',
      description: '30 day focus streak',
      emoji: '🌟',
      requirement: 30,
      type: AchievementType.streak,
      tier: AchievementTier.gold,
    ),
    Achievement(
      id: 'streak_100',
      name: 'Unstoppable',
      description: '100 day focus streak',
      emoji: '🔱',
      requirement: 100,
      type: AchievementType.streak,
      tier: AchievementTier.platinum,
    ),

    // Daily goals
    Achievement(
      id: 'daily_goal_1',
      name: 'Goal Getter',
      description: 'Reach your daily goal for the first time',
      emoji: '✅',
      requirement: 1,
      type: AchievementType.dailyGoals,
      tier: AchievementTier.bronze,
    ),
    Achievement(
      id: 'daily_goal_7',
      name: 'Weekly Winner',
      description: 'Reach your daily goal 7 times',
      emoji: '🎯',
      requirement: 7,
      type: AchievementType.dailyGoals,
      tier: AchievementTier.bronze,
    ),
    Achievement(
      id: 'daily_goal_30',
      name: 'Consistent Achiever',
      description: 'Reach your daily goal 30 times',
      emoji: '🏅',
      requirement: 30,
      type: AchievementType.dailyGoals,
      tier: AchievementTier.silver,
    ),

    // Tasks completed
    Achievement(
      id: 'tasks_10',
      name: 'Task Tackler',
      description: 'Complete 10 tasks',
      emoji: '📝',
      requirement: 10,
      type: AchievementType.tasks,
      tier: AchievementTier.bronze,
    ),
    Achievement(
      id: 'tasks_50',
      name: 'Productivity Pro',
      description: 'Complete 50 tasks',
      emoji: '📋',
      requirement: 50,
      type: AchievementType.tasks,
      tier: AchievementTier.silver,
    ),
    Achievement(
      id: 'tasks_100',
      name: 'Task Master',
      description: 'Complete 100 tasks',
      emoji: '🎪',
      requirement: 100,
      type: AchievementType.tasks,
      tier: AchievementTier.gold,
    ),

    // Special achievements
    Achievement(
      id: 'early_bird',
      name: 'Early Bird',
      description: 'Complete a session before 7 AM',
      emoji: '🐦',
      requirement: 1,
      type: AchievementType.special,
      tier: AchievementTier.silver,
    ),
    Achievement(
      id: 'night_owl',
      name: 'Night Owl',
      description: 'Complete a session after 11 PM',
      emoji: '🦉',
      requirement: 1,
      type: AchievementType.special,
      tier: AchievementTier.silver,
    ),
    Achievement(
      id: 'weekend_warrior',
      name: 'Weekend Warrior',
      description: 'Complete 5 sessions on a weekend',
      emoji: '⚔️',
      requirement: 5,
      type: AchievementType.special,
      tier: AchievementTier.silver,
    ),
    Achievement(
      id: 'marathon',
      name: 'Focus Marathon',
      description: 'Complete 8 sessions in a single day',
      emoji: '🏃',
      requirement: 8,
      type: AchievementType.special,
      tier: AchievementTier.gold,
    ),
  ];

  static List<Achievement> getAchievementsByType(AchievementType type) {
    return achievements.where((a) => a.type == type).toList();
  }

  static List<Achievement> getUnlockedAchievements(Map<String, bool> unlocked) {
    return achievements.where((a) => unlocked[a.id] == true).toList();
  }

  static List<Achievement> getLockedAchievements(Map<String, bool> unlocked) {
    return achievements.where((a) => unlocked[a.id] != true).toList();
  }

  static int calculateProgress(Achievement achievement, int currentValue) {
    if (currentValue >= achievement.requirement) return 100;
    return ((currentValue / achievement.requirement) * 100).round();
  }
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int requirement;
  final AchievementType type;
  final AchievementTier tier;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.requirement,
    required this.type,
    required this.tier,
  });

  Color get tierColor {
    switch (tier) {
      case AchievementTier.bronze:
        return const Color(0xFFCD7F32);
      case AchievementTier.silver:
        return const Color(0xFFC0C0C0);
      case AchievementTier.gold:
        return const Color(0xFFFFD700);
      case AchievementTier.platinum:
        return const Color(0xFFE5E4E2);
    }
  }
}

enum AchievementType {
  sessions,
  totalMinutes,
  streak,
  dailyGoals,
  tasks,
  special,
}

enum AchievementTier {
  bronze,
  silver,
  gold,
  platinum,
}
