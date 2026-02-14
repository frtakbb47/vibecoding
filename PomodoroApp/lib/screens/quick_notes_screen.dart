import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class QuickNotesScreen extends StatefulWidget {
  const QuickNotesScreen({super.key});

  @override
  State<QuickNotesScreen> createState() => _QuickNotesScreenState();
}

class _QuickNotesScreenState extends State<QuickNotesScreen> {
  final List<_Note> _notes = [
    _Note(
      id: '1',
      content: 'Remember to review chapter 5 before the exam',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      category: 'Study',
      color: Colors.blue,
    ),
    _Note(
      id: '2',
      content: 'Follow up with client about the project deadline',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      category: 'Work',
      color: Colors.indigo,
    ),
    _Note(
      id: '3',
      content: 'Great idea: Use mind maps for the history topic',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      category: 'Idea',
      color: Colors.amber,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Notes'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                if (value == 'newest') {
                  _notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                } else {
                  _notes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'newest',
                child: Text('Newest first'),
              ),
              const PopupMenuItem(
                value: 'oldest',
                child: Text('Oldest first'),
              ),
            ],
          ),
        ],
      ),
      body: _notes.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return _buildNoteCard(context, note, index);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddNoteDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Note'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No notes yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Capture your thoughts during focus sessions',
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(BuildContext context, _Note note, int index) {
    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        final removedNote = _notes.removeAt(index);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Note deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  _notes.insert(index, removedNote);
                });
              },
            ),
          ),
        );
        setState(() {});
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => _showEditNoteDialog(context, note, index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: note.color, width: 4),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: note.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        note.category,
                        style: TextStyle(
                          color: note.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(note.createdAt),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  note.content,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }

  void _showAddNoteDialog(BuildContext context) {
    final contentController = TextEditingController();
    String selectedCategory = 'Study';
    Color selectedColor = Colors.blue;

    final categories = {
      'Study': Colors.blue,
      'Work': Colors.indigo,
      'Idea': Colors.amber,
      'Todo': Colors.green,
      'Important': Colors.red,
      'Personal': Colors.purple,
    };

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'New Note',
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
                controller: contentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Write your note...',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.entries.map((entry) {
                  final isSelected = selectedCategory == entry.key;
                  return ChoiceChip(
                    label: Text(entry.key),
                    selected: isSelected,
                    selectedColor: entry.value.withOpacity(0.2),
                    onSelected: (selected) {
                      if (selected) {
                        setDialogState(() {
                          selectedCategory = entry.key;
                          selectedColor = entry.value;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    if (contentController.text.isNotEmpty) {
                      setState(() {
                        _notes.insert(0, _Note(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          content: contentController.text,
                          createdAt: DateTime.now(),
                          category: selectedCategory,
                          color: selectedColor,
                        ));
                      });
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Save Note'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditNoteDialog(BuildContext context, _Note note, int index) {
    final contentController = TextEditingController(text: note.content);
    String selectedCategory = note.category;
    Color selectedColor = note.color;

    final categories = {
      'Study': Colors.blue,
      'Work': Colors.indigo,
      'Idea': Colors.amber,
      'Todo': Colors.green,
      'Important': Colors.red,
      'Personal': Colors.purple,
    };

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Note',
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
                controller: contentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Write your note...',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.entries.map((entry) {
                  final isSelected = selectedCategory == entry.key;
                  return ChoiceChip(
                    label: Text(entry.key),
                    selected: isSelected,
                    selectedColor: entry.value.withOpacity(0.2),
                    onSelected: (selected) {
                      if (selected) {
                        setDialogState(() {
                          selectedCategory = entry.key;
                          selectedColor = entry.value;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    if (contentController.text.isNotEmpty) {
                      setState(() {
                        _notes[index] = _Note(
                          id: note.id,
                          content: contentController.text,
                          createdAt: note.createdAt,
                          category: selectedCategory,
                          color: selectedColor,
                        );
                      });
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Note {
  final String id;
  final String content;
  final DateTime createdAt;
  final String category;
  final Color color;

  _Note({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.category,
    required this.color,
  });
}
