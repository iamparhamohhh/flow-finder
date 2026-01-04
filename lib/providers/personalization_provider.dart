// lib/providers/personalization_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/recommendation_model.dart';
import '../models/custom_practice_model.dart';
import '../models/voice_model.dart';
import '../models/theme_model.dart';
import '../services/personalization_service.dart';
import '../services/recommendation_service.dart';

class PersonalizationProvider with ChangeNotifier {
  final PersonalizationService _service = PersonalizationService();
  final RecommendationService _recommendationService = RecommendationService();

  UserPreferences? _preferences;
  List<CustomBreathingPattern> _customPatterns = [];
  List<CustomPracticeRoutine> _customRoutines = [];
  List<UserMood> _moodHistory = [];
  List<PracticeRecommendation> _recommendations = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  UserPreferences? get preferences => _preferences;
  List<CustomBreathingPattern> get customPatterns => _customPatterns;
  List<CustomPracticeRoutine> get customRoutines => _customRoutines;
  List<UserMood> get moodHistory => _moodHistory;
  List<PracticeRecommendation> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Theme getters
  AppThemeData get currentTheme =>
      AppThemeData.getTheme(_preferences?.preferredTheme ?? AppThemeType.ocean);

  ThemeData get themeData => currentTheme.toThemeData();

  // Voice getters
  VoiceOption? get selectedVoice {
    if (_preferences?.preferredVoiceId == null) return null;
    return _service.getVoiceById(_preferences!.preferredVoiceId!);
  }

  List<VoiceOption> get availableVoices => _service.getAvailableVoices();

  // Initialize
  Future<void> init() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _service.init();
      await loadPreferences();
      await loadCustomPatterns();
      await loadCustomRoutines();
      await loadMoodHistory();
      await loadRecommendations();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to initialize personalization';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error initializing personalization: $e');
    }
  }

  // Load preferences
  Future<void> loadPreferences() async {
    try {
      _preferences = await _service.loadPreferences();

      // Create default preferences if none exist
      if (_preferences == null) {
        _preferences = UserPreferences(
          userId: 'current_user',
          lastUpdated: DateTime.now(),
        );
        await _service.savePreferences(_preferences!);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  // Update preferences
  Future<void> updatePreferences(UserPreferences newPreferences) async {
    try {
      _preferences = newPreferences;
      await _service.savePreferences(newPreferences);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update preferences';
      notifyListeners();
      debugPrint('Error updating preferences: $e');
    }
  }

  // Update theme
  Future<void> updateTheme(AppThemeType theme) async {
    if (_preferences == null) return;

    final updated = _preferences!.copyWith(preferredTheme: theme);
    await updatePreferences(updated);
  }

  // Update voice
  Future<void> updateVoice(String voiceId) async {
    if (_preferences == null) return;

    final updated = _preferences!.copyWith(preferredVoiceId: voiceId);
    await updatePreferences(updated);
  }

  // Update volume settings
  Future<void> updateVolumes({double? background, double? voice}) async {
    if (_preferences == null) return;

    final updated = _preferences!.copyWith(
      backgroundMusicVolume: background,
      voiceVolume: voice,
    );
    await updatePreferences(updated);
  }

  // Toggle settings
  Future<void> toggleSoundEffects(bool enabled) async {
    if (_preferences == null) return;
    final updated = _preferences!.copyWith(soundEffectsEnabled: enabled);
    await updatePreferences(updated);
  }

  Future<void> toggleHapticFeedback(bool enabled) async {
    if (_preferences == null) return;
    final updated = _preferences!.copyWith(hapticFeedbackEnabled: enabled);
    await updatePreferences(updated);
  }

  Future<void> toggleAdaptiveDifficulty(bool enabled) async {
    if (_preferences == null) return;
    final updated = _preferences!.copyWith(adaptiveDifficultyEnabled: enabled);
    await updatePreferences(updated);
  }

  // Mood tracking
  Future<void> saveMood(UserMood mood) async {
    try {
      await _service.saveMood(mood);
      await loadMoodHistory();
      await loadRecommendations(); // Refresh recommendations based on new mood
    } catch (e) {
      _error = 'Failed to save mood';
      notifyListeners();
      debugPrint('Error saving mood: $e');
    }
  }

  Future<void> loadMoodHistory() async {
    try {
      _moodHistory = await _service.getMoodHistory(days: 30);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading mood history: $e');
    }
  }

  MoodType? get latestMood =>
      _moodHistory.isNotEmpty ? _moodHistory.first.mood : null;

  // Custom breathing patterns
  Future<void> loadCustomPatterns() async {
    try {
      _customPatterns = await _service.getCustomPatterns();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading custom patterns: $e');
    }
  }

  Future<void> saveCustomPattern(CustomBreathingPattern pattern) async {
    try {
      await _service.saveCustomPattern(pattern);
      await loadCustomPatterns();
    } catch (e) {
      _error = 'Failed to save custom pattern';
      notifyListeners();
      debugPrint('Error saving custom pattern: $e');
    }
  }

  Future<void> deleteCustomPattern(String patternId) async {
    try {
      await _service.deleteCustomPattern(patternId);
      await loadCustomPatterns();
    } catch (e) {
      _error = 'Failed to delete pattern';
      notifyListeners();
      debugPrint('Error deleting pattern: $e');
    }
  }

  CustomBreathingPattern? getPatternById(String patternId) {
    return _customPatterns.cast<CustomBreathingPattern?>().firstWhere(
      (p) => p?.id == patternId,
      orElse: () => null,
    );
  }

  // Custom routines
  Future<void> loadCustomRoutines() async {
    try {
      _customRoutines = await _service.getCustomRoutines();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading custom routines: $e');
    }
  }

  Future<void> saveCustomRoutine(CustomPracticeRoutine routine) async {
    try {
      await _service.saveCustomRoutine(routine);
      await loadCustomRoutines();
    } catch (e) {
      _error = 'Failed to save custom routine';
      notifyListeners();
      debugPrint('Error saving custom routine: $e');
    }
  }

  Future<void> deleteCustomRoutine(String routineId) async {
    try {
      await _service.deleteCustomRoutine(routineId);
      await loadCustomRoutines();
    } catch (e) {
      _error = 'Failed to delete routine';
      notifyListeners();
      debugPrint('Error deleting routine: $e');
    }
  }

  // Recommendations
  Future<void> loadRecommendations() async {
    try {
      _isLoading = true;
      notifyListeners();

      _recommendations = await _recommendationService.getRecommendations(
        currentMood: latestMood,
        timeOfDay: RecommendationService.getCurrentTimeOfDay(),
        practiceHistory: [], // TODO: Get from activity provider
        averageSessionDuration: _preferences?.defaultPracticeDuration ?? 10,
        currentStreak: 0, // TODO: Get from activity provider
        favoritePractices: _preferences?.favoritePractices ?? [],
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load recommendations';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading recommendations: $e');
    }
  }

  // Get adaptive settings
  Map<String, dynamic> getAdaptiveSettings({
    required int completedSessions,
    required int averageDuration,
    required double completionRate,
  }) {
    return _service.calculateAdaptiveSettings(
      completedSessions: completedSessions,
      averageDuration: averageDuration,
      completionRate: completionRate,
    );
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
