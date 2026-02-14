import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/storage_service.dart';
import '../models/session.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';
import '../widgets/productivity_heatmap.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _selectedPeriod = 0; // 0: Week, 1: Month, 2: Year

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).statistics),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsCards(),
            const SizedBox(height: 24),
            // GitHub-style Productivity Heatmap
            const ProductivityHeatmap(),
            const SizedBox(height: 24),
            _buildPeriodSelector(),
            const SizedBox(height: 16),
            _buildChart(),
            const SizedBox(height: 24),
            _buildRecentSessions(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final todayCount = StorageService.getTodayWorkSessionCount();
    final streak = StorageService.getCurrentStreak();
    final allSessions = StorageService.getAllSessions();
    final totalWorkSessions = allSessions
        .where((s) => s.type == AppConstants.stateWork && s.completed)
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            AppLocalizations.of(context).todayProgress.split(' ')[0],
            todayCount.toString(),
            Icons.today,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            AppLocalizations.of(context).streak,
            '$streak',
            Icons.local_fire_department,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            AppLocalizations.of(context).completed,
            totalWorkSessions.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SegmentedButton<int>(
        style: SegmentedButton.styleFrom(
          minimumSize: const Size(80, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        segments: [
          ButtonSegment(
            value: 0,
            label: Text(AppLocalizations.of(context).week, style: const TextStyle(fontSize: 14)),
          ),
          ButtonSegment(
            value: 1,
            label: Text(AppLocalizations.of(context).month, style: const TextStyle(fontSize: 14)),
          ),
          ButtonSegment(
            value: 2,
            label: Text(AppLocalizations.of(context).year, style: const TextStyle(fontSize: 14)),
          ),
        ],
        selected: {_selectedPeriod},
        onSelectionChanged: (Set<int> newSelection) {
          setState(() => _selectedPeriod = newSelection.first);
        },
      ),
    );
  }

  Widget _buildChart() {
    final data = _getChartData();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).completedSessions,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: data.isEmpty
                  ? Center(child: Text(AppLocalizations.of(context).noDataAvailable))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: (data.map((e) => e.value).reduce((a, b) => a > b ? a : b) + 2)
                            .toDouble(),
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 &&
                                    value.toInt() < data.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      data[value.toInt()].label,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: data
                            .asMap()
                            .entries
                            .map(
                              (entry) => BarChartGroupData(
                                x: entry.key,
                                barRods: [
                                  BarChartRodData(
                                    toY: entry.value.value.toDouble(),
                                    color: AppConstants.primaryRed,
                                    width: 20,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<ChartData> _getChartData() {
    final now = DateTime.now();
    List<ChartData> data = [];

    switch (_selectedPeriod) {
      case 0: // Week
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final sessions = StorageService.getSessionsByDate(date);
          final count = sessions
              .where((s) => s.type == AppConstants.stateWork && s.completed)
              .length;
          data.add(ChartData(_getDayLabel(date.weekday), count));
        }
        break;
      case 1: // Month
        for (int i = 29; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final sessions = StorageService.getSessionsByDate(date);
          final count = sessions
              .where((s) => s.type == AppConstants.stateWork && s.completed)
              .length;
          if (i % 5 == 0 || i == 29) {
            data.add(ChartData('${date.day}', count));
          }
        }
        break;
      case 2: // Year
        for (int i = 11; i >= 0; i--) {
          final month = DateTime(now.year, now.month - i, 1);
          final nextMonth = DateTime(now.year, now.month - i + 1, 1);
          final sessions = StorageService.getSessionsInRange(month, nextMonth);
          final count = sessions
              .where((s) => s.type == AppConstants.stateWork && s.completed)
              .length;
          data.add(ChartData(_getMonthLabel(month.month), count));
        }
        break;
    }

    return data;
  }

  Widget _buildRecentSessions() {
    final sessions = StorageService.getAllSessions().take(10).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).recentSessions,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (sessions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(AppLocalizations.of(context).noSessionsYet),
                ),
              )
            else
              ...sessions.map((session) => _buildSessionTile(session)),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTile(PomodoroSession session) {
    IconData icon;
    Color color;
    String label;

    switch (session.type) {
      case AppConstants.stateWork:
        icon = Icons.work_outline;
        color = AppConstants.primaryRed;
        label = AppLocalizations.of(context).workSessionLabel;
        break;
      case AppConstants.stateShortBreak:
        icon = Icons.coffee_outlined;
        color = AppConstants.primaryGreen;
        label = AppLocalizations.of(context).shortBreakLabel;
        break;
      case AppConstants.stateLongBreak:
        icon = Icons.beach_access_outlined;
        color = AppConstants.primaryBlue;
        label = AppLocalizations.of(context).longBreakLabel;
        break;
      default:
        icon = Icons.timer;
        color = Colors.grey;
        label = AppLocalizations.of(context).session;
    }

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      subtitle: Text(
        '${_formatDateTime(session.startTime)} • ${session.durationMinutes} ${AppLocalizations.of(context).min}',
      ),
      trailing: Icon(
        session.completed ? Icons.check_circle : Icons.cancel,
        color: session.completed ? Colors.green : Colors.grey,
      ),
    );
  }

  String _getDayLabel(int weekday) {
    final l10n = AppLocalizations.of(context);
    return [l10n.mon, l10n.tue, l10n.wed, l10n.thu, l10n.fri, l10n.sat, l10n.sun][weekday - 1];
  }

  String _getMonthLabel(int month) {
    return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][month - 1];
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final l10n = AppLocalizations.of(context);

    if (date == today) {
      return '${l10n.today} ${_formatTime(dateTime)}';
    } else if (date == today.subtract(const Duration(days: 1))) {
      return '${l10n.yesterday} ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month} ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class ChartData {
  final String label;
  final int value;

  ChartData(this.label, this.value);
}
