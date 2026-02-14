import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/audio_service.dart';
import '../services/ambient_sounds_service.dart';
import '../widgets/help_tooltip.dart';
import '../utils/help_texts.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with AutomaticKeepAliveClientMixin {
  bool _showAdvanced = false;

  @override
  bool get wantKeepAlive => true;  // Keep state alive for smoother navigation

  String _currentSoundId = '';  // Track selected sound

  String _getLocalizedSoundNameById(BuildContext context, String soundId) {
    final l10n = AppLocalizations.of(context);
    switch (soundId) {
      case '':
        return l10n.none;
      case 'rain':
        return l10n.rain;
      case 'coffee':
        return l10n.cafe;
      case 'whitenoise':
        return l10n.whiteNoise;
      case 'forest':
        return l10n.forest;
      case 'ocean':
        return l10n.ocean;
      case 'fire':
        return l10n.fireplace;
      case 'night':
        return l10n.night;
      case 'lofi':
        return l10n.lofi;
      default:
        return soundId;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settings),
      ),
      body: Selector<SettingsProvider, SettingsSnapshot>(
        selector: (_, settings) => SettingsSnapshot(
          languageCode: settings.languageCode,
          isDarkMode: settings.isDarkMode,
          workDuration: settings.workDuration,
          shortBreakDuration: settings.shortBreakDuration,
          longBreakDuration: settings.longBreakDuration,
          autoStartBreaks: settings.autoStartBreaks,
          autoStartPomodoros: settings.autoStartPomodoros,
          notificationsEnabled: settings.notificationsEnabled,
          soundEnabled: settings.soundEnabled,
          volume: settings.volume,
          dailyGoal: settings.dailyGoal,
          sessionsBeforeLongBreak: settings.sessionsBeforeLongBreak,
          tickingSoundEnabled: settings.tickingSoundEnabled,
        ),
        builder: (context, snapshot, _) {
          final settings = Provider.of<SettingsProvider>(context, listen: false);

          return ListView(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            cacheExtent: 1000,
            children: [
              // Language Selection
              _buildLanguageTile(context, snapshot.languageCode, settings),

              // Appearance
              _buildSwitchTile(
                context,
                AppLocalizations.of(context).darkMode,
                '',
                snapshot.isDarkMode,
                (_) => settings.toggleTheme(),
                Icons.dark_mode,
              ),

              const Divider(height: 40),

              _buildDurationTile(
                context,
                AppLocalizations.of(context).workDuration,
                '',
                snapshot.workDuration,
                (value) => settings.updateWorkDuration(value.round()),
                1,
                180,
                Icons.work_outline,
                help: HelpTexts.workDuration,
              ),
              _buildDurationTile(
                context,
                AppLocalizations.of(context).shortBreakDuration,
                '',
                snapshot.shortBreakDuration,
                (value) => settings.updateShortBreakDuration(value.round()),
                1,
                60,
                Icons.coffee_outlined,
                help: HelpTexts.shortBreak,
              ),
              _buildDurationTile(
                context,
                AppLocalizations.of(context).longBreakDuration,
                '',
                snapshot.longBreakDuration,
                (value) => settings.updateLongBreakDuration(value.round()),
                5,
                120,
                Icons.beach_access_outlined,
                help: HelpTexts.longBreak,
              ),

              const Divider(height: 40),

              _buildSwitchTile(
                context,
                AppLocalizations.of(context).autoStartBreaks,
                '',
                snapshot.autoStartBreaks,
                settings.updateAutoStartBreaks,
                Icons.play_circle_outline,
                help: HelpTexts.autoStartBreaks,
              ),
              _buildSwitchTile(
                context,
                AppLocalizations.of(context).autoStartPomodoros,
                '',
                snapshot.autoStartPomodoros,
                settings.updateAutoStartPomodoros,
                Icons.play_arrow,
                help: HelpTexts.autoStartPomodoros,
              ),

              const Divider(height: 40),

              _buildSwitchTile(
                context,
                AppLocalizations.of(context).enableNotifications,
                '',
                snapshot.notificationsEnabled,
                settings.updateNotificationsEnabled,
                Icons.notifications_active,
                help: HelpTexts.notifications,
              ),
              _buildSwitchTile(
                context,
                AppLocalizations.of(context).enableSounds,
                '',
                snapshot.soundEnabled,
                (value) {
                  settings.updateSoundEnabled(value);
                  if (value) {
                    AudioService.setVolume(snapshot.volume);
                  }
                },
                Icons.volume_up,
                help: HelpTexts.sounds,
              ),
              if (snapshot.soundEnabled)
                _buildSliderTile(
                  context,
                  'Vol',
                  '',
                  snapshot.volume,
                  (value) {
                    settings.updateVolume(value);
                    AudioService.setVolume(value);
                  },
                  0,
                  1,
                  divisions: 10,
                  icon: Icons.volume_down,
                  percentage: true,
                ),

              const Divider(height: 40),

              _buildAmbientSoundTile(context),

              const Divider(height: 40),

              _buildSliderTile(
                context,
                AppLocalizations.of(context).goal,
                '',
                snapshot.dailyGoal.toDouble(),
                (value) => settings.updateDailyGoal(value.round()),
                1,
                20,
                divisions: 19,
                icon: Icons.flag,
                suffix: ' ${AppLocalizations.of(context).sessions}',
                help: HelpTexts.dailyGoal,
              ),

              const SizedBox(height: 24),

              // ADVANCED SETTINGS TOGGLE
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: const Icon(Icons.settings_suggest),
                  title: Text(
                    AppLocalizations.of(context).settings,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(''),
                  initiallyExpanded: _showAdvanced,
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _showAdvanced = expanded;
                    });
                  },
                  children: [
                    const Divider(),

                    // Sessions before long break
                    _buildSliderTile(
                      context,
                      AppLocalizations.of(context).pomodorosUntilLongBreak,
                      '',
                      snapshot.sessionsBeforeLongBreak.toDouble(),
                      (value) => settings.updateSessionsBeforeLongBreak(value.round()),
                      2,
                      10,
                      divisions: 8,
                      icon: Icons.repeat,
                      suffix: ' sessions',
                      help: HelpTexts.sessionsBeforeLongBreak,
                    ),

                    // Ticking sound
                    _buildSwitchTile(
                      context,
                      AppLocalizations.of(context).tickingSound,
                      '',
                      snapshot.tickingSoundEnabled,
                      settings.updateTickingSoundEnabled,
                      Icons.access_time,
                      help: HelpTexts.tickingSound,
                    ),

                    const SizedBox(height: 16),

                    // Data Management
                    _buildSectionHeader(context, AppLocalizations.of(context).dataManagement, Icons.storage),

                    ListTile(
                      leading: const Icon(Icons.file_download),
                      title: Text(AppLocalizations.of(context).exportData),
                      subtitle: Text(AppLocalizations.of(context).backupTasksStats),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Implement export
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${AppLocalizations.of(context).exportData} ${AppLocalizations.of(context).comingSoon.toLowerCase()}!')),
                        );
                      },
                    ),

                    ListTile(
                      leading: const Icon(Icons.file_upload),
                      title: Text(AppLocalizations.of(context).importData),
                      subtitle: Text(AppLocalizations.of(context).restoreFromBackup),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Implement import
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${AppLocalizations.of(context).importData} ${AppLocalizations.of(context).comingSoon.toLowerCase()}!')),
                        );
                      },
                    ),

                    const Divider(height: 32),

                    // Reset to defaults
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: OutlinedButton.icon(
                        onPressed: () => _showResetDialog(context, settings),
                        icon: const Icon(Icons.restore, color: Colors.orange),
                        label: Text(AppLocalizations.of(context).resetToDefaults),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          foregroundColor: Colors.orange,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // App Info
              Center(
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context).appName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, String? currentLanguage, SettingsProvider settings) {
    final languages = {
      null: 'System Default',
      'en': '🇬🇧 English',
      'es': '🇪🇸 Español',
      'fr': '🇫🇷 Français',
      'de': '🇩🇪 Deutsch',
      'zh': '🇨🇳 中文',
      'ja': '🇯🇵 日本語',
      'pt': '🇵🇹 Português',
      'it': '🇮🇹 Italiano',
      'ru': '🇷🇺 Русский',
      'ar': '🇸🇦 العربية',
      'tr': '🇹🇷 Türkçe',
      'ko': '🇰🇷 한국어',
      'nl': '🇳🇱 Nederlands',
      'pl': '🇵🇱 Polski',
      'sv': '🇸🇪 Svenska',
      'hi': '🇮🇳 हिन्दी',
      'th': '🇹🇭 ไทย',
      'vi': '🇻🇳 Tiếng Việt',
      'id': '🇮🇩 Bahasa Indonesia',
      'ms': '🇲🇾 Bahasa Melayu',
      'bn': '🇧🇩 বাংলা',
      'ta': '🇮🇳 தமிழ்',
      'te': '🇮🇳 తెలుగు',
      'mr': '🇮🇳 मराठी',
      'gu': '🇮🇳 ગુજરાતી',
      'kn': '🇮🇳 ಕನ್ನಡ',
      'ml': '🇮🇳 മലയാളം',
      'pa': '🇮🇳 ਪੰਜਾਬੀ',
      'ur': '🇵🇰 اردو',
      'fa': '🇮🇷 فارسی',
      'he': '🇮🇱 עברית',
      'uk': '🇺🇦 Українська',
      'cs': '🇨🇿 Čeština',
      'el': '🇬🇷 Ελληνικά',
      'hu': '🇭🇺 Magyar',
      'ro': '🇷🇴 Română',
      'da': '🇩🇰 Dansk',
      'fi': '🇫🇮 Suomi',
      'no': '🇳🇴 Norsk',
      'sk': '🇸🇰 Slovenčina',
      'sq': '🇦🇱 Shqip',
      'bg': '🇧🇬 Български',
      'hr': '🇭🇷 Hrvatski',
      'sr': '🇷🇸 Српски',
      'ca': '🇪🇸 Català',
      'fil': '🇵🇭 Filipino',
      'az': '🇦🇿 Azərbaycan',
      'ka': '🇬🇪 ქართული',
      'my': '🇲🇲 မြန်မာ',
      'sw': '🇰🇪 Kiswahili',
      'am': '🇪🇹 አማርኛ',
      'ku': '🇮🇶 Kurdî (Kurmancî)',
    };

    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(AppLocalizations.of(context).language),
      subtitle: Text(languages[currentLanguage] ?? 'System Default'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final selected = await showDialog<String?>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(AppLocalizations.of(context).selectLanguage),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: languages.entries.map((entry) {
                  final isSelected = entry.key == currentLanguage;
                  return RadioListTile<String?>(
                    title: Text(entry.value),
                    value: entry.key,
                    groupValue: currentLanguage,
                    selected: isSelected,
                    onChanged: (value) {
                      Navigator.pop(dialogContext, value);
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(AppLocalizations.of(context).cancel),
              ),
            ],
          ),
        );

        if (selected != null || (selected == null && currentLanguage != null)) {
          await settings.updateLanguageCode(selected);
        }
      },
    );
  }

  Widget _buildAmbientSoundTile(BuildContext context) {
    final currentSoundData = _currentSoundId.isEmpty
        ? null
        : AmbientSoundsService.getSoundById(_currentSoundId);
    final displayEmoji = currentSoundData?.emoji ?? '🔇';
    final displayName = _getLocalizedSoundNameById(context, _currentSoundId);

    return ListTile(
      leading: const Icon(Icons.music_note),
      title: Text(AppLocalizations.of(context).backgroundSound),
      subtitle: Text('$displayEmoji $displayName'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        // Build list with "None" option first
        final soundOptions = [
          const _SoundOption(id: '', name: 'None', emoji: '🔇', description: 'No ambient sound'),
          ...AmbientSoundsService.sounds.map((s) => _SoundOption(
            id: s.id,
            name: s.name,
            emoji: s.emoji,
            description: s.description,
          )),
        ];

        final selected = await showDialog<String>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(AppLocalizations.of(context).selectAmbientSound),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: soundOptions.map((sound) {
                  final isSelected = sound.id == _currentSoundId;
                  return RadioListTile<String>(
                    title: Row(
                      children: [
                        Text(sound.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_getLocalizedSoundNameById(context, sound.id)),
                              Text(
                                sound.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    value: sound.id,
                    groupValue: _currentSoundId,
                    selected: isSelected,
                    onChanged: (value) {
                      Navigator.pop(dialogContext, value);
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(AppLocalizations.of(context).cancel),
              ),
            ],
          ),
        );

        if (selected != null) {
          // Stop all sounds first
          await AmbientSoundsService.stopAll();

          // Play selected sound if not "None"
          if (selected.isNotEmpty) {
            await AmbientSoundsService.playSound(selected, 0.5);
          }

          setState(() {
            _currentSoundId = selected;
          });
        }
      },
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon, {
    HelpContent? help,
  }) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Row(
        children: [
          Expanded(child: Text(title)),
          if (help != null)
            InfoButton(
              title: help.title,
              message: help.message,
              tips: help.tips,
              size: 18,
            ),
        ],
      ),
      subtitle: subtitle.isEmpty ? null : Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildDurationTile(
    BuildContext context,
    String title,
    String subtitle,
    int value,
    Function(double) onChanged,
    double min,
    double max,
    IconData icon, {
    HelpContent? help,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Row(
            children: [
              Expanded(child: Text(title)),
              if (help != null)
                InfoButton(
                  title: help.title,
                  message: help.message,
                  tips: help.tips,
                  size: 18,
                ),
            ],
          ),
          subtitle: subtitle.isEmpty ? null : Text(subtitle, style: const TextStyle(fontSize: 12)),
          trailing: InkWell(
            onTap: () async {
              final controller = TextEditingController(text: value.toString());
              final newValue = await showDialog<int>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text('${AppLocalizations.of(context).setValue}: $title'),
                  content: TextField(
                    controller: controller,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).minutes,
                      hintText: '${min.toInt()}-${max.toInt()}',
                      suffixText: AppLocalizations.of(context).min,
                    ),
                    onSubmitted: (val) {
                      final parsed = int.tryParse(val);
                      Navigator.pop(dialogContext, parsed);
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: Text(AppLocalizations.of(context).cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        final parsed = int.tryParse(controller.text);
                        Navigator.pop(dialogContext, parsed);
                      },
                      child: Text(AppLocalizations.of(context).set),
                    ),
                  ],
                ),
              );
              if (newValue != null && newValue >= min && newValue <= max) {
                onChanged(newValue.toDouble());
              } else if (newValue != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${AppLocalizations.of(context).valueBetween} ${min.toInt()} - ${max.toInt()} ${AppLocalizations.of(context).minutes}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$value ${AppLocalizations.of(context).min}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit,
                    size: 14,
                    color: Theme.of(context).primaryColor.withOpacity(0.6),
                  ),
                ],
              ),
            ),
          ),
        ),
        Slider(
          value: value.toDouble(),
          min: min,
          max: max,
          divisions: (max - min).round(),
          label: '$value minutes',
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSliderTile(
    BuildContext context,
    String title,
    String subtitle,
    double value,
    Function(double) onChanged,
    double min,
    double max, {
    required int divisions,
    required IconData icon,
    String suffix = '',
    bool percentage = false,
    HelpContent? help,
  }) {
    String displayValue;
    if (percentage) {
      displayValue = '${(value * 100).round()}%';
    } else {
      displayValue = '${value.round()}$suffix';
    }

    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Row(
            children: [
              Expanded(child: Text(title)),
              if (help != null)
                InfoButton(
                  title: help.title,
                  message: help.message,
                  tips: help.tips,
                  size: 18,
                ),
            ],
          ),
          subtitle: subtitle.isEmpty ? null : Text(subtitle, style: const TextStyle(fontSize: 12)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              displayValue,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: displayValue,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _showResetDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).resetSettings),
        content: Text(
          AppLocalizations.of(context).resetConfirmation,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              settings.resetToDefaults();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context).resetToDefaults),
                ),
              );
            },
            child: Text(
              AppLocalizations.of(context).reset,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// Snapshot class to reduce unnecessary rebuilds
class SettingsSnapshot {
  final String? languageCode;
  final bool isDarkMode;
  final int workDuration;
  final int shortBreakDuration;
  final int longBreakDuration;
  final bool autoStartBreaks;
  final bool autoStartPomodoros;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final double volume;
  final int dailyGoal;
  final int sessionsBeforeLongBreak;
  final bool tickingSoundEnabled;

  SettingsSnapshot({
    required this.languageCode,
    required this.isDarkMode,
    required this.workDuration,
    required this.shortBreakDuration,
    required this.longBreakDuration,
    required this.autoStartBreaks,
    required this.autoStartPomodoros,
    required this.notificationsEnabled,
    required this.soundEnabled,
    required this.volume,
    required this.dailyGoal,
    required this.sessionsBeforeLongBreak,
    required this.tickingSoundEnabled,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsSnapshot &&
          languageCode == other.languageCode &&
          isDarkMode == other.isDarkMode &&
          workDuration == other.workDuration &&
          shortBreakDuration == other.shortBreakDuration &&
          longBreakDuration == other.longBreakDuration &&
          autoStartBreaks == other.autoStartBreaks &&
          autoStartPomodoros == other.autoStartPomodoros &&
          notificationsEnabled == other.notificationsEnabled &&
          soundEnabled == other.soundEnabled &&
          volume == other.volume &&
          dailyGoal == other.dailyGoal &&
          sessionsBeforeLongBreak == other.sessionsBeforeLongBreak &&
          tickingSoundEnabled == other.tickingSoundEnabled;

  @override
  int get hashCode =>
      languageCode.hashCode ^
      isDarkMode.hashCode ^
      workDuration.hashCode ^
      shortBreakDuration.hashCode ^
      longBreakDuration.hashCode ^
      autoStartBreaks.hashCode ^
      autoStartPomodoros.hashCode ^
      notificationsEnabled.hashCode ^
      soundEnabled.hashCode ^
      volume.hashCode ^
      dailyGoal.hashCode ^
      sessionsBeforeLongBreak.hashCode ^
      tickingSoundEnabled.hashCode;
}

/// Helper class for sound option display
class _SoundOption {
  final String id;
  final String name;
  final String emoji;
  final String description;

  const _SoundOption({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
  });
}
