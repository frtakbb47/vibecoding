import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

/// Service for managing multiple ambient sounds simultaneously (Sound Mixer)
class AmbientSoundsService {
  static final Map<String, AudioPlayer> _players = {};
  static final Map<String, double> _volumes = {}; // Track volume per sound
  static bool _isInitialized = false;
  static bool _isPaused = false; // Track global pause state

  static Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  static final List<AmbientSound> sounds = [
    AmbientSound(
      id: 'rain',
      name: 'Rain',
      emoji: '🌧️',
      description: 'Gentle rainfall',
      color: Colors.blue,
      assetPath: 'sounds/rain.mp3',
    ),
    AmbientSound(
      id: 'forest',
      name: 'Forest',
      emoji: '🌲',
      description: 'Birds and nature',
      color: Colors.green,
      assetPath: 'sounds/forest.mp3',
    ),
    AmbientSound(
      id: 'ocean',
      name: 'Ocean Waves',
      emoji: '🌊',
      description: 'Calm ocean waves',
      color: Colors.cyan,
      assetPath: 'sounds/ocean.mp3',
    ),
    AmbientSound(
      id: 'fire',
      name: 'Fireplace',
      emoji: '🔥',
      description: 'Crackling fire',
      color: Colors.orange,
      assetPath: 'sounds/fireplace.mp3',
    ),
    AmbientSound(
      id: 'coffee',
      name: 'Coffee Shop',
      emoji: '☕',
      description: 'Ambient cafe sounds',
      color: Colors.brown,
      assetPath: 'sounds/cafe.mp3',
    ),
    AmbientSound(
      id: 'whitenoise',
      name: 'White Noise',
      emoji: '📻',
      description: 'Consistent background noise',
      color: Colors.blueGrey,
      assetPath: 'sounds/white_noise.mp3',
    ),
    AmbientSound(
      id: 'lofi',
      name: 'Lo-Fi Beats',
      emoji: '🎧',
      description: 'Chill study beats',
      color: Colors.pink,
      assetPath: 'sounds/lofi.mp3',
    ),
    AmbientSound(
      id: 'night',
      name: 'Night Sounds',
      emoji: '🌙',
      description: 'Crickets and night ambiance',
      color: Colors.deepPurple,
      assetPath: 'sounds/night.mp3',
    ),
  ];

  static AmbientSound? getSoundById(String id) {
    try {
      return sounds.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Check if a specific sound is currently active (playing or paused)
  static bool isSoundActive(String soundId) {
    return _players.containsKey(soundId) &&
           (_players[soundId]!.state == PlayerState.playing ||
            _players[soundId]!.state == PlayerState.paused);
  }

  /// Check if a specific sound is currently playing
  static bool isSoundPlaying(String soundId) {
    return _players.containsKey(soundId) &&
           _players[soundId]!.state == PlayerState.playing;
  }

  /// Get current volume for a sound (returns 0.5 default if not set)
  static double getVolume(String soundId) {
    return _volumes[soundId] ?? 0.5;
  }

  /// Get list of currently active sound IDs
  static List<String> get activeSoundIds {
    return _players.entries
        .where((e) => e.value.state == PlayerState.playing ||
                      e.value.state == PlayerState.paused)
        .map((e) => e.key)
        .toList();
  }

  /// Toggle a sound on/off (main mixer function)
  static Future<void> toggleSound(String soundId) async {
    if (isSoundActive(soundId)) {
      // Sound is active - stop and dispose it
      await stopSound(soundId, dispose: true);
    } else {
      // Sound is not active - start it
      await playSound(soundId, _volumes[soundId] ?? 0.5);
    }
  }

  /// Play a sound at specified volume (0.0 to 1.0)
  static Future<void> playSound(String soundId, double volume) async {
    final sound = getSoundById(soundId);
    if (sound == null || sound.assetPath == null) return;

    try {
      // Store the volume
      _volumes[soundId] = volume.clamp(0.0, 1.0);

      // Get or create player for this sound
      if (!_players.containsKey(soundId)) {
        _players[soundId] = AudioPlayer();
        await _players[soundId]!.setReleaseMode(ReleaseMode.loop);
      }

      final player = _players[soundId]!;
      await player.setVolume(_volumes[soundId]!);

      // If not already playing (and not globally paused), start it
      if (player.state != PlayerState.playing && !_isPaused) {
        await player.play(AssetSource(sound.assetPath!));
      }
    } catch (e) {
      debugPrint('Error playing sound $soundId: $e');
    }
  }

  /// Update volume for a playing sound
  static Future<void> setVolume(String soundId, double volume) async {
    // Always store the volume
    _volumes[soundId] = volume.clamp(0.0, 1.0);

    if (_players.containsKey(soundId)) {
      try {
        await _players[soundId]!.setVolume(_volumes[soundId]!);

        // If volume is 0, stop the sound
        if (volume <= 0) {
          await stopSound(soundId, dispose: true);
        }
      } catch (e) {
        debugPrint('Error setting volume for $soundId: $e');
      }
    } else if (volume > 0) {
      // Start playing if not already
      await playSound(soundId, volume);
    }
  }

  /// Stop a specific sound (optionally dispose the player)
  static Future<void> stopSound(String soundId, {bool dispose = false}) async {
    if (_players.containsKey(soundId)) {
      try {
        await _players[soundId]!.stop();
        if (dispose) {
          _players[soundId]!.dispose();
          _players.remove(soundId);
        }
      } catch (e) {
        debugPrint('Error stopping sound $soundId: $e');
      }
    }
  }

  /// Stop all sounds and optionally dispose all players
  static Future<void> stopAll({bool dispose = false}) async {
    for (final entry in _players.entries.toList()) {
      try {
        await entry.value.stop();
        if (dispose) {
          entry.value.dispose();
          _players.remove(entry.key);
        }
      } catch (e) {
        debugPrint('Error stopping player: $e');
      }
    }
  }

  /// Pause all sounds (called when timer pauses)
  static Future<void> pauseAll() async {
    _isPaused = true;
    for (final player in _players.values) {
      try {
        if (player.state == PlayerState.playing) {
          await player.pause();
        }
      } catch (e) {
        debugPrint('Error pausing player: $e');
      }
    }
  }

  /// Resume all paused sounds (called when timer resumes)
  static Future<void> resumeAll() async {
    _isPaused = false;
    for (final player in _players.values) {
      try {
        if (player.state == PlayerState.paused) {
          await player.resume();
        }
      } catch (e) {
        debugPrint('Error resuming player: $e');
      }
    }
  }

  /// Check if globally paused
  static bool get isPaused => _isPaused;

  /// Check if any sound is playing
  static bool get isPlaying {
    return _players.values.any((p) => p.state == PlayerState.playing);
  }

  /// Dispose all players
  static void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    _players.clear();
    _isInitialized = false;
  }
}

class AmbientSound {
  final String id;
  final String name;
  final String emoji;
  final String description;
  final Color color;
  final String? assetPath;

  const AmbientSound({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.color,
    this.assetPath,
  });
}
