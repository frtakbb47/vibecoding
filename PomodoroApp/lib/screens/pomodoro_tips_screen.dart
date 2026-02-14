import 'package:flutter/material.dart';

class TipItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const TipItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class PomodoroTipsScreen extends StatelessWidget {
  const PomodoroTipsScreen({super.key});

  static const List<TipItem> _tips = [
    TipItem(
      title: 'Start with a Clear Goal',
      description: 'Before starting a Pomodoro, define exactly what you want to accomplish. Write it down to stay focused and measure progress.',
      icon: Icons.flag,
      color: Colors.green,
    ),
    TipItem(
      title: 'Eliminate Distractions',
      description: 'Put your phone on silent, close unnecessary tabs, and let others know you\'re in focus mode. A distraction-free environment is key.',
      icon: Icons.do_not_disturb,
      color: Colors.red,
    ),
    TipItem(
      title: 'Take Real Breaks',
      description: 'During breaks, step away from your screen. Stretch, walk, hydrate, or look out the window. Your brain needs genuine rest.',
      icon: Icons.coffee,
      color: Colors.brown,
    ),
    TipItem(
      title: 'Track Your Progress',
      description: 'Keep a log of completed Pomodoros. This helps you understand your productivity patterns and motivates you to maintain streaks.',
      icon: Icons.analytics,
      color: Colors.blue,
    ),
    TipItem(
      title: 'Adjust Timer Length',
      description: 'The traditional 25/5 split works for many, but experiment! Some people focus better with 50/10 or 15/3 intervals.',
      icon: Icons.tune,
      color: Colors.purple,
    ),
    TipItem(
      title: 'Plan Your Day in Pomodoros',
      description: 'Estimate how many Pomodoros each task will take. This helps with time management and sets realistic expectations.',
      icon: Icons.schedule,
      color: Colors.orange,
    ),
    TipItem(
      title: 'Handle Interruptions',
      description: 'If interrupted, note the distraction and return to focus. Use the "Inform, Negotiate, Call Back" strategy for external interruptions.',
      icon: Icons.warning,
      color: Colors.amber,
    ),
    TipItem(
      title: 'Group Small Tasks',
      description: 'Combine small tasks (emails, quick calls) into a single Pomodoro instead of giving each one its own session.',
      icon: Icons.apps,
      color: Colors.teal,
    ),
    TipItem(
      title: 'Respect the Timer',
      description: 'When the timer rings, stop. Even mid-sentence. This trains your brain to work efficiently within time constraints.',
      icon: Icons.timer,
      color: Colors.indigo,
    ),
    TipItem(
      title: 'Review and Reflect',
      description: 'At the end of the day, review your completed Pomodoros. What worked? What didn\'t? Use insights to improve tomorrow.',
      icon: Icons.rate_review,
      color: Colors.cyan,
    ),
    TipItem(
      title: 'Stay Hydrated',
      description: 'Keep water nearby and drink during breaks. Dehydration affects concentration and energy levels.',
      icon: Icons.water_drop,
      color: Colors.lightBlue,
    ),
    TipItem(
      title: 'Use Longer Breaks Wisely',
      description: 'After 4 Pomodoros, take a 15-30 minute break. Use this time for a short walk, snack, or something refreshing.',
      icon: Icons.self_improvement,
      color: Colors.pink,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Technique Tips'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lightbulb,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Master the Pomodoro Technique',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Learn these tips to maximize your productivity and make the most of your focus sessions.',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tips List
          ...List.generate(_tips.length, (index) {
            final tip = _tips[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TipCard(tip: tip, index: index + 1),
            );
          }),

          // Quick Reference Card
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Quick Reference',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _buildReferenceItem(
                    context,
                    '🍅',
                    'Work Session',
                    '25 minutes of focused work',
                  ),
                  _buildReferenceItem(
                    context,
                    '☕',
                    'Short Break',
                    '5 minutes rest',
                  ),
                  _buildReferenceItem(
                    context,
                    '🌴',
                    'Long Break',
                    '15-30 minutes after 4 sessions',
                  ),
                  _buildReferenceItem(
                    context,
                    '🎯',
                    'Daily Goal',
                    '8-12 Pomodoros for most people',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildReferenceItem(
    BuildContext context,
    String emoji,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final TipItem tip;
  final int index;

  const _TipCard({required this.tip, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: InkWell(
        onTap: () {
          _showTipDetail(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: tip.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  tip.icon,
                  color: tip.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: tip.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '#$index',
                            style: TextStyle(
                              color: tip.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tip.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tip.description,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTipDetail(BuildContext context) {
    final theme = Theme.of(context);

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
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: tip.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                tip.icon,
                color: tip.color,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tip #$index',
              style: TextStyle(
                color: tip.color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tip.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              tip.description,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 16,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it!'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
