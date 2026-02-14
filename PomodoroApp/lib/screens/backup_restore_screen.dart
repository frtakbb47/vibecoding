import 'package:flutter/material.dart';
import '../services/backup_restore_service.dart';
import '../services/data_management_service.dart';

/// Screen for managing data backup and restore operations.
/// Provides options to export data, import from file, and view data statistics.
class BackupRestoreScreen extends StatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  State<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends State<BackupRestoreScreen> {
  bool _isLoading = false;
  String? _statusMessage;
  bool _isError = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dataSummary = DataManagementService.getDataSummary();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Data Summary Card
            _buildSummaryCard(context, dataSummary, isDark),
            const SizedBox(height: 24),

            // Status Message
            if (_statusMessage != null) ...[
              _buildStatusMessage(context),
              const SizedBox(height: 16),
            ],

            // Export Section
            _buildSectionHeader(context, 'Export Data', Icons.upload_rounded),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              icon: Icons.share_rounded,
              title: 'Share Backup',
              subtitle: 'Create and share a backup file',
              onTap: _isLoading ? null : _handleExportAndShare,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _buildActionCard(
              context,
              icon: Icons.save_alt_rounded,
              title: 'Save to File',
              subtitle: 'Save backup to a specific location',
              onTap: _isLoading ? null : _handleExportToFile,
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // Import Section
            _buildSectionHeader(context, 'Import Data', Icons.download_rounded),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              icon: Icons.file_open_rounded,
              title: 'Restore from Backup',
              subtitle: 'Import data from a backup file',
              onTap: _isLoading ? null : () => _handleImport(merge: false),
              isDark: isDark,
              isDestructive: true,
            ),
            const SizedBox(height: 8),
            _buildActionCard(
              context,
              icon: Icons.merge_rounded,
              title: 'Merge with Backup',
              subtitle: 'Add backup data without overwriting',
              onTap: _isLoading ? null : () => _handleImport(merge: true),
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // Danger Zone
            _buildSectionHeader(context, 'Danger Zone', Icons.warning_rounded,
              color: Colors.red),
            const SizedBox(height: 12),
            _buildActionCard(
              context,
              icon: Icons.delete_forever_rounded,
              title: 'Clear All Data',
              subtitle: 'Delete all sessions, tasks, and settings',
              onTap: _isLoading ? null : _handleClearAll,
              isDark: isDark,
              isDestructive: true,
            ),

            const SizedBox(height: 32),

            // Loading Indicator
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, DataSummary summary, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [Colors.blue.shade50, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.storage_rounded,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Your Data',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  summary.storageSize,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: '⏱️',
                  value: summary.totalFocusFormatted,
                  label: 'Focus Time',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: '🎯',
                  value: '${summary.totalSessions}',
                  label: 'Sessions',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: '📝',
                  value: '${summary.totalTasks}',
                  label: 'Tasks',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  icon: '🔥',
                  value: '${summary.currentStreak}',
                  label: 'Streak',
                ),
              ),
            ],
          ),
          if (summary.firstSessionDate != null) ...[
            const SizedBox(height: 12),
            Text(
              'Data from: ${DataManagementService.getDateRange(summary.firstSessionDate, summary.lastSessionDate)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {
    required String icon,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, {Color? color}) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required bool isDark,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive ? Colors.red : theme.colorScheme.primary;

    return Material(
      color: isDark
          ? (isDestructive ? Colors.red.withOpacity(0.1) : Colors.white.withOpacity(0.05))
          : (isDestructive ? Colors.red.shade50 : Colors.grey.shade100),
      borderRadius: BorderRadius.circular(12),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white30 : Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isError
            ? Colors.red.withOpacity(0.1)
            : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isError
              ? Colors.red.withOpacity(0.3)
              : Colors.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isError ? Icons.error_rounded : Icons.check_circle_rounded,
            color: _isError ? Colors.red : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _statusMessage!,
              style: TextStyle(
                color: _isError ? Colors.red : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => setState(() => _statusMessage = null),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExportAndShare() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    final result = await BackupRestoreService.exportAndShare();

    setState(() {
      _isLoading = false;
      if (result.success) {
        _statusMessage = 'Backup created: ${result.fileName}';
        _isError = false;
      } else {
        _statusMessage = result.error ?? 'Export failed';
        _isError = true;
      }
    });
  }

  Future<void> _handleExportToFile() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    final result = await BackupRestoreService.exportToFile();

    setState(() {
      _isLoading = false;
      if (result.success) {
        _statusMessage = 'Saved: ${result.fileName}';
        _isError = false;
      } else {
        _statusMessage = result.error ?? 'Save failed';
        _isError = true;
      }
    });
  }

  Future<void> _handleImport({required bool merge}) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(merge ? 'Merge Data?' : 'Restore from Backup?'),
        content: Text(
          merge
              ? 'This will add the backup data to your existing data. No data will be lost.'
              : 'This will REPLACE all your current data with the backup. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: merge
                ? null
                : FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(merge ? 'Merge' : 'Replace'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    final result = await BackupRestoreService.importFromFile(merge: merge);

    setState(() {
      _isLoading = false;
      if (result.success) {
        _statusMessage = result.summary;
        _isError = false;
      } else {
        _statusMessage = result.error ?? 'Import failed';
        _isError = true;
      }
    });
  }

  Future<void> _handleClearAll() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Clear All Data?'),
          ],
        ),
        content: const Text(
          'This will permanently delete ALL your sessions, tasks, and settings. '
          'This action cannot be undone.\n\n'
          'Consider creating a backup first!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      await DataManagementService.clearSessions();
      await DataManagementService.clearTasks();
      await DataManagementService.resetSettings();

      setState(() {
        _isLoading = false;
        _statusMessage = 'All data cleared successfully';
        _isError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Failed to clear data: $e';
        _isError = true;
      });
    }
  }
}
