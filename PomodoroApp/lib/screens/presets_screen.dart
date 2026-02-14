import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/timer_preset.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';

class PresetsScreen extends StatelessWidget {
  const PresetsScreen({super.key});

  String _getLocalizedPresetName(BuildContext context, String id) {
    final l10n = AppLocalizations.of(context);
    switch (id) {
      case 'deep_work':
        return l10n.deepWorkName;
      case 'study':
        return l10n.studySessionName;
      case 'quick_sprint':
        return l10n.quickSprintName;
      case 'flow_state':
        return l10n.flowStateName;
      case 'classic':
        return l10n.classicPomodoroName;
      case 'creative':
        return l10n.creativeWorkName;
      default:
        return id;
    }
  }

  String _getLocalizedPresetDesc(BuildContext context, String id) {
    final l10n = AppLocalizations.of(context);
    switch (id) {
      case 'deep_work':
        return l10n.deepWorkDesc;
      case 'study':
        return l10n.studySessionDesc;
      case 'quick_sprint':
        return l10n.quickSprintDesc;
      case 'flow_state':
        return l10n.flowStateDesc;
      case 'classic':
        return l10n.classicPomodoroDesc;
      case 'creative':
        return l10n.creativeWorkDesc;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).quickStartPresets),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              AppLocalizations.of(context).choosePreset,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          ...TimerPreset.defaultPresets.map((preset) =>
              _buildPresetCard(context, preset)),
          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateCustomPreset(context),
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context).customPreset),
      ),
    );
  }

  Widget _buildPresetCard(BuildContext context, TimerPreset preset) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _applyPreset(context, preset),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    preset.emoji,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getLocalizedPresetName(context, preset.id),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getLocalizedPresetDesc(context, preset.id),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildInfoChip(
                    Icons.work_outline,
                    '${preset.workMinutes} ${AppLocalizations.of(context).minWork}',
                    Colors.blue,
                  ),
                  _buildInfoChip(
                    Icons.coffee_outlined,
                    '${preset.shortBreakMinutes} ${AppLocalizations.of(context).minBreak}',
                    Colors.green,
                  ),
                  _buildInfoChip(
                    Icons.beach_access_outlined,
                    '${preset.longBreakMinutes} ${AppLocalizations.of(context).minLong}',
                    Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _applyPreset(BuildContext context, TimerPreset preset) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    settings.updateWorkDuration(preset.workMinutes);
    settings.updateShortBreakDuration(preset.shortBreakMinutes);
    settings.updateLongBreakDuration(preset.longBreakMinutes);
    settings.updateSessionsBeforeLongBreak(preset.sessionsBeforeLongBreak);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${preset.emoji} ${preset.name} ${AppLocalizations.of(context).presetAppliedMsg}'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    Navigator.pop(context);
  }

  void _showCreateCustomPreset(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).customPreset),
        content: Text(
          AppLocalizations.of(context).customPresetSoon,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).ok),
          ),
        ],
      ),
    );
  }
}
