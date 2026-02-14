import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

/// A compact weekly activity chart showing sessions per day
class WeeklyActivityChart extends StatelessWidget {
  final double height;
  final bool showLabels;

  const WeeklyActivityChart({
    super.key,
    this.height = 120,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = _getWeeklyData();
    final maxSessions = data.values.fold<int>(1, (max, val) => val > max ? val : max);

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final date = DateTime.now().subtract(Duration(days: 6 - index));
          final dayName = _getDayName(date.weekday);
          final sessions = data[_dateKey(date)] ?? 0;
          final barHeight = maxSessions > 0
              ? (sessions / maxSessions) * (height - 24)
              : 0.0;
          final isToday = index == 6;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Session count
                  if (sessions > 0)
                    Text(
                      '$sessions',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isToday
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: 4),
                  // Bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    height: barHeight.clamp(4.0, height - 24),
                    decoration: BoxDecoration(
                      color: isToday
                          ? theme.colorScheme.primary
                          : sessions > 0
                              ? theme.colorScheme.primary.withOpacity(0.5)
                              : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Day label
                  if (showLabels)
                    Text(
                      dayName,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        color: isToday
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Map<String, int> _getWeeklyData() {
    final data = <String, int>{};
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final sessions = StorageService.getSessionsByDate(date);
      final workSessions = sessions.where((s) =>
          s.type == AppConstants.stateWork && s.completed).length;
      data[_dateKey(date)] = workSessions;
    }

    return data;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  String _getDayName(int weekday) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[weekday - 1];
  }
}

/// A circular progress indicator showing daily goal progress
class DailyGoalRing extends StatelessWidget {
  final int currentMinutes;
  final int goalMinutes;
  final double size;
  final double strokeWidth;
  final bool showLabel;

  const DailyGoalRing({
    super.key,
    required this.currentMinutes,
    required this.goalMinutes,
    this.size = 100,
    this.strokeWidth = 10,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = goalMinutes > 0
        ? (currentMinutes / goalMinutes).clamp(0.0, 1.0)
        : 0.0;
    final isComplete = currentMinutes >= goalMinutes;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          // Progress ring
          SizedBox(
            width: size,
            height: size,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: strokeWidth,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete ? Colors.green : theme.colorScheme.primary,
                  ),
                  strokeCap: StrokeCap.round,
                );
              },
            ),
          ),
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isComplete)
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: size * 0.3,
                )
              else
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    fontSize: size * 0.2,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              if (showLabel && !isComplete)
                Text(
                  '$currentMinutes/${goalMinutes}m',
                  style: TextStyle(
                    fontSize: size * 0.1,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A card showing focus statistics comparison
class FocusComparisonCard extends StatelessWidget {
  const FocusComparisonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final comparison = _getComparison();

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.compare_arrows,
                    color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'This Week vs Last Week',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildComparisonStat(
                    context,
                    label: 'Sessions',
                    thisWeek: comparison['thisWeekSessions'] ?? 0,
                    lastWeek: comparison['lastWeekSessions'] ?? 0,
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: theme.colorScheme.outlineVariant,
                ),
                Expanded(
                  child: _buildComparisonStat(
                    context,
                    label: 'Minutes',
                    thisWeek: comparison['thisWeekMinutes'] ?? 0,
                    lastWeek: comparison['lastWeekMinutes'] ?? 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonStat(
    BuildContext context, {
    required String label,
    required int thisWeek,
    required int lastWeek,
  }) {
    final theme = Theme.of(context);
    final diff = thisWeek - lastWeek;
    final percentChange = lastWeek > 0
        ? ((diff / lastWeek) * 100).round()
        : thisWeek > 0 ? 100 : 0;
    final isPositive = diff >= 0;

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$thisWeek',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: isPositive ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 2),
              Text(
                '$percentChange%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, int> _getComparison() {
    final now = DateTime.now();
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));

    final thisWeekSessions = StorageService.getSessionsInRange(
      thisWeekStart,
      now,
    ).where((s) => s.type == AppConstants.stateWork && s.completed);

    final lastWeekSessions = StorageService.getSessionsInRange(
      lastWeekStart,
      lastWeekEnd,
    ).where((s) => s.type == AppConstants.stateWork && s.completed);

    return {
      'thisWeekSessions': thisWeekSessions.length,
      'lastWeekSessions': lastWeekSessions.length,
      'thisWeekMinutes': thisWeekSessions.fold<int>(
          0, (sum, s) => sum + s.durationMinutes),
      'lastWeekMinutes': lastWeekSessions.fold<int>(
          0, (sum, s) => sum + s.durationMinutes),
    };
  }
}

/// Quick start buttons for common focus durations
class QuickStartButtons extends StatelessWidget {
  final Function(int minutes, String label) onStart;

  const QuickStartButtons({
    super.key,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presets = [
      {'minutes': 15, 'label': 'Quick', 'icon': Icons.bolt, 'color': Colors.orange},
      {'minutes': 25, 'label': 'Classic', 'icon': Icons.timer, 'color': Colors.red},
      {'minutes': 45, 'label': 'Deep', 'icon': Icons.psychology, 'color': Colors.purple},
      {'minutes': 90, 'label': 'Ultra', 'icon': Icons.rocket_launch, 'color': Colors.blue},
    ];

    return Row(
      children: presets.map((preset) {
        final minutes = preset['minutes'] as int;
        final label = preset['label'] as String;
        final icon = preset['icon'] as IconData;
        final color = preset['color'] as Color;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => onStart(minutes, label),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: color, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        '${minutes}m',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          color: color.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Recent sessions list
class RecentSessionsList extends StatelessWidget {
  final int maxItems;

  const RecentSessionsList({
    super.key,
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessions = StorageService.getAllSessions()
        .where((s) => s.type == AppConstants.stateWork && s.completed)
        .take(maxItems)
        .toList();

    if (sessions.isEmpty) {
      return Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.history,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'No sessions yet',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Start a focus session to see your history',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: sessions.asMap().entries.map((entry) {
          final index = entry.key;
          final session = entry.value;
          final isLast = index == sessions.length - 1;

          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.timer,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  session.taskTitle ?? '${session.durationMinutes} min session',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  _formatTime(session.startTime),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Text(
                  '${session.durationMinutes}m',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 56,
                  endIndent: 16,
                  color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}

/// Motivational streak display
class StreakDisplay extends StatelessWidget {
  const StreakDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final streak = StorageService.getCurrentStreak();
    final bestStreak = _getBestStreak();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.2),
            Colors.red.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Fire icon with animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_fire_department,
                color: Colors.orange,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak day streak!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                Text(
                  streak > 0
                      ? 'Keep it up! Best: $bestStreak days'
                      : 'Start a session to begin your streak',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (streak >= 7)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '🔥 On Fire!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  int _getBestStreak() {
    // This would need to be stored/calculated properly
    // For now, return current streak as a placeholder
    return StorageService.getCurrentStreak();
  }
}
