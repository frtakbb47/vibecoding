import 'package:hive/hive.dart';

part 'session.g.dart';

@HiveType(typeId: 2)
class PomodoroSession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime startTime;

  @HiveField(2)
  DateTime endTime;

  @HiveField(3)
  String type; // 'work', 'short_break', 'long_break'

  @HiveField(4)
  int durationMinutes;

  @HiveField(5)
  bool completed;

  @HiveField(6)
  String? taskId;

  @HiveField(7)
  String? taskTitle;

  PomodoroSession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.durationMinutes,
    this.completed = true,
    this.taskId,
    this.taskTitle,
  });

  Duration get duration => endTime.difference(startTime);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'type': type,
      'durationMinutes': durationMinutes,
      'completed': completed,
      'taskId': taskId,
      'taskTitle': taskTitle,
    };
  }

  factory PomodoroSession.fromJson(Map<String, dynamic> json) {
    return PomodoroSession(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      type: json['type'],
      durationMinutes: json['durationMinutes'],
      completed: json['completed'] ?? true,
      taskId: json['taskId'],
      taskTitle: json['taskTitle'],
    );
  }
}
