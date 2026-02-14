import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static final AudioPlayer _tickPlayer = AudioPlayer();

  static bool _isInitialized = false;
  static double _volume = 0.7;

  static Future<void> init() async {
    if (_isInitialized) return;

    await _player.setReleaseMode(ReleaseMode.stop);
    await _tickPlayer.setReleaseMode(ReleaseMode.loop);

    _isInitialized = true;
  }

  static Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
    await _tickPlayer.setVolume(_volume * 0.3); // Ticking is quieter
  }

  static Future<void> playCompletionSound() async {
    try {
      await _player.stop();
      // Using a built-in notification sound
      // In production, you'd add custom audio files to assets/sounds/
      await _player.play(AssetSource('sounds/completion.mp3'));
    } catch (e) {
      debugPrint('Error playing completion sound: $e');
      // Fallback: just don't play sound if file is missing
    }
  }

  static Future<void> playBreakSound() async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/break.mp3'));
    } catch (e) {
      debugPrint('Error playing break sound: $e');
    }
  }

  static Future<void> startTickingSound() async {
    try {
      await _tickPlayer.stop();
      await _tickPlayer.setVolume(_volume * 0.3);
      await _tickPlayer.play(AssetSource('sounds/tick.mp3'));
    } catch (e) {
      debugPrint('Error playing ticking sound: $e');
    }
  }

  static Future<void> stopTickingSound() async {
    try {
      await _tickPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping ticking sound: $e');
    }
  }

  static Future<void> stopAll() async {
    await _player.stop();
    await _tickPlayer.stop();
  }

  static void dispose() {
    _player.dispose();
    _tickPlayer.dispose();
  }
}
