import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class BreathingExercise {
  final String id;
  final String name;
  final String description;
  final int inhaleSeconds;
  final int holdSeconds;
  final int exhaleSeconds;
  final int holdAfterExhaleSeconds;
  final int cycles;
  final Color color;

  const BreathingExercise({
    required this.id,
    required this.name,
    required this.description,
    required this.inhaleSeconds,
    required this.holdSeconds,
    required this.exhaleSeconds,
    this.holdAfterExhaleSeconds = 0,
    required this.cycles,
    required this.color,
  });

  int get totalSeconds =>
      (inhaleSeconds + holdSeconds + exhaleSeconds + holdAfterExhaleSeconds) * cycles;
}

class BreathingExercisesScreen extends StatefulWidget {
  const BreathingExercisesScreen({super.key});

  @override
  State<BreathingExercisesScreen> createState() => _BreathingExercisesScreenState();
}

class _BreathingExercisesScreenState extends State<BreathingExercisesScreen> {
  static const List<BreathingExercise> _exercises = [
    BreathingExercise(
      id: 'box',
      name: 'Box Breathing',
      description: 'Used by Navy SEALs to stay calm. Equal counts for inhale, hold, exhale, hold.',
      inhaleSeconds: 4,
      holdSeconds: 4,
      exhaleSeconds: 4,
      holdAfterExhaleSeconds: 4,
      cycles: 4,
      color: Colors.blue,
    ),
    BreathingExercise(
      id: '478',
      name: '4-7-8 Relaxing',
      description: 'Dr. Weil\'s technique for relaxation and sleep. Great for stress relief.',
      inhaleSeconds: 4,
      holdSeconds: 7,
      exhaleSeconds: 8,
      cycles: 4,
      color: Colors.purple,
    ),
    BreathingExercise(
      id: 'energizing',
      name: 'Energizing Breath',
      description: 'Quick breathing to boost energy and alertness.',
      inhaleSeconds: 3,
      holdSeconds: 0,
      exhaleSeconds: 3,
      cycles: 6,
      color: Colors.orange,
    ),
    BreathingExercise(
      id: 'calming',
      name: 'Calming Breath',
      description: 'Extended exhale for parasympathetic activation.',
      inhaleSeconds: 4,
      holdSeconds: 2,
      exhaleSeconds: 6,
      cycles: 5,
      color: Colors.teal,
    ),
    BreathingExercise(
      id: 'focus',
      name: 'Focus Breath',
      description: 'Balance your mind before a focus session.',
      inhaleSeconds: 5,
      holdSeconds: 5,
      exhaleSeconds: 5,
      cycles: 4,
      color: Colors.indigo,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Breathing Exercises'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.air,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Breathe & Focus',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          'Use these exercises during breaks to reset your mind.',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Exercise cards
          ..._exercises.map((exercise) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ExerciseCard(
              exercise: exercise,
              onStart: () => _startExercise(exercise),
            ),
          )),
        ],
      ),
    );
  }

  void _startExercise(BreathingExercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _BreathingSessionScreen(exercise: exercise),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final BreathingExercise exercise;
  final VoidCallback onStart;

  const _ExerciseCard({required this.exercise, required this.onStart});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalMinutes = exercise.totalSeconds ~/ 60;
    final totalSecondsRemainder = exercise.totalSeconds % 60;

    return Card(
      child: InkWell(
        onTap: onStart,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: exercise.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.air, color: exercise.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${exercise.inhaleSeconds}-${exercise.holdSeconds}-${exercise.exhaleSeconds}${exercise.holdAfterExhaleSeconds > 0 ? '-${exercise.holdAfterExhaleSeconds}' : ''} pattern',
                          style: TextStyle(
                            color: exercise.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$totalMinutes:${totalSecondsRemainder.toString().padLeft(2, '0')}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${exercise.cycles} cycles',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                exercise.description,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: exercise.color,
                    side: BorderSide(color: exercise.color),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreathingSessionScreen extends StatefulWidget {
  final BreathingExercise exercise;

  const _BreathingSessionScreen({required this.exercise});

  @override
  State<_BreathingSessionScreen> createState() => _BreathingSessionScreenState();
}

class _BreathingSessionScreenState extends State<_BreathingSessionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _timer;

  int _currentCycle = 1;
  String _phase = 'Get Ready';
  int _countdown = 3;
  bool _isStarted = false;
  bool _isComplete = false;

  int _phaseSeconds = 0;
  int _phaseIndex = 0;

  List<_BreathPhase> get _phases {
    final e = widget.exercise;
    final phases = <_BreathPhase>[];

    if (e.inhaleSeconds > 0) {
      phases.add(_BreathPhase('Breathe In', e.inhaleSeconds, true));
    }
    if (e.holdSeconds > 0) {
      phases.add(_BreathPhase('Hold', e.holdSeconds, false));
    }
    if (e.exhaleSeconds > 0) {
      phases.add(_BreathPhase('Breathe Out', e.exhaleSeconds, true));
    }
    if (e.holdAfterExhaleSeconds > 0) {
      phases.add(_BreathPhase('Hold', e.holdAfterExhaleSeconds, false));
    }

    return phases;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
        _startExercise();
      }
    });
  }

  void _startExercise() {
    setState(() {
      _isStarted = true;
      _phaseIndex = 0;
      _startPhase();
    });
  }

  void _startPhase() {
    if (_phaseIndex >= _phases.length) {
      // Complete cycle
      if (_currentCycle >= widget.exercise.cycles) {
        _complete();
        return;
      }
      setState(() {
        _currentCycle++;
        _phaseIndex = 0;
      });
    }

    final phase = _phases[_phaseIndex];
    setState(() {
      _phase = phase.name;
      _phaseSeconds = phase.seconds;
    });

    _controller.duration = Duration(seconds: phase.seconds);

    if (phase.name == 'Breathe In') {
      _controller.forward(from: 0);
    } else if (phase.name == 'Breathe Out') {
      _controller.reverse(from: 1);
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_phaseSeconds > 1) {
        setState(() => _phaseSeconds--);
      } else {
        timer.cancel();
        setState(() => _phaseIndex++);
        _startPhase();
      }
    });
  }

  void _complete() {
    _timer?.cancel();
    setState(() {
      _isComplete = true;
      _phase = 'Complete!';
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = widget.exercise.color;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.exercise.name),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // Breathing circle
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final scale = _isStarted && !_isComplete
                      ? 0.6 + (_controller.value * 0.4)
                      : _isComplete ? 0.8 : 0.6;

                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.1),
                        border: Border.all(color: color.withOpacity(0.3), width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_isStarted)
                              Text(
                                '$_countdown',
                                style: TextStyle(
                                  fontSize: 72,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              )
                            else if (_isComplete)
                              Icon(Icons.check_circle, size: 80, color: color)
                            else ...[
                              Text(
                                '$_phaseSeconds',
                                style: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),

            // Phase text
            Text(
              _phase,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 16),

            // Cycle counter
            if (_isStarted && !_isComplete)
              Text(
                'Cycle $_currentCycle of ${widget.exercise.cycles}',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),

            const Spacer(),

            // Bottom action
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: _isComplete
                    ? FilledButton(
                        onPressed: () => Navigator.pop(context),
                        style: FilledButton.styleFrom(backgroundColor: color),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('Done'),
                        ),
                      )
                    : OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('Cancel'),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreathPhase {
  final String name;
  final int seconds;
  final bool animates;

  const _BreathPhase(this.name, this.seconds, this.animates);
}
