import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility utilities for the Pomodoro App
///
/// Provides helpers for making the app more accessible
/// to users with disabilities.
class AccessibilityService {
  /// Announce a message to screen readers
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Announce timer status changes
  static void announceTimerStatus(BuildContext context, String status, String time) {
    announce(context, '$status. Time remaining: $time');
  }

  /// Announce session completion
  static void announceSessionComplete(BuildContext context, String sessionType) {
    announce(context, '$sessionType session complete. Great job!');
  }

  /// Announce task changes
  static void announceTaskUpdate(BuildContext context, String taskName, String action) {
    announce(context, 'Task "$taskName" $action');
  }
}

/// Semantic wrapper for timer display
class SemanticTimer extends StatelessWidget {
  final Widget child;
  final String timeRemaining;
  final String timerState;
  final String sessionType;

  const SemanticTimer({
    super.key,
    required this.child,
    required this.timeRemaining,
    required this.timerState,
    required this.sessionType,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$sessionType timer. $timeRemaining remaining. Status: $timerState',
      liveRegion: true,
      child: ExcludeSemantics(
        child: child,
      ),
    );
  }
}

/// Button with enhanced accessibility
class AccessibleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final String semanticLabel;
  final String? semanticHint;
  final bool isSelected;

  const AccessibleButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.semanticLabel,
    this.semanticHint,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      enabled: onPressed != null,
      selected: isSelected,
      child: ElevatedButton(
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}

/// Progress indicator with accessibility
class AccessibleProgress extends StatelessWidget {
  final double value;
  final String label;
  final Color? color;

  const AccessibleProgress({
    super.key,
    required this.value,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (value * 100).round();

    return Semantics(
      label: '$label: $percentage percent complete',
      value: '$percentage%',
      child: LinearProgressIndicator(
        value: value,
        valueColor: color != null ? AlwaysStoppedAnimation(color) : null,
      ),
    );
  }
}

/// Extension for adding accessibility to any widget
extension AccessibilityExtension on Widget {
  /// Wrap widget with semantic label
  Widget withSemanticLabel(String label, {String? hint}) {
    return Semantics(
      label: label,
      hint: hint,
      child: this,
    );
  }

  /// Mark as a button for accessibility
  Widget asButton({
    required String label,
    String? hint,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: enabled,
      child: this,
    );
  }

  /// Mark as a heading for accessibility
  Widget asHeading({required String label, bool isHeader = true}) {
    return Semantics(
      label: label,
      header: isHeader,
      child: this,
    );
  }
}

/// High contrast theme colors for accessibility
class AccessibleColors {
  /// High contrast color pairs (background, foreground)
  static const Map<String, (Color, Color)> highContrastPairs = {
    'work': (Color(0xFFB71C1C), Colors.white),      // Dark red bg, white text
    'shortBreak': (Color(0xFF1B5E20), Colors.white), // Dark green bg, white text
    'longBreak': (Color(0xFF0D47A1), Colors.white),  // Dark blue bg, white text
    'neutral': (Color(0xFF212121), Colors.white),    // Dark grey bg, white text
  };

  /// Get accessible color pair for a session type
  static (Color, Color) getColorPair(String sessionType) {
    return highContrastPairs[sessionType] ?? highContrastPairs['neutral']!;
  }

  /// Check if colors have sufficient contrast (WCAG AA standard)
  static bool hasSufficientContrast(Color foreground, Color background) {
    final ratio = _calculateContrastRatio(foreground, background);
    return ratio >= 4.5; // WCAG AA standard for normal text
  }

  static double _calculateContrastRatio(Color foreground, Color background) {
    final l1 = _relativeLuminance(foreground);
    final l2 = _relativeLuminance(background);
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  static double _relativeLuminance(Color color) {
    double r = color.red / 255;
    double g = color.green / 255;
    double b = color.blue / 255;

    r = r <= 0.03928 ? r / 12.92 : _gammaCorrect(r);
    g = g <= 0.03928 ? g / 12.92 : _gammaCorrect(g);
    b = b <= 0.03928 ? b / 12.92 : _gammaCorrect(b);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _gammaCorrect(double value) {
    return ((value + 0.055) / 1.055);
  }
}
