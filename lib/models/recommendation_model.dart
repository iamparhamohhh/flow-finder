// lib/models/recommendation_model.dart

import 'custom_practice_model.dart';
import 'theme_model.dart';

enum MoodType { stressed, anxious, calm, energetic, tired, happy, sad, neutral }

enum TimeOfDay { morning, afternoon, evening, night }

class UserMood {
  final MoodType mood;
  final int intensity; // 1-5
  final DateTime timestamp;
  final String? note;

  UserMood({
    required this.mood,
    required this.intensity,
    required this.timestamp,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'mood': mood.name,
      'intensity': intensity,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
    };
  }

  factory UserMood.fromJson(Map<String, dynamic> json) {
    return UserMood(
      mood: MoodType.values.firstWhere((e) => e.name == json['mood']),
      intensity: json['intensity'],
      timestamp: DateTime.parse(json['timestamp']),
      note: json['note'],
    );
  }
}

class PracticeRecommendation {
  final String id;
  final String title;
  final String description;
  final PracticeType type;
  final int durationMinutes;
  final double confidenceScore; // 0.0 - 1.0
  final List<String> reasons;
  final String? breathingPatternId;
  final String? customRoutineId;
  final Map<String, dynamic>? metadata;

  PracticeRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.durationMinutes,
    required this.confidenceScore,
    required this.reasons,
    this.breathingPatternId,
    this.customRoutineId,
    this.metadata,
  });

  String get confidenceLabel {
    if (confidenceScore >= 0.8) return 'Highly Recommended';
    if (confidenceScore >= 0.6) return 'Recommended';
    return 'Suggested';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'durationMinutes': durationMinutes,
      'confidenceScore': confidenceScore,
      'reasons': reasons,
      'breathingPatternId': breathingPatternId,
      'customRoutineId': customRoutineId,
      'metadata': metadata,
    };
  }

  factory PracticeRecommendation.fromJson(Map<String, dynamic> json) {
    return PracticeRecommendation(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: PracticeType.values.firstWhere((e) => e.name == json['type']),
      durationMinutes: json['durationMinutes'],
      confidenceScore: json['confidenceScore'],
      reasons: List<String>.from(json['reasons']),
      breathingPatternId: json['breathingPatternId'],
      customRoutineId: json['customRoutineId'],
      metadata: json['metadata'],
    );
  }
}

class UserPreferences {
  final String userId;
  final String? preferredVoiceId;
  final AppThemeType preferredTheme;
  final bool soundEffectsEnabled;
  final bool hapticFeedbackEnabled;
  final int defaultPracticeDuration; // minutes
  final List<PracticeType> favoritePractices;
  final List<TimeOfDay> preferredPracticeTimes;
  final bool adaptiveDifficultyEnabled;
  final double backgroundMusicVolume; // 0.0 - 1.0
  final double voiceVolume; // 0.0 - 1.0
  final bool autoStartNextPractice;
  final DateTime lastUpdated;

  UserPreferences({
    required this.userId,
    this.preferredVoiceId,
    this.preferredTheme = AppThemeType.ocean,
    this.soundEffectsEnabled = true,
    this.hapticFeedbackEnabled = true,
    this.defaultPracticeDuration = 10,
    this.favoritePractices = const [],
    this.preferredPracticeTimes = const [],
    this.adaptiveDifficultyEnabled = true,
    this.backgroundMusicVolume = 0.5,
    this.voiceVolume = 0.8,
    this.autoStartNextPractice = false,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'preferredVoiceId': preferredVoiceId,
      'preferredTheme': preferredTheme.name,
      'soundEffectsEnabled': soundEffectsEnabled,
      'hapticFeedbackEnabled': hapticFeedbackEnabled,
      'defaultPracticeDuration': defaultPracticeDuration,
      'favoritePractices': favoritePractices.map((e) => e.name).toList(),
      'preferredPracticeTimes': preferredPracticeTimes
          .map((e) => e.name)
          .toList(),
      'adaptiveDifficultyEnabled': adaptiveDifficultyEnabled,
      'backgroundMusicVolume': backgroundMusicVolume,
      'voiceVolume': voiceVolume,
      'autoStartNextPractice': autoStartNextPractice,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      userId: json['userId'],
      preferredVoiceId: json['preferredVoiceId'],
      preferredTheme: AppThemeType.values.firstWhere(
        (e) => e.name == json['preferredTheme'],
        orElse: () => AppThemeType.ocean,
      ),
      soundEffectsEnabled: json['soundEffectsEnabled'] ?? true,
      hapticFeedbackEnabled: json['hapticFeedbackEnabled'] ?? true,
      defaultPracticeDuration: json['defaultPracticeDuration'] ?? 10,
      favoritePractices:
          (json['favoritePractices'] as List?)
              ?.map((e) => PracticeType.values.firstWhere((t) => t.name == e))
              .toList() ??
          [],
      preferredPracticeTimes:
          (json['preferredPracticeTimes'] as List?)
              ?.map((e) => TimeOfDay.values.firstWhere((t) => t.name == e))
              .toList() ??
          [],
      adaptiveDifficultyEnabled: json['adaptiveDifficultyEnabled'] ?? true,
      backgroundMusicVolume: json['backgroundMusicVolume'] ?? 0.5,
      voiceVolume: json['voiceVolume'] ?? 0.8,
      autoStartNextPractice: json['autoStartNextPractice'] ?? false,
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  UserPreferences copyWith({
    String? preferredVoiceId,
    AppThemeType? preferredTheme,
    bool? soundEffectsEnabled,
    bool? hapticFeedbackEnabled,
    int? defaultPracticeDuration,
    List<PracticeType>? favoritePractices,
    List<TimeOfDay>? preferredPracticeTimes,
    bool? adaptiveDifficultyEnabled,
    double? backgroundMusicVolume,
    double? voiceVolume,
    bool? autoStartNextPractice,
  }) {
    return UserPreferences(
      userId: userId,
      preferredVoiceId: preferredVoiceId ?? this.preferredVoiceId,
      preferredTheme: preferredTheme ?? this.preferredTheme,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      hapticFeedbackEnabled:
          hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      defaultPracticeDuration:
          defaultPracticeDuration ?? this.defaultPracticeDuration,
      favoritePractices: favoritePractices ?? this.favoritePractices,
      preferredPracticeTimes:
          preferredPracticeTimes ?? this.preferredPracticeTimes,
      adaptiveDifficultyEnabled:
          adaptiveDifficultyEnabled ?? this.adaptiveDifficultyEnabled,
      backgroundMusicVolume:
          backgroundMusicVolume ?? this.backgroundMusicVolume,
      voiceVolume: voiceVolume ?? this.voiceVolume,
      autoStartNextPractice:
          autoStartNextPractice ?? this.autoStartNextPractice,
      lastUpdated: DateTime.now(),
    );
  }
}
