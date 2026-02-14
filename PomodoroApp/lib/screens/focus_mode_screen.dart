import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../services/motivational_quotes_service.dart';

class FocusModeScreen extends StatefulWidget {
  final int initialMinutes;
  final String? taskName;
  final String? category;

  const FocusModeScreen({
    super.key,
    this.initialMinutes = 25,
    this.taskName,
    this.category,
  });

  @override
  State<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends State<FocusModeScreen>
    with TickerProviderStateMixin {
  late int _remainingSeconds;
  late int _totalSeconds;
  Timer? _timer;
  bool _isRunning = false;
  bool _isCompleted = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Quote _currentQuote;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.initialMinutes * 60;
    _remainingSeconds = _totalSeconds;
    _currentQuote = MotivationalQuotesService.getRandomQuote();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Enter immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    // Exit immersive mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _completeSession();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _totalSeconds;
      _isCompleted = false;
    });
  }

  void _completeSession() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isCompleted = true;
    });
    HapticFeedback.heavyImpact();
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (_remainingSeconds / _totalSeconds);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFF1a1a2e),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            if (!_isCompleted) {
              if (_isRunning) {
                _pauseTimer();
              } else {
                _startTimer();
              }
            }
          },
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent,
            child: _isCompleted
                ? _buildCompletedView(context)
                : _buildTimerView(context, progress),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerView(BuildContext context, double progress) {
    return Column(
      children: [
        // Top bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _showExitConfirmation(context),
                icon: const Icon(Icons.close, color: Colors.white54),
              ),
              if (widget.category != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.category!,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              IconButton(
                onPressed: _resetTimer,
                icon: const Icon(Icons.refresh, color: Colors.white54),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Task name
        if (widget.taskName != null) ...[
          Text(
            widget.taskName!,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Timer display
        ScaleTransition(
          scale: _isRunning ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 280,
                height: 280,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(
                    _isRunning ? Colors.greenAccent : Colors.white38,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(_remainingSeconds),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.w200,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isRunning ? 'FOCUSING' : 'TAP TO START',
                    style: TextStyle(
                      color: _isRunning ? Colors.greenAccent : Colors.white54,
                      fontSize: 14,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const Spacer(),

        // Quote
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Text(
                '"${_currentQuote.text}"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '— ${_currentQuote.author}',
                style: const TextStyle(
                  color: Colors.white24,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(
              icon: Icons.remove_circle_outline,
              onTap: () {
                if (_remainingSeconds > 60) {
                  setState(() => _remainingSeconds -= 60);
                }
              },
            ),
            const SizedBox(width: 24),
            _buildControlButton(
              icon: _isRunning ? Icons.pause : Icons.play_arrow,
              size: 64,
              onTap: _isRunning ? _pauseTimer : _startTimer,
              isPrimary: true,
            ),
            const SizedBox(width: 24),
            _buildControlButton(
              icon: Icons.add_circle_outline,
              onTap: () {
                setState(() => _remainingSeconds += 60);
              },
            ),
          ],
        ),

        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildCompletedView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '🎉',
          style: TextStyle(fontSize: 80),
        ),
        const SizedBox(height: 24),
        const Text(
          'Session Complete!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You focused for ${widget.initialMinutes} minutes',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                _resetTimer();
              },
              icon: const Icon(Icons.replay),
              label: const Text('Again'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.check),
              label: const Text('Done'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    double size = 48,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isPrimary ? Colors.greenAccent : Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isPrimary ? Colors.black : Colors.white54,
          size: size * 0.5,
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    if (!_isRunning && _remainingSeconds == _totalSeconds) {
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Focus Mode?'),
        content: const Text('Your current session will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close focus mode
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
