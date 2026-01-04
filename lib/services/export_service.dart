// lib/services/export_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/tracking_model.dart';
import '../models/analytics_model.dart';
import 'tracking_service.dart';

class ExportService {
  final TrackingService _trackingService;

  ExportService({TrackingService? trackingService})
    : _trackingService = trackingService ?? TrackingService();

  // Export data as CSV
  Future<String> exportToCSV({
    required DateTime startDate,
    required DateTime endDate,
    required String userId,
  }) async {
    final exportData = await _collectExportData(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    final csvContent = _generateCSV(exportData);
    final file = await _saveToFile(
      content: csvContent,
      fileName:
          'flow_finder_data_${_formatDateForFilename(DateTime.now())}.csv',
    );

    return file.path;
  }

  // Export data as JSON
  Future<String> exportToJSON({
    required DateTime startDate,
    required DateTime endDate,
    required String userId,
    AnalyticsReport? report,
  }) async {
    final exportData = await _collectExportData(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
      report: report,
    );

    final jsonContent = const JsonEncoder.withIndent(
      '  ',
    ).convert(exportData.toJson());
    final file = await _saveToFile(
      content: jsonContent,
      fileName:
          'flow_finder_data_${_formatDateForFilename(DateTime.now())}.json',
    );

    return file.path;
  }

  // Export report as plain text
  Future<String> exportReportAsText(AnalyticsReport report) async {
    final textContent = _generateReportText(report);
    final file = await _saveToFile(
      content: textContent,
      fileName:
          'flow_finder_report_${_formatDateForFilename(DateTime.now())}.txt',
    );

    return file.path;
  }

  // Share exported file
  Future<void> shareExportedFile(String filePath) async {
    await Share.shareXFiles([XFile(filePath)]);
  }

  // Collect all export data
  Future<ExportData> _collectExportData({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
    AnalyticsReport? report,
  }) async {
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

    final dailyCheckIns = await _trackingService.getDailyCheckIns(
      startDate: startDate,
      endDate: endDate,
    );

    return ExportData(
      userId: userId,
      exportDate: DateTime.now(),
      startDate: startDate,
      endDate: endDate,
      moodEntries: moodEntries,
      sleepEntries: sleepEntries,
      stressEntries: stressEntries,
      dailyCheckIns: dailyCheckIns,
      report: report,
    );
  }

  // Generate CSV content
  String _generateCSV(ExportData data) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('Flow Finder Export');
    buffer.writeln('Export Date: ${_formatDateTime(data.exportDate)}');
    buffer.writeln(
      'Period: ${_formatDate(data.startDate)} to ${_formatDate(data.endDate)}',
    );
    buffer.writeln('User ID: ${data.userId}');
    buffer.writeln('');

    // Mood Journal CSV
    if (data.moodEntries.isNotEmpty) {
      buffer.writeln('=== MOOD JOURNAL ===');
      buffer.writeln(
        'Date,Time,Pre-Mood,Post-Mood,Practice,Mood Change,Tags,Notes',
      );
      for (var entry in data.moodEntries) {
        buffer.writeln(_moodEntryToCSVRow(entry));
      }
      buffer.writeln('');
    }

    // Sleep Tracking CSV
    if (data.sleepEntries.isNotEmpty) {
      buffer.writeln('=== SLEEP TRACKING ===');
      buffer.writeln(
        'Date,Bedtime,Wake Time,Hours,Quality,Awake Count,Felt Rested,Practices Before Sleep,Notes',
      );
      for (var entry in data.sleepEntries) {
        buffer.writeln(_sleepEntryToCSVRow(entry));
      }
      buffer.writeln('');
    }

    // Stress Monitoring CSV
    if (data.stressEntries.isNotEmpty) {
      buffer.writeln('=== STRESS MONITORING ===');
      buffer.writeln('Date,Time,Level,Triggers,Symptoms,Coping Strategy,Notes');
      for (var entry in data.stressEntries) {
        buffer.writeln(_stressEntryToCSVRow(entry));
      }
      buffer.writeln('');
    }

    // Daily Check-ins CSV
    if (data.dailyCheckIns.isNotEmpty) {
      buffer.writeln('=== DAILY CHECK-INS ===');
      buffer.writeln(
        'Date,Mood,Stress,Energy,Sleep Quality,Practice Count,Highlights,Challenges',
      );
      for (var entry in data.dailyCheckIns) {
        buffer.writeln(_dailyCheckInToCSVRow(entry));
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }

  // Generate report text
  String _generateReportText(AnalyticsReport report) {
    final buffer = StringBuffer();

    // Header
    buffer.writeln('=' * 60);
    buffer.writeln('FLOW FINDER ${report.periodLabel.toUpperCase()}');
    buffer.writeln('=' * 60);
    buffer.writeln('');
    buffer.writeln(
      'Period: ${_formatDate(report.startDate)} to ${_formatDate(report.endDate)}',
    );
    buffer.writeln('Generated: ${_formatDateTime(report.generatedAt)}');
    buffer.writeln('');

    // Practice Statistics
    buffer.writeln('PRACTICE STATISTICS');
    buffer.writeln('-' * 60);
    buffer.writeln('Total Practices: ${report.totalPractices}');
    buffer.writeln('Total Minutes: ${report.totalMinutes}');
    buffer.writeln(
      'Average Daily Practices: ${report.averageDailyPractices.toStringAsFixed(1)}',
    );
    buffer.writeln('Longest Streak: ${report.longestStreak} days');
    buffer.writeln('Current Streak: ${report.currentStreak} days');
    buffer.writeln('');
    buffer.writeln('Practice Type Breakdown:');
    report.practiceTypeBreakdown.forEach((type, count) {
      buffer.writeln('  - $type: $count');
    });
    buffer.writeln('');

    // Mood Statistics
    buffer.writeln('MOOD STATISTICS');
    buffer.writeln('-' * 60);
    buffer.writeln(
      'Average Mood Rating: ${report.averageMoodRating.toStringAsFixed(1)}/5',
    );
    buffer.writeln(
      'Average Mood Improvement: +${report.moodImprovement.toStringAsFixed(1)}',
    );
    buffer.writeln('Trend: ${_getTrendLabel(report.moodTrend)}');
    buffer.writeln('');

    // Sleep Statistics
    if (report.averageSleepHours != null) {
      buffer.writeln('SLEEP STATISTICS');
      buffer.writeln('-' * 60);
      buffer.writeln(
        'Average Hours: ${report.averageSleepHours!.toStringAsFixed(1)}',
      );
      buffer.writeln(
        'Average Quality: ${report.averageSleepQuality!.toStringAsFixed(1)}/5',
      );
      buffer.writeln('Trend: ${_getTrendLabel(report.sleepTrend!)}');
      buffer.writeln('');
    }

    // Stress Statistics
    if (report.averageStressLevel != null) {
      buffer.writeln('STRESS STATISTICS');
      buffer.writeln('-' * 60);
      buffer.writeln(
        'Average Level: ${report.averageStressLevel!.toStringAsFixed(1)}/5',
      );
      buffer.writeln('Trend: ${_getTrendLabel(report.stressTrend!)}');
      if (report.topStressTriggers != null &&
          report.topStressTriggers!.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('Top Stress Triggers:');
        final sortedTriggers = report.topStressTriggers!.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        for (var trigger in sortedTriggers.take(5)) {
          buffer.writeln('  - ${trigger.key}: ${trigger.value} times');
        }
      }
      buffer.writeln('');
    }

    // Key Insights
    if (report.keyInsights.isNotEmpty) {
      buffer.writeln('KEY INSIGHTS');
      buffer.writeln('-' * 60);
      for (var i = 0; i < report.keyInsights.length; i++) {
        buffer.writeln('${i + 1}. ${report.keyInsights[i]}');
      }
      buffer.writeln('');
    }

    // Recommendations
    if (report.recommendations.isNotEmpty) {
      buffer.writeln('RECOMMENDATIONS');
      buffer.writeln('-' * 60);
      for (var i = 0; i < report.recommendations.length; i++) {
        buffer.writeln('${i + 1}. ${report.recommendations[i]}');
      }
      buffer.writeln('');
    }

    buffer.writeln('=' * 60);
    buffer.writeln('End of Report');
    buffer.writeln('=' * 60);

    return buffer.toString();
  }

  // Helper methods for CSV rows
  String _moodEntryToCSVRow(MoodJournalEntry entry) {
    return [
      _formatDate(entry.timestamp),
      _formatTime(entry.timestamp),
      entry.preMood.label,
      entry.postMood?.label ?? '',
      entry.practiceName ?? '',
      entry.hasPostMood ? entry.moodImprovement.toString() : '',
      entry.tags.join('; '),
      _escapeCsvValue(entry.notes ?? ''),
    ].join(',');
  }

  String _sleepEntryToCSVRow(SleepEntry entry) {
    return [
      _formatDate(entry.date),
      _formatTime(entry.bedtime),
      _formatTime(entry.wakeTime),
      entry.hoursSlept.toStringAsFixed(1),
      entry.quality.label,
      entry.awakeDuringNight?.toString() ?? '',
      entry.feltRested?.toString() ?? '',
      entry.practicesBeforeSleep.join('; '),
      _escapeCsvValue(entry.notes ?? ''),
    ].join(',');
  }

  String _stressEntryToCSVRow(StressEntry entry) {
    return [
      _formatDate(entry.timestamp),
      _formatTime(entry.timestamp),
      entry.level.label,
      entry.triggers.join('; '),
      entry.symptoms.join('; '),
      _escapeCsvValue(entry.copingStrategy ?? ''),
      _escapeCsvValue(entry.notes ?? ''),
    ].join(',');
  }

  String _dailyCheckInToCSVRow(DailyCheckIn entry) {
    return [
      _formatDate(entry.date),
      entry.overallMood?.label ?? '',
      entry.stressLevel?.label ?? '',
      entry.energyLevel?.toString() ?? '',
      entry.lastNightSleep?.label ?? '',
      entry.practiceCount?.toString() ?? '',
      _escapeCsvValue(entry.highlights ?? ''),
      _escapeCsvValue(entry.challenges ?? ''),
    ].join(',');
  }

  // File operations
  Future<File> _saveToFile({
    required String content,
    required String fileName,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);
    return file;
  }

  // Formatting helpers
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  String _formatDateForFilename(DateTime date) {
    return DateFormat('yyyyMMdd_HHmmss').format(date);
  }

  String _escapeCsvValue(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _getTrendLabel(TrendDirection trend) {
    switch (trend) {
      case TrendDirection.improving:
        return '📈 Improving';
      case TrendDirection.stable:
        return '➡️ Stable';
      case TrendDirection.declining:
        return '📉 Declining';
    }
  }
}
