import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A visually stunning share card for completed Pomodoro sessions.
/// This widget is designed to be captured as an image for sharing on social media.
/// Uses a 9:16 aspect ratio (Instagram Story format).
class SessionShareCard extends StatelessWidget {
  /// Duration of the session in minutes
  final int durationMinutes;

  /// Task name or focus category (e.g., "Deep Work", "Study Session")
  final String taskName;

  /// Current day streak count
  final int currentStreak;

  /// Total sessions completed today
  final int todaySessions;

  /// Optional: Overtime minutes if user was in flow mode
  final int? overtimeMinutes;

  const SessionShareCard({
    super.key,
    required this.durationMinutes,
    required this.taskName,
    required this.currentStreak,
    this.todaySessions = 1,
    this.overtimeMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 9 / 16, // Instagram Story format
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E), // Midnight blue
              Color(0xFF16213E), // Dark blue
              Color(0xFF0F3460), // Deep blue
              Color(0xFF533483), // Purple accent
            ],
            stops: [0.0, 0.35, 0.65, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Geometric pattern overlay
            _buildGeometricPattern(),

            // Main content
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 1),

                  // Duration - Hero element
                  _buildDurationDisplay(),

                  const SizedBox(height: 24),

                  // Task name
                  _buildTaskName(),

                  const SizedBox(height: 32),

                  // Stats row (Streak & Sessions)
                  _buildStatsRow(),

                  // Overtime badge if applicable
                  if (overtimeMinutes != null && overtimeMinutes! > 0) ...[
                    const SizedBox(height: 24),
                    _buildOvertimeBadge(),
                  ],

                  const Spacer(flex: 2),

                  // Footer with app branding
                  _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeometricPattern() {
    return CustomPaint(
      painter: _GeometricPatternPainter(),
      size: Size.infinite,
    );
  }

  Widget _buildDurationDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Small label
        Text(
          'FOCUSED FOR',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 8),
        // Big duration
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$durationMinutes',
              style: const TextStyle(
                fontSize: 96,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'MIN',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskName() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        taskName,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        // Streak
        _buildStatItem(
          emoji: '🔥',
          value: '$currentStreak',
          label: 'Day Streak',
          accentColor: const Color(0xFFFF6B6B),
        ),
        const SizedBox(width: 24),
        // Today's sessions
        _buildStatItem(
          emoji: '✅',
          value: '$todaySessions',
          label: 'Today',
          accentColor: const Color(0xFF4ECDC4),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String emoji,
    required String value,
    required String label,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withOpacity(0.3),
            accentColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOvertimeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD93D), Color(0xFFFF6B6B)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD93D).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            'FLOW MODE: +$overtimeMinutes min',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        // App icon placeholder (can be replaced with actual icon)
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE74C3C),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text(
              '🍅',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verified by',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.5),
                letterSpacing: 1,
              ),
            ),
            const Text(
              'Pomodoro Timer',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Date
        Text(
          _formatDate(DateTime.now()),
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

/// Custom painter for geometric background pattern
class _GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw subtle circles
    for (int i = 0; i < 5; i++) {
      final radius = 50.0 + (i * 80);
      final opacity = 0.03 - (i * 0.005);
      paint.color = Colors.white.withOpacity(opacity.clamp(0.01, 0.05));

      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.2),
        radius,
        paint,
      );
    }

    // Draw diagonal lines
    paint.color = Colors.white.withOpacity(0.02);
    for (int i = 0; i < 10; i++) {
      final startY = size.height * (i * 0.15);
      canvas.drawLine(
        Offset(0, startY),
        Offset(size.width * 0.4, startY + size.height * 0.3),
        paint,
      );
    }

    // Draw decorative dots
    paint.style = PaintingStyle.fill;
    paint.color = Colors.white.withOpacity(0.05);
    final random = math.Random(42); // Fixed seed for consistency
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final dotSize = 1.0 + random.nextDouble() * 2;
      canvas.drawCircle(Offset(x, y), dotSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
