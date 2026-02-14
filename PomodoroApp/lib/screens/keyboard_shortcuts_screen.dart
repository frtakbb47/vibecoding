import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShortcutItem {
  final String key;
  final String description;
  final IconData icon;

  const ShortcutItem({
    required this.key,
    required this.description,
    required this.icon,
  });
}

class KeyboardShortcutsScreen extends StatelessWidget {
  const KeyboardShortcutsScreen({super.key});

  static const List<ShortcutItem> _timerShortcuts = [
    ShortcutItem(
      key: 'Space',
      description: 'Start / Pause timer',
      icon: Icons.play_circle_outline,
    ),
    ShortcutItem(
      key: 'R',
      description: 'Reset timer',
      icon: Icons.refresh,
    ),
    ShortcutItem(
      key: 'S',
      description: 'Skip to next session',
      icon: Icons.skip_next,
    ),
    ShortcutItem(
      key: '+',
      description: 'Add 1 minute',
      icon: Icons.add,
    ),
    ShortcutItem(
      key: '-',
      description: 'Subtract 1 minute',
      icon: Icons.remove,
    ),
  ];

  static const List<ShortcutItem> _navigationShortcuts = [
    ShortcutItem(
      key: '1',
      description: 'Go to Timer',
      icon: Icons.timer,
    ),
    ShortcutItem(
      key: '2',
      description: 'Go to Tasks',
      icon: Icons.check_circle,
    ),
    ShortcutItem(
      key: '3',
      description: 'Go to Statistics',
      icon: Icons.bar_chart,
    ),
    ShortcutItem(
      key: '4',
      description: 'Go to Settings',
      icon: Icons.settings,
    ),
    ShortcutItem(
      key: 'Ctrl + D',
      description: 'Open Dashboard',
      icon: Icons.dashboard,
    ),
  ];

  static const List<ShortcutItem> _taskShortcuts = [
    ShortcutItem(
      key: 'N',
      description: 'New task',
      icon: Icons.add_task,
    ),
    ShortcutItem(
      key: 'Enter',
      description: 'Mark task complete',
      icon: Icons.check,
    ),
    ShortcutItem(
      key: 'Delete',
      description: 'Delete selected task',
      icon: Icons.delete,
    ),
    ShortcutItem(
      key: '↑ / ↓',
      description: 'Navigate tasks',
      icon: Icons.swap_vert,
    ),
  ];

  static const List<ShortcutItem> _generalShortcuts = [
    ShortcutItem(
      key: 'Ctrl + ,',
      description: 'Open settings',
      icon: Icons.settings,
    ),
    ShortcutItem(
      key: 'Ctrl + ?',
      description: 'Show keyboard shortcuts',
      icon: Icons.keyboard,
    ),
    ShortcutItem(
      key: 'Escape',
      description: 'Close dialogs',
      icon: Icons.close,
    ),
    ShortcutItem(
      key: 'F11',
      description: 'Toggle fullscreen',
      icon: Icons.fullscreen,
    ),
    ShortcutItem(
      key: 'Ctrl + M',
      description: 'Toggle sound mute',
      icon: Icons.volume_off,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keyboard Shortcuts'),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.keyboard,
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
                          'Work Faster with Shortcuts',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Use these keyboard shortcuts to control the app without using your mouse.',
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
          const SizedBox(height: 24),

          // Timer Shortcuts
          _buildSection(
            context,
            title: 'Timer Controls',
            icon: Icons.timer,
            color: Colors.red,
            shortcuts: _timerShortcuts,
          ),
          const SizedBox(height: 16),

          // Navigation Shortcuts
          _buildSection(
            context,
            title: 'Navigation',
            icon: Icons.navigation,
            color: Colors.blue,
            shortcuts: _navigationShortcuts,
          ),
          const SizedBox(height: 16),

          // Task Shortcuts
          _buildSection(
            context,
            title: 'Task Management',
            icon: Icons.task_alt,
            color: Colors.green,
            shortcuts: _taskShortcuts,
          ),
          const SizedBox(height: 16),

          // General Shortcuts
          _buildSection(
            context,
            title: 'General',
            icon: Icons.apps,
            color: Colors.purple,
            shortcuts: _generalShortcuts,
          ),
          const SizedBox(height: 24),

          // Note
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Keyboard shortcuts work best on desktop and web. Some shortcuts may vary by platform.',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<ShortcutItem> shortcuts,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...shortcuts.map((shortcut) => _ShortcutRow(shortcut: shortcut)),
        ],
      ),
    );
  }
}

class _ShortcutRow extends StatelessWidget {
  final ShortcutItem shortcut;

  const _ShortcutRow({required this.shortcut});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            shortcut.icon,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              shortcut.description,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          _KeyboardKey(keyLabel: shortcut.key),
        ],
      ),
    );
  }
}

class _KeyboardKey extends StatelessWidget {
  final String keyLabel;

  const _KeyboardKey({required this.keyLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keys = keyLabel.split(' + ');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < keys.length; i++) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Text(
              keys[i],
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          if (i < keys.length - 1) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '+',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}
