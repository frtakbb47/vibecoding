import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/focus_score_service.dart';

class FocusScoreCard extends StatefulWidget {
  final bool compact;

  const FocusScoreCard({super.key, this.compact = false});

  @override
  State<FocusScoreCard> createState() => _FocusScoreCardState();
}

class _FocusScoreCardState extends State<FocusScoreCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scoreAnimation;
  late FocusScoreData _scoreData;

  @override
  void initState() {
    super.initState();
    _scoreData = FocusScoreService.calculateFocusScore();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scoreAnimation = Tween<double>(
      begin: 0,
      end: _scoreData.overallScore.toDouble(),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return const Color(0xFF4CAF50);
    if (score >= 60) return const Color(0xFF8BC34A);
    if (score >= 40) return const Color(0xFFFFEB3B);
    if (score >= 20) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  IconData _getTrendIcon(ScoreTrend trend) {
    switch (trend) {
      case ScoreTrend.improving:
        return Icons.trending_up;
      case ScoreTrend.declining:
        return Icons.trending_down;
      case ScoreTrend.neutral:
        return Icons.trending_flat;
    }
  }

  Color _getTrendColor(ScoreTrend trend) {
    switch (trend) {
      case ScoreTrend.improving:
        return Colors.green;
      case ScoreTrend.declining:
        return Colors.red;
      case ScoreTrend.neutral:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return _buildCompactCard(context);
    }
    return _buildFullCard(context);
  }

  Widget _buildCompactCard(BuildContext context) {
    final scoreColor = _getScoreColor(_scoreData.overallScore);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scoreColor.withOpacity(0.1),
              scoreColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Row(
          children: [
            // Circular score
            SizedBox(
              width: 60,
              height: 60,
              child: AnimatedBuilder(
                animation: _scoreAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _CircularScorePainter(
                      score: _scoreAnimation.value / 100,
                      color: scoreColor,
                    ),
                    child: Center(
                      child: Text(
                        '${_scoreAnimation.value.round()}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            // Score info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Focus Score',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _getTrendIcon(_scoreData.trend),
                        size: 18,
                        color: _getTrendColor(_scoreData.trend),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _scoreData.level.emoji,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _scoreData.level.title,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Next milestone
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${_scoreData.nextMilestone}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullCard(BuildContext context) {
    final scoreColor = _getScoreColor(_scoreData.overallScore);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scoreColor.withOpacity(0.15),
              scoreColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🎯 Focus Score',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTrendColor(_scoreData.trend).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTrendIcon(_scoreData.trend),
                        size: 16,
                        color: _getTrendColor(_scoreData.trend),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _scoreData.trend == ScoreTrend.improving
                            ? 'Improving'
                            : _scoreData.trend == ScoreTrend.declining
                                ? 'Declining'
                                : 'Stable',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getTrendColor(_scoreData.trend),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Score display
            Row(
              children: [
                // Large score circle
                SizedBox(
                  width: 120,
                  height: 120,
                  child: AnimatedBuilder(
                    animation: _scoreAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _CircularScorePainter(
                          score: _scoreAnimation.value / 100,
                          color: scoreColor,
                          strokeWidth: 10,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_scoreAnimation.value.round()}',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: scoreColor,
                                ),
                              ),
                              Text(
                                'of 100',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 24),

                // Score breakdown
                Expanded(
                  child: Column(
                    children: [
                      _buildScoreRow('Completion', _scoreData.completionScore, 30, Colors.blue),
                      const SizedBox(height: 8),
                      _buildScoreRow('Consistency', _scoreData.consistencyScore, 25, Colors.green),
                      const SizedBox(height: 8),
                      _buildScoreRow('Duration', _scoreData.durationScore, 25, Colors.purple),
                      const SizedBox(height: 8),
                      _buildScoreRow('Streak Bonus', _scoreData.streakBonus, 20, Colors.orange),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Level badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scoreColor.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _scoreData.level.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_scoreData.level.title} Level',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Next: ${_scoreData.nextMilestone}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Insights
            if (_scoreData.insights.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '💡 Insights',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...(_scoreData.insights.take(2).map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  insight,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, int value, int max, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / max,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _CircularScorePainter extends CustomPainter {
  final double score;
  final Color color;
  final double strokeWidth;

  _CircularScorePainter({
    required this.score,
    required this.color,
    this.strokeWidth = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (score > 0) {
      final progressPaint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * score,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircularScorePainter oldDelegate) {
    return oldDelegate.score != score;
  }
}
