// lib/services/recommendation_service.dart

import 'dart:math';
import '../models/recommendation_model.dart';
import '../models/custom_practice_model.dart';

/// AI-Powered Recommendation Service
/// Uses rule-based AI to suggest practices based on user patterns
class RecommendationService {
  static final RecommendationService _instance =
      RecommendationService._internal();
  factory RecommendationService() => _instance;
  RecommendationService._internal();

  final _random = Random();

  /// Get personalized recommendations based on multiple factors
  Future<List<PracticeRecommendation>> getRecommendations({
    required MoodType? currentMood,
    required TimeOfDay timeOfDay,
    required List<PracticeType> practiceHistory,
    required int averageSessionDuration,
    required int currentStreak,
    required List<PracticeType> favoritePractices,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final recommendations = <PracticeRecommendation>[];

    // Mood-based recommendations
    if (currentMood != null) {
      recommendations.addAll(_getMoodBasedRecommendations(currentMood));
    }

    // Time-based recommendations
    recommendations.addAll(_getTimeBasedRecommendations(timeOfDay));

    // History-based recommendations
    if (practiceHistory.isNotEmpty) {
      recommendations.addAll(_getHistoryBasedRecommendations(practiceHistory));
    }

    // Streak-based recommendations
    if (currentStreak > 7) {
      recommendations.addAll(_getStreakRecommendations(currentStreak));
    }

    // Adaptive duration recommendations
    recommendations.addAll(
      _getAdaptiveDurationRecommendations(averageSessionDuration),
    );

    // Remove duplicates and sort by confidence score
    final uniqueRecommendations = _deduplicateAndScore(recommendations);
    uniqueRecommendations.sort(
      (a, b) => b.confidenceScore.compareTo(a.confidenceScore),
    );

    return uniqueRecommendations.take(5).toList();
  }

  /// Get recommendations based on current mood
  List<PracticeRecommendation> _getMoodBasedRecommendations(MoodType mood) {
    switch (mood) {
      case MoodType.stressed:
        return [
          PracticeRecommendation(
            id: 'stress_breathing',
            title: '4-7-8 Calming Breath',
            description: 'Scientifically proven to reduce stress and anxiety',
            type: PracticeType.breathing,
            durationMinutes: 5,
            confidenceScore: 0.9,
            reasons: [
              'You indicated feeling stressed',
              'Extended exhale activates parasympathetic nervous system',
              'Quick 5-minute session for immediate relief',
            ],
            breathingPatternId: '478_breathing',
          ),
          PracticeRecommendation(
            id: 'stress_bodyscan',
            title: 'Progressive Muscle Relaxation',
            description: 'Release physical tension stored in your body',
            type: PracticeType.pmr,
            durationMinutes: 15,
            confidenceScore: 0.85,
            reasons: [
              'PMR is effective for stress-related tension',
              'Helps identify and release muscle tightness',
            ],
          ),
        ];

      case MoodType.anxious:
        return [
          PracticeRecommendation(
            id: 'anxiety_breathing',
            title: 'Box Breathing for Anxiety',
            description: 'Used by Navy SEALs to stay calm under pressure',
            type: PracticeType.breathing,
            durationMinutes: 8,
            confidenceScore: 0.92,
            reasons: [
              'You indicated feeling anxious',
              'Equal breathing creates mental balance',
              'Proven to reduce anxiety symptoms',
            ],
            breathingPatternId: 'box_breathing',
          ),
          PracticeRecommendation(
            id: 'anxiety_meditation',
            title: 'Mindfulness Meditation',
            description: 'Ground yourself in the present moment',
            type: PracticeType.meditation,
            durationMinutes: 10,
            confidenceScore: 0.88,
            reasons: [
              'Mindfulness reduces rumination',
              'Helps break anxiety thought patterns',
            ],
          ),
        ];

      case MoodType.tired:
        return [
          PracticeRecommendation(
            id: 'energy_breathing',
            title: 'Energizing Breath Work',
            description: 'Quick breathing to boost energy naturally',
            type: PracticeType.breathing,
            durationMinutes: 5,
            confidenceScore: 0.87,
            reasons: [
              'You indicated feeling tired',
              'Quick inhales increase oxygen and alertness',
              'Natural alternative to caffeine',
            ],
            breathingPatternId: 'energizing_breath',
          ),
        ];

      case MoodType.calm:
        return [
          PracticeRecommendation(
            id: 'maintain_calm',
            title: 'Coherent Breathing',
            description: 'Maintain and deepen your calm state',
            type: PracticeType.breathing,
            durationMinutes: 10,
            confidenceScore: 0.80,
            reasons: [
              'You\'re already calm - deepen the experience',
              'Coherent breathing enhances heart rate variability',
            ],
            breathingPatternId: 'coherent_breathing',
          ),
        ];

      case MoodType.energetic:
        return [
          PracticeRecommendation(
            id: 'channel_energy',
            title: 'Dynamic Body Scan',
            description: 'Channel your energy into mindful awareness',
            type: PracticeType.bodyScan,
            durationMinutes: 12,
            confidenceScore: 0.75,
            reasons: [
              'You have high energy - use it mindfully',
              'Body scan helps maintain focus',
            ],
          ),
        ];

      case MoodType.sad:
      case MoodType.happy:
      case MoodType.neutral:
        return [];
    }
  }

  /// Get recommendations based on time of day
  List<PracticeRecommendation> _getTimeBasedRecommendations(
    TimeOfDay timeOfDay,
  ) {
    switch (timeOfDay) {
      case TimeOfDay.morning:
        return [
          PracticeRecommendation(
            id: 'morning_routine',
            title: 'Morning Energizer',
            description: 'Start your day with clarity and purpose',
            type: PracticeType.breathing,
            durationMinutes: 7,
            confidenceScore: 0.82,
            reasons: [
              'It\'s morning - perfect time for energizing practice',
              'Sets positive tone for the day',
            ],
            breathingPatternId: 'energizing_breath',
          ),
        ];

      case TimeOfDay.afternoon:
        return [
          PracticeRecommendation(
            id: 'afternoon_reset',
            title: 'Midday Reset',
            description: 'Recharge for the rest of your day',
            type: PracticeType.meditation,
            durationMinutes: 10,
            confidenceScore: 0.78,
            reasons: [
              'Afternoon is ideal for a mental reset',
              'Combat afternoon energy dip',
            ],
          ),
        ];

      case TimeOfDay.evening:
        return [
          PracticeRecommendation(
            id: 'evening_unwind',
            title: 'Evening Unwind',
            description: 'Release the day\'s tension',
            type: PracticeType.bodyScan,
            durationMinutes: 15,
            confidenceScore: 0.80,
            reasons: [
              'Evening is perfect for winding down',
              'Prepare your mind and body for rest',
            ],
          ),
        ];

      case TimeOfDay.night:
        return [
          PracticeRecommendation(
            id: 'sleep_prep',
            title: '4-7-8 Sleep Breathing',
            description: 'Prepare for restful sleep',
            type: PracticeType.breathing,
            durationMinutes: 5,
            confidenceScore: 0.90,
            reasons: [
              'Nighttime - optimize for sleep',
              '4-7-8 breathing promotes sleep onset',
              'Short session won\'t delay bedtime',
            ],
            breathingPatternId: '478_breathing',
          ),
        ];
    }
  }

  /// Get recommendations based on practice history
  List<PracticeRecommendation> _getHistoryBasedRecommendations(
    List<PracticeType> history,
  ) {
    final recommendations = <PracticeRecommendation>[];

    // Count practice types
    final typeCounts = <PracticeType, int>{};
    for (var type in history) {
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }

    // Find most practiced type
    final mostPracticed = typeCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Find least practiced type
    final allTypes = PracticeType.values.where((t) => t != PracticeType.custom);
    final leastPracticed = allTypes
        .where((t) => !typeCounts.containsKey(t))
        .firstOrNull;

    // Recommend favorite type
    recommendations.add(
      PracticeRecommendation(
        id: 'history_favorite',
        title: 'Your Favorite: ${_getTypeName(mostPracticed)}',
        description: 'Continue what works for you',
        type: mostPracticed,
        durationMinutes: 10,
        confidenceScore: 0.75,
        reasons: ['Your most practiced type', 'Consistency builds habits'],
      ),
    );

    // Recommend trying something new
    if (leastPracticed != null) {
      recommendations.add(
        PracticeRecommendation(
          id: 'history_explore',
          title: 'Try Something New: ${_getTypeName(leastPracticed)}',
          description: 'Expand your mindfulness practice',
          type: leastPracticed,
          durationMinutes: 8,
          confidenceScore: 0.65,
          reasons: [
            'You haven\'t tried this yet',
            'Variety enhances overall practice',
          ],
        ),
      );
    }

    return recommendations;
  }

  /// Get recommendations based on streak
  List<PracticeRecommendation> _getStreakRecommendations(int streak) {
    return [
      PracticeRecommendation(
        id: 'streak_challenge',
        title: 'Streak Master Challenge',
        description:
            'Level up your $streak-day streak with an advanced practice',
        type: PracticeType.meditation,
        durationMinutes: 20,
        confidenceScore: 0.70,
        reasons: [
          'You have a $streak-day streak - you\'re ready for more',
          'Challenge yourself to grow',
          'Extended session for experienced practitioners',
        ],
      ),
    ];
  }

  /// Get adaptive duration recommendations
  List<PracticeRecommendation> _getAdaptiveDurationRecommendations(
    int avgDuration,
  ) {
    if (avgDuration < 10) {
      return [
        PracticeRecommendation(
          id: 'adaptive_increase',
          title: 'Gradually Extend Your Practice',
          description: 'Try a slightly longer session',
          type: PracticeType.breathing,
          durationMinutes: avgDuration + 3,
          confidenceScore: 0.68,
          reasons: [
            'Your average is $avgDuration minutes',
            'Gradual increases build capacity',
          ],
        ),
      ];
    } else if (avgDuration > 20) {
      return [
        PracticeRecommendation(
          id: 'adaptive_quick',
          title: 'Quick Refresh',
          description: 'Sometimes less is more',
          type: PracticeType.breathing,
          durationMinutes: 5,
          confidenceScore: 0.72,
          reasons: [
            'Your sessions average $avgDuration minutes',
            'Short sessions maintain consistency',
            'Perfect for busy days',
          ],
        ),
      ];
    }

    return [];
  }

  /// Remove duplicates and adjust confidence scores
  List<PracticeRecommendation> _deduplicateAndScore(
    List<PracticeRecommendation> recommendations,
  ) {
    final seen = <String>{};
    final unique = <PracticeRecommendation>[];

    for (var rec in recommendations) {
      if (!seen.contains(rec.id)) {
        seen.add(rec.id);
        unique.add(rec);
      }
    }

    return unique;
  }

  String _getTypeName(PracticeType type) {
    switch (type) {
      case PracticeType.breathing:
        return 'Breathing';
      case PracticeType.meditation:
        return 'Meditation';
      case PracticeType.bodyScan:
        return 'Body Scan';
      case PracticeType.pmr:
        return 'PMR';
      case PracticeType.custom:
        return 'Custom';
    }
  }

  /// Get time of day from current time
  static TimeOfDay getCurrentTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return TimeOfDay.morning;
    if (hour >= 12 && hour < 17) return TimeOfDay.afternoon;
    if (hour >= 17 && hour < 21) return TimeOfDay.evening;
    return TimeOfDay.night;
  }
}
