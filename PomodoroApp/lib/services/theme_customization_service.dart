import 'package:flutter/material.dart';

class AccentColorOption {
  final String name;
  final Color color;
  final Color darkVariant;

  const AccentColorOption({
    required this.name,
    required this.color,
    required this.darkVariant,
  });
}

class BackgroundPattern {
  final String id;
  final String name;
  final IconData icon;

  const BackgroundPattern({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class ThemeCustomizationService {
  static final List<AccentColorOption> accentColors = [
    const AccentColorOption(
      name: 'Tomato Red',
      color: Color(0xFFE53935),
      darkVariant: Color(0xFFEF5350),
    ),
    const AccentColorOption(
      name: 'Ocean Blue',
      color: Color(0xFF1E88E5),
      darkVariant: Color(0xFF42A5F5),
    ),
    const AccentColorOption(
      name: 'Forest Green',
      color: Color(0xFF43A047),
      darkVariant: Color(0xFF66BB6A),
    ),
    const AccentColorOption(
      name: 'Royal Purple',
      color: Color(0xFF8E24AA),
      darkVariant: Color(0xFFAB47BC),
    ),
    const AccentColorOption(
      name: 'Sunset Orange',
      color: Color(0xFFFB8C00),
      darkVariant: Color(0xFFFFA726),
    ),
    const AccentColorOption(
      name: 'Deep Teal',
      color: Color(0xFF00897B),
      darkVariant: Color(0xFF26A69A),
    ),
    const AccentColorOption(
      name: 'Rose Pink',
      color: Color(0xFFD81B60),
      darkVariant: Color(0xFFEC407A),
    ),
    const AccentColorOption(
      name: 'Indigo Night',
      color: Color(0xFF3949AB),
      darkVariant: Color(0xFF5C6BC0),
    ),
    const AccentColorOption(
      name: 'Amber Gold',
      color: Color(0xFFFFB300),
      darkVariant: Color(0xFFFFCA28),
    ),
    const AccentColorOption(
      name: 'Cyan Wave',
      color: Color(0xFF00ACC1),
      darkVariant: Color(0xFF26C6DA),
    ),
    const AccentColorOption(
      name: 'Lime Fresh',
      color: Color(0xFF7CB342),
      darkVariant: Color(0xFF9CCC65),
    ),
    const AccentColorOption(
      name: 'Brown Earth',
      color: Color(0xFF6D4C41),
      darkVariant: Color(0xFF8D6E63),
    ),
  ];

  static final List<BackgroundPattern> backgroundPatterns = [
    const BackgroundPattern(
      id: 'none',
      name: 'Solid Color',
      icon: Icons.square,
    ),
    const BackgroundPattern(
      id: 'dots',
      name: 'Dots',
      icon: Icons.blur_circular,
    ),
    const BackgroundPattern(
      id: 'grid',
      name: 'Grid',
      icon: Icons.grid_on,
    ),
    const BackgroundPattern(
      id: 'diagonal',
      name: 'Diagonal Lines',
      icon: Icons.line_style,
    ),
    const BackgroundPattern(
      id: 'waves',
      name: 'Waves',
      icon: Icons.waves,
    ),
    const BackgroundPattern(
      id: 'circles',
      name: 'Circles',
      icon: Icons.radio_button_unchecked,
    ),
    const BackgroundPattern(
      id: 'gradient',
      name: 'Gradient',
      icon: Icons.gradient,
    ),
  ];

  static int _selectedAccentIndex = 0;
  static String _selectedPatternId = 'none';
  static bool _useSystemTheme = true;
  static bool _isDarkMode = false;
  static double _fontSize = 1.0; // Multiplier: 0.8, 0.9, 1.0, 1.1, 1.2
  static bool _reduceAnimations = false;

  static AccentColorOption get currentAccent => accentColors[_selectedAccentIndex];
  static String get currentPatternId => _selectedPatternId;
  static bool get useSystemTheme => _useSystemTheme;
  static bool get isDarkMode => _isDarkMode;
  static double get fontSize => _fontSize;
  static bool get reduceAnimations => _reduceAnimations;

  static void setAccentColor(int index) {
    if (index >= 0 && index < accentColors.length) {
      _selectedAccentIndex = index;
    }
  }

  static void setBackgroundPattern(String patternId) {
    if (backgroundPatterns.any((p) => p.id == patternId)) {
      _selectedPatternId = patternId;
    }
  }

  static void setUseSystemTheme(bool value) {
    _useSystemTheme = value;
  }

  static void setDarkMode(bool value) {
    _isDarkMode = value;
  }

  static void setFontSize(double value) {
    _fontSize = value.clamp(0.8, 1.2);
  }

  static void setReduceAnimations(bool value) {
    _reduceAnimations = value;
  }

  static ThemeData buildLightTheme() {
    final accent = currentAccent.color;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
    );
  }

  static ThemeData buildDarkTheme() {
    final accent = currentAccent.darkVariant;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.dark,
      ),
      fontFamily: 'Roboto',
    );
  }

  static List<double> get fontSizeOptions => [0.8, 0.9, 1.0, 1.1, 1.2];

  static String fontSizeLabel(double value) {
    switch (value) {
      case 0.8:
        return 'Small';
      case 0.9:
        return 'Slightly Small';
      case 1.0:
        return 'Normal';
      case 1.1:
        return 'Slightly Large';
      case 1.2:
        return 'Large';
      default:
        return 'Normal';
    }
  }
}
