import 'package:flutter/material.dart';

class StudyPlannerScreen extends StatefulWidget {
  const StudyPlannerScreen({super.key});

  @override
  State<StudyPlannerScreen> createState() => _StudyPlannerScreenState();
}

class _StudyPlannerScreenState extends State<StudyPlannerScreen> {
  final List<_StudyBlock> _studyBlocks = [
    _StudyBlock(
      id: '1',
      subject: 'Mathematics',
      emoji: '📐',
      color: Colors.blue,
      startTime: const TimeOfDay(hour: 9, minute: 0),
      duration: 50,
      isCompleted: true,
    ),
    _StudyBlock(
      id: '2',
      subject: 'Physics',
      emoji: '⚛️',
      color: Colors.purple,
      startTime: const TimeOfDay(hour: 10, minute: 0),
      duration: 50,
      isCompleted: true,
    ),
    _StudyBlock(
      id: '3',
      subject: 'Chemistry',
      emoji: '🧪',
      color: Colors.green,
      startTime: const TimeOfDay(hour: 14, minute: 0),
      duration: 50,
      isCompleted: false,
    ),
    _StudyBlock(
      id: '4',
      subject: 'English',
      emoji: '📚',
      color: Colors.orange,
      startTime: const TimeOfDay(hour: 15, minute: 0),
      duration: 50,
      isCompleted: false,
    ),
    _StudyBlock(
      id: '5',
      subject: 'History',
      emoji: '📜',
      color: Colors.brown,
      startTime: const TimeOfDay(hour: 16, minute: 0),
      duration: 25,
      isCompleted: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final completedCount = _studyBlocks.where((b) => b.isCompleted).length;
    final totalMinutes = _studyBlocks.fold<int>(0, (sum, b) => sum + b.duration);
    final completedMinutes = _studyBlocks
        .where((b) => b.isCompleted)
        .fold<int>(0, (sum, b) => sum + b.duration);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _showDatePicker(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Today's summary
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context).colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Today',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Dec 30, 2024',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryStat(
                      context,
                      '$completedCount/${_studyBlocks.length}',
                      'Sessions',
                    ),
                    _buildSummaryStat(
                      context,
                      '${completedMinutes}m',
                      'Completed',
                    ),
                    _buildSummaryStat(
                      context,
                      '${totalMinutes - completedMinutes}m',
                      'Remaining',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: totalMinutes > 0 ? completedMinutes / totalMinutes : 0,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),

          // Schedule list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _studyBlocks.length,
              itemBuilder: (context, index) {
                final block = _studyBlocks[index];
                final now = TimeOfDay.now();
                final isCurrentHour = now.hour == block.startTime.hour;

                return _buildStudyBlockCard(context, block, isCurrentHour, index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBlockDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Block'),
      ),
    );
  }

  Widget _buildSummaryStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStudyBlockCard(
    BuildContext context,
    _StudyBlock block,
    bool isCurrentHour,
    int index,
  ) {
    return Dismissible(
      key: Key(block.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          _studyBlocks.removeAt(index);
        });
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isCurrentHour && !block.isCompleted
              ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: () => _toggleCompletion(index),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Time column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTimeOfDay(block.startTime),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: block.isCompleted
                            ? Theme.of(context).colorScheme.outline
                            : null,
                      ),
                    ),
                    Text(
                      '${block.duration}m',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Vertical line
                Container(
                  width: 4,
                  height: 50,
                  decoration: BoxDecoration(
                    color: block.isCompleted
                        ? Colors.green
                        : block.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 16),

                // Subject info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            block.emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              block.subject,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                decoration: block.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: block.isCompleted
                                    ? Theme.of(context).colorScheme.outline
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isCurrentHour && !block.isCompleted)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '⏰ Current block',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Completion indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: block.isCompleted
                        ? Colors.green
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    border: block.isCompleted
                        ? null
                        : Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            width: 2,
                          ),
                  ),
                  child: block.isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  void _toggleCompletion(int index) {
    setState(() {
      _studyBlocks[index] = _StudyBlock(
        id: _studyBlocks[index].id,
        subject: _studyBlocks[index].subject,
        emoji: _studyBlocks[index].emoji,
        color: _studyBlocks[index].color,
        startTime: _studyBlocks[index].startTime,
        duration: _studyBlocks[index].duration,
        isCompleted: !_studyBlocks[index].isCompleted,
      );
    });
  }

  void _showDatePicker(BuildContext context) async {
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
  }

  void _showAddBlockDialog(BuildContext context) {
    final subjectController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    int selectedDuration = 25;
    String selectedEmoji = '📚';
    Color selectedColor = Colors.blue;

    final emojis = ['📚', '📐', '⚛️', '🧪', '📜', '💻', '🎨', '🎵', '🌍', '🔬'];
    final colors = [
      Colors.blue, Colors.purple, Colors.green, Colors.orange,
      Colors.red, Colors.teal, Colors.indigo, Colors.pink,
    ];
    final durations = [25, 30, 45, 50, 60, 90];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Study Block',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject Name',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),

                // Time picker
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Start Time', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: selectedTime,
                              );
                              if (time != null) {
                                setDialogState(() => selectedTime = time);
                              }
                            },
                            icon: const Icon(Icons.access_time),
                            label: Text(_formatTimeOfDay(selectedTime)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Duration', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          DropdownButton<int>(
                            value: selectedDuration,
                            items: durations.map((d) => DropdownMenuItem(
                              value: d,
                              child: Text('$d min'),
                            )).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() => selectedDuration = value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Icon picker
                const Text('Icon', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: emojis.map((emoji) {
                    final isSelected = selectedEmoji == emoji;
                    return InkWell(
                      onTap: () => setDialogState(() => selectedEmoji = emoji),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected ? selectedColor.withOpacity(0.2) : null,
                          border: isSelected
                              ? Border.all(color: selectedColor, width: 2)
                              : Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Color picker
                const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colors.map((color) {
                    final isSelected = selectedColor == color;
                    return InkWell(
                      onTap: () => setDialogState(() => selectedColor = color),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                          boxShadow: isSelected
                              ? [BoxShadow(color: color, blurRadius: 8)]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      if (subjectController.text.isNotEmpty) {
                        setState(() {
                          _studyBlocks.add(_StudyBlock(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            subject: subjectController.text,
                            emoji: selectedEmoji,
                            color: selectedColor,
                            startTime: selectedTime,
                            duration: selectedDuration,
                            isCompleted: false,
                          ));
                          _studyBlocks.sort((a, b) {
                            final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
                            final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
                            return aMinutes.compareTo(bMinutes);
                          });
                        });
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Block'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StudyBlock {
  final String id;
  final String subject;
  final String emoji;
  final Color color;
  final TimeOfDay startTime;
  final int duration;
  final bool isCompleted;

  _StudyBlock({
    required this.id,
    required this.subject,
    required this.emoji,
    required this.color,
    required this.startTime,
    required this.duration,
    required this.isCompleted,
  });
}
