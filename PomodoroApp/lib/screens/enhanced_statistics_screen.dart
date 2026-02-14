import 'package:flutter/material.dart';
import 'dart:math';

class EnhancedStatisticsScreen extends StatefulWidget {
  const EnhancedStatisticsScreen({super.key});

  @override
  State<EnhancedStatisticsScreen> createState() => _EnhancedStatisticsScreenState();
}

class _EnhancedStatisticsScreenState extends State<EnhancedStatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Week';

  // Simulated data
  final Random _random = Random(42);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Charts'),
            Tab(text: 'Insights'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(theme),
          _buildChartsTab(theme),
          _buildInsightsTab(theme),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Focus Score
        _buildFocusScoreCard(theme),
        const SizedBox(height: 16),

        // Quick stats
        Row(
          children: [
            Expanded(child: _buildStatCard(theme, 'Today', '127', 'min', Colors.blue)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(theme, 'This Week', '14.2', 'hrs', Colors.green)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard(theme, 'Sessions', '23', 'total', Colors.orange)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(theme, 'Streak', '7', 'days', Colors.red)),
          ],
        ),
        const SizedBox(height: 16),

        // Heatmap Calendar
        _buildHeatmapCalendar(theme),
        const SizedBox(height: 16),

        // Most productive hours
        _buildProductiveHoursCard(theme),
      ],
    );
  }

  Widget _buildChartsTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Period selector
        Row(
          children: ['Day', 'Week', 'Month', 'Year'].map((period) {
            final isSelected = _selectedPeriod == period;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(period),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedPeriod = period),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Daily focus chart
        _buildDailyFocusChart(theme),
        const SizedBox(height: 16),

        // Category breakdown
        _buildCategoryBreakdown(theme),
        const SizedBox(height: 16),

        // Session distribution
        _buildSessionDistribution(theme),
      ],
    );
  }

  Widget _buildInsightsTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInsightCard(
          theme,
          icon: Icons.trending_up,
          color: Colors.green,
          title: 'Great Progress!',
          description: 'Your focus time increased by 23% compared to last week.',
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          theme,
          icon: Icons.schedule,
          color: Colors.blue,
          title: 'Peak Hours',
          description: 'You\'re most productive between 9 AM and 11 AM.',
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          theme,
          icon: Icons.local_fire_department,
          color: Colors.orange,
          title: 'Hot Streak',
          description: 'You\'ve maintained a 7-day streak. Keep going!',
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          theme,
          icon: Icons.category,
          color: Colors.purple,
          title: 'Top Category',
          description: 'Most time spent on "Study" - 8.5 hours this week.',
        ),
        const SizedBox(height: 12),
        _buildInsightCard(
          theme,
          icon: Icons.lightbulb,
          color: Colors.amber,
          title: 'Suggestion',
          description: 'Try scheduling your hardest tasks during your peak hours for better results.',
        ),
        const SizedBox(height: 16),

        // Weekly comparison
        _buildWeeklyComparison(theme),
      ],
    );
  }

  Widget _buildFocusScoreCard(ThemeData theme) {
    const score = 85;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 10,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(
                      score >= 80 ? Colors.green : score >= 60 ? Colors.orange : Colors.red,
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$score',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Score',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Focus Score',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Excellent! You\'re in the top 15% of focused users.',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.arrow_upward, size: 16, color: Colors.green),
                      Text(
                        '+5 from last week',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String label, String value, String unit, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    unit,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapCalendar(ThemeData theme) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final startWeekday = startOfMonth.weekday;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Focus Heatmap',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  _getMonthName(now.month),
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Weekday headers
            Row(
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) {
                return Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),

            // Calendar grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: 42,
              itemBuilder: (context, index) {
                final dayOffset = index - startWeekday + 1;
                if (dayOffset < 1 || dayOffset > daysInMonth) {
                  return const SizedBox();
                }

                final minutes = _random.nextInt(150);
                final intensity = (minutes / 150).clamp(0.0, 1.0);
                final isToday = dayOffset == now.day;

                return Container(
                  decoration: BoxDecoration(
                    color: minutes == 0
                        ? theme.colorScheme.surfaceContainerHighest
                        : Colors.green.withOpacity(0.2 + intensity * 0.8),
                    borderRadius: BorderRadius.circular(4),
                    border: isToday
                        ? Border.all(color: theme.colorScheme.primary, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$dayOffset',
                      style: TextStyle(
                        fontSize: 11,
                        color: intensity > 0.5 ? Colors.white : theme.colorScheme.onSurface,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Less', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(width: 8),
                ...List.generate(5, (i) {
                  return Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i == 0
                          ? theme.colorScheme.surfaceContainerHighest
                          : Colors.green.withOpacity(0.2 + (i / 4) * 0.8),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                Text('More', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductiveHoursCard(ThemeData theme) {
    final hours = List.generate(24, (i) => _random.nextInt(60));
    final maxHour = hours.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Most Productive Hours',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(24, (i) {
                  final height = maxHour > 0 ? (hours[i] / maxHour) * 60 : 0.0;
                  return Expanded(
                    child: Tooltip(
                      message: '${i.toString().padLeft(2, '0')}:00 - ${hours[i]} min',
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        height: height + 4,
                        decoration: BoxDecoration(
                          color: i >= 9 && i <= 11
                              ? Colors.green
                              : theme.colorScheme.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('00:00', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                Text('06:00', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                Text('12:00', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                Text('18:00', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
                Text('24:00', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyFocusChart(ThemeData theme) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final values = List.generate(7, (i) => _random.nextInt(180) + 20);
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Focus Time',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final height = (values[i] / maxValue) * 120;
                  final isToday = i == DateTime.now().weekday - 1;

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${values[i]}',
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: height,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isToday
                                ? theme.colorScheme.primary
                                : theme.colorScheme.primary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          days[i],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(ThemeData theme) {
    final categories = [
      ('Study', 35, Colors.blue),
      ('Work', 28, Colors.orange),
      ('Coding', 20, Colors.purple),
      ('Reading', 12, Colors.green),
      ('Other', 5, Colors.grey),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...categories.map((cat) => _buildCategoryRow(theme, cat.$1, cat.$2, cat.$3)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(ThemeData theme, String name, int percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name),
                    Text('$percent%', style: TextStyle(fontWeight: FontWeight.w600, color: color)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent / 100,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionDistribution(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Duration Distribution',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDistributionRow(theme, '< 15 min', 8, Colors.red),
            _buildDistributionRow(theme, '15-25 min', 45, Colors.orange),
            _buildDistributionRow(theme, '25-45 min', 32, Colors.green),
            _buildDistributionRow(theme, '> 45 min', 15, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionRow(ThemeData theme, String range, int percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              range,
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent / 100,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '$percent%',
              style: TextStyle(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
    ThemeData theme, {
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
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

  Widget _buildWeeklyComparison(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week vs Last Week',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildComparisonRow(theme, 'Focus Time', '14.2 hrs', '11.5 hrs', true),
            _buildComparisonRow(theme, 'Sessions', '23', '18', true),
            _buildComparisonRow(theme, 'Avg Session', '37 min', '38 min', false),
            _buildComparisonRow(theme, 'Goals Met', '6/7', '4/7', true),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(
    ThemeData theme,
    String label,
    String thisWeek,
    String lastWeek,
    bool improved,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(
              thisWeek,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              lastWeek,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 30,
            child: Icon(
              improved ? Icons.arrow_upward : Icons.arrow_downward,
              color: improved ? Colors.green : Colors.red,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
