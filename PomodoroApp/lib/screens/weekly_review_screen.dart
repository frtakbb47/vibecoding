import 'package:flutter/material.dart';

class WeeklyReviewScreen extends StatelessWidget {
  const WeeklyReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulated weekly data
    final weeklyData = _WeeklyData(
      totalMinutes: 845,
      totalSessions: 34,
      averageSessionLength: 25,
      mostProductiveDay: 'Wednesday',
      mostProductiveTime: '9:00 AM - 11:00 AM',
      tasksCompleted: 28,
      goalCompletionRate: 85,
      currentStreak: 12,
      dailyMinutes: [120, 95, 145, 80, 130, 175, 100],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Review'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareWeeklyStats(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Week summary header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.tertiary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    '🎉',
                    style: TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Great Week!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dec 23 - Dec 29, 2024',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Key metrics
            Text(
              'Key Metrics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    '⏱️',
                    '${weeklyData.totalMinutes ~/ 60}h ${weeklyData.totalMinutes % 60}m',
                    'Total Focus Time',
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    '🎯',
                    '${weeklyData.totalSessions}',
                    'Sessions Completed',
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    '✅',
                    '${weeklyData.tasksCompleted}',
                    'Tasks Completed',
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    '🔥',
                    '${weeklyData.currentStreak} days',
                    'Current Streak',
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Daily breakdown chart
            Text(
              'Daily Focus Time',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildWeeklyChart(context, weeklyData.dailyMinutes),
              ),
            ),
            const SizedBox(height: 24),

            // Insights
            Text(
              'Insights',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInsightCard(
              context,
              '📈',
              'Most Productive Day',
              weeklyData.mostProductiveDay,
              'You focused ${weeklyData.dailyMinutes.reduce((a, b) => a > b ? a : b)} minutes!',
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildInsightCard(
              context,
              '⏰',
              'Peak Hours',
              weeklyData.mostProductiveTime,
              'This is when you focus best',
              Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildInsightCard(
              context,
              '📊',
              'Goal Achievement',
              '${weeklyData.goalCompletionRate}%',
              'Daily goal completion rate',
              Colors.purple,
            ),
            const SizedBox(height: 8),
            _buildInsightCard(
              context,
              '⏱️',
              'Average Session',
              '${weeklyData.averageSessionLength} min',
              'Your typical focus duration',
              Colors.orange,
            ),
            const SizedBox(height: 24),

            // Tips based on data
            Text(
              'Suggestions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSuggestionCard(
              context,
              '💡',
              'Consider longer sessions on Thursdays - your data shows lower focus time.',
            ),
            const SizedBox(height: 8),
            _buildSuggestionCard(
              context,
              '🎯',
              'You\'re 15% more productive in the morning. Schedule important tasks then!',
            ),
            const SizedBox(height: 8),
            _buildSuggestionCard(
              context,
              '🏆',
              'You\'re close to a 2-week streak! Keep going for a new record!',
            ),
            const SizedBox(height: 24),

            // CTA
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.rocket_launch),
                label: const Text('Start a New Week Strong!'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String emoji,
    String value,
    String label,
    Color color,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: color, width: 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, List<int> dailyMinutes) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final maxMinutes = dailyMinutes.reduce((a, b) => a > b ? a : b).toDouble();

    return SizedBox(
      height: 180,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final minutes = dailyMinutes[index];
          final height = maxMinutes > 0 ? (minutes / maxMinutes * 120) : 0.0;
          final hours = minutes ~/ 60;
          final mins = minutes % 60;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                hours > 0 ? '${hours}h${mins > 0 ? ' ${mins}m' : ''}' : '${mins}m',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32,
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.tertiary,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                days[index],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildInsightCard(
    BuildContext context,
    String emoji,
    String title,
    String value,
    String subtitle,
    Color color,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(BuildContext context, String emoji, String text) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareWeeklyStats(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Weekly summary copied to clipboard!'),
      ),
    );
  }
}

class _WeeklyData {
  final int totalMinutes;
  final int totalSessions;
  final int averageSessionLength;
  final String mostProductiveDay;
  final String mostProductiveTime;
  final int tasksCompleted;
  final int goalCompletionRate;
  final int currentStreak;
  final List<int> dailyMinutes;

  _WeeklyData({
    required this.totalMinutes,
    required this.totalSessions,
    required this.averageSessionLength,
    required this.mostProductiveDay,
    required this.mostProductiveTime,
    required this.tasksCompleted,
    required this.goalCompletionRate,
    required this.currentStreak,
    required this.dailyMinutes,
  });
}
