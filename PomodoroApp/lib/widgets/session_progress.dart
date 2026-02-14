import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../providers/settings_provider.dart';
import '../services/storage_service.dart';
import '../utils/help_texts.dart';
import 'help_tooltip.dart';
import '../l10n/app_localizations.dart';

class SessionProgress extends StatelessWidget {
  const SessionProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TimerProvider, SettingsProvider>(
      builder: (context, timer, settings, _) {
        final todayCount = StorageService.getTodayWorkSessionCount();
        final dailyGoal = settings.dailyGoal;
        final progress = (todayCount / dailyGoal).clamp(0.0, 1.0);

        return Card(
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
                        Text(
                          AppLocalizations.of(context).todayProgress,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const InfoButton(
                          title: 'Daily Progress',
                          message: 'Track your focus sessions for today. Each completed focus session counts toward your daily goal.',
                          tips: [
                            'Sessions reset at midnight',
                            'Adjust your goal in Settings',
                            'Completed sessions are saved automatically',
                          ],
                          size: 16,
                        ),
                      ],
                    ),
                    Text(
                      '$todayCount / $dailyGoal',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatChip(
                      context,
                      icon: Icons.check_circle_outline,
                      label: AppLocalizations.of(context).completed,
                      value: timer.completedSessions.toString(),
                      color: Colors.green,
                    ),
                    _buildStatChip(
                      context,
                      icon: Icons.local_fire_department,
                      label: AppLocalizations.of(context).streak,
                      value: '${StorageService.getCurrentStreak()}d',
                      color: Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
