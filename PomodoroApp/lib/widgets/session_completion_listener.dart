import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../widgets/session_completion_dialog.dart';
import '../services/storage_service.dart';

/// A widget that listens for session completions and shows the completion dialog.
/// This should be placed at the root of the app's widget tree (typically in HomeScreen).
class SessionCompletionListener extends StatefulWidget {
  final Widget child;

  const SessionCompletionListener({
    super.key,
    required this.child,
  });

  @override
  State<SessionCompletionListener> createState() => _SessionCompletionListenerState();
}

class _SessionCompletionListenerState extends State<SessionCompletionListener> {
  int? _lastCompletionCounter;

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timer, _) {
        // Check if a new session was completed
        if (timer.sessionCompletionCounter != _lastCompletionCounter &&
            timer.lastCompletedSession != null) {
          // Update counter
          _lastCompletionCounter = timer.sessionCompletionCounter;

          // Show dialog after the current frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _showCompletionDialog(context, timer);
            }
          });
        }

        return widget.child;
      },
    );
  }

  void _showCompletionDialog(BuildContext context, TimerProvider timer) {
    final session = timer.lastCompletedSession;
    if (session == null) return;

    // Calculate overtime if applicable
    final overtimeMinutes = timer.isInFlowMode
        ? (timer.overtimeSeconds / 60).ceil()
        : null;

    SessionCompletionDialog.show(
      context,
      session: session,
      overtimeMinutes: overtimeMinutes,
      onContinue: () {
        // User wants to start another session
        // Get the default work duration from settings
        final settings = StorageService.getSettings();
        timer.start(durationMinutes: settings.workDuration);
      },
      onTakeBreak: () {
        // User wants to take a break
        // Skip to break session
        timer.skip();
      },
    );
  }
}
