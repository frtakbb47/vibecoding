import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// FEATURE 4: PRODUCTIVITY HEATMAP (GitHub-style contribution graph)
// ═══════════════════════════════════════════════════════════════════════════════

/// A GitHub-style contribution heatmap showing daily focus activity
/// Displays the last 365 days of productivity data
class ProductivityHeatmap extends StatelessWidget {
  final int weeksToShow;
  final double cellSize;
  final double cellSpacing;
  final bool showMonthLabels;
  final bool showDayLabels;
  final bool showLegend;
  final Color? emptyColor;
  final List<Color>? colorGradient;

  const ProductivityHeatmap({
    super.key,
    this.weeksToShow = 52, // Full year
    this.cellSize = 12,
    this.cellSpacing = 3,
    this.showMonthLabels = true,
    this.showDayLabels = true,
    this.showLegend = true,
    this.emptyColor,
    this.colorGradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get heatmap data
    final heatmapData = _buildHeatmapData();

    // Default colors
    final empty = emptyColor ?? (isDark ? Colors.grey[850]! : Colors.grey[200]!);
    final gradient = colorGradient ?? [
      empty,
      const Color(0xFF9BE9A8), // Light green
      const Color(0xFF40C463), // Medium green
      const Color(0xFF30A14E), // Dark green
      const Color(0xFF216E39), // Darkest green
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month labels
        if (showMonthLabels) _buildMonthLabels(heatmapData, theme),

        const SizedBox(height: 4),

        // Heatmap grid with day labels
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day labels (Mon, Wed, Fri)
            if (showDayLabels) _buildDayLabels(theme),

            // Heatmap cells
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true, // Most recent on the right
                child: _buildHeatmapGrid(heatmapData, gradient, empty, theme),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Legend and stats
        if (showLegend) _buildLegend(heatmapData, gradient, empty, theme),
      ],
    );
  }

  /// Build heatmap data from Pomodoro sessions
  Map<DateTime, int> _buildHeatmapData() {
    final sessions = StorageService.getAllSessions();
    final Map<DateTime, int> data = {};

    // Only count completed work sessions
    final workSessions = sessions.where((s) =>
      s.type == AppConstants.stateWork && s.completed
    );

    for (final session in workSessions) {
      // Normalize to date only (no time)
      final date = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );

      data[date] = (data[date] ?? 0) + session.durationMinutes;
    }

    return data;
  }

  /// Calculate intensity level (0-4) based on minutes
  int _getIntensityLevel(int minutes) {
    if (minutes == 0) return 0;
    if (minutes < 30) return 1;   // < 30 min
    if (minutes < 60) return 2;   // 30-60 min
    if (minutes < 120) return 3;  // 1-2 hours
    return 4;                      // 2+ hours
  }

  /// Build month labels row
  Widget _buildMonthLabels(Map<DateTime, int> data, ThemeData theme) {
    final now = DateTime.now();
    final months = <String>[];
    final positions = <int>[];

    String? lastMonth;
    int weekIndex = 0;

    for (int i = weeksToShow - 1; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + (i * 7)));
      final monthName = _getMonthName(weekStart.month);

      if (monthName != lastMonth) {
        months.add(monthName);
        positions.add(weekIndex);
        lastMonth = monthName;
      }
      weekIndex++;
    }

    return SizedBox(
      height: 16,
      child: Row(
        children: [
          if (showDayLabels) SizedBox(width: 28), // Space for day labels
          Expanded(
            child: Stack(
              children: [
                for (int i = 0; i < months.length; i++)
                  Positioned(
                    left: positions[i] * (cellSize + cellSpacing),
                    child: Text(
                      months[i],
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build day labels column
  Widget _buildDayLabels(ThemeData theme) {
    final labels = ['', 'Mon', '', 'Wed', '', 'Fri', ''];

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: labels.map((label) => SizedBox(
          height: cellSize + cellSpacing,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
          ),
        )).toList(),
      ),
    );
  }

  /// Build the actual heatmap grid
  Widget _buildHeatmapGrid(
    Map<DateTime, int> data,
    List<Color> gradient,
    Color empty,
    ThemeData theme,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Build weeks (columns)
    final weeks = <Widget>[];

    for (int week = weeksToShow - 1; week >= 0; week--) {
      final weekStart = today.subtract(Duration(days: today.weekday - 1 + (week * 7)));

      // Build days in this week (rows)
      final days = <Widget>[];

      for (int day = 0; day < 7; day++) {
        final date = weekStart.add(Duration(days: day));

        // Don't show future dates
        if (date.isAfter(today)) {
          days.add(SizedBox(
            width: cellSize,
            height: cellSize,
          ));
          continue;
        }

        final minutes = data[date] ?? 0;
        final level = _getIntensityLevel(minutes);
        final color = gradient[level.clamp(0, gradient.length - 1)];

        days.add(
          Tooltip(
            message: _formatTooltip(date, minutes),
            child: Container(
              width: cellSize,
              height: cellSize,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
                border: date == today
                    ? Border.all(color: theme.colorScheme.primary, width: 1.5)
                    : null,
              ),
            ),
          ),
        );
      }

      weeks.add(
        Padding(
          padding: EdgeInsets.only(right: cellSpacing),
          child: Column(
            children: days.map((day) => Padding(
              padding: EdgeInsets.only(bottom: cellSpacing),
              child: day,
            )).toList(),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: weeks,
    );
  }

  /// Build legend row
  Widget _buildLegend(
    Map<DateTime, int> data,
    List<Color> gradient,
    Color empty,
    ThemeData theme,
  ) {
    // Calculate stats
    final totalMinutes = data.values.fold<int>(0, (sum, m) => sum + m);
    final totalDays = data.keys.length;
    final currentStreak = _calculateCurrentStreak(data);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Stats
        Row(
          children: [
            _buildStatChip(
              '${(totalMinutes / 60).toStringAsFixed(1)}h',
              'Total',
              theme,
            ),
            const SizedBox(width: 12),
            _buildStatChip(
              '$totalDays',
              'Days',
              theme,
            ),
            const SizedBox(width: 12),
            _buildStatChip(
              '$currentStreak 🔥',
              'Streak',
              theme,
            ),
          ],
        ),

        // Color legend
        Row(
          children: [
            Text(
              'Less',
              style: TextStyle(
                fontSize: 10,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(width: 4),
            ...gradient.map((color) => Container(
              width: cellSize,
              height: cellSize,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            )),
            const SizedBox(width: 4),
            Text(
              'More',
              style: TextStyle(
                fontSize: 10,
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatChip(String value, String label, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  String _formatTooltip(DateTime date, int minutes) {
    final dayName = _getDayName(date.weekday);
    final monthName = _getMonthName(date.month);

    if (minutes == 0) {
      return 'No activity on $dayName, $monthName ${date.day}';
    }

    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    final timeStr = hours > 0
        ? '${hours}h ${mins}m'
        : '${mins}m';

    return '$timeStr on $dayName, $monthName ${date.day}';
  }

  String _getMonthName(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
  }

  String _getDayName(int weekday) {
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday];
  }

  int _calculateCurrentStreak(Map<DateTime, int> data) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int streak = 0;
    DateTime checkDate = today;

    // If no activity today, start from yesterday
    if (!data.containsKey(today) || data[today] == 0) {
      checkDate = today.subtract(const Duration(days: 1));
    }

    while (true) {
      if (data.containsKey(checkDate) && data[checkDate]! > 0) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}

/// Compact version for dashboard/home screen
class CompactProductivityHeatmap extends StatelessWidget {
  final int weeksToShow;

  const CompactProductivityHeatmap({
    super.key,
    this.weeksToShow = 12, // ~3 months
  });

  @override
  Widget build(BuildContext context) {
    return ProductivityHeatmap(
      weeksToShow: weeksToShow,
      cellSize: 10,
      cellSpacing: 2,
      showMonthLabels: false,
      showDayLabels: false,
      showLegend: false,
    );
  }
}
