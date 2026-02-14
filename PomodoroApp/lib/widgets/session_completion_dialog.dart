import 'package:flutter/material.dart';
import '../services/share_service.dart';
import '../services/storage_service.dart';
import '../models/session.dart';

/// Dialog shown when a Pomodoro session completes successfully.
/// Provides session stats, celebration, and sharing capabilities.
class SessionCompletionDialog extends StatelessWidget {
  /// The completed session
  final PomodoroSession session;

  /// Overtime minutes if user was in flow mode
  final int? overtimeMinutes;

  /// Callback when user wants to continue to next session
  final VoidCallback? onContinue;

  /// Callback when user wants to take a break
  final VoidCallback? onTakeBreak;

  const SessionCompletionDialog({
    super.key,
    required this.session,
    this.overtimeMinutes,
    this.onContinue,
    this.onTakeBreak,
  });

  /// Show the dialog
  static Future<void> show(
    BuildContext context, {
    required PomodoroSession session,
    int? overtimeMinutes,
    VoidCallback? onContinue,
    VoidCallback? onTakeBreak,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SessionCompletionDialog(
        session: session,
        overtimeMinutes: overtimeMinutes,
        onContinue: onContinue,
        onTakeBreak: onTakeBreak,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentStreak = StorageService.getCurrentStreak();
    final todaySessions = StorageService.getTodayWorkSessionCount();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                  ]
                : [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Celebration emoji
            const Text(
              '🎉',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Session Complete!',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle with duration
            Text(
              'You focused for ${session.durationMinutes} minutes',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),

            // Task name if applicable
            if (session.taskTitle != null) ...[
              const SizedBox(height: 4),
              Text(
                session.taskTitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Overtime badge if applicable
            if (overtimeMinutes != null && overtimeMinutes! > 0) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD93D), Color(0xFFFF6B6B)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      'FLOW: +$overtimeMinutes min',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  context,
                  emoji: '🔥',
                  value: '$currentStreak',
                  label: 'Day Streak',
                ),
                _buildStatCard(
                  context,
                  emoji: '✅',
                  value: '$todaySessions',
                  label: 'Today',
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Share button
            OutlinedButton.icon(
              onPressed: () => _handleShare(context),
              icon: const Icon(Icons.ios_share_rounded),
              label: const Text('Share Stats'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                if (onTakeBreak != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onTakeBreak?.call();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Take Break'),
                    ),
                  ),
                if (onTakeBreak != null && onContinue != null)
                  const SizedBox(width: 12),
                if (onContinue != null)
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onContinue?.call();
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Continue'),
                    ),
                  ),
                if (onContinue == null && onTakeBreak == null)
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required String emoji,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleShare(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Get task name for share card
      final taskName = session.taskTitle ?? 'Deep Focus';

      // Share the session stats
      final success = await ShareService.shareSessionStats(
        durationMinutes: session.durationMinutes,
        taskName: taskName,
        overtimeMinutes: overtimeMinutes,
      );

      // Close loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (!success && context.mounted) {
        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to share. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Close loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();

        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
