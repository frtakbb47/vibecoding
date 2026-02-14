import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';
import '../utils/help_texts.dart';
import 'help_tooltip.dart';
import '../l10n/app_localizations.dart';

class ControlButtons extends StatelessWidget {
  const ControlButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TimerProvider, SettingsProvider>(
      builder: (context, timer, settings, _) {
        return Column(
          children: [
            // Main control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (timer.state == TimerState.idle) ...[
                  _buildLargeButton(
                    context,
                    label: AppLocalizations.of(context).start,
                    icon: Icons.play_arrow_rounded,
                    onPressed: () {
                      int duration;
                      switch (timer.currentType) {
                        case AppConstants.stateWork:
                          duration = settings.workDuration;
                          break;
                        case AppConstants.stateShortBreak:
                          duration = settings.shortBreakDuration;
                          break;
                        case AppConstants.stateLongBreak:
                          duration = settings.longBreakDuration;
                          break;
                        default:
                          duration = settings.workDuration;
                      }
                      timer.start(durationMinutes: duration);
                    },
                    color: AppConstants.primaryRed,
                  ),
                ] else if (timer.state == TimerState.running) ...[
                  _buildLargeButton(
                    context,
                    label: AppLocalizations.of(context).pause,
                    icon: Icons.pause_rounded,
                    onPressed: () => timer.pause(),
                    color: Colors.orange,
                  ),
                ] else if (timer.state == TimerState.paused) ...[
                  _buildLargeButton(
                    context,
                    label: AppLocalizations.of(context).resume,
                    icon: Icons.play_arrow_rounded,
                    onPressed: () => timer.resume(),
                    color: AppConstants.primaryGreen,
                  ),
                  const SizedBox(width: 12),
                  _buildSmallButton(
                    context,
                    icon: Icons.refresh_rounded,
                    onPressed: () => timer.reset(),
                    tooltip: AppLocalizations.of(context).reset,
                  ),
                ] else if (timer.state == TimerState.flow) ...[
                  // Flow Mode - show finish button with overtime indicator
                  Column(
                    children: [
                      // Overtime indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.purple.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome, color: Colors.purple, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Flow Mode +${timer.overtimeDisplay}',
                              style: const TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Finish button
                      _buildLargeButton(
                        context,
                        label: 'Finish Session',
                        icon: Icons.check_circle_rounded,
                        onPressed: () => timer.finishFlowSession(),
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ],
              ],
            ),

            // Skip button (only when timer is running or paused, not in flow mode)
            if (timer.state == TimerState.running || timer.state == TimerState.paused) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => timer.skip(),
                icon: const Icon(Icons.skip_next_rounded),
                label: Text(AppLocalizations.of(context).skip),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],

            // Timer type selector (only when idle)
            if (timer.state == TimerState.idle) ...[
              const SizedBox(height: 24),
              // Help row for timer modes
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Select Timer Mode',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const InfoButton(
                      title: 'Timer Modes',
                      message: 'Choose what type of session you want to start:\n\n'
                          '• Focus: Concentrated work time\n'
                          '• Break: Short rest between sessions\n'
                          '• Long: Extended break after multiple focus sessions',
                      tips: [
                        'Start with Focus mode for work',
                        'The app auto-switches modes after each session',
                        'You can manually switch anytime when paused',
                      ],
                      size: 16,
                    ),
                  ],
                ),
              ),
              _buildTimerTypeSelector(context, timer, settings),
            ],
          ],
        );
      },
    );
  }

  Widget _buildLargeButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 28),
      label: Text(
        label,
        style: const TextStyle(fontSize: 18),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 4,
      ),
    );
  }

  Widget _buildSmallButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[700],
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
        elevation: 4,
      ),
      child: Icon(icon, size: 24),
    );
  }

  Widget _buildTimerTypeSelector(
    BuildContext context,
    TimerProvider timer,
    SettingsProvider settings,
  ) {
    return Container(
      constraints: const BoxConstraints(minWidth: 400),
      child: SegmentedButton<String>(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          minimumSize: WidgetStateProperty.all(const Size(120, 50)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        showSelectedIcon: true,
        segments: [
          ButtonSegment(
            value: AppConstants.stateWork,
            label: Text(AppLocalizations.of(context).focus, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            icon: const Icon(Icons.work_outline, size: 22),
          ),
          ButtonSegment(
            value: AppConstants.stateShortBreak,
            label: Text(AppLocalizations.of(context).breakLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            icon: const Icon(Icons.coffee_outlined, size: 22),
          ),
          ButtonSegment(
            value: AppConstants.stateLongBreak,
            label: Text(AppLocalizations.of(context).long, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            icon: const Icon(Icons.beach_access_outlined, size: 22),
          ),
        ],
        selected: {timer.currentType},
        onSelectionChanged: (Set<String> newSelection) {
          final type = newSelection.first;
          int duration;
          switch (type) {
            case AppConstants.stateWork:
              duration = settings.workDuration;
              break;
            case AppConstants.stateShortBreak:
              duration = settings.shortBreakDuration;
              break;
            case AppConstants.stateLongBreak:
              duration = settings.longBreakDuration;
              break;
            default:
              duration = settings.workDuration;
          }
          timer.setTimerType(type, duration);
        },
      ),
    );
  }
}
