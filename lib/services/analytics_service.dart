// lib/services/analytics_service.dart

import 'package:uuid/uuid.dart';
import '../models/tracking_model.dart';
import '../models/analytics_model.dart';
import 'tracking_service.dart';

class AnalyticsService {
  final TrackingService _trackingService;
  final _uuid = const Uuid();

  AnalyticsService({TrackingService? trackingService})
    : _trackingService = trackingService ?? TrackingService();

  // Generate comprehensive analytics report
  Future<AnalyticsReport> generateReport({
    required ReportPeriod period,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) async {
    // Calculate date range based on period
    final endDate = customEndDate ?? DateTime.now();
    final startDate = customStartDate ?? _getStartDate(period, endDate);

    // Fetch all data for the period
    final moodEntries = await _trackingService.getMoodEntries(
      startDate: startDate,
      endDate: endDate,
    );
    final sleepEntries = await _trackingService.getSleepEntries(
      startDate: startDate,
      endDate: endDate,
    );
    final stressEntries = await _trackingService.getStressEntries(
      startDate: startDate,
      endDate: endDate,
    );

    // Calculate practice statistics (mock for now - will integrate with activity provider)
    final practiceStats = _calculatePracticeStats(startDate, endDate);

    // Calculate mood statistics
    final moodStats = _calculateMoodStats(moodEntries);

    // Calculate sleep statistics
    final sleepStats = _calculateSleepStats(sleepEntries);

    // Calculate stress statistics
    final stressStats = _calculateStressStats(stressEntries);

    // Generate insights and recommendations
    final insights = _generateInsights(
      moodStats,
      sleepStats,
      stressStats,
      practiceStats,
    );
    final recommendations = _generateRecommendations(
      moodStats,
      sleepStats,
      stressStats,
    );

    return AnalyticsReport(
      id: _uuid.v4(),
      period: period,
      startDate: startDate,
      endDate: endDate,
      generatedAt: DateTime.now(),
      totalPractices: practiceStats['total'] ?? 0,
      totalMinutes: practiceStats['totalMinutes'] ?? 0,
      averageDailyPractices: practiceStats['averageDaily'] ?? 0.0,
      longestStreak: practiceStats['longestStreak'] ?? 0,
      currentStreak: practiceStats['currentStreak'] ?? 0,
      practiceTypeBreakdown: practiceStats['breakdown'] ?? {},
      averageMoodRating: moodStats['average'] ?? 0.0,
      moodImprovement: moodStats['improvement'] ?? 0.0,
      moodTrend: moodStats['trend'] ?? TrendDirection.stable,
      moodDistribution: moodStats['distribution'] ?? {},
      averageSleepHours: sleepStats['averageHours'],
      averageSleepQuality: sleepStats['averageQuality'],
      sleepTrend: sleepStats['trend'],
      sleepCorrelations: sleepStats['correlations'],
      averageStressLevel: stressStats['average'],
      stressTrend: stressStats['trend'],
      topStressTriggers: stressStats['topTriggers'],
      commonSymptoms: stressStats['commonSymptoms'],
      keyInsights: insights,
      recommendations: recommendations,
    );
  }

  // Calculate trend for a metric
  Future<TrendAnalysis> calculateTrend({
    required String metric,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    List<DataPoint> dataPoints = [];

    if (metric == 'mood') {
      final entries = await _trackingService.getMoodEntries(
        startDate: startDate,
        endDate: endDate,
      );
      dataPoints = _aggregateMoodDataPoints(entries);
    } else if (metric == 'sleep') {
      final entries = await _trackingService.getSleepEntries(
        startDate: startDate,
        endDate: endDate,
      );
      dataPoints = _aggregateSleepDataPoints(entries);
    } else if (metric == 'stress') {
      final entries = await _trackingService.getStressEntries(
        startDate: startDate,
        endDate: endDate,
      );
      dataPoints = _aggregateStressDataPoints(entries);
    }

    final trend = _analyzeTrend(dataPoints);
    final changePercentage = _calculateChangePercentage(dataPoints);

    return TrendAnalysis(
      metric: metric,
      direction: trend,
      changePercentage: changePercentage,
      dataPoints: dataPoints,
    );
  }

  // Generate insights based on data
  Future<List<Insight>> generateInsights({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    List<Insight> insights = [];

    final moodEntries = await _trackingService.getMoodEntries(
      startDate: startDate,
      endDate: endDate,
    );
    final sleepEntries = await _trackingService.getSleepEntries(
      startDate: startDate,
      endDate: endDate,
    );
    final stressEntries = await _trackingService.getStressEntries(
      startDate: startDate,
      endDate: endDate,
    );

    // Mood improvement insight
    final moodImprovements = moodEntries
        .where((e) => e.hasPostMood && e.moodImprovement > 0)
        .length;
    if (moodImprovements > moodEntries.length * 0.7) {
      insights.add(
        Insight(
          id: _uuid.v4(),
          title: 'Great Progress! 🎉',
          description:
              'Your mood improved after ${(moodImprovements / moodEntries.length * 100).toInt()}% of your practices!',
          type: InsightType.positive,
          priority: InsightPriority.high,
          generatedAt: DateTime.now(),
        ),
      );
    }

    // Sleep quality insight
    if (sleepEntries.isNotEmpty) {
      final avgQuality =
          sleepEntries.map((e) => e.quality.index + 1).reduce((a, b) => a + b) /
          sleepEntries.length;
      if (avgQuality >= 4.0) {
        insights.add(
          Insight(
            id: _uuid.v4(),
            title: 'Excellent Sleep Quality 😴',
            description:
                'Your average sleep quality is ${avgQuality.toStringAsFixed(1)}/5. Keep it up!',
            type: InsightType.positive,
            priority: InsightPriority.medium,
            generatedAt: DateTime.now(),
          ),
        );
      } else if (avgQuality < 3.0) {
        insights.add(
          Insight(
            id: _uuid.v4(),
            title: 'Sleep Needs Attention 🌙',
            description:
                'Your sleep quality has been below average. Try evening relaxation practices.',
            type: InsightType.suggestion,
            priority: InsightPriority.high,
            generatedAt: DateTime.now(),
          ),
        );
      }
    }

    // Stress trend insight
    if (stressEntries.length >= 7) {
      final recentStress = stressEntries.take(3).map((e) => e.level.index + 1);
      final olderStress = stressEntries
          .skip(stressEntries.length - 3)
          .map((e) => e.level.index + 1);
      final recentAvg = recentStress.reduce((a, b) => a + b) / 3;
      final olderAvg = olderStress.reduce((a, b) => a + b) / 3;

      if (recentAvg < olderAvg - 0.5) {
        insights.add(
          Insight(
            id: _uuid.v4(),
            title: 'Stress Levels Improving 😌',
            description:
                'Your stress has decreased by ${((olderAvg - recentAvg) / olderAvg * 100).toInt()}%!',
            type: InsightType.positive,
            priority: InsightPriority.medium,
            generatedAt: DateTime.now(),
          ),
        );
      }
    }

    return insights;
  }

  // Private helper methods
  DateTime _getStartDate(ReportPeriod period, DateTime endDate) {
    switch (period) {
      case ReportPeriod.weekly:
        return endDate.subtract(const Duration(days: 7));
      case ReportPeriod.monthly:
        return endDate.subtract(const Duration(days: 30));
      case ReportPeriod.quarterly:
        return endDate.subtract(const Duration(days: 90));
      case ReportPeriod.yearly:
        return endDate.subtract(const Duration(days: 365));
    }
  }

  Map<String, dynamic> _calculatePracticeStats(
    DateTime startDate,
    DateTime endDate,
  ) {
    // Mock data - will integrate with actual activity provider
    final days = endDate.difference(startDate).inDays + 1;
    return {
      'total': 45,
      'totalMinutes': 675,
      'averageDaily': 45 / days,
      'longestStreak': 12,
      'currentStreak': 7,
      'breakdown': {
        'Breathing': 20,
        'Meditation': 15,
        'Body Scan': 6,
        'PMR': 4,
      },
    };
  }

  Map<String, dynamic> _calculateMoodStats(List<MoodJournalEntry> entries) {
    if (entries.isEmpty) {
      return {
        'average': 0.0,
        'improvement': 0.0,
        'trend': TrendDirection.stable,
        'distribution': {},
      };
    }

    final avgMood =
        entries.map((e) => e.preMood.index + 1).reduce((a, b) => a + b) /
        entries.length;

    final withPostMood = entries.where((e) => e.hasPostMood).toList();
    final avgImprovement = withPostMood.isEmpty
        ? 0.0
        : withPostMood.map((e) => e.moodImprovement).reduce((a, b) => a + b) /
              withPostMood.length;

    final distribution = <MoodRating, int>{};
    for (var mood in MoodRating.values) {
      distribution[mood] = entries.where((e) => e.preMood == mood).length;
    }

    final trend = _calculateMoodTrend(entries);

    return {
      'average': avgMood,
      'improvement': avgImprovement,
      'trend': trend,
      'distribution': distribution,
    };
  }

  Map<String, dynamic> _calculateSleepStats(List<SleepEntry> entries) {
    if (entries.isEmpty) return {};

    final avgHours =
        entries.map((e) => e.hoursSlept).reduce((a, b) => a + b) /
        entries.length;
    final avgQuality =
        entries.map((e) => e.quality.index + 1).reduce((a, b) => a + b) /
        entries.length;
    final trend = _calculateSleepTrend(entries);

    return {
      'averageHours': avgHours,
      'averageQuality': avgQuality,
      'trend': trend,
      'correlations': <PracticeSleepCorrelation>[],
    };
  }

  Map<String, dynamic> _calculateStressStats(List<StressEntry> entries) {
    if (entries.isEmpty) return {};

    final avgStress =
        entries.map((e) => e.level.index + 1).reduce((a, b) => a + b) /
        entries.length;
    final trend = _calculateStressTrend(entries);

    final triggerCounts = <String, int>{};
    final symptomCounts = <String, int>{};

    for (var entry in entries) {
      for (var trigger in entry.triggers) {
        triggerCounts[trigger] = (triggerCounts[trigger] ?? 0) + 1;
      }
      for (var symptom in entry.symptoms) {
        symptomCounts[symptom] = (symptomCounts[symptom] ?? 0) + 1;
      }
    }

    return {
      'average': avgStress,
      'trend': trend,
      'topTriggers': triggerCounts,
      'commonSymptoms': symptomCounts,
    };
  }

  TrendDirection _calculateMoodTrend(List<MoodJournalEntry> entries) {
    if (entries.length < 3) return TrendDirection.stable;

    final sorted = List<MoodJournalEntry>.from(entries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final firstHalf = sorted.take(sorted.length ~/ 2);
    final secondHalf = sorted.skip(sorted.length ~/ 2);

    final firstAvg =
        firstHalf.map((e) => e.preMood.index + 1).reduce((a, b) => a + b) /
        firstHalf.length;
    final secondAvg =
        secondHalf.map((e) => e.preMood.index + 1).reduce((a, b) => a + b) /
        secondHalf.length;

    if (secondAvg > firstAvg + 0.3) return TrendDirection.improving;
    if (secondAvg < firstAvg - 0.3) return TrendDirection.declining;
    return TrendDirection.stable;
  }

  TrendDirection _calculateSleepTrend(List<SleepEntry> entries) {
    if (entries.length < 3) return TrendDirection.stable;

    final sorted = List<SleepEntry>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    final firstHalf = sorted.take(sorted.length ~/ 2);
    final secondHalf = sorted.skip(sorted.length ~/ 2);

    final firstAvg =
        firstHalf.map((e) => e.quality.index + 1).reduce((a, b) => a + b) /
        firstHalf.length;
    final secondAvg =
        secondHalf.map((e) => e.quality.index + 1).reduce((a, b) => a + b) /
        secondHalf.length;

    if (secondAvg > firstAvg + 0.3) return TrendDirection.improving;
    if (secondAvg < firstAvg - 0.3) return TrendDirection.declining;
    return TrendDirection.stable;
  }

  TrendDirection _calculateStressTrend(List<StressEntry> entries) {
    if (entries.length < 3) return TrendDirection.stable;

    final sorted = List<StressEntry>.from(entries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final firstHalf = sorted.take(sorted.length ~/ 2);
    final secondHalf = sorted.skip(sorted.length ~/ 2);

    final firstAvg =
        firstHalf.map((e) => e.level.index + 1).reduce((a, b) => a + b) /
        firstHalf.length;
    final secondAvg =
        secondHalf.map((e) => e.level.index + 1).reduce((a, b) => a + b) /
        secondHalf.length;

    // For stress, lower is better
    if (secondAvg < firstAvg - 0.3) return TrendDirection.improving;
    if (secondAvg > firstAvg + 0.3) return TrendDirection.declining;
    return TrendDirection.stable;
  }

  List<DataPoint> _aggregateMoodDataPoints(List<MoodJournalEntry> entries) {
    final dataPoints = <DataPoint>[];
    for (var entry in entries) {
      dataPoints.add(
        DataPoint(
          date: entry.timestamp,
          value: (entry.preMood.index + 1).toDouble(),
        ),
      );
    }
    return dataPoints;
  }

  List<DataPoint> _aggregateSleepDataPoints(List<SleepEntry> entries) {
    final dataPoints = <DataPoint>[];
    for (var entry in entries) {
      dataPoints.add(
        DataPoint(
          date: entry.date,
          value: (entry.quality.index + 1).toDouble(),
        ),
      );
    }
    return dataPoints;
  }

  List<DataPoint> _aggregateStressDataPoints(List<StressEntry> entries) {
    final dataPoints = <DataPoint>[];
    for (var entry in entries) {
      dataPoints.add(
        DataPoint(
          date: entry.timestamp,
          value: (entry.level.index + 1).toDouble(),
        ),
      );
    }
    return dataPoints;
  }

  TrendDirection _analyzeTrend(List<DataPoint> dataPoints) {
    if (dataPoints.length < 3) return TrendDirection.stable;

    final sorted = List<DataPoint>.from(dataPoints)
      ..sort((a, b) => a.date.compareTo(b.date));

    final firstHalf = sorted.take(sorted.length ~/ 2);
    final secondHalf = sorted.skip(sorted.length ~/ 2);

    final firstAvg =
        firstHalf.map((e) => e.value).reduce((a, b) => a + b) /
        firstHalf.length;
    final secondAvg =
        secondHalf.map((e) => e.value).reduce((a, b) => a + b) /
        secondHalf.length;

    if (secondAvg > firstAvg + 0.3) return TrendDirection.improving;
    if (secondAvg < firstAvg - 0.3) return TrendDirection.declining;
    return TrendDirection.stable;
  }

  double _calculateChangePercentage(List<DataPoint> dataPoints) {
    if (dataPoints.length < 2) return 0.0;

    final sorted = List<DataPoint>.from(dataPoints)
      ..sort((a, b) => a.date.compareTo(b.date));

    final firstValue = sorted.first.value;
    final lastValue = sorted.last.value;

    if (firstValue == 0) return 0.0;

    return ((lastValue - firstValue) / firstValue) * 100;
  }

  List<String> _generateInsights(
    Map<String, dynamic> moodStats,
    Map<String, dynamic> sleepStats,
    Map<String, dynamic> stressStats,
    Map<String, dynamic> practiceStats,
  ) {
    List<String> insights = [];

    // Practice insights
    final totalPractices = practiceStats['total'] ?? 0;
    if (totalPractices > 20) {
      insights.add(
        'You completed $totalPractices practices this period - excellent consistency!',
      );
    }

    // Mood insights
    final moodImprovement = moodStats['improvement'] ?? 0.0;
    if (moodImprovement > 0.5) {
      insights.add(
        'Practices are significantly improving your mood (+${moodImprovement.toStringAsFixed(1)} on average)',
      );
    }

    // Sleep insights
    if (sleepStats['averageHours'] != null) {
      final hours = sleepStats['averageHours'] as double;
      if (hours >= 7 && hours <= 9) {
        insights.add(
          'Your sleep duration is in the optimal range (${hours.toStringAsFixed(1)} hours)',
        );
      }
    }

    // Stress insights
    if (stressStats['average'] != null) {
      final stress = stressStats['average'] as double;
      if (stress <= 2.0) {
        insights.add(
          'Your stress levels are well-managed (${stress.toStringAsFixed(1)}/5)',
        );
      }
    }

    return insights;
  }

  List<String> _generateRecommendations(
    Map<String, dynamic> moodStats,
    Map<String, dynamic> sleepStats,
    Map<String, dynamic> stressStats,
  ) {
    List<String> recommendations = [];

    // Sleep recommendations
    if (sleepStats['averageHours'] != null) {
      final hours = sleepStats['averageHours'] as double;
      if (hours < 7) {
        recommendations.add(
          'Try evening relaxation practices to improve sleep duration',
        );
      }
      if (sleepStats['averageQuality'] != null &&
          (sleepStats['averageQuality'] as double) < 3.0) {
        recommendations.add(
          'Consider practicing 4-7-8 breathing before bed for better sleep quality',
        );
      }
    }

    // Stress recommendations
    if (stressStats['average'] != null) {
      final stress = stressStats['average'] as double;
      if (stress >= 4.0) {
        recommendations.add(
          'High stress detected - try daily stress reduction practices like PMR',
        );
      }
    }

    // Mood recommendations
    final moodImprovement = moodStats['improvement'] ?? 0.0;
    if (moodImprovement < 0.3) {
      recommendations.add(
        'Experiment with different practice types to find what works best for you',
      );
    }

    return recommendations;
  }
}
