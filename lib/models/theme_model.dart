// lib/models/theme_model.dart

import 'package:flutter/material.dart';

enum AppThemeType {
  ocean,
  forest,
  space,
  sunset,
  mountain,
  desert,
  aurora,
  zen,
}

class AppThemeData {
  final AppThemeType type;
  final String name;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final List<Color> gradientColors;
  final String? backgroundImage;
  final String emoji;

  const AppThemeData({
    required this.type,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.gradientColors,
    this.backgroundImage,
    required this.emoji,
  });

  ThemeData toThemeData({bool isDark = false}) {
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }

  static const Map<AppThemeType, AppThemeData> themes = {
    AppThemeType.ocean: AppThemeData(
      type: AppThemeType.ocean,
      name: 'Ocean',
      description: 'Calm and peaceful like the deep sea',
      emoji: '🌊',
      primaryColor: Color(0xFF0077BE),
      secondaryColor: Color(0xFF00A8CC),
      backgroundColor: Color(0xFFE6F7FF),
      surfaceColor: Color(0xFFFFFFFF),
      gradientColors: [Color(0xFF0077BE), Color(0xFF00A8CC), Color(0xFF5DADE2)],
      backgroundImage: null,
    ),
    AppThemeType.forest: AppThemeData(
      type: AppThemeType.forest,
      name: 'Forest',
      description: 'Fresh and rejuvenating like nature',
      emoji: '🌲',
      primaryColor: Color(0xFF2E7D32),
      secondaryColor: Color(0xFF66BB6A),
      backgroundColor: Color(0xFFE8F5E9),
      surfaceColor: Color(0xFFFFFFFF),
      gradientColors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF4CAF50)],
    ),
    AppThemeType.space: AppThemeData(
      type: AppThemeType.space,
      name: 'Space',
      description: 'Mysterious and infinite',
      emoji: '🌌',
      primaryColor: Color(0xFF1A237E),
      secondaryColor: Color(0xFF5C6BC0),
      backgroundColor: Color(0xFF0D1117),
      surfaceColor: Color(0xFF1F2937),
      gradientColors: [Color(0xFF0D1117), Color(0xFF1A237E), Color(0xFF3949AB)],
    ),
    AppThemeType.sunset: AppThemeData(
      type: AppThemeType.sunset,
      name: 'Sunset',
      description: 'Warm and comforting',
      emoji: '🌅',
      primaryColor: Color(0xFFFF6B6B),
      secondaryColor: Color(0xFFFFD93D),
      backgroundColor: Color(0xFFFFF5E6),
      surfaceColor: Color(0xFFFFFFFF),
      gradientColors: [Color(0xFFFF6B6B), Color(0xFFFFB347), Color(0xFFFFD93D)],
    ),
    AppThemeType.mountain: AppThemeData(
      type: AppThemeType.mountain,
      name: 'Mountain',
      description: 'Strong and grounding',
      emoji: '⛰️',
      primaryColor: Color(0xFF5D4E37),
      secondaryColor: Color(0xFF8B7355),
      backgroundColor: Color(0xFFF5F5DC),
      surfaceColor: Color(0xFFFFFFFF),
      gradientColors: [Color(0xFF4A3C2A), Color(0xFF5D4E37), Color(0xFF8B7355)],
    ),
    AppThemeType.desert: AppThemeData(
      type: AppThemeType.desert,
      name: 'Desert',
      description: 'Warm and minimalist',
      emoji: '🏜️',
      primaryColor: Color(0xFFD4A574),
      secondaryColor: Color(0xFFE8C39E),
      backgroundColor: Color(0xFFFFF8DC),
      surfaceColor: Color(0xFFFFFFFF),
      gradientColors: [Color(0xFFC19A6B), Color(0xFFD4A574), Color(0xFFE8C39E)],
    ),
    AppThemeType.aurora: AppThemeData(
      type: AppThemeType.aurora,
      name: 'Aurora',
      description: 'Magical and inspiring',
      emoji: '✨',
      primaryColor: Color(0xFF8E44AD),
      secondaryColor: Color(0xFF3498DB),
      backgroundColor: Color(0xFFF4ECF7),
      surfaceColor: Color(0xFFFFFFFF),
      gradientColors: [Color(0xFF8E44AD), Color(0xFF3498DB), Color(0xFF1ABC9C)],
    ),
    AppThemeType.zen: AppThemeData(
      type: AppThemeType.zen,
      name: 'Zen',
      description: 'Minimalist and balanced',
      emoji: '☯️',
      primaryColor: Color(0xFF424242),
      secondaryColor: Color(0xFF757575),
      backgroundColor: Color(0xFFFAFAFA),
      surfaceColor: Color(0xFFFFFFFF),
      gradientColors: [Color(0xFF212121), Color(0xFF424242), Color(0xFF757575)],
    ),
  };

  static AppThemeData getTheme(AppThemeType type) {
    return themes[type]!;
  }

  static List<AppThemeData> getAllThemes() {
    return themes.values.toList();
  }
}
