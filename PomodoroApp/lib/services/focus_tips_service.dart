import 'dart:math';

class FocusTip {
  final String title;
  final String content;
  final String category; // 'study', 'work', 'health', 'productivity'
  final String emoji;

  const FocusTip({
    required this.title,
    required this.content,
    required this.category,
    required this.emoji,
  });
}

class FocusTipsService {
  static final Random _random = Random();

  static const List<FocusTip> studyTips = [
    FocusTip(
      title: 'Active Recall',
      content: 'Test yourself on the material instead of just re-reading. This strengthens memory pathways.',
      category: 'study',
      emoji: '🧠',
    ),
    FocusTip(
      title: 'Spaced Repetition',
      content: 'Review material at increasing intervals to move knowledge into long-term memory.',
      category: 'study',
      emoji: '📅',
    ),
    FocusTip(
      title: 'Teach What You Learn',
      content: 'Explaining concepts to others (or yourself) helps identify gaps in understanding.',
      category: 'study',
      emoji: '👨‍🏫',
    ),
    FocusTip(
      title: 'Interleaving',
      content: 'Mix different topics or problem types during study sessions for better retention.',
      category: 'study',
      emoji: '🔀',
    ),
    FocusTip(
      title: 'Mind Mapping',
      content: 'Create visual diagrams connecting ideas to improve understanding and recall.',
      category: 'study',
      emoji: '🗺️',
    ),
    FocusTip(
      title: 'The Feynman Technique',
      content: 'Explain complex topics in simple terms. If you can\'t, you need to study more.',
      category: 'study',
      emoji: '💡',
    ),
    FocusTip(
      title: 'Study Environment',
      content: 'Find a consistent, distraction-free study space. Your brain will associate it with focus.',
      category: 'study',
      emoji: '📚',
    ),
    FocusTip(
      title: 'Start with the Hardest',
      content: 'Tackle difficult subjects first when your mental energy is highest.',
      category: 'study',
      emoji: '⚡',
    ),
  ];

  static const List<FocusTip> workTips = [
    FocusTip(
      title: 'Eat the Frog',
      content: 'Do your most challenging or important task first thing in the morning.',
      category: 'work',
      emoji: '🐸',
    ),
    FocusTip(
      title: 'Time Blocking',
      content: 'Schedule specific blocks of time for different types of tasks.',
      category: 'work',
      emoji: '📊',
    ),
    FocusTip(
      title: 'Two-Minute Rule',
      content: 'If a task takes less than 2 minutes, do it immediately.',
      category: 'work',
      emoji: '⏱️',
    ),
    FocusTip(
      title: 'Batch Similar Tasks',
      content: 'Group similar tasks together to reduce context switching.',
      category: 'work',
      emoji: '📦',
    ),
    FocusTip(
      title: 'Single-Tasking',
      content: 'Focus on one task at a time. Multitasking reduces productivity by up to 40%.',
      category: 'work',
      emoji: '🎯',
    ),
    FocusTip(
      title: 'Email Batching',
      content: 'Check email at set times instead of constantly. This protects your focus.',
      category: 'work',
      emoji: '📧',
    ),
    FocusTip(
      title: 'Weekly Review',
      content: 'End each week by reviewing what you accomplished and planning the next week.',
      category: 'work',
      emoji: '📝',
    ),
    FocusTip(
      title: 'Clear Your Desk',
      content: 'A clutter-free workspace reduces mental load and helps maintain focus.',
      category: 'work',
      emoji: '🧹',
    ),
  ];

  static const List<FocusTip> healthTips = [
    FocusTip(
      title: '20-20-20 Rule',
      content: 'Every 20 minutes, look at something 20 feet away for 20 seconds to reduce eye strain.',
      category: 'health',
      emoji: '👁️',
    ),
    FocusTip(
      title: 'Stay Hydrated',
      content: 'Drink water regularly. Even mild dehydration can affect concentration.',
      category: 'health',
      emoji: '💧',
    ),
    FocusTip(
      title: 'Movement Breaks',
      content: 'Stand up and stretch every 30-60 minutes to maintain energy and focus.',
      category: 'health',
      emoji: '🏃',
    ),
    FocusTip(
      title: 'Proper Posture',
      content: 'Sit with your back straight, feet flat, and screen at eye level.',
      category: 'health',
      emoji: '🪑',
    ),
    FocusTip(
      title: 'Quality Sleep',
      content: '7-9 hours of sleep is essential for memory consolidation and focus.',
      category: 'health',
      emoji: '😴',
    ),
    FocusTip(
      title: 'Brain Food',
      content: 'Eat nuts, berries, and fish rich in omega-3 to boost brain function.',
      category: 'health',
      emoji: '🥜',
    ),
    FocusTip(
      title: 'Deep Breathing',
      content: 'Take 5 deep breaths when stressed. This activates your parasympathetic nervous system.',
      category: 'health',
      emoji: '🧘',
    ),
    FocusTip(
      title: 'Natural Light',
      content: 'Exposure to natural light improves mood and helps regulate your circadian rhythm.',
      category: 'health',
      emoji: '☀️',
    ),
  ];

  static const List<FocusTip> productivityTips = [
    FocusTip(
      title: 'Phone-Free Focus',
      content: 'Put your phone in another room during focus sessions. Out of sight, out of mind.',
      category: 'productivity',
      emoji: '📵',
    ),
    FocusTip(
      title: 'Morning Routine',
      content: 'Start your day with a consistent routine to build momentum.',
      category: 'productivity',
      emoji: '🌅',
    ),
    FocusTip(
      title: 'Know Your Peak Hours',
      content: 'Schedule important work during your natural high-energy periods.',
      category: 'productivity',
      emoji: '⏰',
    ),
    FocusTip(
      title: 'Break Down Big Tasks',
      content: 'Large projects feel less overwhelming when split into smaller steps.',
      category: 'productivity',
      emoji: '🧩',
    ),
    FocusTip(
      title: 'Use Deadlines',
      content: 'Self-imposed deadlines create urgency and help avoid procrastination.',
      category: 'productivity',
      emoji: '⏳',
    ),
    FocusTip(
      title: 'Reward Yourself',
      content: 'Celebrate completing focus sessions with small rewards to build positive habits.',
      category: 'productivity',
      emoji: '🎁',
    ),
    FocusTip(
      title: 'Start Imperfectly',
      content: 'Don\'t wait for perfect conditions. Starting is often the hardest part.',
      category: 'productivity',
      emoji: '🚀',
    ),
    FocusTip(
      title: 'Track Your Progress',
      content: 'Seeing your completed sessions and streaks builds motivation.',
      category: 'productivity',
      emoji: '📈',
    ),
  ];

  static FocusTip getRandomTip() {
    final allTips = [...studyTips, ...workTips, ...healthTips, ...productivityTips];
    return allTips[_random.nextInt(allTips.length)];
  }

  static FocusTip getRandomStudyTip() {
    return studyTips[_random.nextInt(studyTips.length)];
  }

  static FocusTip getRandomWorkTip() {
    return workTips[_random.nextInt(workTips.length)];
  }

  static FocusTip getRandomHealthTip() {
    return healthTips[_random.nextInt(healthTips.length)];
  }

  static FocusTip getRandomProductivityTip() {
    return productivityTips[_random.nextInt(productivityTips.length)];
  }

  static FocusTip getTipForBreak(bool isLongBreak) {
    if (isLongBreak) {
      // During long breaks, give health or productivity tips
      final tips = [...healthTips, ...productivityTips];
      return tips[_random.nextInt(tips.length)];
    } else {
      // During short breaks, give quick health tips
      return healthTips[_random.nextInt(healthTips.length)];
    }
  }
}
