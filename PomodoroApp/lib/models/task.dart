import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  int estimatedPomodoros;

  @HiveField(4)
  int completedPomodoros;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? completedAt;

  @HiveField(8)
  int priority; // 0: low, 1: medium, 2: high

  Task({
    required this.id,
    required this.title,
    this.description,
    this.estimatedPomodoros = 1,
    this.completedPomodoros = 0,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.priority = 1,
  });

  double get progress {
    if (estimatedPomodoros == 0) return 0.0;
    return (completedPomodoros / estimatedPomodoros).clamp(0.0, 1.0);
  }

  void incrementPomodoro() {
    completedPomodoros++;
    if (completedPomodoros >= estimatedPomodoros) {
      isCompleted = true;
      completedAt = DateTime.now();
    }
    save();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'estimatedPomodoros': estimatedPomodoros,
      'completedPomodoros': completedPomodoros,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'priority': priority,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      estimatedPomodoros: json['estimatedPomodoros'] ?? 1,
      completedPomodoros: json['completedPomodoros'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      priority: json['priority'] ?? 1,
    );
  }
}
