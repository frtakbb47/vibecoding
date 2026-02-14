import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class DailyGoalProgress extends StatelessWidget {
  final int completedMinutes;
  final int targetMinutes;
  final int sessionsCompleted;

  const DailyGoalProgress({
    super.key,
    required this.completedMinutes,
    required this.targetMinutes,
    required this.sessionsCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final progress = targetMinutes > 0
        ? (completedMinutes / targetMinutes).clamp(0.0, 1.0)
        : 0.0;
    final isGoalAchieved = completedMinutes >= targetMinutes && targetMinutes > 0;

    final hours = completedMinutes ~/ 60;
    final mins = completedMinutes % 60;
    final targetHours = targetMinutes ~/ 60;
    final targetMins = targetMinutes % 60;

    String timeText;
    if (hours > 0) {
      timeText = '${hours}h ${mins}m';
    } else {
      timeText = '${mins}m';
    }

    String targetText;
    if (targetHours > 0) {
      targetText = '${targetHours}h ${targetMins}m';
    } else {
      targetText = '${targetMins}m';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isGoalAchieved ? Icons.emoji_events : Icons.flag_outlined,
                      color: isGoalAchieved
                          ? Colors.amber
                          : Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.todayProgress,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (isGoalAchieved)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Goal Achieved!',
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isGoalAchieved
                      ? Colors.amber
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(
                  icon: Icons.timer_outlined,
                  value: timeText,
                  label: '/ $targetText',
                ),
                _StatItem(
                  icon: Icons.done_all,
                  value: '$sessionsCompleted',
                  label: l10n.sessions,
                ),
                _StatItem(
                  icon: Icons.percent,
                  value: '${(progress * 100).toInt()}%',
                  label: l10n.progress,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
