import 'package:flutter/material.dart';
import '../services/productivity_insights_service.dart';

class ProductivityInsightsScreen extends StatefulWidget {
  const ProductivityInsightsScreen({super.key});

  @override
  State<ProductivityInsightsScreen> createState() => _ProductivityInsightsScreenState();
}

class _ProductivityInsightsScreenState extends State<ProductivityInsightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ProductivityAnalysis _analysis;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _analysis = ProductivityInsightsService.analyzeProductivity();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productivity Insights'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.insights), text: 'Overview'),
            Tab(icon: Icon(Icons.schedule), text: 'Timing'),
            Tab(icon: Icon(Icons.lightbulb_outline), text: 'Tips'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildTimingTab(),
          _buildTipsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weekly trend card
          _buildTrendCard(),
          const SizedBox(height: 16),

          // Streak analysis
          _buildStreakCard(),
          const SizedBox(height: 16),

          // Focus distribution
          _buildDistributionCard(),
          const SizedBox(height: 16),

          // Optimal session length
          _buildOptimalLengthCard(),
        ],
      ),
    );
  }

  Widget _buildTrendCard() {
    final trend = _analysis.weeklyTrend;
    final isUp = trend.direction == TrendDirection.up;
    final isDown = trend.direction == TrendDirection.down;

    final color = isUp ? Colors.green : isDown ? Colors.red : Colors.grey;
    final icon = isUp ? Icons.trending_up : isDown ? Icons.trending_down : Icons.trending_flat;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📊 Weekly Trend',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 16, color: color),
                      const SizedBox(width: 4),
                      Text(
                        '${trend.percentChange.abs().toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTrendStat(
                    label: 'This Week',
                    value: '${trend.thisWeekTotal}',
                    subtitle: 'sessions',
                    isHighlighted: true,
                  ),
                ),
                Container(
                  height: 50,
                  width: 1,
                  color: Colors.grey.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildTrendStat(
                    label: 'Last Week',
                    value: '${trend.lastWeekTotal}',
                    subtitle: 'sessions',
                    isHighlighted: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendStat({
    required String label,
    required String value,
    required String subtitle,
    required bool isHighlighted,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isHighlighted
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[700],
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard() {
    final streak = _analysis.streakAnalysis;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔥 Streak Analysis',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStreakItem(
                    label: 'Current',
                    value: '${streak.currentStreak}',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStreakItem(
                    label: 'Longest',
                    value: '${streak.longestStreak}',
                    icon: Icons.emoji_events,
                    color: Colors.amber,
                  ),
                ),
                Expanded(
                  child: _buildStreakItem(
                    label: 'Avg/Day',
                    value: streak.averageSessionsPerStreakDay.toStringAsFixed(1),
                    icon: Icons.bar_chart,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDistributionCard() {
    final distribution = _analysis.focusDistribution;
    final maxValue = distribution.values.isEmpty
        ? 1
        : distribution.values.reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🌤️ Focus Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...distribution.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildDistributionBar(
                label: entry.key,
                value: entry.value,
                maxValue: maxValue,
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionBar({
    required String label,
    required int value,
    required int maxValue,
  }) {
    final progress = maxValue > 0 ? value / maxValue : 0.0;
    final color = label.contains('Morning')
        ? Colors.orange
        : label.contains('Afternoon')
            ? Colors.blue
            : label.contains('Evening')
                ? Colors.purple
                : Colors.indigo;

    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 30,
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildOptimalLengthCard() {
    final optimal = _analysis.optimalSessionLength;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.withOpacity(0.1),
              Colors.purple.withOpacity(0.05),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${optimal.recommendedMinutes}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚡ Optimal Session Length',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${optimal.recommendedMinutes} minutes',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    optimal.reason,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Best hours
          _buildBestHoursCard(),
          const SizedBox(height: 16),

          // Best days
          _buildBestDaysCard(),
        ],
      ),
    );
  }

  Widget _buildBestHoursCard() {
    final hours = _analysis.bestFocusHours;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⏰ Best Focus Hours',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Based on your completion rate',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            if (hours.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Complete more sessions to see your best hours',
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ...hours.asMap().entries.map((entry) {
                final index = entry.key;
                final hour = entry.value;
                final color = index == 0
                    ? Colors.green
                    : index == 1
                        ? Colors.blue
                        : Colors.grey;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildHourRow(hour, color, index + 1),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildHourRow(HourlyProductivity hour, Color color, int rank) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatHour(hour.hour),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${hour.completedSessions} sessions • ${(hour.completionRate * 100).round()}% completion',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${hour.totalMinutes}m',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBestDaysCard() {
    final days = _analysis.bestFocusDays;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '📅 Focus by Day',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (days.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Complete sessions on different days to see patterns',
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: days.map((day) => _buildDayChip(day)).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayChip(DailyProductivity day) {
    final isTopDay = _analysis.bestFocusDays.first.dayNumber == day.dayNumber;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isTopDay
            ? Colors.green.withOpacity(0.15)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: isTopDay
            ? Border.all(color: Colors.green.withOpacity(0.5))
            : null,
      ),
      child: Column(
        children: [
          Text(
            day.dayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isTopDay ? Colors.green : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${day.completedSessions}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isTopDay ? Colors.green : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsTab() {
    final suggestions = _analysis.suggestions;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 Personalized Suggestions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Based on your focus patterns',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),

          ...suggestions.map((suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSuggestionCard(suggestion),
          )),

          if (suggestions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.psychology, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Complete more sessions to unlock personalized tips!',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(ProductivitySuggestion suggestion) {
    Color priorityColor;
    switch (suggestion.priority) {
      case SuggestionPriority.high:
        priorityColor = Colors.red;
        break;
      case SuggestionPriority.medium:
        priorityColor = Colors.orange;
        break;
      case SuggestionPriority.low:
        priorityColor = Colors.blue;
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(
              color: priorityColor,
              width: 4,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              suggestion.icon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    suggestion.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12:00 AM';
    if (hour == 12) return '12:00 PM';
    if (hour < 12) return '$hour:00 AM';
    return '${hour - 12}:00 PM';
  }
}
