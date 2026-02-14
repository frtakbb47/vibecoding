import 'package:flutter/material.dart';
import '../services/theme_customization_service.dart';

class ThemeCustomizationScreen extends StatefulWidget {
  const ThemeCustomizationScreen({super.key});

  @override
  State<ThemeCustomizationScreen> createState() => _ThemeCustomizationScreenState();
}

class _ThemeCustomizationScreenState extends State<ThemeCustomizationScreen> {
  int _selectedColorIndex = 0;
  String _selectedPatternId = 'none';
  bool _useSystemTheme = true;
  bool _isDarkMode = false;
  double _fontSize = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _useSystemTheme = ThemeCustomizationService.useSystemTheme;
    _isDarkMode = ThemeCustomizationService.isDarkMode;
    _fontSize = ThemeCustomizationService.fontSize;
    _selectedPatternId = ThemeCustomizationService.currentPatternId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Mode
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.brightness_6, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Theme Mode',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // System theme toggle
                  SwitchListTile(
                    title: const Text('Use System Theme'),
                    subtitle: const Text('Automatically switch between light and dark'),
                    value: _useSystemTheme,
                    onChanged: (value) {
                      setState(() => _useSystemTheme = value);
                      ThemeCustomizationService.setUseSystemTheme(value);
                    },
                    secondary: const Icon(Icons.phone_android),
                  ),

                  if (!_useSystemTheme) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _ThemeModeCard(
                            icon: Icons.light_mode,
                            label: 'Light',
                            isSelected: !_isDarkMode,
                            onTap: () {
                              setState(() => _isDarkMode = false);
                              ThemeCustomizationService.setDarkMode(false);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ThemeModeCard(
                            icon: Icons.dark_mode,
                            label: 'Dark',
                            isSelected: _isDarkMode,
                            onTap: () {
                              setState(() => _isDarkMode = true);
                              ThemeCustomizationService.setDarkMode(true);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Accent Color
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Accent Color',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: ThemeCustomizationService.accentColors.length,
                    itemBuilder: (context, index) {
                      final colorOption = ThemeCustomizationService.accentColors[index];
                      final isSelected = _selectedColorIndex == index;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedColorIndex = index);
                          ThemeCustomizationService.setAccentColor(index);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorOption.color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                            boxShadow: isSelected
                                ? [BoxShadow(color: colorOption.color.withOpacity(0.5), blurRadius: 12)]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white, size: 24)
                              : null,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      ThemeCustomizationService.accentColors[_selectedColorIndex].name,
                      style: TextStyle(
                        color: ThemeCustomizationService.accentColors[_selectedColorIndex].color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Background Pattern
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.texture, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Background Pattern',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: ThemeCustomizationService.backgroundPatterns.map((pattern) {
                      final isSelected = _selectedPatternId == pattern.id;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedPatternId = pattern.id);
                          ThemeCustomizationService.setBackgroundPattern(pattern.id);
                        },
                        child: Container(
                          width: 80,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(color: theme.colorScheme.primary, width: 2)
                                : null,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                pattern.icon,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                pattern.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Font Size
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.text_fields, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Font Size',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('A', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Slider(
                          value: _fontSize,
                          min: 0.8,
                          max: 1.2,
                          divisions: 4,
                          label: ThemeCustomizationService.fontSizeLabel(_fontSize),
                          onChanged: (value) {
                            setState(() => _fontSize = value);
                            ThemeCustomizationService.setFontSize(value);
                          },
                        ),
                      ),
                      const Text('A', style: TextStyle(fontSize: 24)),
                    ],
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ThemeCustomizationService.fontSizeLabel(_fontSize),
                        style: TextStyle(
                          fontSize: 16 * _fontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Accessibility
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.accessibility, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Accessibility',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Reduce Animations'),
                    subtitle: const Text('Minimize motion effects'),
                    value: ThemeCustomizationService.reduceAnimations,
                    onChanged: (value) {
                      setState(() {});
                      ThemeCustomizationService.setReduceAnimations(value);
                    },
                    secondary: const Icon(Icons.animation),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Preview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.preview, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Preview',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Sample Text',
                          style: TextStyle(
                            fontSize: 18 * _fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This is how your text will appear throughout the app.',
                          style: TextStyle(fontSize: 14 * _fontSize),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FilledButton(
                              onPressed: () {},
                              child: const Text('Button'),
                            ),
                            OutlinedButton(
                              onPressed: () {},
                              child: const Text('Button'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ThemeModeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeModeCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
