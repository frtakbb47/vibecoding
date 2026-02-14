import 'package:flutter/material.dart';
import 'dart:async';

class StretchExercisesScreen extends StatefulWidget {
  const StretchExercisesScreen({super.key});

  @override
  State<StretchExercisesScreen> createState() => _StretchExercisesScreenState();
}

class _StretchExercisesScreenState extends State<StretchExercisesScreen> {
  int _currentExerciseIndex = 0;
  int _remainingSeconds = 30;
  bool _isRunning = false;
  Timer? _timer;

  final List<_Exercise> _exercises = [
    _Exercise(
      name: 'Neck Rolls',
      emoji: '🔄',
      description: 'Slowly roll your head in a circular motion. 5 times each direction.',
      duration: 30,
      category: 'Neck',
    ),
    _Exercise(
      name: 'Shoulder Shrugs',
      emoji: '💪',
      description: 'Raise shoulders to ears, hold for 3 seconds, release. Repeat 10 times.',
      duration: 30,
      category: 'Shoulders',
    ),
    _Exercise(
      name: 'Wrist Circles',
      emoji: '🤲',
      description: 'Rotate wrists slowly in circles. 10 times each direction.',
      duration: 20,
      category: 'Wrists',
    ),
    _Exercise(
      name: 'Chest Opener',
      emoji: '🙌',
      description: 'Clasp hands behind back, squeeze shoulder blades together, look up.',
      duration: 30,
      category: 'Chest',
    ),
    _Exercise(
      name: 'Seated Spinal Twist',
      emoji: '🌀',
      description: 'Sit tall, twist torso to the right, hold. Repeat on left side.',
      duration: 40,
      category: 'Back',
    ),
    _Exercise(
      name: 'Hip Flexor Stretch',
      emoji: '🦵',
      description: 'Stand, step one foot forward into lunge, hold. Switch legs.',
      duration: 40,
      category: 'Hips',
    ),
    _Exercise(
      name: 'Eye Palming',
      emoji: '👀',
      description: 'Rub hands together, cup warm palms over closed eyes. Relax.',
      duration: 30,
      category: 'Eyes',
    ),
    _Exercise(
      name: 'Finger Stretches',
      emoji: '🖐️',
      description: 'Spread fingers wide, hold 5 sec. Make fist, hold 5 sec. Repeat.',
      duration: 30,
      category: 'Hands',
    ),
    _Exercise(
      name: 'Standing Side Stretch',
      emoji: '🌊',
      description: 'Stand, reach one arm overhead and lean to opposite side. Hold.',
      duration: 30,
      category: 'Sides',
    ),
    _Exercise(
      name: 'Deep Breathing',
      emoji: '🧘',
      description: 'Inhale deeply for 4 seconds, hold for 4, exhale for 4. Repeat 5 times.',
      duration: 60,
      category: 'Breathing',
    ),
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startExercise() {
    setState(() {
      _isRunning = true;
      _remainingSeconds = _exercises[_currentExerciseIndex].duration;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        setState(() => _isRunning = false);
        _showCompletionFeedback();
      }
    });
  }

  void _pauseExercise() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _skipExercise() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      if (_currentExerciseIndex < _exercises.length - 1) {
        _currentExerciseIndex++;
        _remainingSeconds = _exercises[_currentExerciseIndex].duration;
      }
    });
  }

  void _previousExercise() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      if (_currentExerciseIndex > 0) {
        _currentExerciseIndex--;
        _remainingSeconds = _exercises[_currentExerciseIndex].duration;
      }
    });
  }

  void _showCompletionFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Exercise complete! Great job! 🎉'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Auto-advance to next exercise after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _currentExerciseIndex < _exercises.length - 1) {
        setState(() {
          _currentExerciseIndex++;
          _remainingSeconds = _exercises[_currentExerciseIndex].duration;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _exercises[_currentExerciseIndex];
    final progress = (_exercises[_currentExerciseIndex].duration - _remainingSeconds) /
                     _exercises[_currentExerciseIndex].duration;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stretch Exercises'),
        actions: [
          TextButton.icon(
            onPressed: () => _showAllExercises(context),
            icon: const Icon(Icons.list),
            label: const Text('All'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentExerciseIndex + 1) / _exercises.length,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              'Exercise ${_currentExerciseIndex + 1} of ${_exercises.length}',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Category chip
                  Chip(
                    label: Text(exercise.category),
                    avatar: Text(exercise.emoji),
                  ),
                  const SizedBox(height: 24),

                  // Exercise illustration (emoji placeholder)
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        exercise.emoji,
                        style: const TextStyle(fontSize: 80),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Exercise name
                  Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        exercise.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Timer display
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: CircularProgressIndicator(
                          value: _isRunning ? progress : 0,
                          strokeWidth: 10,
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '$_remainingSeconds',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          Text(
                            'seconds',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Control buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.outlined(
                        onPressed: _currentExerciseIndex > 0 ? _previousExercise : null,
                        icon: const Icon(Icons.skip_previous),
                        iconSize: 32,
                      ),
                      const SizedBox(width: 16),
                      FilledButton.icon(
                        onPressed: _isRunning ? _pauseExercise : _startExercise,
                        icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                        label: Text(_isRunning ? 'Pause' : 'Start'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton.outlined(
                        onPressed: _currentExerciseIndex < _exercises.length - 1
                            ? _skipExercise
                            : null,
                        icon: const Icon(Icons.skip_next),
                        iconSize: 32,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllExercises(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Exercises',
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
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  final exercise = _exercises[index];
                  final isActive = index == _currentExerciseIndex;

                  return ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isActive
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          exercise.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    title: Text(
                      exercise.name,
                      style: TextStyle(
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    subtitle: Text('${exercise.duration}s • ${exercise.category}'),
                    trailing: isActive
                        ? const Icon(Icons.play_circle_filled)
                        : null,
                    onTap: () {
                      _timer?.cancel();
                      setState(() {
                        _currentExerciseIndex = index;
                        _remainingSeconds = _exercises[index].duration;
                        _isRunning = false;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Exercise {
  final String name;
  final String emoji;
  final String description;
  final int duration;
  final String category;

  const _Exercise({
    required this.name,
    required this.emoji,
    required this.description,
    required this.duration,
    required this.category,
  });
}
