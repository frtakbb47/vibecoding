import 'package:flutter/material.dart';

class SessionNote {
  final String id;
  final DateTime timestamp;
  final String note;
  final int sessionDuration;
  final String? category;
  final String? mood;

  const SessionNote({
    required this.id,
    required this.timestamp,
    required this.note,
    required this.sessionDuration,
    this.category,
    this.mood,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'note': note,
    'sessionDuration': sessionDuration,
    'category': category,
    'mood': mood,
  };

  factory SessionNote.fromJson(Map<String, dynamic> json) => SessionNote(
    id: json['id'],
    timestamp: DateTime.parse(json['timestamp']),
    note: json['note'],
    sessionDuration: json['sessionDuration'],
    category: json['category'],
    mood: json['mood'],
  );
}

class SessionNotesService {
  static final List<SessionNote> _notes = [];

  static List<SessionNote> get allNotes => List.unmodifiable(_notes);

  static List<SessionNote> getNotesForDate(DateTime date) {
    return _notes.where((note) =>
      note.timestamp.year == date.year &&
      note.timestamp.month == date.month &&
      note.timestamp.day == date.day
    ).toList();
  }

  static List<SessionNote> getNotesForCategory(String category) {
    return _notes.where((note) => note.category == category).toList();
  }

  static void addNote(SessionNote note) {
    _notes.insert(0, note);
  }

  static void deleteNote(String id) {
    _notes.removeWhere((note) => note.id == id);
  }

  static List<SessionNote> searchNotes(String query) {
    final lowerQuery = query.toLowerCase();
    return _notes.where((note) =>
      note.note.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  static Map<String, int> getCategoryStats() {
    final stats = <String, int>{};
    for (final note in _notes) {
      if (note.category != null) {
        stats[note.category!] = (stats[note.category!] ?? 0) + 1;
      }
    }
    return stats;
  }

  static List<String> get moods => ['😊', '😐', '😓', '🔥', '😴', '💪', '🎯', '🤔'];

  static List<String> get categories => [
    'Study',
    'Work',
    'Creative',
    'Exercise',
    'Reading',
    'Coding',
    'Writing',
    'Other',
  ];

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Study':
        return Icons.school;
      case 'Work':
        return Icons.work;
      case 'Creative':
        return Icons.palette;
      case 'Exercise':
        return Icons.fitness_center;
      case 'Reading':
        return Icons.menu_book;
      case 'Coding':
        return Icons.code;
      case 'Writing':
        return Icons.edit_note;
      default:
        return Icons.category;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Study':
        return Colors.blue;
      case 'Work':
        return Colors.orange;
      case 'Creative':
        return Colors.purple;
      case 'Exercise':
        return Colors.green;
      case 'Reading':
        return Colors.teal;
      case 'Coding':
        return Colors.indigo;
      case 'Writing':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}
