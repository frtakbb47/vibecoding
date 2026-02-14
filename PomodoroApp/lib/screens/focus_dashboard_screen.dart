import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/timer_provider.dart';
import '../providers/settings_provider.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';
import '../widgets/focus_tip_card.dart';
import '../widgets/focus_score_card.dart';
import '../widgets/motivational_quote_widget.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/productivity_heatmap.dart';
import 'subjects_screen.dart';
import 'stretch_exercises_screen.dart';
import 'quick_notes_screen.dart';
import 'achievements_screen.dart';
import 'ambient_sounds_screen.dart';
import 'weekly_review_screen.dart';
import 'focus_mode_screen.dart';
import 'study_planner_screen.dart';
import 'pomodoro_tips_screen.dart';
import 'keyboard_shortcuts_screen.dart';
import 'break_activities_screen.dart';
import 'session_notes_screen.dart';
import 'timer_presets_screen.dart';
import 'daily_planning_screen.dart';
import 'theme_customization_screen.dart';
import 'enhanced_statistics_screen.dart';
import 'breathing_exercises_screen.dart';
import 'productivity_insights_screen.dart';
import 'data_management_screen.dart';

class FocusDashboardScreen extends StatefulWidget {
  const FocusDashboardScreen({super.key});

  @override
  State<FocusDashboardScreen> createState() => _FocusDashboardScreenState();
}

class _FocusDashboardScreenState extends State<FocusDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _dailyGoalMinutes = 120;

  // Get real data from storage
  int get _todayMinutes {
    final sessions = StorageService.getSessionsByDate(DateTime.now());
    return sessions
        .where((s) => s.type == AppConstants.stateWork && s.completed)
        .fold<int>(0, (sum, s) => sum + s.durationMinutes);
  }

  int get _todaySessions {
    return StorageService.getTodayWorkSessionCount();
  }

  int get _currentStreak {
    return StorageService.getCurrentStreak();
  }

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
        title: const Text('Focus Dashboard'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(25),
              ),
              labelColor: theme.colorScheme.onPrimary,
              unselectedLabelColor: theme.colorScheme.onSurface,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Student'),
                Tab(text: 'Work'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(context),
          _buildStudentTab(context),
          _buildWorkTab(context),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's Progress Hero Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Progress",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_fire_department, color: Colors.orange, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '$_currentStreak day streak',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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
                      child: _buildProgressStat(
                        value: '$_todayMinutes',
                        label: 'minutes',
                        icon: Icons.timer,
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.white24),
                    Expanded(
                      child: _buildProgressStat(
                        value: '$_todaySessions',
                        label: 'sessions',
                        icon: Icons.check_circle_outline,
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.white24),
                    Expanded(
                      child: _buildProgressStat(
                        value: '${((_todayMinutes / _dailyGoalMinutes) * 100).round()}%',
                        label: 'of goal',
                        icon: Icons.flag,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (_todayMinutes / _dailyGoalMinutes).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Daily Goal Quick Set
          Card(
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
                      Icon(Icons.flag, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Daily Goal',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _showGoalDialog(context),
                        child: const Text('Custom'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [30, 60, 90, 120, 180].map((mins) {
                        final isSelected = _dailyGoalMinutes == mins;
                        final label = mins >= 60 ? '${mins ~/ 60}h' : '${mins}m';
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(label),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) setState(() => _dailyGoalMinutes = mins);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Quick Start Section
          Text(
            '⚡ Quick Start',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          QuickStartButtons(
            onStart: (minutes, label) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FocusModeScreen(
                    initialMinutes: minutes,
                    category: label,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // Weekly Activity Chart
          Card(
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
                      Icon(Icons.bar_chart, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'This Week',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EnhancedStatisticsScreen()),
                        ),
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const WeeklyActivityChart(height: 100),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Week Comparison Card
          const FocusComparisonCard(),
          const SizedBox(height: 20),

          // Daily Goal Quick Set with Ring
          Card(
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
                      Icon(Icons.flag, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Daily Goal',
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _showGoalDialog(context),
                        child: const Text('Custom'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      DailyGoalRing(
                        currentMinutes: _todayMinutes,
                        goalMinutes: _dailyGoalMinutes,
                        size: 80,
                        strokeWidth: 8,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [30, 60, 90, 120, 180].map((mins) {
                              final isSelected = _dailyGoalMinutes == mins;
                              final label = mins >= 60 ? '${mins ~/ 60}h' : '${mins}m';
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(label),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    if (selected) setState(() => _dailyGoalMinutes = mins);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Focus Score Card
          const FocusScoreCard(compact: true),
          const SizedBox(height: 20),

          // Recent Sessions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📋 Recent Sessions',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EnhancedStatisticsScreen()),
                ),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const RecentSessionsList(maxItems: 3),
          const SizedBox(height: 20),

          // Quick Actions Grid (Reorganized - 2x3 with most important features)
          Text(
            'Quick Actions',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
            children: [
              _buildCompactActionButton(context, Icons.school, 'Subjects', Colors.blue,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubjectsScreen()))),
              _buildCompactActionButton(context, Icons.emoji_events, 'Achievements', Colors.amber,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementsScreen()))),
              _buildCompactActionButton(context, Icons.headphones, 'Sounds', Colors.purple,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AmbientSoundsScreen()))),
              _buildCompactActionButton(context, Icons.air, 'Breathe', Colors.teal,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BreathingExercisesScreen()))),
              _buildCompactActionButton(context, Icons.insights, 'Insights', Colors.deepOrange,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductivityInsightsScreen()))),
              _buildCompactActionButton(context, Icons.note_alt, 'Notes', Colors.green,
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuickNotesScreen()))),
            ],
          ),
          const SizedBox(height: 8),

          // "More Features" expandable section
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text(
              'More Features',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            children: [
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.9,
                children: [
                  _buildMiniActionButton(context, Icons.self_improvement, 'Stretch', Colors.green,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StretchExercisesScreen()))),
                  _buildMiniActionButton(context, Icons.calendar_month, 'Review', Colors.teal,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WeeklyReviewScreen()))),
                  _buildMiniActionButton(context, Icons.lightbulb_outline, 'Tips', Colors.indigo,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PomodoroTipsScreen()))),
                  _buildMiniActionButton(context, Icons.coffee, 'Breaks', Colors.brown,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BreakActivitiesScreen()))),
                  _buildMiniActionButton(context, Icons.keyboard, 'Shortcuts', Colors.blueGrey,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KeyboardShortcutsScreen()))),
                  _buildMiniActionButton(context, Icons.note_add, 'Journal', Colors.cyan,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SessionNotesScreen()))),
                  _buildMiniActionButton(context, Icons.speed, 'Presets', Colors.red,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimerPresetsScreen()))),
                  _buildMiniActionButton(context, Icons.today, 'Plan', Colors.deepPurple,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyPlanningScreen()))),
                  _buildMiniActionButton(context, Icons.palette, 'Theme', Colors.pink,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ThemeCustomizationScreen()))),
                  _buildMiniActionButton(context, Icons.insights, 'Insights', Colors.indigo,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductivityInsightsScreen()))),
                  _buildMiniActionButton(context, Icons.storage, 'Data', Colors.grey,
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DataManagementScreen()))),
                  _buildMiniActionButton(context, Icons.water_drop, 'Hydrate', Colors.lightBlue,
                    () {}),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Daily Quote (compact)
          const DailyQuoteCard(),
          const SizedBox(height: 16),

          // Focus Tip (compact)
          const FocusTipCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProgressStat({required String value, required String label, required IconData icon}) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactActionButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniActionButton(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentTab(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Stats Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue[600]!,
                  Colors.blue[400]!,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.school, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Study Mode',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStudentStat('$_todaySessions', 'Sessions'),
                    Container(width: 1, height: 30, color: Colors.white24),
                    _buildStudentStat('${_todayMinutes}m', 'Studied'),
                    Container(width: 1, height: 30, color: Colors.white24),
                    _buildStudentStat('$_currentStreak', 'Day Streak'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick actions for students
          Row(
            children: [
              Expanded(
                child: _buildLargeActionButton(
                  context,
                  icon: Icons.play_circle_filled,
                  label: 'Focus Mode',
                  subtitle: 'Distraction-free timer',
                  color: Colors.green,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FocusModeScreen(
                        initialMinutes: 25,
                        category: 'Study',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLargeActionButton(
                  context,
                  icon: Icons.calendar_today,
                  label: 'Study Planner',
                  subtitle: 'Plan your day',
                  color: Colors.blue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StudyPlannerScreen()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick study session buttons
          Text(
            '⏱️ Quick Study Sessions',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildQuickStudyButton(context, 15, 'Quick Review', Icons.flash_on, Colors.orange)),
              const SizedBox(width: 8),
              Expanded(child: _buildQuickStudyButton(context, 25, 'Pomodoro', Icons.timer, Colors.red)),
              const SizedBox(width: 8),
              Expanded(child: _buildQuickStudyButton(context, 50, 'Deep Study', Icons.psychology, Colors.purple)),
            ],
          ),
          const SizedBox(height: 24),

          // Study tips section
          Text(
            '📚 Study Tips',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const FocusTipCard(category: 'study'),
          const SizedBox(height: 24),

          // Study techniques
          Text(
            '🎯 Effective Study Techniques',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildStudyTechniqueCard(
            context,
            icon: Icons.psychology,
            title: 'Active Recall',
            description: 'Test yourself regularly instead of passive re-reading',
            color: Colors.purple,
          ),
          const SizedBox(height: 8),
          _buildStudyTechniqueCard(
            context,
            icon: Icons.schedule,
            title: 'Spaced Repetition',
            description: 'Review material at increasing intervals',
            color: Colors.blue,
          ),
          const SizedBox(height: 8),
          _buildStudyTechniqueCard(
            context,
            icon: Icons.account_tree,
            title: 'Mind Mapping',
            description: 'Visualize connections between concepts',
            color: Colors.green,
          ),
          const SizedBox(height: 8),
          _buildStudyTechniqueCard(
            context,
            icon: Icons.record_voice_over,
            title: 'Feynman Technique',
            description: 'Explain concepts in simple terms',
            color: Colors.orange,
          ),
          const SizedBox(height: 24),

          // Health tips for students
          Text(
            '💪 Stay Healthy While Studying',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const FocusTipCard(category: 'health'),
        ],
      ),
    );
  }

  Widget _buildWorkTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Work Stats Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.green, Colors.teal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.work_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Work Mode',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Today\'s productivity metrics',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildWorkStat('$_todaySessions', 'Sessions'),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    _buildWorkStat('${_todayMinutes}m', 'Focused'),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    _buildWorkStat('$_currentStreak', 'Streak'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick actions for workers
          Row(
            children: [
              Expanded(
                child: _buildLargeActionButton(
                  context,
                  icon: Icons.play_circle_filled,
                  label: 'Focus Mode',
                  subtitle: 'Deep work session',
                  color: Colors.green,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FocusModeScreen(
                        initialMinutes: 50,
                        category: 'Work',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLargeActionButton(
                  context,
                  icon: Icons.headphones,
                  label: 'Ambient Sounds',
                  subtitle: 'Focus atmosphere',
                  color: Colors.purple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AmbientSoundsScreen()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick Work Sessions
          Text(
            '⚡ Quick Work Sessions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildQuickWorkButton(context, 25, 'Sprint', Icons.flash_on, Colors.orange),
              const SizedBox(width: 8),
              _buildQuickWorkButton(context, 50, 'Deep Work', Icons.psychology, Colors.green),
              const SizedBox(width: 8),
              _buildQuickWorkButton(context, 90, 'Flow State', Icons.auto_awesome, Colors.purple),
            ],
          ),
          const SizedBox(height: 24),

          // Work tips section
          Text(
            '💼 Productivity Tips',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const FocusTipCard(category: 'work'),
          const SizedBox(height: 24),

          // Desk ergonomics
          Text(
            '🪑 Desk Ergonomics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildErgonomicTip(
                    context,
                    '👁️',
                    'Screen Position',
                    'Keep monitor at arm\'s length, top of screen at eye level',
                  ),
                  const Divider(),
                  _buildErgonomicTip(
                    context,
                    '🪑',
                    'Chair Height',
                    'Feet flat on floor, thighs parallel to ground',
                  ),
                  const Divider(),
                  _buildErgonomicTip(
                    context,
                    '⌨️',
                    'Keyboard & Mouse',
                    'Elbows at 90°, wrists straight and relaxed',
                  ),
                  const Divider(),
                  _buildErgonomicTip(
                    context,
                    '💡',
                    'Lighting',
                    'Avoid glare on screen, use natural light when possible',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Productivity methods
          Text(
            '🚀 Productivity Methods',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildProductivityMethodCard(
            context,
            '🐸',
            'Eat the Frog',
            'Do your most challenging task first thing in the morning',
          ),
          const SizedBox(height: 8),
          _buildProductivityMethodCard(
            context,
            '📦',
            'Task Batching',
            'Group similar tasks together to reduce context switching',
          ),
          const SizedBox(height: 8),
          _buildProductivityMethodCard(
            context,
            '⏱️',
            'Time Blocking',
            'Schedule specific blocks for different types of work',
          ),
          const SizedBox(height: 8),
          _buildProductivityMethodCard(
            context,
            '✌️',
            'Two-Minute Rule',
            'If a task takes less than 2 minutes, do it immediately',
          ),
        ],
      ),
    );
  }

  Widget _buildStudyTechniqueCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
      ),
    );
  }

  Widget _buildErgonomicTip(
    BuildContext context,
    String emoji,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductivityMethodCard(
    BuildContext context,
    String emoji,
    String title,
    String description,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  Widget _buildLargeActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGoalDialog(BuildContext context) {
    int newGoal = _dailyGoalMinutes;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Daily Focus Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How many minutes do you want to focus daily?',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setDialogState) {
                return Column(
                  children: [
                    Slider(
                      value: newGoal.toDouble(),
                      min: 15,
                      max: 480,
                      divisions: 31,
                      label: '${newGoal ~/ 60}h ${newGoal % 60}m',
                      onChanged: (value) {
                        setDialogState(() => newGoal = value.toInt());
                      },
                    ),
                    Text(
                      '${newGoal ~/ 60} hours ${newGoal % 60} minutes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() => _dailyGoalMinutes = newGoal);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStudyButton(
    BuildContext context,
    int minutes,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FocusModeScreen(
                  initialMinutes: minutes,
                  category: 'study',
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
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
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '$minutes min',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickWorkButton(
    BuildContext context,
    int minutes,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FocusModeScreen(
                  initialMinutes: minutes,
                  category: 'work',
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
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
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '$minutes min',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
