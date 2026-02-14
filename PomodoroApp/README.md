# 🍅 Pomodoro Timer

A cross-platform Pomodoro timer app built with Flutter.

## Features

- ⏱️ Classic Pomodoro timer (25 min work, 5 min break)
- ✅ Task management with Pomodoro tracking
- 📊 Statistics and productivity charts
- 🏆 40+ achievements to unlock
- 🌙 Dark/Light theme
- 🌍 52 language support
- 🎵 Ambient sounds (rain, forest, cafe, etc.)
- 🔔 Notifications
- 💾 Local data storage

## Platforms

- Web
- Windows
- macOS
- Linux
- iOS
- Android

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run
flutter run -d chrome    # Web
flutter run -d windows   # Windows
flutter run -d macos     # macOS
```

## Build

```bash
flutter build web --release
flutter build windows --release
flutter build apk --release
```

## Project Structure

```
lib/
├── main.dart           # Entry point
├── models/             # Data models (Hive)
├── providers/          # State management
├── services/           # Business logic
├── screens/            # UI pages
├── widgets/            # Reusable components
└── utils/              # Helpers & theme
```

## Audio Credits

The ambient sounds used in this app:
- Rain sounds
- Forest ambience
- Coffee shop background
- Ocean waves
- Fireplace crackling
- Wind sounds
- Birds chirping

*Sound files should be placed in `assets/sounds/`*
