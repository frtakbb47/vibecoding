import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/session.dart';
import '../models/task.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/audio_service.dart';
import '../utils/constants.dart';

/// Timer states including Flow Mode (overtime).
///
/// - [idle]: Timer not started
/// - [running]: Timer counting down
/// - [paused]: Timer paused (preserves end time)
/// - [flow]: Flow Mode - Timer hit 00:00, now counting UP (overtime)
enum TimerState {
  idle,      // Timer not started
  running,   // Timer counting down
  paused,    // Timer paused (preserves end time)
  flow,      // FLOW MODE: Timer hit 00:00, now counting UP (overtime)
}

/// Keys for persisting timer state to Hive.
class _TimerPersistenceKeys {
  static const String sessionEndTime = 'timer_session_end_time';
  static const String sessionStartTime = 'timer_session_start_time';
  static const String sessionType = 'timer_session_type';
  static const String totalDuration = 'timer_total_duration';
  static const String isPaused = 'timer_is_paused';
  static const String pausedRemaining = 'timer_paused_remaining';
  static const String isFlowMode = 'timer_is_flow_mode';
  static const String flowStartTime = 'timer_flow_start_time';
  static const String selectedTaskId = 'timer_selected_task_id';
}

/// Main timer provider managing Pomodoro session state.
///
/// Uses [ChangeNotifier] for reactive UI updates with Provider.
class TimerProvider extends ChangeNotifier {
  Timer? _timer;

  // ═══════════════════════════════════════════════════════════════════════════
  // FEATURE 1: TIMESTAMP-BASED TIMER (survives background/restart)
  // ═══════════════════════════════════════════════════════════════════════════
  DateTime? _sessionEndTime;      // When the timer SHOULD complete
  DateTime? _sessionStartTime;    // When the session started
  int _totalSeconds = 0;          // Original duration in seconds
  int _remainingSeconds = 0;      // Calculated: endTime - now (for display)
  int _pausedRemainingSeconds = 0; // Seconds left when paused

  // ═══════════════════════════════════════════════════════════════════════════
  // FEATURE 2: FLOW MODE (Overtime)
  // ═══════════════════════════════════════════════════════════════════════════
  DateTime? _flowStartTime;       // When flow mode started (timer hit 00:00)
  int _overtimeSeconds = 0;       // How long we've been in flow mode
  bool _flowModeEnabled = true;   // User preference: enable flow mode?

  // ═══════════════════════════════════════════════════════════════════════════
  // FEATURE 3: ACTIVE TASK LINKING
  // ═══════════════════════════════════════════════════════════════════════════
  String? _selectedTaskId;        // Currently linked task ID

  // ═══════════════════════════════════════════════════════════════════════════
  // FEATURE 4: ZEN MODE (Distraction-free UI)
  // ═══════════════════════════════════════════════════════════════════════════
  bool _isZenMode = false;        // Hide non-essential UI when running
  bool _zenModeAutoEnabled = true; // Auto-enable zen mode when timer starts

  TimerState _state = TimerState.idle;
  String _currentType = AppConstants.stateWork;
  int _completedSessions = 0;

  // ═══════════════════════════════════════════════════════════════════════════
  // FEATURE: SESSION COMPLETION TRACKING (for UI dialogs)
  // ═══════════════════════════════════════════════════════════════════════════
  PomodoroSession? _lastCompletedSession; // Last completed session
  int _sessionCompletionCounter = 0;      // Increments on each completion

  TimerProvider() {
    _init();
  }

  /// Initialize and restore any persisted timer state
  void _init() {
    _remainingSeconds = AppConstants.defaultWorkDuration * 60;
    _totalSeconds = _remainingSeconds;

    // Attempt to restore timer state from Hive (survives app restart)
    _restoreTimerState();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GETTERS
  // ═══════════════════════════════════════════════════════════════════════════

  TimerState get state => _state;
  String get currentType => _currentType;
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  int get completedSessions => _completedSessions;
  int get overtimeSeconds => _overtimeSeconds;
  bool get isInFlowMode => _state == TimerState.flow;
  bool get flowModeEnabled => _flowModeEnabled;
  String? get selectedTaskId => _selectedTaskId;

  /// Get the currently selected task (if any)
  Task? get selectedTask {
    if (_selectedTaskId == null) return null;
    return StorageService.getTask(_selectedTaskId!);
  }

  /// Whether Zen Mode is currently active (hide non-essential UI)
  bool get isZenMode => _isZenMode;

  /// Whether Zen Mode auto-enables when timer starts
  bool get zenModeAutoEnabled => _zenModeAutoEnabled;

  /// Last completed session (for showing completion dialog)
  PomodoroSession? get lastCompletedSession => _lastCompletedSession;

  /// Session completion counter (increments each time, helps UI detect changes)
  int get sessionCompletionCounter => _sessionCompletionCounter;

  /// Whether timer is in an active state (running or flow)
  bool get isActive => _state == TimerState.running || _state == TimerState.flow;

  /// Formatted overtime display string (e.g., "05:30")
  String get overtimeDisplay {
    final minutes = _overtimeSeconds ~/ 60;
    final seconds = _overtimeSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Progress for circular timer (0.0 to 1.0+)
  /// In flow mode, progress exceeds 1.0 to show overtime visually
  double get progress {
    if (_totalSeconds <= 0) return 0.0;
    if (_state == TimerState.flow) {
      // In flow mode: 1.0 + overtime ratio (can exceed 1.0)
      return 1.0 + (_overtimeSeconds / _totalSeconds);
    }
    return (_totalSeconds - _remainingSeconds) / _totalSeconds;
  }

  /// Display string for the timer
  /// Normal: "25:00" countdown
  /// Flow mode: "+05:30" counting up with plus sign
  String get timeDisplay {
    if (_state == TimerState.flow) {
      final minutes = _overtimeSeconds ~/ 60;
      final seconds = _overtimeSeconds % 60;
      return '+${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get isWork => _currentType == AppConstants.stateWork;
  bool get isShortBreak => _currentType == AppConstants.stateShortBreak;
  bool get isLongBreak => _currentType == AppConstants.stateLongBreak;

  String get currentTypeLabel {
    switch (_currentType) {
      case AppConstants.stateWork:
        return AppStrings.workSession;
      case AppConstants.stateShortBreak:
        return AppStrings.shortBreak;
      case AppConstants.stateLongBreak:
        return AppStrings.longBreak;
      default:
        return '';
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FEATURE 1: TIMESTAMP-BASED TIMER CONTROL
  // ═══════════════════════════════════════════════════════════════════════════

  /// Start a new timer session using timestamp logic
  void start({required int durationMinutes, String? type}) {
    if (type != null) {
      _currentType = type;
    }

    final now = DateTime.now();
    _totalSeconds = durationMinutes * 60;
    _sessionStartTime = now;
    _sessionEndTime = now.add(Duration(seconds: _totalSeconds));
    _remainingSeconds = _totalSeconds;
    _overtimeSeconds = 0;
    _flowStartTime = null;
    _state = TimerState.running;

    // FEATURE 4: Auto-enable Zen Mode when timer starts
    if (_zenModeAutoEnabled) {
      _isZenMode = true;
    }

    // CHANGE 2: Enable wakelock to prevent screen sleep
    WakelockPlus.enable();

    // Persist to Hive (survives app restart)
    _persistTimerState();

    // Start the UI ticker
    _startTicker();

    // Start ticking sound if enabled
    final settings = StorageService.getSettings();
    if (settings.tickingSoundEnabled && settings.soundEnabled) {
      AudioService.startTickingSound();
    }

    notifyListeners();
  }

  /// Pause the timer - saves remaining time for accurate resume
  void pause() {
    _timer?.cancel();
    _pausedRemainingSeconds = _remainingSeconds;
    _state = TimerState.paused;

    // CHANGE 2: Disable wakelock when paused
    WakelockPlus.disable();

    _persistTimerState();
    AudioService.stopTickingSound();
    notifyListeners();
  }

  /// Resume from pause - recalculates end time based on remaining seconds
  void resume() {
    if (_state == TimerState.paused) {
      final now = DateTime.now();
      // Recalculate end time from the paused remaining seconds
      _sessionEndTime = now.add(Duration(seconds: _pausedRemainingSeconds));
      _state = TimerState.running;

      // CHANGE 2: Re-enable wakelock on resume
      WakelockPlus.enable();

      _persistTimerState();
      _startTicker();

      final settings = StorageService.getSettings();
      if (settings.tickingSoundEnabled && settings.soundEnabled) {
        AudioService.startTickingSound();
      }

      notifyListeners();
    }
  }

  /// Reset timer to initial state
  void reset() {
    _timer?.cancel();
    _state = TimerState.idle;
    _remainingSeconds = _totalSeconds;
    _overtimeSeconds = 0;
    _flowStartTime = null;
    _sessionEndTime = null;

    // CHANGE 2: Disable wakelock on reset
    WakelockPlus.disable();

    _clearPersistedTimerState();
    AudioService.stopTickingSound();
    notifyListeners();
  }

  /// Skip current session without completing
  void skip() {
    _timer?.cancel();
    _completeSession(completed: false, includeOvertime: false);
    _clearPersistedTimerState();
    _moveToNextSession();
  }

  /// Start the periodic ticker for UI updates
  void _startTicker() {
    _timer?.cancel();
    // Tick every 100ms for smoother UI, but only notify every second
    _timer = Timer.periodic(const Duration(milliseconds: 100), _tick);
  }

  /// Core tick logic using timestamp calculation
  void _tick(Timer timer) {
    final now = DateTime.now();

    if (_state == TimerState.flow) {
      // FLOW MODE: Count UP from when we hit 00:00
      if (_flowStartTime != null) {
        _overtimeSeconds = now.difference(_flowStartTime!).inSeconds;
        notifyListeners();
      }
      return;
    }

    if (_state == TimerState.running && _sessionEndTime != null) {
      final diff = _sessionEndTime!.difference(now);
      final newRemaining = diff.inSeconds;

      // Only notify if the second changed (avoids excessive rebuilds)
      if (newRemaining != _remainingSeconds) {
        _remainingSeconds = newRemaining.clamp(0, _totalSeconds * 2);

        if (_remainingSeconds <= 0) {
          // Timer completed! Check for flow mode
          _onTimerReachedZero();
        } else {
          notifyListeners();
        }
      }
    }
  }

  /// Called when countdown reaches 00:00
  Future<void> _onTimerReachedZero() async {
    _remainingSeconds = 0;
    AudioService.stopTickingSound();

    final settings = StorageService.getSettings();

    // Play completion sound
    if (settings.soundEnabled) {
      if (_currentType == AppConstants.stateWork) {
        await AudioService.playCompletionSound();
      } else {
        await AudioService.playBreakSound();
      }
    }

    // Show notification
    if (settings.notificationsEnabled) {
      if (_currentType == AppConstants.stateWork) {
        await NotificationService.showWorkCompleteNotification();
      } else {
        await NotificationService.showBreakCompleteNotification(
          _currentType == AppConstants.stateLongBreak
        );
      }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // FEATURE 2: Enter Flow Mode instead of auto-completing
    // ═══════════════════════════════════════════════════════════════════════
    if (_flowModeEnabled && _currentType == AppConstants.stateWork) {
      // Enter flow mode - let user keep working
      _flowStartTime = DateTime.now();
      _overtimeSeconds = 0;
      _state = TimerState.flow;
      _persistTimerState();
      notifyListeners();
    } else {
      // Standard behavior: complete and move on
      _finishSession();
    }
  }

  /// Finish the current session (called from UI in flow mode, or automatically)
  void finishFlowSession() {
    if (_state == TimerState.flow) {
      _finishSession();
    }
  }

  /// Complete session and handle next steps
  Future<void> _finishSession() async {
    _timer?.cancel();

    // Save completed session (including overtime if in flow mode)
    _completeSession(completed: true, includeOvertime: _state == TimerState.flow);
    _clearPersistedTimerState();

    // Move to next session
    _moveToNextSession();

    // Auto-start if enabled (but not after flow mode - let user take a break)
    final settings = StorageService.getSettings();
    if (_state != TimerState.flow) {
      if ((_currentType != AppConstants.stateWork && settings.autoStartBreaks) ||
          (_currentType == AppConstants.stateWork && settings.autoStartPomodoros)) {
        final duration = _getDurationForType(_currentType);
        start(durationMinutes: duration);
        return;
      }
    }

    _state = TimerState.idle;
    _overtimeSeconds = 0;
    _flowStartTime = null;
    notifyListeners();
  }

  /// Save completed session to Hive
  void _completeSession({required bool completed, required bool includeOvertime}) {
    if (_sessionStartTime == null) return;

    // Calculate actual duration including overtime
    int actualDurationMinutes = _totalSeconds ~/ 60;
    if (includeOvertime && _overtimeSeconds > 0) {
      actualDurationMinutes += (_overtimeSeconds / 60).ceil();
    }

    final session = PomodoroSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: _sessionStartTime!,
      endTime: DateTime.now(),
      type: _currentType,
      durationMinutes: actualDurationMinutes,
      completed: completed,
      taskId: _selectedTaskId,
      taskTitle: selectedTask?.title,
    );

    StorageService.addSession(session);

    // Track last completed session for UI (only if successfully completed)
    if (completed && _currentType == AppConstants.stateWork) {
      _lastCompletedSession = session;
      _sessionCompletionCounter++;
      _completedSessions++;

      // FEATURE: FOCUS ECONOMY - Award coins for completed work sessions
      _awardCoinsForSession(actualDurationMinutes);

      // CHANGE 3: Increment linked task's completed pomodoros
      _incrementLinkedTaskPomodoro();
    }
  }

  /// Increment the linked task's completed pomodoro count
  void _incrementLinkedTaskPomodoro() {
    if (_selectedTaskId == null) return;

    final task = StorageService.getTask(_selectedTaskId!);
    if (task == null) return;

    // Use the Task model's built-in increment method
    // This handles incrementing and auto-completion
    task.incrementPomodoro();

    debugPrint('Task "${task.title}" updated: ${task.completedPomodoros}/${task.estimatedPomodoros} pomodoros');
  }

  /// Award coins for completing a work session (Focus Economy)
  void _awardCoinsForSession(int durationMinutes) {
    final settings = StorageService.getSettings();
    final coinsEarned = durationMinutes; // 1 coin per minute focused
    settings.totalCoins += coinsEarned;
    StorageService.saveSettings(settings);
    debugPrint('Focus Economy: Earned $coinsEarned coins! Total: ${settings.totalCoins}');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PERSISTENCE (Survives app restart/background)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Save current timer state to Hive
  void _persistTimerState() {
    final box = StorageService.timerStateBox;
    box.put(_TimerPersistenceKeys.sessionEndTime, _sessionEndTime?.millisecondsSinceEpoch);
    box.put(_TimerPersistenceKeys.sessionStartTime, _sessionStartTime?.millisecondsSinceEpoch);
    box.put(_TimerPersistenceKeys.sessionType, _currentType);
    box.put(_TimerPersistenceKeys.totalDuration, _totalSeconds);
    box.put(_TimerPersistenceKeys.isPaused, _state == TimerState.paused);
    box.put(_TimerPersistenceKeys.pausedRemaining, _pausedRemainingSeconds);
    box.put(_TimerPersistenceKeys.isFlowMode, _state == TimerState.flow);
    box.put(_TimerPersistenceKeys.flowStartTime, _flowStartTime?.millisecondsSinceEpoch);
    box.put(_TimerPersistenceKeys.selectedTaskId, _selectedTaskId);
  }

  /// Restore timer state from Hive (called on app start)
  void _restoreTimerState() {
    try {
      final box = StorageService.timerStateBox;

      final endTimeMs = box.get(_TimerPersistenceKeys.sessionEndTime) as int?;
      final startTimeMs = box.get(_TimerPersistenceKeys.sessionStartTime) as int?;
      final sessionType = box.get(_TimerPersistenceKeys.sessionType) as String?;
      final totalDuration = box.get(_TimerPersistenceKeys.totalDuration) as int?;
      final isPaused = box.get(_TimerPersistenceKeys.isPaused) as bool? ?? false;
      final pausedRemaining = box.get(_TimerPersistenceKeys.pausedRemaining) as int? ?? 0;
      final isFlowMode = box.get(_TimerPersistenceKeys.isFlowMode) as bool? ?? false;
      final flowStartMs = box.get(_TimerPersistenceKeys.flowStartTime) as int?;
      final savedTaskId = box.get(_TimerPersistenceKeys.selectedTaskId) as String?;

      // Restore selected task ID
      _selectedTaskId = savedTaskId;

      if (endTimeMs == null || startTimeMs == null || sessionType == null || totalDuration == null) {
        return; // No persisted state
      }

      _sessionEndTime = DateTime.fromMillisecondsSinceEpoch(endTimeMs);
      _sessionStartTime = DateTime.fromMillisecondsSinceEpoch(startTimeMs);
      _currentType = sessionType;
      _totalSeconds = totalDuration;

      if (isFlowMode && flowStartMs != null) {
        // Restore flow mode
        _flowStartTime = DateTime.fromMillisecondsSinceEpoch(flowStartMs);
        _overtimeSeconds = DateTime.now().difference(_flowStartTime!).inSeconds;
        _remainingSeconds = 0;
        _state = TimerState.flow;
        _startTicker();
      } else if (isPaused) {
        // Restore paused state
        _pausedRemainingSeconds = pausedRemaining;
        _remainingSeconds = pausedRemaining;
        _state = TimerState.paused;
      } else {
        // Check if timer is still running or already completed
        final now = DateTime.now();
        final remaining = _sessionEndTime!.difference(now).inSeconds;

        if (remaining > 0) {
          // Timer still has time left - resume it
          _remainingSeconds = remaining;
          _state = TimerState.running;
          _startTicker();

          // CHANGE 2: Re-enable wakelock on restore
          WakelockPlus.enable();

          final settings = StorageService.getSettings();
          if (settings.tickingSoundEnabled && settings.soundEnabled) {
            AudioService.startTickingSound();
          }
        } else {
          // Timer completed while app was closed
          if (_flowModeEnabled && _currentType == AppConstants.stateWork) {
            // Enter flow mode from the end time
            _flowStartTime = _sessionEndTime;
            _overtimeSeconds = now.difference(_sessionEndTime!).inSeconds;
            _remainingSeconds = 0;
            _state = TimerState.flow;
            _startTicker();
          } else {
            // Session completed - save it
            _completeSession(completed: true, includeOvertime: false);
            _clearPersistedTimerState();
            _moveToNextSession();
            _state = TimerState.idle;
          }
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error restoring timer state: $e');
      _clearPersistedTimerState();
    }
  }

  /// Clear persisted timer state
  void _clearPersistedTimerState() {
    final box = StorageService.timerStateBox;
    box.delete(_TimerPersistenceKeys.sessionEndTime);
    box.delete(_TimerPersistenceKeys.sessionStartTime);
    box.delete(_TimerPersistenceKeys.sessionType);
    box.delete(_TimerPersistenceKeys.totalDuration);
    box.delete(_TimerPersistenceKeys.isPaused);
    box.delete(_TimerPersistenceKeys.pausedRemaining);
    box.delete(_TimerPersistenceKeys.isFlowMode);
    box.delete(_TimerPersistenceKeys.flowStartTime);
    // Note: We don't clear selectedTaskId here - task selection persists across sessions
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SESSION MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════════════

  void _moveToNextSession() {
    if (_currentType == AppConstants.stateWork) {
      // Determine if it's time for a long break
      if (_completedSessions % StorageService.getSettings().sessionsBeforeLongBreak == 0 &&
          _completedSessions > 0) {
        _currentType = AppConstants.stateLongBreak;
      } else {
        _currentType = AppConstants.stateShortBreak;
      }
    } else {
      _currentType = AppConstants.stateWork;
    }

    final duration = _getDurationForType(_currentType);
    _totalSeconds = duration * 60;
    _remainingSeconds = _totalSeconds;
    _overtimeSeconds = 0;
    _flowStartTime = null;
    notifyListeners();
  }

  int _getDurationForType(String type) {
    final settings = StorageService.getSettings();
    switch (type) {
      case AppConstants.stateWork:
        return settings.workDuration;
      case AppConstants.stateShortBreak:
        return settings.shortBreakDuration;
      case AppConstants.stateLongBreak:
        return settings.longBreakDuration;
      default:
        return settings.workDuration;
    }
  }

  void setTimerType(String type, int durationMinutes) {
    _currentType = type;
    _totalSeconds = durationMinutes * 60;
    _remainingSeconds = _totalSeconds;
    _state = TimerState.idle;
    _overtimeSeconds = 0;
    notifyListeners();
  }

  /// Set timer type without changing duration (uses saved settings)
  void setType(String type) {
    if (_state != TimerState.idle) return;

    _currentType = type;
    final duration = _getDurationForType(type);
    _totalSeconds = duration * 60;
    _remainingSeconds = _totalSeconds;
    notifyListeners();
  }

  /// Add time to the current session (extends end time)
  void addTime(int minutes) {
    if (_sessionEndTime != null && _state == TimerState.running) {
      _sessionEndTime = _sessionEndTime!.add(Duration(minutes: minutes));
      _totalSeconds += minutes * 60;
      _persistTimerState();
    } else {
      _remainingSeconds += minutes * 60;
      _totalSeconds += minutes * 60;
    }
    notifyListeners();
  }

  /// Toggle flow mode preference
  void setFlowModeEnabled(bool enabled) {
    _flowModeEnabled = enabled;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CHANGE 3: TASK SELECTION METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Select a task to link with the timer
  void selectTask(String taskId) {
    _selectedTaskId = taskId;
    // Persist immediately so it survives restart
    final box = StorageService.timerStateBox;
    box.put(_TimerPersistenceKeys.selectedTaskId, taskId);
    notifyListeners();
  }

  /// Clear the selected task
  void clearSelectedTask() {
    _selectedTaskId = null;
    final box = StorageService.timerStateBox;
    box.delete(_TimerPersistenceKeys.selectedTaskId);
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FEATURE 4: ZEN MODE CONTROL
  // ═══════════════════════════════════════════════════════════════════════════

  /// Manually toggle Zen Mode on/off
  void toggleZenMode() {
    _isZenMode = !_isZenMode;
    notifyListeners();
  }

  /// Set Zen Mode state explicitly
  void setZenMode(bool enabled) {
    _isZenMode = enabled;
    notifyListeners();
  }

  /// Temporarily show UI (user tapped to reveal)
  void showUITemporarily() {
    if (_isZenMode) {
      _isZenMode = false;
      notifyListeners();
    }
  }

  /// Set whether Zen Mode should auto-enable when timer starts
  void setZenModeAutoEnabled(bool enabled) {
    _zenModeAutoEnabled = enabled;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    AudioService.stopTickingSound();
    // CHANGE 2: Ensure wakelock is disabled on dispose
    WakelockPlus.disable();
    super.dispose();
  }
}
