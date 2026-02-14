import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/session_share_card.dart';
import 'storage_service.dart';

/// Service for capturing and sharing session statistics as images.
/// Creates Instagram-Story-ready share cards.
class ShareService {
  static final ScreenshotController _screenshotController = ScreenshotController();

  /// Captures a SessionShareCard and returns the image as Uint8List.
  ///
  /// [durationMinutes] - Duration of the completed session
  /// [taskName] - Name of the task or focus category
  /// [currentStreak] - Current day streak count
  /// [todaySessions] - Number of sessions completed today
  /// [overtimeMinutes] - Optional overtime minutes if flow mode was used
  static Future<Uint8List?> captureSessionCard({
    required int durationMinutes,
    required String taskName,
    required int currentStreak,
    int todaySessions = 1,
    int? overtimeMinutes,
  }) async {
    try {
      // Create the share card widget
      final shareCard = MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: SizedBox(
              width: 1080 / 3, // Scale down for capture (will be upscaled)
              child: SessionShareCard(
                durationMinutes: durationMinutes,
                taskName: taskName,
                currentStreak: currentStreak,
                todaySessions: todaySessions,
                overtimeMinutes: overtimeMinutes,
              ),
            ),
          ),
        ),
      );

      // Capture at higher resolution for crisp images
      final imageBytes = await _screenshotController.captureFromLongWidget(
        shareCard,
        pixelRatio: 3.0, // High resolution for sharing
        delay: const Duration(milliseconds: 100),
      );

      return imageBytes;
    } catch (e) {
      debugPrint('ShareService: Failed to capture session card: $e');
      return null;
    }
  }

  /// Saves the image bytes to a temporary file and returns the file path.
  static Future<String?> saveToTempFile(Uint8List imageBytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${tempDir.path}/pomodoro_session_$timestamp.png';

      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      return filePath;
    } catch (e) {
      debugPrint('ShareService: Failed to save image to temp file: $e');
      return null;
    }
  }

  /// Complete flow: Capture session card and share via system share sheet.
  ///
  /// Returns true if sharing was initiated successfully.
  static Future<bool> shareSessionStats({
    required int durationMinutes,
    required String taskName,
    int? currentStreak,
    int? todaySessions,
    int? overtimeMinutes,
  }) async {
    try {
      // Get streak from storage if not provided
      final streak = currentStreak ?? StorageService.getCurrentStreak();
      final sessions = todaySessions ?? StorageService.getTodayWorkSessionCount();

      // Capture the share card
      final imageBytes = await captureSessionCard(
        durationMinutes: durationMinutes,
        taskName: taskName,
        currentStreak: streak,
        todaySessions: sessions,
        overtimeMinutes: overtimeMinutes,
      );

      if (imageBytes == null) {
        debugPrint('ShareService: Failed to capture image');
        return false;
      }

      // Save to temp file
      final filePath = await saveToTempFile(imageBytes);
      if (filePath == null) {
        debugPrint('ShareService: Failed to save temp file');
        return false;
      }

      // Share via system share sheet
      final result = await Share.shareXFiles(
        [XFile(filePath)],
        text: '🍅 Just completed a $durationMinutes min focus session! '
              '🔥 $streak day streak. #Pomodoro #DeepWork #Productivity',
      );

      // Clean up temp file after sharing (optional, system usually handles this)
      if (result.status == ShareResultStatus.success) {
        // File was shared successfully
        debugPrint('ShareService: Shared successfully');
      }

      return true;
    } catch (e) {
      debugPrint('ShareService: Failed to share: $e');
      return false;
    }
  }

  /// Quick share with minimal parameters - uses currently selected task or default name.
  static Future<bool> quickShare({
    required int durationMinutes,
    String? taskName,
    int? overtimeMinutes,
  }) async {
    return shareSessionStats(
      durationMinutes: durationMinutes,
      taskName: taskName ?? 'Deep Focus',
      overtimeMinutes: overtimeMinutes,
    );
  }
}
