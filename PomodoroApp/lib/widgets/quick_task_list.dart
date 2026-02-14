import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/timer_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/constants.dart';
import '../l10n/app_localizations.dart';
import '../screens/tasks_screen.dart';

class QuickTaskList extends StatelessWidget {
  const QuickTaskList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final activeTasks = taskProvider.activeTasks.take(3).toList();

        if (activeTasks.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.task_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context).noActiveTasks,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TasksScreen()),
                    ),
                    child: Text(AppLocalizations.of(context).addTask),
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context).quickTasks,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TasksScreen()),
                      ),
                      child: Text(AppLocalizations.of(context).viewAll),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...activeTasks.map((task) => _buildTaskItem(context, task)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTaskItem(BuildContext context, task) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

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

    final isCurrentTask = taskProvider.currentTask?.id == task.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isCurrentTask
              ? AppConstants.primaryRed
              : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: priorityColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          task.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: LinearProgressIndicator(
          value: task.progress,
          backgroundColor: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
        trailing: IconButton(
          icon: Icon(
            isCurrentTask ? Icons.stop_circle : Icons.play_circle_outline,
            color: isCurrentTask ? Colors.red : AppConstants.primaryRed,
          ),
          onPressed: () {
            if (isCurrentTask) {
              taskProvider.setCurrentTask(null);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context).taskDeselected),
                  duration: const Duration(seconds: 1),
                ),
              );
            } else {
              taskProvider.setCurrentTask(task);
              timerProvider.setTimerType(
                AppConstants.stateWork,
                settingsProvider.workDuration,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${AppLocalizations.of(context).workingOn}: ${task.title}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
