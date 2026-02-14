import 'package:flutter/foundation.dart';
import '../models/pomodoro_settings.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  late PomodoroSettings _settings;
  bool _isDarkMode = false;

  SettingsProvider() {
    _loadSettings();
  }

  PomodoroSettings get settings => _settings;
  bool get isDarkMode => _isDarkMode;

  int get workDuration => _settings.workDuration;
  int get shortBreakDuration => _settings.shortBreakDuration;
  int get longBreakDuration => _settings.longBreakDuration;
  int get sessionsBeforeLongBreak => _settings.sessionsBeforeLongBreak;
  bool get autoStartBreaks => _settings.autoStartBreaks;
  bool get autoStartPomodoros => _settings.autoStartPomodoros;
  bool get soundEnabled => _settings.soundEnabled;
  bool get notificationsEnabled => _settings.notificationsEnabled;
  bool get tickingSoundEnabled => _settings.tickingSoundEnabled;
  double get volume => _settings.volume;
  int get dailyGoal => _settings.dailyGoal;
  String? get languageCode => _settings.languageCode;
  int get totalCoins => _settings.totalCoins;

  void _loadSettings() {
    _settings = StorageService.getSettings();
    notifyListeners();
  }

  Future<void> updateWorkDuration(int minutes) async {
    _settings.workDuration = minutes;
    await _saveSettings();
  }

  Future<void> updateShortBreakDuration(int minutes) async {
    _settings.shortBreakDuration = minutes;
    await _saveSettings();
  }

  Future<void> updateLongBreakDuration(int minutes) async {
    _settings.longBreakDuration = minutes;
    await _saveSettings();
  }

  Future<void> updateSessionsBeforeLongBreak(int sessions) async {
    _settings.sessionsBeforeLongBreak = sessions;
    await _saveSettings();
  }

  Future<void> updateAutoStartBreaks(bool value) async {
    _settings.autoStartBreaks = value;
    await _saveSettings();
  }

  Future<void> updateAutoStartPomodoros(bool value) async {
    _settings.autoStartPomodoros = value;
    await _saveSettings();
  }

  Future<void> updateSoundEnabled(bool value) async {
    _settings.soundEnabled = value;
    await _saveSettings();
  }

  Future<void> updateNotificationsEnabled(bool value) async {
    _settings.notificationsEnabled = value;
    await _saveSettings();
  }

  Future<void> updateTickingSoundEnabled(bool value) async {
    _settings.tickingSoundEnabled = value;
    await _saveSettings();
  }

  Future<void> updateVolume(double value) async {
    _settings.volume = value;
    await _saveSettings();
  }

  Future<void> updateDailyGoal(int sessions) async {
    _settings.dailyGoal = sessions;
    await _saveSettings();
  }

  Future<void> updateLanguageCode(String? code) async {
    _settings.languageCode = code;
    await _saveSettings();
  }

  Future<void> updateTotalCoins(int coins) async {
    _settings.totalCoins = coins;
    await _saveSettings();
  }

  Future<bool> spendCoins(int amount) async {
    if (_settings.totalCoins >= amount) {
      _settings.totalCoins -= amount;
      await _saveSettings();
      return true;
    }
    return false;
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _settings = PomodoroSettings();
    await _saveSettings();
  }
}
