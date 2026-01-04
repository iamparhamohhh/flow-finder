// lib/models/analytics_model.dart

import 'tracking_model.dart';

enum ReportPeriod { weekly, monthly, quarterly, yearly }

enum TrendDirection { improving, stable, declining }

// Analytics Report
class AnalyticsReport {
  final String id;
  final ReportPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime generatedAt;

  // Practice Statistics
  final int totalPractices;
  final int totalMinutes;
  final double averageDailyPractices;
  final int longestStreak;
  final int currentStreak;
  final Map<String, int> practiceTypeBreakdown; // type -> count

  // Mood Statistics
  final double averageMoodRating; // 1-5
  final double moodImprovement; // Average post-practice improvement
  final TrendDirection moodTrend;
  final Map<MoodRating, int> moodDistribution;

  // Sleep Statistics
  final double? averageSleepHours;
  final double? averageSleepQuality; // 1-5
  final TrendDirection? sleepTrend;
  final List<PracticeSleepCorrelation>? sleepCorrelations;

  // Stress Statistics
  final double? averageStressLevel; // 1-5
  final TrendDirection? stressTrend;
  final Map<String, int>? topStressTriggers; // trigger -> count
  final Map<String, int>? commonSymptoms; // symptom -> count

  // Insights
  final List<String> keyInsights;
  final List<String> recommendations;

  AnalyticsReport({
    required this.id,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.generatedAt,
    required this.totalPractices,
    required this.totalMinutes,
    required this.averageDailyPractices,
    required this.longestStreak,
    required this.currentStreak,
    required this.practiceTypeBreakdown,
    required this.averageMoodRating,
    required this.moodImprovement,
    required this.moodTrend,
    required this.moodDistribution,
    this.averageSleepHours,
    this.averageSleepQuality,
    this.sleepTrend,
    this.sleepCorrelations,
    this.averageStressLevel,
    this.stressTrend,
    this.topStressTriggers,
    this.commonSymptoms,
    required this.keyInsights,
    required this.recommendations,
  });

  String get periodLabel {
    switch (period) {
      case ReportPeriod.weekly:
        return 'Weekly Report';
      case ReportPeriod.monthly:
        return 'Monthly Report';
      case ReportPeriod.quarterly:
        return 'Quarterly Report';
      case ReportPeriod.yearly:
        return 'Yearly Report';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'period': period.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'generatedAt': generatedAt.toIso8601String(),
      'totalPractices': totalPractices,
      'totalMinutes': totalMinutes,
      'averageDailyPractices': averageDailyPractices,
      'longestStreak': longestStreak,
      'currentStreak': currentStreak,
      'practiceTypeBreakdown': practiceTypeBreakdown,
      'averageMoodRating': averageMoodRating,
      'moodImprovement': moodImprovement,
      'moodTrend': moodTrend.name,
      'moodDistribution': moodDistribution.map((k, v) => MapEntry(k.name, v)),
      'averageSleepHours': averageSleepHours,
      'averageSleepQuality': averageSleepQuality,
      'sleepTrend': sleepTrend?.name,
      'averageStressLevel': averageStressLevel,
      'stressTrend': stressTrend?.name,
      'topStressTriggers': topStressTriggers,
      'commonSymptoms': commonSymptoms,
      'keyInsights': keyInsights,
      'recommendations': recommendations,
    };
  }
}

// Trend Analysis
class TrendAnalysis {
  final String metric; // e.g., "mood", "sleep", "stress"
  final TrendDirection direction;
  final double changePercentage; // positive or negative
  final List<DataPoint> dataPoints;

  TrendAnalysis({
    required this.metric,
    required this.direction,
    required this.changePercentage,
    required this.dataPoints,
  });

  String get trendDescription {
    final absChange = changePercentage.abs().toStringAsFixed(1);
    switch (direction) {
      case TrendDirection.improving:
        return 'Improving by $absChange%';
      case TrendDirection.stable:
        return 'Stable (±$absChange%)';
      case TrendDirection.declining:
        return 'Declining by $absChange%';
    }
  }
}

// Data Point for charts
class DataPoint {
  final DateTime date;
  final double value;
  final String? label;

  DataPoint({required this.date, required this.value, this.label});
}

// Insight (AI-generated or rule-based insight)
class Insight {
  final String id;
  final String title;
  final String description;
  final InsightType type;
  final InsightPriority priority;
  final DateTime generatedAt;
  final List<String> supportingData;

  Insight({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.generatedAt,
    this.supportingData = const [],
  });
}

enum InsightType {
  positive, // Good news
  suggestion, // Recommendation
  warning, // Something to watch
  milestone, // Achievement
}

enum InsightPriority { low, medium, high }

// Export Data Format
class ExportData {
  final String userId;
  final DateTime exportDate;
  final DateTime startDate;
  final DateTime endDate;
  final List<MoodJournalEntry> moodEntries;
  final List<SleepEntry> sleepEntries;
  final List<StressEntry> stressEntries;
  final List<DailyCheckIn> dailyCheckIns;
  final AnalyticsReport? report;

  ExportData({
    required this.userId,
    required this.exportDate,
    required this.startDate,
    required this.endDate,
    required this.moodEntries,
    required this.sleepEntries,
    required this.stressEntries,
    required this.dailyCheckIns,
    this.report,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'exportDate': exportDate.toIso8601String(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'moodEntries': moodEntries.map((e) => e.toJson()).toList(),
      'sleepEntries': sleepEntries.map((e) => e.toJson()).toList(),
      'stressEntries': stressEntries.map((e) => e.toJson()).toList(),
      'dailyCheckIns': dailyCheckIns.map((e) => e.toJson()).toList(),
      'report': report?.toJson(),
    };
  }
}

// Statistics Summary (for dashboard widgets)
class StatisticsSummary {
  final DateTime period;
  final int practiceCount;
  final double averageMood;
  final double? averageSleep;
  final double? averageStress;
  final TrendDirection moodTrend;
  final TrendDirection? sleepTrend;
  final TrendDirection? stressTrend;

  StatisticsSummary({
    required this.period,
    required this.practiceCount,
    required this.averageMood,
    this.averageSleep,
    this.averageStress,
    required this.moodTrend,
    this.sleepTrend,
    this.stressTrend,
  });
}
