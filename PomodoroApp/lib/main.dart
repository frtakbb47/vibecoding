import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io' show Platform;
import 'package:flutter_localizations/flutter_localizations.dart';

import 'providers/timer_provider.dart';
import 'providers/task_provider.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'services/audio_service.dart';
import 'services/ambient_sounds_service.dart';
import 'screens/home_screen.dart';
import 'utils/theme.dart';
import 'l10n/app_localizations.dart';

/// Custom Material localizations delegate that falls back to English
/// for locales not supported by Flutter's built-in Material localizations.
///
/// This ensures the app can display in 52 languages while system dialogs
/// gracefully fall back to English when needed.
class _FallbackMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _FallbackMaterialLocalizationsDelegate();

  // Locales supported by Flutter's GlobalMaterialLocalizations
  static const _materialSupportedLocales = {
    'en', 'es', 'fr', 'de', 'zh', 'ja', 'pt', 'it', 'ru', 'ar', 'tr', 'ko',
    'nl', 'pl', 'sv', 'hi', 'th', 'vi', 'id', 'ms', 'bn', 'ta', 'te', 'mr',
    'gu', 'kn', 'ml', 'pa', 'ur', 'fa', 'he', 'uk', 'cs', 'el', 'hu', 'ro',
    'da', 'fi', 'no', 'nb', 'sk', 'sq', 'bg', 'hr', 'sr', 'ca', 'fil', 'az',
    'ka', 'my', 'sw', 'am', 'af', 'be', 'bs', 'cy', 'et', 'eu', 'gl', 'hy',
    'is', 'kk', 'km', 'ky', 'lo', 'lt', 'lv', 'mk', 'mn', 'ne', 'or', 'ps',
    'si', 'sl', 'tl', 'uz', 'zu',
  };

  @override
  bool isSupported(Locale locale) => true; // Accept all locales

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    // If locale is supported by Material, use it; otherwise fall back to English
    final effectiveLocale = _materialSupportedLocales.contains(locale.languageCode)
        ? locale
        : const Locale('en');
    return GlobalMaterialLocalizations.delegate.load(effectiveLocale);
  }

  @override
  bool shouldReload(_FallbackMaterialLocalizationsDelegate old) => false;
}

/// Custom Cupertino localizations delegate with English fallback.
///
/// Similar to [_FallbackMaterialLocalizationsDelegate] but for iOS-style widgets.
class _FallbackCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const _FallbackCupertinoLocalizationsDelegate();

  static const _cupertinoSupportedLocales = {
    'en', 'es', 'fr', 'de', 'zh', 'ja', 'pt', 'it', 'ru', 'ar', 'tr', 'ko',
    'nl', 'pl', 'sv', 'hi', 'th', 'vi', 'id', 'ms', 'bn', 'ta', 'te', 'mr',
    'gu', 'kn', 'ml', 'pa', 'ur', 'fa', 'he', 'uk', 'cs', 'el', 'hu', 'ro',
    'da', 'fi', 'no', 'nb', 'sk', 'sq', 'bg', 'hr', 'sr', 'ca', 'fil', 'az',
    'ka', 'my', 'sw', 'am',
  };

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    final effectiveLocale = _cupertinoSupportedLocales.contains(locale.languageCode)
        ? locale
        : const Locale('en');
    return GlobalCupertinoLocalizations.delegate.load(effectiveLocale);
  }

  @override
  bool shouldReload(_FallbackCupertinoLocalizationsDelegate old) => false;
}

/// Application entry point.
///
/// Initializes all services and runs the app:
/// 1. Hive database initialization
/// 2. Storage service setup
/// 3. Window manager configuration (desktop only)
/// 4. Provider setup for state management
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();
  await StorageService.init();

  // Initialize notifications
  await NotificationService.init();

  // Initialize audio services
  await AudioService.init();
  await AmbientSoundsService.init();

  // Configure window for desktop platforms (not web)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 600),
      minimumSize: Size(400, 500),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      title: 'Pomodoro Timer',
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(const PomodoroApp());
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Pomodoro Timer',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: settings.languageCode != null
                ? Locale(settings.languageCode!)
                : null, // null = use system locale
            localizationsDelegates: const [
              AppLocalizations.delegate,
              _FallbackMaterialLocalizationsDelegate(),
              GlobalWidgetsLocalizations.delegate,
              _FallbackCupertinoLocalizationsDelegate(),
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            localeResolutionCallback: (locale, supportedLocales) {
              // For languages not supported by Material/Cupertino localizations,
              // we still use them for our AppLocalizations but the app will
              // fall back to English for system dialogs
              if (locale != null) {
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale.languageCode) {
                    return supportedLocale;
                  }
                }
              }
              return const Locale('en');
            },
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
