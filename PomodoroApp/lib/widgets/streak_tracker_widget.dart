import 'package:flutter/material.dart';

class StreakTrackerWidget extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final List<bool> lastSevenDays;

  const StreakTrackerWidget({
    super.key,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastSevenDays = const [false, false, false, false, false, false, false],
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('🔥', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Focus Streak',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Keep your momentum going!',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Streak stats
            Row(
              children: [
                Expanded(
                  child: _buildStreakStat(
                    context,
                    'Current',
                    currentStreak,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStreakStat(
                    context,
                    'Longest',
                    longestStreak,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Last 7 days
            Text(
              'Last 7 Days',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                final isCompleted = index < lastSevenDays.length && lastSevenDays[index];
                final isToday = index == 6;

                return Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? Colors.orange
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        border: isToday && !isCompleted
                            ? Border.all(color: Colors.orange, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : Text(
                                dayNames[index],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isToday
                                      ? Colors.orange
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                      ),
                    ),
                    if (isToday)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                );
              }),
            ),

            // Motivational message
            if (currentStreak > 0) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('💪', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getMotivationalMessage(currentStreak),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStreakStat(BuildContext context, String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '$label ${value == 1 ? 'day' : 'days'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _getMotivationalMessage(int streak) {
    if (streak >= 100) return 'Legendary! 100+ days of pure dedication!';
    if (streak >= 30) return 'Incredible! A full month of focus!';
    if (streak >= 14) return 'Two weeks strong! Keep crushing it!';
    if (streak >= 7) return 'One week done! You\'re on fire!';
    if (streak >= 3) return 'Building momentum! Don\'t stop now!';
    return 'Great start! Come back tomorrow!';
  }
}

class MiniStreakDisplay extends StatelessWidget {
  final int currentStreak;

  const MiniStreakDisplay({
    super.key,
    this.currentStreak = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (currentStreak == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            '$currentStreak',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
