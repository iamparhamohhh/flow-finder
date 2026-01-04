// lib/services/personalization_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../models/recommendation_model.dart';
import '../models/custom_practice_model.dart';
import '../models/voice_model.dart';

/// Service for managing user preferences and personalization
class PersonalizationService {
  static final PersonalizationService _instance =
      PersonalizationService._internal();
  factory PersonalizationService() => _instance;
  PersonalizationService._internal();

  static const String _preferencesBoxName = 'user_preferences';
  static const String _moodHistoryBoxName = 'mood_history';
  static const String _customPatternsBoxName = 'custom_breathing_patterns';
  static const String _customRoutinesBoxName = 'custom_routines';

  /// Initialize Hive boxes
  Future<void> init() async {
    if (!Hive.isBoxOpen(_preferencesBoxName)) {
      await Hive.openBox(_preferencesBoxName);
    }
    if (!Hive.isBoxOpen(_moodHistoryBoxName)) {
      await Hive.openBox(_moodHistoryBoxName);
    }
    if (!Hive.isBoxOpen(_customPatternsBoxName)) {
      await Hive.openBox(_customPatternsBoxName);
    }
    if (!Hive.isBoxOpen(_customRoutinesBoxName)) {
      await Hive.openBox(_customRoutinesBoxName);
    }
  }

  /// Save user preferences
  Future<void> savePreferences(UserPreferences preferences) async {
    final box = Hive.box(_preferencesBoxName);
    await box.put('current_user', preferences.toJson());
  }

  /// Load user preferences
  Future<UserPreferences?> loadPreferences() async {
    final box = Hive.box(_preferencesBoxName);
    final data = box.get('current_user');
    if (data != null) {
      return UserPreferences.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  /// Save mood entry
  Future<void> saveMood(UserMood mood) async {
    final box = Hive.box(_moodHistoryBoxName);
    final key = mood.timestamp.toIso8601String();
    await box.put(key, mood.toJson());
  }

  /// Get mood history
  Future<List<UserMood>> getMoodHistory({int? days}) async {
    final box = Hive.box(_moodHistoryBoxName);
    final allMoods = box.values
        .map((e) => UserMood.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    if (days != null) {
      final cutoff = DateTime.now().subtract(Duration(days: days));
      return allMoods.where((m) => m.timestamp.isAfter(cutoff)).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    return allMoods..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Save custom breathing pattern
  Future<void> saveCustomPattern(CustomBreathingPattern pattern) async {
    final box = Hive.box(_customPatternsBoxName);
    await box.put(pattern.id, pattern.toJson());
  }

  /// Get all custom breathing patterns
  Future<List<CustomBreathingPattern>> getCustomPatterns() async {
    final box = Hive.box(_customPatternsBoxName);
    final patterns = box.values
        .map(
          (e) => CustomBreathingPattern.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();

    // Add default patterns if box is empty
    if (patterns.isEmpty) {
      final defaultPatterns = CustomBreathingPattern.getDefaultPatterns();
      for (var pattern in defaultPatterns) {
        await saveCustomPattern(pattern);
      }
      return defaultPatterns;
    }

    return patterns..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Delete custom breathing pattern
  Future<void> deleteCustomPattern(String patternId) async {
    final box = Hive.box(_customPatternsBoxName);
    await box.delete(patternId);
  }

  /// Save custom routine
  Future<void> saveCustomRoutine(CustomPracticeRoutine routine) async {
    final box = Hive.box(_customRoutinesBoxName);
    await box.put(routine.id, routine.toJson());
  }

  /// Get all custom routines
  Future<List<CustomPracticeRoutine>> getCustomRoutines() async {
    final box = Hive.box(_customRoutinesBoxName);
    return box.values
        .map(
          (e) => CustomPracticeRoutine.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Delete custom routine
  Future<void> deleteCustomRoutine(String routineId) async {
    final box = Hive.box(_customRoutinesBoxName);
    await box.delete(routineId);
  }

  /// Get available voices
  List<VoiceOption> getAvailableVoices() {
    return VoiceOption.getDefaultVoices();
  }

  /// Get voice by ID
  VoiceOption? getVoiceById(String voiceId) {
    return VoiceOption.getDefaultVoices().cast<VoiceOption?>().firstWhere(
      (v) => v?.id == voiceId,
      orElse: () => null,
    );
  }

  /// Calculate adaptive difficulty settings
  Map<String, dynamic> calculateAdaptiveSettings({
    required int completedSessions,
    required int averageDuration,
    required double completionRate,
  }) {
    // Simple adaptive algorithm
    int recommendedDuration = 10;
    String difficulty = 'beginner';

    if (completedSessions > 50 && completionRate > 0.8) {
      recommendedDuration = 20;
      difficulty = 'advanced';
    } else if (completedSessions > 20 && completionRate > 0.7) {
      recommendedDuration = 15;
      difficulty = 'intermediate';
    }

    return {
      'recommendedDuration': recommendedDuration,
      'difficulty': difficulty,
      'shouldIncreaseDifficulty':
          completionRate > 0.85 && completedSessions > 10,
      'shouldDecreaseDifficulty': completionRate < 0.5 && completedSessions > 5,
    };
  }
}
