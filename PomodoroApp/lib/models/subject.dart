import 'package:hive/hive.dart';

part 'subject.g.dart';

@HiveType(typeId: 4)
class Subject extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? emoji;

  @HiveField(3)
  int colorValue;

  @HiveField(4)
  int totalMinutes; // Total focus time in minutes

  @HiveField(5)
  int targetMinutesPerWeek; // Weekly goal

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  bool isArchived;

  Subject({
    required this.id,
    required this.name,
    this.emoji,
    required this.colorValue,
    this.totalMinutes = 0,
    this.targetMinutesPerWeek = 0,
    required this.createdAt,
    this.isArchived = false,
  });

  void addMinutes(int minutes) {
    totalMinutes += minutes;
    save();
  }

  double get weeklyProgress {
    if (targetMinutesPerWeek == 0) return 0;
    return (totalMinutes / targetMinutesPerWeek).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'colorValue': colorValue,
      'totalMinutes': totalMinutes,
      'targetMinutesPerWeek': targetMinutesPerWeek,
      'createdAt': createdAt.toIso8601String(),
      'isArchived': isArchived,
    };
  }

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      emoji: json['emoji'],
      colorValue: json['colorValue'] ?? 0xFF2196F3,
      totalMinutes: json['totalMinutes'] ?? 0,
      targetMinutesPerWeek: json['targetMinutesPerWeek'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      isArchived: json['isArchived'] ?? false,
    );
  }
}
