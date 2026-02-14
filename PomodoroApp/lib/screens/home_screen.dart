import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/timer_display.dart';
import '../widgets/control_buttons.dart';
import '../widgets/session_progress.dart';
import '../widgets/quick_task_list.dart';
import '../widgets/break_suggestion.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/sound_mixer_sheet.dart';
import '../services/onboarding_service.dart';
import '../l10n/app_localizations.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';
import 'tasks_screen.dart';
import 'presets_screen.dart';
import 'focus_dashboard_screen.dart';
import 'focus_store_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // Zen Mode animation
  late AnimationController _zenAnimationController;
  late Animation<double> _zenFadeAnimation;

  // Keyboard shortcuts
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Setup Zen Mode animation
    _zenAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _zenFadeAnimation = CurvedAnimation(
      parent: _zenAnimationController,
      curve: Curves.easeInOut,
    );

    // Show welcome dialog for first-time users
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WelcomeDialog.showIfNeeded(context);
    });
  }

  @override
  void dispose() {
    _zenAnimationController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  String _getTypeLabel(BuildContext context, String currentType) {
    final l10n = AppLocalizations.of(context);
    switch (currentType) {
      case 'work':
        return l10n.focusTime;
      case 'short_break':
        return l10n.shortBreakDuration;
      case 'long_break':
        return l10n.longBreakDuration;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, timer, _) {
        // Update Zen Mode animation based on timer state
        if (timer.isZenMode) {
          _zenAnimationController.forward();
        } else {
          _zenAnimationController.reverse();
        }

        return KeyboardListener(
          focusNode: _keyboardFocusNode,
          autofocus: true,
          onKeyEvent: (event) => _handleKeyPress(event, timer),
          child: ResponsiveLayout(
            mobileBody: _buildMobileLayout(context, timer),
            desktopBody: _buildDesktopLayout(context, timer),
          ),
        );
      },
    );
  }

  /// Handle keyboard shortcuts
  void _handleKeyPress(KeyEvent event, TimerProvider timer) {
    if (event is! KeyDownEvent) return;

    final settings = Provider.of<SettingsProvider>(context, listen: false).settings;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.space:
        // Space: Toggle Start/Pause
        if (timer.state == TimerState.idle) {
          timer.start(durationMinutes: settings.workDuration);
        } else if (timer.state == TimerState.running) {
          timer.pause();
        } else if (timer.state == TimerState.paused) {
          timer.resume();
        }
        break;
      case LogicalKeyboardKey.keyS:
        // S: Skip current phase
        if (timer.state != TimerState.idle) {
          timer.skip();
        }
        break;
      case LogicalKeyboardKey.keyR:
        // R: Reset timer
        if (timer.state != TimerState.idle) {
          timer.reset();
        }
        break;
    }
  }

  /// Mobile layout with Zen Mode support
  Widget _buildMobileLayout(BuildContext context, TimerProvider timer) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return GestureDetector(
      // Tap anywhere to temporarily show UI when in Zen Mode
      onTap: timer.isZenMode ? () => timer.showUITemporarily() : null,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        appBar: _buildAppBar(context, timer),
        body: SafeArea(
          child: Stack(
            children: [
              // Main content
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Timer is always visible
                    const TimerDisplay(),
                    const SizedBox(height: 32),
                    const ControlButtons(),
                    const SizedBox(height: 32),
                    // Session progress with Zen Mode fade
                    _buildZenFadeWidget(const SessionProgress()),
                    const SizedBox(height: 16),
                    // Break suggestion with Zen Mode fade
                    _buildZenFadeWidget(
                      _buildBreakSuggestion(timer),
                    ),
                    const SizedBox(height: 20),
                    // Task list with Zen Mode fade - improved styling
                    _buildZenFadeWidget(
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.task_alt_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.tasks,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const TasksScreen()),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text('View All'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const QuickTaskList(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
              // Zen Mode indicator
              if (timer.isZenMode)
                Positioned(
                  bottom: 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: timer.isZenMode ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '👆 Tap to show controls',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Desktop layout - now uses centered single column for better appearance
  Widget _buildDesktopLayout(BuildContext context, TimerProvider timer) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: timer.isZenMode ? () => timer.showUITemporarily() : null,
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        appBar: _buildAppBar(context, timer),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Timer section
                    const TimerDisplay(),
                    const SizedBox(height: 32),
                    const ControlButtons(),
                    const SizedBox(height: 32),
                    _buildZenFadeWidget(const SessionProgress()),
                    const SizedBox(height: 20),
                    _buildZenFadeWidget(_buildBreakSuggestion(timer)),
                    const SizedBox(height: 24),

                    // Tasks section - now below timer with proper styling
                    _buildZenFadeWidget(
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 500),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.task_alt_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  l10n.tasks,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const TasksScreen()),
                                  ),
                                  icon: const Icon(Icons.open_in_new, size: 16),
                                  label: const Text('View All'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const QuickTaskList(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build app bar with Zen Mode-aware actions
  PreferredSizeWidget _buildAppBar(BuildContext context, TimerProvider timer) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AppBar(
      elevation: 0,
      title: AnimatedBuilder(
        animation: _zenFadeAnimation,
        builder: (context, child) => Opacity(
          opacity: 1.0 - (_zenFadeAnimation.value * 0.5),
          child: Text(
            _getTypeLabel(context, timer.currentType),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ),
      actions: [
        // Coin Balance (Focus Economy) - Compact pill
        _buildZenFadeWidget(
          Consumer<SettingsProvider>(
            builder: (context, settings, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FocusStoreScreen()),
                ),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        '${settings.totalCoins}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Zen Mode toggle button (always visible)
        IconButton(
          icon: Icon(
            timer.isZenMode ? Icons.visibility_off : Icons.visibility,
            size: 22,
          ),
          onPressed: () => timer.toggleZenMode(),
          tooltip: timer.isZenMode ? 'Exit Zen Mode' : 'Enter Zen Mode',
        ),
        // Other actions with Zen Mode fade - now using popup menu for cleaner UI
        _buildZenFadeWidget(
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 22),
            tooltip: 'More options',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            position: PopupMenuPosition.under,
            onSelected: (value) {
              switch (value) {
                case 'sound_mixer':
                  SoundMixerSheet.show(context);
                  break;
                case 'help':
                  _showQuickHelpDialog(context);
                  break;
                case 'dashboard':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const FocusDashboardScreen()));
                  break;
                case 'presets':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const PresetsScreen()));
                  break;
                case 'statistics':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticsScreen()));
                  break;
                case 'settings':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'sound_mixer',
                child: _buildPopupMenuItem(Icons.graphic_eq_rounded, 'Sound Mixer', theme),
              ),
              PopupMenuItem(
                value: 'dashboard',
                child: _buildPopupMenuItem(Icons.dashboard_outlined, 'Focus Dashboard', theme),
              ),
              PopupMenuItem(
                value: 'presets',
                child: _buildPopupMenuItem(Icons.bolt, l10n.quickStartPresets, theme),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'statistics',
                child: _buildPopupMenuItem(Icons.bar_chart_rounded, l10n.statistics, theme),
              ),
              PopupMenuItem(
                value: 'settings',
                child: _buildPopupMenuItem(Icons.settings_outlined, l10n.settings, theme),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'help',
                child: _buildPopupMenuItem(Icons.help_outline_rounded, 'Quick Help', theme),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPopupMenuItem(IconData icon, String label, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurface),
        const SizedBox(width: 12),
        Text(label),
      ],
    );
  }

  /// Wrap widget in Zen Mode fade animation
  Widget _buildZenFadeWidget(Widget child) {
    return AnimatedBuilder(
      animation: _zenFadeAnimation,
      builder: (context, _) => Opacity(
        opacity: 1.0 - _zenFadeAnimation.value,
        child: IgnorePointer(
          ignoring: _zenFadeAnimation.value > 0.5,
          child: child,
        ),
      ),
    );
  }

  /// Build break suggestion widget
  Widget _buildBreakSuggestion(TimerProvider timer) {
    if (timer.currentType == 'short_break' || timer.currentType == 'long_break') {
      return BreakSuggestion(
        isLongBreak: timer.currentType == 'long_break',
      );
    }
    return const SizedBox.shrink();
  }

  void _showQuickHelpDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.help_outline_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Quick Help'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpSection(
                '🎯 Getting Started',
                'Tap START to begin a 25-minute focus session. Work until the timer ends, then take a break.',
                isDark,
              ),
              _buildHelpSection(
                '⌨️ Keyboard Shortcuts',
                '• Space - Start/Pause timer\n'
                '• R - Reset timer\n'
                '• S - Skip to next session\n'
                '• Esc - Stop timer',
                isDark,
              ),
              _buildHelpSection(
                '💡 Pro Tips',
                '• Look for ⓘ icons for detailed explanations\n'
                '• Complete 4 focus sessions for a long break\n'
                '• Track progress in Statistics',
                isDark,
              ),
              _buildHelpSection(
                '⚙️ Customize',
                'Visit Settings to adjust timer durations, sounds, and daily goals.',
                isDark,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Show the full onboarding again
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const WelcomeDialog(),
              );
            },
            child: const Text('Show Tutorial'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String title, String content, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
