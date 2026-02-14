import 'package:flutter/material.dart';
import '../services/timer_presets_service.dart';

class TimerPresetsScreen extends StatefulWidget {
  const TimerPresetsScreen({super.key});

  @override
  State<TimerPresetsScreen> createState() => _TimerPresetsScreenState();
}

class _TimerPresetsScreenState extends State<TimerPresetsScreen> {
  TimerPreset? _selectedPreset;

  @override
  void initState() {
    super.initState();
    _selectedPreset = TimerPresetsService.defaultPreset;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer Presets'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create custom preset',
            onPressed: () => _showCreatePresetDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current selection
          if (_selectedPreset != null) ...[
            _buildCurrentPresetCard(theme),
            const SizedBox(height: 24),
          ],

          // Built-in presets
          Text(
            '⚡ Quick Start Presets',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...TimerPresetsService.builtInPresets.map(
            (preset) => _PresetCard(
              preset: preset,
              isSelected: _selectedPreset?.id == preset.id,
              onTap: () => setState(() => _selectedPreset = preset),
              onApply: () => _applyPreset(preset),
            ),
          ),

          // Custom presets
          if (TimerPresetsService.customPresets.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              '✨ Your Custom Presets',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...TimerPresetsService.customPresets.map(
              (preset) => _PresetCard(
                preset: preset,
                isSelected: _selectedPreset?.id == preset.id,
                onTap: () => setState(() => _selectedPreset = preset),
                onApply: () => _applyPreset(preset),
                onDelete: () {
                  TimerPresetsService.removeCustomPreset(preset.id);
                  setState(() {
                    if (_selectedPreset?.id == preset.id) {
                      _selectedPreset = TimerPresetsService.defaultPreset;
                    }
                  });
                },
              ),
            ),
          ],

          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePresetDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Create Preset'),
      ),
    );
  }

  Widget _buildCurrentPresetCard(ThemeData theme) {
    final preset = _selectedPreset!;

    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: preset.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(preset.icon, color: preset.color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Preset',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        preset.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildTimeBadge(theme, '${preset.workMinutes}m', 'Work', Colors.red),
                const SizedBox(width: 12),
                _buildTimeBadge(theme, '${preset.shortBreakMinutes}m', 'Short', Colors.green),
                const SizedBox(width: 12),
                _buildTimeBadge(theme, '${preset.longBreakMinutes}m', 'Long', Colors.blue),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => _applyPreset(preset),
                child: const Text('Apply to Timer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBadge(ThemeData theme, String time, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              time,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyPreset(TimerPreset preset) {
    Navigator.pop(context, preset);
  }

  void _showCreatePresetDialog(BuildContext context) {
    final nameController = TextEditingController();
    int workMinutes = 25;
    int shortBreakMinutes = 5;
    int longBreakMinutes = 15;
    int sessions = 4;
    Color selectedColor = Colors.red;
    IconData selectedIcon = Icons.timer;

    final colors = [
      Colors.red, Colors.blue, Colors.green, Colors.orange,
      Colors.purple, Colors.teal, Colors.pink, Colors.indigo,
    ];

    final icons = [
      Icons.timer, Icons.psychology, Icons.school, Icons.flash_on,
      Icons.rocket_launch, Icons.palette, Icons.code, Icons.fitness_center,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final theme = Theme.of(context);

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Create Custom Preset',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // Name
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Preset Name',
                          hintText: 'My Custom Preset',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Icon selection
                      Text('Icon', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: icons.map((icon) {
                          final isSelected = selectedIcon == icon;
                          return GestureDetector(
                            onTap: () => setDialogState(() => selectedIcon = icon),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected ? selectedColor.withOpacity(0.2) : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected ? Border.all(color: selectedColor, width: 2) : null,
                              ),
                              child: Icon(icon, color: isSelected ? selectedColor : theme.colorScheme.onSurfaceVariant),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Color selection
                      Text('Color', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: colors.map((color) {
                          final isSelected = selectedColor == color;
                          return GestureDetector(
                            onTap: () => setDialogState(() => selectedColor = color),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                                boxShadow: isSelected
                                    ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Work duration
                      _buildSlider(
                        theme,
                        'Work Duration',
                        workMinutes,
                        5,
                        120,
                        (v) => setDialogState(() => workMinutes = v.round()),
                        Colors.red,
                      ),
                      const SizedBox(height: 16),

                      // Short break
                      _buildSlider(
                        theme,
                        'Short Break',
                        shortBreakMinutes,
                        1,
                        30,
                        (v) => setDialogState(() => shortBreakMinutes = v.round()),
                        Colors.green,
                      ),
                      const SizedBox(height: 16),

                      // Long break
                      _buildSlider(
                        theme,
                        'Long Break',
                        longBreakMinutes,
                        5,
                        60,
                        (v) => setDialogState(() => longBreakMinutes = v.round()),
                        Colors.blue,
                      ),
                      const SizedBox(height: 16),

                      // Sessions before long break
                      _buildSlider(
                        theme,
                        'Sessions before long break',
                        sessions,
                        2,
                        8,
                        (v) => setDialogState(() => sessions = v.round()),
                        Colors.orange,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),

                // Save button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (nameController.text.trim().isNotEmpty) {
                          final preset = TimerPreset(
                            id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                            name: nameController.text.trim(),
                            description: 'Custom preset',
                            icon: selectedIcon,
                            color: selectedColor,
                            workMinutes: workMinutes,
                            shortBreakMinutes: shortBreakMinutes,
                            longBreakMinutes: longBreakMinutes,
                            sessionsBeforeLongBreak: sessions,
                            isBuiltIn: false,
                          );
                          TimerPresetsService.addCustomPreset(preset);
                          Navigator.pop(context);
                          setState(() => _selectedPreset = preset);
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Create Preset'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlider(
    ThemeData theme,
    String label,
    int value,
    int min,
    int max,
    ValueChanged<double> onChanged,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.titleSmall),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$value min',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          activeColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _PresetCard extends StatelessWidget {
  final TimerPreset preset;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onApply;
  final VoidCallback? onDelete;

  const _PresetCard({
    required this.preset,
    required this.isSelected,
    required this.onTap,
    required this.onApply,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: preset.color, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: preset.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(preset.icon, color: preset.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preset.name,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      preset.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${preset.workMinutes}/${preset.shortBreakMinutes}/${preset.longBreakMinutes} min',
                      style: TextStyle(
                        fontSize: 12,
                        color: preset.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: onDelete,
                  color: Colors.red,
                ),
              IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: onApply,
                color: preset.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
