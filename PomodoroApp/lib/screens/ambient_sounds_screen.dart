import 'package:flutter/material.dart';
import '../services/ambient_sounds_service.dart';

class AmbientSoundsScreen extends StatefulWidget {
  const AmbientSoundsScreen({super.key});

  @override
  State<AmbientSoundsScreen> createState() => _AmbientSoundsScreenState();
}

class _AmbientSoundsScreenState extends State<AmbientSoundsScreen> {
  final Map<String, double> _activeVolumes = {};
  bool _isPlaying = false;

  @override
  void dispose() {
    // Stop all sounds when leaving the screen (optional - comment out to keep playing)
    // AmbientSoundsService.stopAll();
    super.dispose();
  }

  void _toggleSound(String soundId, double volume) {
    setState(() {
      if (volume > 0) {
        _activeVolumes[soundId] = volume;
        _isPlaying = true;
        AmbientSoundsService.playSound(soundId, volume);
      } else {
        _activeVolumes.remove(soundId);
        AmbientSoundsService.stopSound(soundId);
        if (_activeVolumes.isEmpty) {
          _isPlaying = false;
        }
      }
    });
  }

  void _updateVolume(String soundId, double volume) {
    setState(() {
      if (volume <= 0) {
        _activeVolumes.remove(soundId);
        AmbientSoundsService.stopSound(soundId);
        if (_activeVolumes.isEmpty) {
          _isPlaying = false;
        }
      } else {
        _activeVolumes[soundId] = volume;
        AmbientSoundsService.setVolume(soundId, volume);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeSounds = _activeVolumes.entries.where((e) => e.value > 0).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambient Sounds'),
        actions: [
          if (activeSounds > 0)
            TextButton.icon(
              onPressed: _stopAll,
              icon: const Icon(Icons.stop),
              label: const Text('Stop All'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Now playing indicator
          if (activeSounds > 0)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.tertiaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Now Playing',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$activeSounds sound${activeSounds > 1 ? 's' : ''} mixed',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () {
                      setState(() {
                        _isPlaying = !_isPlaying;
                        if (_isPlaying) {
                          AmbientSoundsService.resumeAll();
                        } else {
                          AmbientSoundsService.pauseAll();
                        }
                      });
                    },
                    icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  ),
                ],
              ),
            ),

          // Info card
          if (activeSounds == 0)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Mix multiple sounds together for your perfect focus atmosphere',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),

          // Sound grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: AmbientSoundsService.sounds.length,
              itemBuilder: (context, index) {
                final sound = AmbientSoundsService.sounds[index];
                final volume = _activeVolumes[sound.id] ?? 0.0;
                final isActive = volume > 0;

                return Card(
                  elevation: isActive ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isActive
                        ? BorderSide(color: sound.color, width: 2)
                        : BorderSide.none,
                  ),
                  child: InkWell(
                    onTap: () {
                      if (isActive) {
                        _toggleSound(sound.id, 0);
                      } else {
                        _toggleSound(sound.id, 0.7);
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? sound.color.withOpacity(0.2)
                                  : Theme.of(context).colorScheme.surfaceContainerHighest,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                sound.emoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            sound.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isActive ? sound.color : null,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            sound.description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isActive) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 20,
                              child: Slider(
                                value: volume,
                                onChanged: (value) {
                                  _updateVolume(sound.id, value);
                                },
                                activeColor: sound.color,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: activeSounds > 0
          ? FloatingActionButton.extended(
              onPressed: () => _showSavePresetDialog(context),
              icon: const Icon(Icons.save),
              label: const Text('Save Mix'),
            )
          : null,
    );
  }

  void _stopAll() {
    setState(() {
      _activeVolumes.clear();
      _isPlaying = false;
    });
    AmbientSoundsService.stopAll();
  }

  void _showSavePresetDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Sound Mix'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Mix Name',
                hintText: 'e.g., Rainy Coffee Shop',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Text(
              'This mix includes ${_activeVolumes.length} sounds',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Mix "${nameController.text}" saved!'),
                    action: SnackBarAction(
                      label: 'View',
                      onPressed: () {},
                    ),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
