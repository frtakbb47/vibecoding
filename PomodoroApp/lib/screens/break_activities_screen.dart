import 'package:flutter/material.dart';
import 'dart:math';

class BreakActivity {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final Duration duration;
  final String category;
  final List<String> benefits;

  const BreakActivity({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.duration,
    required this.category,
    required this.benefits,
  });
}

class BreakActivitiesScreen extends StatefulWidget {
  const BreakActivitiesScreen({super.key});

  @override
  State<BreakActivitiesScreen> createState() => _BreakActivitiesScreenState();
}

class _BreakActivitiesScreenState extends State<BreakActivitiesScreen> {
  String _selectedCategory = 'All';
  BreakActivity? _randomActivity;

  static const List<BreakActivity> _activities = [
    // Physical
    BreakActivity(
      id: 'stretch',
      name: 'Quick Stretch',
      description: 'Do some simple stretches for your neck, shoulders, and back.',
      emoji: '🧘',
      duration: Duration(minutes: 3),
      category: 'Physical',
      benefits: ['Reduces tension', 'Improves posture', 'Boosts circulation'],
    ),
    BreakActivity(
      id: 'walk',
      name: 'Short Walk',
      description: 'Take a quick walk around your room or office.',
      emoji: '🚶',
      duration: Duration(minutes: 5),
      category: 'Physical',
      benefits: ['Increases blood flow', 'Clears mind', 'Burns calories'],
    ),
    BreakActivity(
      id: 'jumping',
      name: 'Jumping Jacks',
      description: 'Do 20-30 jumping jacks to get your heart pumping.',
      emoji: '⭐',
      duration: Duration(minutes: 2),
      category: 'Physical',
      benefits: ['Energy boost', 'Quick cardio', 'Wakes you up'],
    ),
    BreakActivity(
      id: 'desk_yoga',
      name: 'Desk Yoga',
      description: 'Simple yoga poses you can do at your desk.',
      emoji: '🪷',
      duration: Duration(minutes: 5),
      category: 'Physical',
      benefits: ['Flexibility', 'Stress relief', 'Body awareness'],
    ),
    BreakActivity(
      id: 'eye_exercise',
      name: 'Eye Exercises',
      description: 'Rest your eyes with the 20-20-20 rule and eye movements.',
      emoji: '👀',
      duration: Duration(minutes: 2),
      category: 'Physical',
      benefits: ['Reduces eye strain', 'Prevents fatigue', 'Improves focus'],
    ),

    // Mental
    BreakActivity(
      id: 'breathing',
      name: 'Deep Breathing',
      description: 'Practice 4-7-8 breathing or box breathing technique.',
      emoji: '🌬️',
      duration: Duration(minutes: 3),
      category: 'Mental',
      benefits: ['Calms nerves', 'Reduces stress', 'Centers mind'],
    ),
    BreakActivity(
      id: 'meditation',
      name: 'Mini Meditation',
      description: 'Close your eyes and focus on your breath for a few minutes.',
      emoji: '🧘‍♂️',
      duration: Duration(minutes: 5),
      category: 'Mental',
      benefits: ['Mental clarity', 'Stress reduction', 'Improved focus'],
    ),
    BreakActivity(
      id: 'gratitude',
      name: 'Gratitude Moment',
      description: 'Think of 3 things you are grateful for today.',
      emoji: '🙏',
      duration: Duration(minutes: 2),
      category: 'Mental',
      benefits: ['Positive mindset', 'Mood boost', 'Perspective shift'],
    ),
    BreakActivity(
      id: 'visualization',
      name: 'Visualization',
      description: 'Visualize achieving your goals or a peaceful place.',
      emoji: '🎯',
      duration: Duration(minutes: 3),
      category: 'Mental',
      benefits: ['Motivation', 'Goal clarity', 'Positive energy'],
    ),
    BreakActivity(
      id: 'mindfulness',
      name: 'Mindful Moment',
      description: 'Notice 5 things you can see, 4 you can touch, 3 you can hear.',
      emoji: '🌸',
      duration: Duration(minutes: 2),
      category: 'Mental',
      benefits: ['Present awareness', 'Anxiety reduction', 'Grounding'],
    ),

    // Refreshment
    BreakActivity(
      id: 'water',
      name: 'Hydrate',
      description: 'Drink a glass of water to stay hydrated.',
      emoji: '💧',
      duration: Duration(minutes: 1),
      category: 'Refreshment',
      benefits: ['Hydration', 'Brain function', 'Energy levels'],
    ),
    BreakActivity(
      id: 'snack',
      name: 'Healthy Snack',
      description: 'Grab a nutritious snack like fruit, nuts, or yogurt.',
      emoji: '🍎',
      duration: Duration(minutes: 5),
      category: 'Refreshment',
      benefits: ['Blood sugar', 'Energy boost', 'Brain fuel'],
    ),
    BreakActivity(
      id: 'tea',
      name: 'Make Tea/Coffee',
      description: 'Prepare your favorite warm beverage mindfully.',
      emoji: '☕',
      duration: Duration(minutes: 5),
      category: 'Refreshment',
      benefits: ['Caffeine boost', 'Ritual break', 'Warmth comfort'],
    ),
    BreakActivity(
      id: 'face_wash',
      name: 'Refresh Face',
      description: 'Splash cold water on your face to feel refreshed.',
      emoji: '🚿',
      duration: Duration(minutes: 2),
      category: 'Refreshment',
      benefits: ['Alertness', 'Skin refresh', 'Wake up effect'],
    ),

    // Social
    BreakActivity(
      id: 'chat',
      name: 'Quick Chat',
      description: 'Have a brief conversation with a colleague or friend.',
      emoji: '💬',
      duration: Duration(minutes: 5),
      category: 'Social',
      benefits: ['Social connection', 'Mood lift', 'Mental break'],
    ),
    BreakActivity(
      id: 'pet',
      name: 'Pet Time',
      description: 'Spend a moment with your pet if you have one nearby.',
      emoji: '🐱',
      duration: Duration(minutes: 3),
      category: 'Social',
      benefits: ['Stress relief', 'Joy boost', 'Unconditional love'],
    ),
    BreakActivity(
      id: 'message',
      name: 'Send a Message',
      description: 'Send a kind message to someone you care about.',
      emoji: '💌',
      duration: Duration(minutes: 2),
      category: 'Social',
      benefits: ['Connection', 'Kindness', 'Relationship building'],
    ),

    // Creative
    BreakActivity(
      id: 'doodle',
      name: 'Quick Doodle',
      description: 'Sketch something simple or abstract on paper.',
      emoji: '✏️',
      duration: Duration(minutes: 5),
      category: 'Creative',
      benefits: ['Creativity', 'Right brain activation', 'Relaxation'],
    ),
    BreakActivity(
      id: 'music',
      name: 'Listen to Music',
      description: 'Put on your favorite song and really listen to it.',
      emoji: '🎵',
      duration: Duration(minutes: 4),
      category: 'Creative',
      benefits: ['Mood boost', 'Inspiration', 'Mental refresh'],
    ),
    BreakActivity(
      id: 'window',
      name: 'Window Gazing',
      description: 'Look out the window and observe the world outside.',
      emoji: '🪟',
      duration: Duration(minutes: 3),
      category: 'Creative',
      benefits: ['Eye rest', 'Mind wandering', 'Inspiration'],
    ),
  ];

  List<String> get _categories {
    final cats = _activities.map((a) => a.category).toSet().toList();
    return ['All', ...cats];
  }

  List<BreakActivity> get _filteredActivities {
    if (_selectedCategory == 'All') return _activities;
    return _activities.where((a) => a.category == _selectedCategory).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Physical':
        return Colors.green;
      case 'Mental':
        return Colors.purple;
      case 'Refreshment':
        return Colors.blue;
      case 'Social':
        return Colors.orange;
      case 'Creative':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  void _pickRandomActivity() {
    final random = Random();
    final activity = _filteredActivities[random.nextInt(_filteredActivities.length)];
    setState(() {
      _randomActivity = activity;
    });
    _showActivityDetail(activity);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Break Activities'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Random activity',
            onPressed: _pickRandomActivity,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                final color = category == 'All'
                    ? theme.colorScheme.primary
                    : _getCategoryColor(category);

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    selectedColor: color.withOpacity(0.2),
                    checkmarkColor: color,
                    labelStyle: TextStyle(
                      color: isSelected ? color : theme.colorScheme.onSurface,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          // Random Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              color: theme.colorScheme.primaryContainer,
              child: InkWell(
                onTap: _pickRandomActivity,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pick Random Activity',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              'Can\'t decide? Let us choose for you!',
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Activities Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _filteredActivities.length,
              itemBuilder: (context, index) {
                final activity = _filteredActivities[index];
                return _ActivityCard(
                  activity: activity,
                  color: _getCategoryColor(activity.category),
                  onTap: () => _showActivityDetail(activity),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showActivityDetail(BreakActivity activity) {
    final theme = Theme.of(context);
    final color = _getCategoryColor(activity.category);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              activity.emoji,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                activity.category,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              activity.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer, size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  '${activity.duration.inMinutes} min',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              activity.description,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Benefits
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Benefits',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: activity.benefits.map((benefit) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, size: 14, color: color),
                            const SizedBox(width: 4),
                            Text(
                              benefit,
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start This Activity'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final BreakActivity activity;
  final Color color;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.activity,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                activity.emoji,
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(height: 12),
              Text(
                activity.name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer, size: 12, color: color),
                    const SizedBox(width: 4),
                    Text(
                      '${activity.duration.inMinutes} min',
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
