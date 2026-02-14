import 'package:flutter/material.dart';
import '../services/ambient_sounds_service.dart';

/// A bottom sheet widget for mixing multiple ambient sounds
class SoundMixerSheet extends StatefulWidget {
  const SoundMixerSheet({super.key});

  /// Show the sound mixer as a modal bottom sheet
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SoundMixerSheet(),
    );
  }

  @override
  State<SoundMixerSheet> createState() => _SoundMixerSheetState();
}

class _SoundMixerSheetState extends State<SoundMixerSheet> {
  // Track local state for UI updates
  final Map<String, double> _volumes = {};
  final Set<String> _activeSounds = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentState();
  }

  void _loadCurrentState() {
    // Load current state from service
    for (final sound in AmbientSoundsService.sounds) {
      _volumes[sound.id] = AmbientSoundsService.getVolume(sound.id);
      if (AmbientSoundsService.isSoundActive(sound.id)) {
        _activeSounds.add(sound.id);
      }
    }
  }

  Future<void> _toggleSound(String soundId) async {
    await AmbientSoundsService.toggleSound(soundId);
    setState(() {
      if (_activeSounds.contains(soundId)) {
        _activeSounds.remove(soundId);
      } else {
        _activeSounds.add(soundId);
      }
    });
  }

  Future<void> _setVolume(String soundId, double volume) async {
    await AmbientSoundsService.setVolume(soundId, volume);
    setState(() {
      _volumes[soundId] = volume;
      if (volume <= 0) {
        _activeSounds.remove(soundId);
      }
    });
  }

  Future<void> _stopAll() async {
    await AmbientSoundsService.stopAll(dispose: true);
    setState(() {
      _activeSounds.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.graphic_eq_rounded,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sound Mixer',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_activeSounds.length} sound${_activeSounds.length == 1 ? '' : 's'} active',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_activeSounds.isNotEmpty)
                      TextButton.icon(
                        onPressed: _stopAll,
                        icon: const Icon(Icons.stop_rounded, size: 18),
                        label: const Text('Stop All'),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                      ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Sound list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: AmbientSoundsService.sounds.length,
                  itemBuilder: (context, index) {
                    final sound = AmbientSoundsService.sounds[index];
                    final isActive = _activeSounds.contains(sound.id);
                    final volume = _volumes[sound.id] ?? 0.5;

                    return _SoundMixerTile(
                      sound: sound,
                      isActive: isActive,
                      volume: volume,
                      onToggle: () => _toggleSound(sound.id),
                      onVolumeChanged: (v) => _setVolume(sound.id, v),
                    );
                  },
                ),
              ),

              // Active sounds indicator
              if (_activeSounds.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.1),
                    border: Border(
                      top: BorderSide(
                        color: theme.dividerColor.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        // Active sound chips
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _activeSounds.map((id) {
                              final sound = AmbientSoundsService.getSoundById(id);
                              if (sound == null) return const SizedBox.shrink();
                              return Chip(
                                avatar: Text(sound.emoji, style: const TextStyle(fontSize: 16)),
                                label: Text(
                                  sound.name,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () => _toggleSound(id),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: sound.color.withOpacity(0.2),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Individual sound tile in the mixer
class _SoundMixerTile extends StatelessWidget {
  final AmbientSound sound;
  final bool isActive;
  final double volume;
  final VoidCallback onToggle;
  final ValueChanged<double> onVolumeChanged;

  const _SoundMixerTile({
    required this.sound,
    required this.isActive,
    required this.volume,
    required this.onToggle,
    required this.onVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? sound.color.withOpacity(0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? sound.color.withOpacity(0.3)
              : theme.dividerColor.withOpacity(0.3),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Emoji icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: sound.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          sound.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Name and description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sound.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isActive ? sound.color : null,
                            ),
                          ),
                          Text(
                            sound.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Toggle switch
                    Switch(
                      value: isActive,
                      onChanged: (_) => onToggle(),
                      activeColor: sound.color,
                    ),
                  ],
                ),

                // Volume slider (only visible when active)
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Icon(
                          volume < 0.3
                              ? Icons.volume_mute_rounded
                              : volume < 0.7
                                  ? Icons.volume_down_rounded
                                  : Icons.volume_up_rounded,
                          size: 20,
                          color: sound.color,
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: sound.color,
                              inactiveTrackColor: sound.color.withOpacity(0.2),
                              thumbColor: sound.color,
                              overlayColor: sound.color.withOpacity(0.2),
                              trackHeight: 4,
                            ),
                            child: Slider(
                              value: volume,
                              min: 0.0,
                              max: 1.0,
                              onChanged: onVolumeChanged,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            '${(volume * 100).round()}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: sound.color,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: isActive
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
