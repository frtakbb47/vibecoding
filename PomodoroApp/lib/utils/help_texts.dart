/// Help text constants for tooltips and info dialogs
class HelpTexts {
  // Timer Settings
  static const workDuration = HelpContent(
    title: 'Focus Duration',
    message: 'How long each focus session lasts. The classic Pomodoro technique uses 25 minutes, but you can adjust this to fit your needs.',
    tips: [
      'Start with 25 minutes if you\'re new',
      'Increase to 45-50 minutes for deep work',
      'Decrease to 15-20 minutes if you struggle to focus',
    ],
  );

  static const shortBreak = HelpContent(
    title: 'Short Break',
    message: 'A brief rest between focus sessions. Use this time to stretch, grab water, or rest your eyes.',
    tips: [
      '5 minutes is the classic recommendation',
      'Don\'t skip breaks - they help maintain focus',
      'Step away from your screen during breaks',
    ],
  );

  static const longBreak = HelpContent(
    title: 'Long Break',
    message: 'A longer rest after completing several focus sessions. This helps prevent burnout and refreshes your mind.',
    tips: [
      'Take a walk or do light exercise',
      'Have a healthy snack',
      'Avoid checking social media',
    ],
  );

  static const autoStartBreaks = HelpContent(
    title: 'Auto-Start Breaks',
    message: 'Automatically start the break timer when a focus session ends. Keeps your workflow seamless.',
    tips: [
      'Enable this to maintain momentum',
      'Disable if you need flexibility between sessions',
    ],
  );

  static const autoStartPomodoros = HelpContent(
    title: 'Auto-Start Focus',
    message: 'Automatically start the next focus session when a break ends.',
    tips: [
      'Great for maintaining flow state',
      'Disable if you need to check tasks between sessions',
    ],
  );

  static const sessionsBeforeLongBreak = HelpContent(
    title: 'Sessions Before Long Break',
    message: 'How many focus sessions to complete before taking a long break. The classic method uses 4 sessions.',
    tips: [
      '4 sessions is the traditional recommendation',
      'Adjust based on your stamina',
      'More sessions = longer deep work periods',
    ],
  );

  static const dailyGoal = HelpContent(
    title: 'Daily Goal',
    message: 'Your target number of focus sessions per day. Setting a goal helps track progress and stay motivated.',
    tips: [
      '8 sessions ≈ 4 hours of focused work',
      'Start with a realistic goal and increase over time',
      'Quality matters more than quantity',
    ],
  );

  // Sound Settings
  static const notifications = HelpContent(
    title: 'Notifications',
    message: 'Show system notifications when sessions start and end. Useful when the app is in the background.',
    tips: [
      'Enable if you work with multiple windows',
      'Disable if notifications distract you',
    ],
  );

  static const sounds = HelpContent(
    title: 'Sound Effects',
    message: 'Play audio cues when sessions start, end, or during the timer. Helps you stay aware without watching the screen.',
    tips: [
      'Use headphones for best experience',
      'Adjust volume based on your environment',
    ],
  );

  static const tickingSound = HelpContent(
    title: 'Ticking Sound',
    message: 'Play a clock ticking sound during focus sessions. Some find this helps maintain awareness of time passing.',
    tips: [
      'Can help create a sense of urgency',
      'Disable if you find it distracting',
      'Works well with ambient sounds',
    ],
  );

  static const ambientSounds = HelpContent(
    title: 'Background Sounds',
    message: 'Play ambient sounds during focus sessions to help block distractions and create a productive atmosphere.',
    tips: [
      'Rain sounds are popular for focus',
      'Café noise simulates a coffee shop environment',
      'White noise blocks sudden sounds',
    ],
  );

  // Timer Modes
  static const focusMode = HelpContent(
    title: 'Focus Mode 🎯',
    message: 'Your dedicated work time. During this period, focus on a single task without interruptions.',
    tips: [
      'Turn off phone notifications',
      'Close unnecessary browser tabs',
      'Have water nearby to stay hydrated',
    ],
  );

  static const shortBreakMode = HelpContent(
    title: 'Short Break ☕',
    message: 'A quick rest to recharge between focus sessions. Stand up, stretch, and rest your eyes.',
    tips: [
      'Look at something 20 feet away for 20 seconds',
      'Do some quick stretches',
      'Don\'t start new tasks during breaks',
    ],
  );

  static const longBreakMode = HelpContent(
    title: 'Long Break 🏖️',
    message: 'An extended rest after several focus sessions. Use this time to fully disconnect and recharge.',
    tips: [
      'Take a short walk',
      'Have a nutritious snack',
      'Do a quick meditation',
    ],
  );

  // Features
  static const focusScore = HelpContent(
    title: 'Focus Score',
    message: 'A daily score (0-100) measuring your productivity. Based on completed sessions, consistency, and time spent focused.',
    tips: [
      '90+ = Excellent focus day',
      '70-89 = Good productivity',
      'Score resets each day',
    ],
  );

  static const streak = HelpContent(
    title: 'Focus Streak 🔥',
    message: 'The number of consecutive days you\'ve completed at least one focus session. Building a streak helps form habits.',
    tips: [
      'Complete at least 1 session daily to maintain',
      'Longer streaks = stronger habits',
      'Don\'t break the chain!',
    ],
  );

  static const sessionProgress = HelpContent(
    title: 'Session Progress',
    message: 'Shows how many focus sessions you\'ve completed toward your daily goal. Each circle represents one session.',
    tips: [
      'Filled circles = completed sessions',
      'Empty circles = remaining for goal',
      'Long break triggers after set number of sessions',
    ],
  );

  static const presets = HelpContent(
    title: 'Quick Start Presets',
    message: 'Pre-configured timer settings for different activities. Quickly switch between work styles.',
    tips: [
      'Create custom presets for different tasks',
      'Use "Deep Work" for complex tasks',
      'Use "Quick Focus" for small tasks',
    ],
  );

  static const tasks = HelpContent(
    title: 'Task Management',
    message: 'Organize your work into tasks. Associate focus sessions with specific tasks to track time spent on each.',
    tips: [
      'Break large projects into smaller tasks',
      'Mark tasks as complete when done',
      'Review completed tasks weekly',
    ],
  );

  static const statistics = HelpContent(
    title: 'Statistics',
    message: 'View detailed analytics about your productivity over time. Track daily, weekly, and monthly trends.',
    tips: [
      'Look for patterns in your productivity',
      'Identify your most productive days/times',
      'Use insights to optimize your schedule',
    ],
  );

  // Keyboard Shortcuts
  static const keyboardShortcuts = HelpContent(
    title: 'Keyboard Shortcuts',
    message: 'Control the timer without using the mouse. Great for efficiency!',
    tips: [
      'Space - Start/Pause timer',
      'R - Reset timer',
      'S - Skip current session',
      'Escape - Stop timer',
    ],
  );
}

class HelpContent {
  final String title;
  final String message;
  final List<String> tips;

  const HelpContent({
    required this.title,
    required this.message,
    this.tips = const [],
  });
}
