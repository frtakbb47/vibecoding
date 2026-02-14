import 'package:flutter/material.dart';
import '../services/daily_planning_service.dart';

class DailyPlanningScreen extends StatefulWidget {
  const DailyPlanningScreen({super.key});

  @override
  State<DailyPlanningScreen> createState() => _DailyPlanningScreenState();
}

class _DailyPlanningScreenState extends State<DailyPlanningScreen> {
  late DateTime _selectedDate;
  DailyPlan? _currentPlan;
  final TextEditingController _intentionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadPlan();
  }

  void _loadPlan() {
    _currentPlan = DailyPlanningService.getPlanForDate(_selectedDate);
    if (_currentPlan != null) {
      _intentionController.text = _currentPlan!.intention;
    } else {
      _intentionController.clear();
    }
  }

  @override
  void dispose() {
    _intentionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isToday = _isToday(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Planning'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Date selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                        _loadPlan();
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDate = date;
                            _loadPlan();
                          });
                        }
                      },
                      child: Column(
                        children: [
                          Text(
                            isToday ? 'Today' : _formatDate(_selectedDate),
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!isToday)
                            Text(
                              _getDayName(_selectedDate),
                              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                            ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        _selectedDate = _selectedDate.add(const Duration(days: 1));
                        _loadPlan();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Progress card (if plan exists)
          if (_currentPlan != null) ...[
            _buildProgressCard(theme),
            const SizedBox(height: 16),
          ],

          // Intention section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flag, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Today\'s Intention',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _intentionController,
                    decoration: InputDecoration(
                      hintText: 'What\'s your focus for today?',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Suggestions:',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: DailyPlanningService.intentionSuggestions.take(4).map((s) {
                      return ActionChip(
                        label: Text(s, style: const TextStyle(fontSize: 11)),
                        onPressed: () {
                          _intentionController.text = s;
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sessions goal
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.track_changes, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Session Goal',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filled(
                        onPressed: () {
                          if (_currentPlan != null && _currentPlan!.plannedSessions > 1) {
                            _updatePlan(plannedSessions: _currentPlan!.plannedSessions - 1);
                          }
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      const SizedBox(width: 24),
                      Column(
                        children: [
                          Text(
                            '${_currentPlan?.plannedSessions ?? 4}',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          Text(
                            'sessions',
                            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      IconButton.filled(
                        onPressed: () {
                          final current = _currentPlan?.plannedSessions ?? 4;
                          if (current < 20) {
                            _updatePlan(plannedSessions: current + 1);
                          }
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      '≈ ${(_currentPlan?.plannedSessions ?? 4) * 25} minutes of focus',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Planned tasks
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.checklist, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Planned Tasks',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _showAddTaskDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_currentPlan == null || _currentPlan!.tasks.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(Icons.task_alt, size: 48, color: theme.colorScheme.outline),
                            const SizedBox(height: 8),
                            Text(
                              'No tasks planned',
                              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => _showAddTaskDialog(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Add a task'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._currentPlan!.tasks.map((task) => _TaskItem(
                      task: task,
                      onToggle: () {
                        DailyPlanningService.toggleTaskCompletion(_selectedDate, task.id);
                        setState(() => _loadPlan());
                      },
                      onDelete: () {
                        final updatedTasks = _currentPlan!.tasks.where((t) => t.id != task.id).toList();
                        _updatePlan(tasks: updatedTasks);
                      },
                    )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _savePlan,
              icon: const Icon(Icons.save),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Save Plan'),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProgressCard(ThemeData theme) {
    final plan = _currentPlan!;
    final progress = plan.progressPercent;

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  '${plan.completedSessions}/${plan.plannedSessions} sessions',
                  style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).toInt()}% complete',
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updatePlan({int? plannedSessions, List<PlannedTask>? tasks}) {
    final current = _currentPlan ?? DailyPlan(
      date: _selectedDate,
      intention: _intentionController.text,
      plannedSessions: 4,
      tasks: [],
    );

    _currentPlan = current.copyWith(
      plannedSessions: plannedSessions ?? current.plannedSessions,
      tasks: tasks ?? current.tasks,
    );

    DailyPlanningService.savePlan(_currentPlan!);
    setState(() {});
  }

  void _savePlan() {
    final plan = DailyPlan(
      date: _selectedDate,
      intention: _intentionController.text,
      plannedSessions: _currentPlan?.plannedSessions ?? 4,
      tasks: _currentPlan?.tasks ?? [],
      completedSessions: _currentPlan?.completedSessions ?? 0,
    );

    DailyPlanningService.savePlan(plan);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Plan saved!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    int estimatedSessions = 1;
    int priority = 2;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final theme = Theme.of(context);

          return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Add Task', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Task title',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),

                Text('Estimated sessions', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [1, 2, 3, 4, 5].map((n) {
                    final isSelected = estimatedSessions == n;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('$n'),
                        selected: isSelected,
                        onSelected: (_) => setDialogState(() => estimatedSessions = n),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                Text('Priority', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildPriorityChip(1, 'High', Colors.red, priority, (v) => setDialogState(() => priority = v)),
                    const SizedBox(width: 8),
                    _buildPriorityChip(2, 'Medium', Colors.orange, priority, (v) => setDialogState(() => priority = v)),
                    const SizedBox(width: 8),
                    _buildPriorityChip(3, 'Low', Colors.green, priority, (v) => setDialogState(() => priority = v)),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (titleController.text.trim().isNotEmpty) {
                        final task = PlannedTask(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text.trim(),
                          estimatedSessions: estimatedSessions,
                          priority: priority,
                        );

                        final currentTasks = _currentPlan?.tasks ?? [];
                        _updatePlan(tasks: [...currentTasks, task]);
                        Navigator.pop(context);
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Add Task'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriorityChip(int value, String label, Color color, int current, ValueChanged<int> onSelect) {
    final isSelected = current == value;
    return Expanded(
      child: ChoiceChip(
        label: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag, size: 16, color: isSelected ? Colors.white : color),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        selected: isSelected,
        selectedColor: color,
        onSelected: (_) => onSelect(value),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDayName(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }
}

class _TaskItem extends StatelessWidget {
  final PlannedTask task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskItem({
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: task.isCompleted
            ? Colors.green.withOpacity(0.1)
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => onToggle(),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? theme.colorScheme.onSurfaceVariant : null,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.timer, size: 12, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              '${task.estimatedSessions} session${task.estimatedSessions > 1 ? 's' : ''}',
              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            Icon(Icons.flag, size: 12, color: task.priorityColor),
            const SizedBox(width: 4),
            Text(
              task.priorityLabel,
              style: TextStyle(fontSize: 12, color: task.priorityColor),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.close, size: 18, color: theme.colorScheme.onSurfaceVariant),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
