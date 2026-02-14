import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding_v2';
  static const String _hasSeenFeatureKey = 'has_seen_feature_';

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  static Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, true);
  }

  static Future<bool> hasSeenFeature(String featureId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_hasSeenFeatureKey$featureId') ?? false;
  }

  static Future<void> markFeatureSeen(String featureId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_hasSeenFeatureKey$featureId', true);
  }

  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, false);
  }
}

/// Welcome dialog shown to first-time users
class WelcomeDialog extends StatefulWidget {
  const WelcomeDialog({super.key});

  static Future<void> showIfNeeded(BuildContext context) async {
    final hasSeen = await OnboardingService.hasSeenOnboarding();
    if (!hasSeen && context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const WelcomeDialog(),
      );
    }
  }

  @override
  State<WelcomeDialog> createState() => _WelcomeDialogState();
}

class _WelcomeDialogState extends State<WelcomeDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.timer_outlined,
      color: Colors.red,
      title: 'Welcome to Pomodoro Timer! 🍅',
      description: 'A productivity app based on the Pomodoro Technique - work in focused intervals with regular breaks to maximize your efficiency.',
      tips: [
        'Work for 25 minutes (1 Pomodoro)',
        'Take a 5-minute short break',
        'After 4 pomodoros, take a longer break',
      ],
    ),
    OnboardingPage(
      icon: Icons.touch_app_outlined,
      color: Colors.blue,
      title: 'Easy to Use',
      description: 'The main screen shows your timer. Just tap Start to begin a focus session!',
      tips: [
        'Tap the timer mode buttons to switch between Focus, Short Break, and Long Break',
        'Use keyboard shortcuts for quick control (Space to start/pause)',
        'Look for ⓘ icons for helpful explanations',
      ],
    ),
    OnboardingPage(
      icon: Icons.dashboard_outlined,
      color: Colors.green,
      title: 'Track Your Progress',
      description: 'Monitor your productivity with detailed statistics and focus scores.',
      tips: [
        'View your daily, weekly, and monthly stats',
        'Track your focus score and streak',
        'Set daily goals to stay motivated',
      ],
    ),
    OnboardingPage(
      icon: Icons.music_note_outlined,
      color: Colors.purple,
      title: 'Customize Your Experience',
      description: 'Make the app work for you with customizable settings.',
      tips: [
        'Adjust timer durations in Settings',
        'Enable ambient sounds for better focus',
        'Create quick-start presets for different activities',
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  void _complete() {
    OnboardingService.markOnboardingComplete();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _buildPage(page, isDark);
                },
              ),
            ),

            // Page indicator and buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  // Page dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? _pages[index].color
                              : (isDark ? Colors.grey[600] : Colors.grey[400]),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Buttons
                  Row(
                    children: [
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Text('Back'),
                        ),
                      const Spacer(),
                      if (_currentPage < _pages.length - 1)
                        TextButton(
                          onPressed: _complete,
                          child: const Text('Skip'),
                        ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _nextPage,
                        icon: Icon(
                          _currentPage == _pages.length - 1
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                        label: Text(
                          _currentPage == _pages.length - 1 ? "Let's Go!" : 'Next',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 48,
              color: page.color,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            page.description,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ...page.tips.map((tip) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: page.color,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tip,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final List<String> tips;

  const OnboardingPage({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.tips,
  });
}

/// Feature highlight tooltip that appears once for new features
class FeatureHighlight extends StatefulWidget {
  final String featureId;
  final String title;
  final String description;
  final Widget child;
  final VoidCallback? onDismiss;

  const FeatureHighlight({
    super.key,
    required this.featureId,
    required this.title,
    required this.description,
    required this.child,
    this.onDismiss,
  });

  @override
  State<FeatureHighlight> createState() => _FeatureHighlightState();
}

class _FeatureHighlightState extends State<FeatureHighlight> {
  bool _showHighlight = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _checkIfShouldShow();
  }

  Future<void> _checkIfShouldShow() async {
    final hasSeen = await OnboardingService.hasSeenFeature(widget.featureId);
    if (!hasSeen && mounted) {
      setState(() => _showHighlight = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOverlay();
      });
    }
  }

  void _showOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => _HighlightOverlay(
        layerLink: _layerLink,
        title: widget.title,
        description: widget.description,
        onDismiss: _dismiss,
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    OnboardingService.markFeatureSeen(widget.featureId);
    setState(() => _showHighlight = false);
    widget.onDismiss?.call();
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: _showHighlight
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              )
            : null,
        child: widget.child,
      ),
    );
  }
}

class _HighlightOverlay extends StatelessWidget {
  final LayerLink layerLink;
  final String title;
  final String description;
  final VoidCallback onDismiss;

  const _HighlightOverlay({
    required this.layerLink,
    required this.title,
    required this.description,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent background
        GestureDetector(
          onTap: onDismiss,
          child: Container(
            color: Colors.black54,
          ),
        ),
        // Tooltip
        CompositedTransformFollower(
          link: layerLink,
          offset: const Offset(0, 50),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.new_releases, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onDismiss,
                      child: const Text('Got it'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
