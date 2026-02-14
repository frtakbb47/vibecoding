import 'package:flutter/material.dart';

enum FocusCategory {
  study,
  work,
  personal,
  creative,
  health,
  reading,
}

extension FocusCategoryExtension on FocusCategory {
  String get name {
    switch (this) {
      case FocusCategory.study:
        return 'Study';
      case FocusCategory.work:
        return 'Work';
      case FocusCategory.personal:
        return 'Personal';
      case FocusCategory.creative:
        return 'Creative';
      case FocusCategory.health:
        return 'Health';
      case FocusCategory.reading:
        return 'Reading';
    }
  }

  String get emoji {
    switch (this) {
      case FocusCategory.study:
        return '📚';
      case FocusCategory.work:
        return '💼';
      case FocusCategory.personal:
        return '🏠';
      case FocusCategory.creative:
        return '🎨';
      case FocusCategory.health:
        return '💪';
      case FocusCategory.reading:
        return '📖';
    }
  }

  Color get color {
    switch (this) {
      case FocusCategory.study:
        return Colors.blue;
      case FocusCategory.work:
        return Colors.orange;
      case FocusCategory.personal:
        return Colors.green;
      case FocusCategory.creative:
        return Colors.purple;
      case FocusCategory.health:
        return Colors.red;
      case FocusCategory.reading:
        return Colors.teal;
    }
  }

  IconData get icon {
    switch (this) {
      case FocusCategory.study:
        return Icons.school;
      case FocusCategory.work:
        return Icons.work;
      case FocusCategory.personal:
        return Icons.home;
      case FocusCategory.creative:
        return Icons.brush;
      case FocusCategory.health:
        return Icons.fitness_center;
      case FocusCategory.reading:
        return Icons.menu_book;
    }
  }

  static FocusCategory fromString(String value) {
    return FocusCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => FocusCategory.work,
    );
  }
}
