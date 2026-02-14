import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/timer_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).tasks),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context).active),
            Tab(text: AppLocalizations.of(context).completed),
          ],
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildTaskList(taskProvider.activeTasks, false),
              _buildTaskList(taskProvider.completedTasks, true),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks, bool isCompleted) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted ? Icons.check_circle_outline : Icons.task_outlined,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isCompleted ? AppLocalizations.of(context).noCompletedTasks : AppLocalizations.of(context).noTasks,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(context, task, isCompleted);
      },
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task, bool isCompleted) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);

    Color priorityColor;
    switch (task.priority) {
      case 2:
        priorityColor = Colors.red;
        break;
      case 1:
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.green;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showTaskDetails(context, task),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  if (!isCompleted)
                    IconButton(
                      icon: const Icon(Icons.play_circle_outline, size: 28),
                      onPressed: () {
                        taskProvider.setCurrentTask(task);
                        final settings = Provider.of<SettingsProvider>(context, listen: false);
                        timerProvider.setTimerType(
                          AppConstants.stateWork,
                          settings.workDuration,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${AppLocalizations.of(context).workingOn} ${task.title}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      tooltip: AppLocalizations.of(context).start,
                    ),
                ],
              ),
              if (task.description != null && task.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${task.completedPomodoros} / ${task.estimatedPomodoros} Pomodoros',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: task.progress,
                          backgroundColor: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!isCompleted)
                    IconButton(
                      icon: Icon(
                        task.isCompleted
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: task.isCompleted ? Colors.green : null,
                      ),
                      onPressed: () =>
                          taskProvider.toggleTaskComplete(task.id),
                      tooltip: AppLocalizations.of(context).markAsComplete,
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDelete(context, task),
                    tooltip: AppLocalizations.of(context).deleteTask,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    int estimatedPomodoros = 1;
    int priority = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(AppLocalizations.of(context).addNewTask),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).taskTitle,
                    border: const OutlineInputBorder(),
                  ),
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context).descriptionOptional,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(AppLocalizations.of(context).estimatedPomodoros),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: estimatedPomodoros > 1
                          ? () => setState(() => estimatedPomodoros--)
                          : null,
                    ),
                    Text(
                      estimatedPomodoros.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() => estimatedPomodoros++),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: [
                    ButtonSegment(value: 0, label: Text(AppLocalizations.of(context).low)),
                    ButtonSegment(value: 1, label: Text(AppLocalizations.of(context).medium)),
                    ButtonSegment(value: 2, label: Text(AppLocalizations.of(context).high)),
                  ],
                  selected: {priority},
                  onSelectionChanged: (Set<int> newSelection) {
                    setState(() => priority = newSelection.first);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context).enterTaskTitle)),
                  );
                  return;
                }

                final task = Task(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  description: descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim(),
                  estimatedPomodoros: estimatedPomodoros,
                  createdAt: DateTime.now(),
                  priority: priority,
                );

                Provider.of<TaskProvider>(context, listen: false).addTask(task);
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context).add),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskDetails(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description != null && task.description!.isNotEmpty) ...[
                Text(
                  '${AppLocalizations.of(context).description}:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(task.description!),
                const SizedBox(height: 16),
              ],
              Text(
                '${AppLocalizations.of(context).priority}: ${[AppLocalizations.of(context).low, AppLocalizations.of(context).medium, AppLocalizations.of(context).high][task.priority]}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${AppLocalizations.of(context).progress}: ${task.completedPomodoros} / ${task.estimatedPomodoros} ${AppLocalizations.of(context).pomodoros}',
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: task.progress),
              const SizedBox(height: 16),
              Text('${AppLocalizations.of(context).created}: ${_formatDate(task.createdAt)}'),
              if (task.completedAt != null)
                Text('${AppLocalizations.of(context).completed}: ${_formatDate(task.completedAt!)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).close),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).deleteTask),
        content: Text('${AppLocalizations.of(context).deleteConfirmation.replaceAll('this', '"${task.title}"')}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          FilledButton(
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false)
                  .deleteTask(task.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context).delete),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
