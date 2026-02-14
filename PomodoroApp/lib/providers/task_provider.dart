import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  Task? _currentTask;

  TaskProvider() {
    _loadTasks();
  }

  List<Task> get tasks => _tasks;
  List<Task> get activeTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<Task> get completedTasks => _tasks.where((t) => t.isCompleted).toList();
  Task? get currentTask => _currentTask;

  void _loadTasks() {
    _tasks = StorageService.getAllTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await StorageService.addTask(task);
    _loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await StorageService.updateTask(task);
    _loadTasks();
  }

  Future<void> deleteTask(String taskId) async {
    await StorageService.deleteTask(taskId);
    if (_currentTask?.id == taskId) {
      _currentTask = null;
    }
    _loadTasks();
  }

  Future<void> toggleTaskComplete(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    task.isCompleted = !task.isCompleted;
    if (task.isCompleted) {
      task.completedAt = DateTime.now();
    } else {
      task.completedAt = null;
    }
    await StorageService.updateTask(task);
    _loadTasks();
  }

  void setCurrentTask(Task? task) {
    _currentTask = task;
    notifyListeners();
  }

  Future<void> incrementCurrentTaskPomodoro() async {
    if (_currentTask != null) {
      _currentTask!.incrementPomodoro();
      _loadTasks();
    }
  }

  Task? getTaskById(String taskId) {
    try {
      return _tasks.firstWhere((t) => t.id == taskId);
    } catch (e) {
      return null;
    }
  }

  int get totalPomodorosToday {
    final today = DateTime.now();
    return _tasks
        .where((task) =>
            task.createdAt.year == today.year &&
            task.createdAt.month == today.month &&
            task.createdAt.day == today.day)
        .fold(0, (sum, task) => sum + task.completedPomodoros);
  }

  int get totalActiveTasks => activeTasks.length;
  int get totalCompletedTasks => completedTasks.length;
}
