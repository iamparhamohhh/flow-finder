// lib/services/tracking_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import '../models/tracking_model.dart';

class TrackingService {
  static const String _moodJournalBox = 'mood_journal';
  static const String _sleepEntriesBox = 'sleep_entries';
  static const String _stressEntriesBox = 'stress_entries';
  static const String _dailyCheckInsBox = 'daily_check_ins';

  // Initialize Hive boxes
  Future<void> init() async {
    await Hive.openBox(_moodJournalBox);
    await Hive.openBox(_sleepEntriesBox);
    await Hive.openBox(_stressEntriesBox);
    await Hive.openBox(_dailyCheckInsBox);
  }

  // Helper methods to safely get boxes (opens if not already open)
  Future<Box> _getMoodJournalBox() async {
    if (!Hive.isBoxOpen(_moodJournalBox)) {
      return await Hive.openBox(_moodJournalBox);
    }
    return Hive.box(_moodJournalBox);
  }

  Future<Box> _getSleepEntriesBox() async {
    if (!Hive.isBoxOpen(_sleepEntriesBox)) {
      return await Hive.openBox(_sleepEntriesBox);
    }
    return Hive.box(_sleepEntriesBox);
  }

  Future<Box> _getStressEntriesBox() async {
    if (!Hive.isBoxOpen(_stressEntriesBox)) {
      return await Hive.openBox(_stressEntriesBox);
    }
    return Hive.box(_stressEntriesBox);
  }

  Future<Box> _getDailyCheckInsBox() async {
    if (!Hive.isBoxOpen(_dailyCheckInsBox)) {
      return await Hive.openBox(_dailyCheckInsBox);
    }
    return Hive.box(_dailyCheckInsBox);
  }

  // ========== Mood Journal ==========

  Future<void> saveMoodEntry(MoodJournalEntry entry) async {
    final box = await _getMoodJournalBox();
    await box.put(entry.id, entry.toJson());
  }

  Future<void> updateMoodEntry(MoodJournalEntry entry) async {
    await saveMoodEntry(entry);
  }

  Future<MoodJournalEntry?> getMoodEntry(String id) async {
    final box = await _getMoodJournalBox();
    final data = box.get(id);
    if (data == null) return null;
    return MoodJournalEntry.fromJson(Map<String, dynamic>.from(data));
  }

  Future<List<MoodJournalEntry>> getMoodEntries({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    final box = await _getMoodJournalBox();
    List<MoodJournalEntry> entries = [];

    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        final entry = MoodJournalEntry.fromJson(
          Map<String, dynamic>.from(data),
        );

        // Filter by date range if provided
        if (startDate != null && entry.timestamp.isBefore(startDate)) continue;
        if (endDate != null && entry.timestamp.isAfter(endDate)) continue;

        entries.add(entry);
      }
    }

    // Sort by timestamp (newest first)
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Apply limit if provided
    if (limit != null && entries.length > limit) {
      entries = entries.take(limit).toList();
    }

    return entries;
  }

  Future<void> deleteMoodEntry(String id) async {
    final box = await _getMoodJournalBox();
    await box.delete(id);
  }

  // ========== Sleep Tracking ==========

  Future<void> saveSleepEntry(SleepEntry entry) async {
    final box = await _getSleepEntriesBox();
    await box.put(entry.id, entry.toJson());
  }

  Future<SleepEntry?> getSleepEntry(String id) async {
    final box = await _getSleepEntriesBox();
    final data = box.get(id);
    if (data == null) return null;
    return SleepEntry.fromJson(Map<String, dynamic>.from(data));
  }

  Future<List<SleepEntry>> getSleepEntries({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    final box = await _getSleepEntriesBox();
    List<SleepEntry> entries = [];

    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        final entry = SleepEntry.fromJson(Map<String, dynamic>.from(data));

        // Filter by date range
        if (startDate != null && entry.date.isBefore(startDate)) continue;
        if (endDate != null && entry.date.isAfter(endDate)) continue;

        entries.add(entry);
      }
    }

    // Sort by date (newest first)
    entries.sort((a, b) => b.date.compareTo(a.date));

    if (limit != null && entries.length > limit) {
      entries = entries.take(limit).toList();
    }

    return entries;
  }

  Future<void> deleteSleepEntry(String id) async {
    final box = await _getSleepEntriesBox();
    await box.delete(id);
  }

  // ========== Stress Monitoring ==========

  Future<void> saveStressEntry(StressEntry entry) async {
    final box = await _getStressEntriesBox();
    await box.put(entry.id, entry.toJson());
  }

  Future<StressEntry?> getStressEntry(String id) async {
    final box = await _getStressEntriesBox();
    final data = box.get(id);
    if (data == null) return null;
    return StressEntry.fromJson(Map<String, dynamic>.from(data));
  }

  Future<List<StressEntry>> getStressEntries({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    final box = await _getStressEntriesBox();
    List<StressEntry> entries = [];

    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        final entry = StressEntry.fromJson(Map<String, dynamic>.from(data));

        // Filter by date range
        if (startDate != null && entry.timestamp.isBefore(startDate)) continue;
        if (endDate != null && entry.timestamp.isAfter(endDate)) continue;

        entries.add(entry);
      }
    }

    // Sort by timestamp (newest first)
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (limit != null && entries.length > limit) {
      entries = entries.take(limit).toList();
    }

    return entries;
  }

  Future<void> deleteStressEntry(String id) async {
    final box = await _getStressEntriesBox();
    await box.delete(id);
  }

  // ========== Daily Check-ins ==========

  Future<void> saveDailyCheckIn(DailyCheckIn checkIn) async {
    final box = await _getDailyCheckInsBox();
    await box.put(checkIn.id, checkIn.toJson());
  }

  Future<DailyCheckIn?> getDailyCheckIn(String id) async {
    final box = await _getDailyCheckInsBox();
    final data = box.get(id);
    if (data == null) return null;
    return DailyCheckIn.fromJson(Map<String, dynamic>.from(data));
  }

  Future<DailyCheckIn?> getCheckInForDate(DateTime date) async {
    final box = await _getDailyCheckInsBox();

    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        final checkIn = DailyCheckIn.fromJson(Map<String, dynamic>.from(data));
        if (_isSameDay(checkIn.date, date)) {
          return checkIn;
        }
      }
    }

    return null;
  }

  Future<List<DailyCheckIn>> getDailyCheckIns({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    final box = await _getDailyCheckInsBox();
    List<DailyCheckIn> entries = [];

    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        final entry = DailyCheckIn.fromJson(Map<String, dynamic>.from(data));

        // Filter by date range
        if (startDate != null && entry.date.isBefore(startDate)) continue;
        if (endDate != null && entry.date.isAfter(endDate)) continue;

        entries.add(entry);
      }
    }

    // Sort by date (newest first)
    entries.sort((a, b) => b.date.compareTo(a.date));

    if (limit != null && entries.length > limit) {
      entries = entries.take(limit).toList();
    }

    return entries;
  }

  Future<void> deleteDailyCheckIn(String id) async {
    final box = await _getDailyCheckInsBox();
    await box.delete(id);
  }

  // ========== Analytics & Statistics ==========

  Future<Map<String, dynamic>> getStatistics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final moodEntries = await getMoodEntries(
      startDate: startDate,
      endDate: endDate,
    );
    final sleepEntries = await getSleepEntries(
      startDate: startDate,
      endDate: endDate,
    );
    final stressEntries = await getStressEntries(
      startDate: startDate,
      endDate: endDate,
    );

    return {
      'totalMoodEntries': moodEntries.length,
      'totalSleepEntries': sleepEntries.length,
      'totalStressEntries': stressEntries.length,
      'averageMoodRating': _calculateAverageMoodRating(moodEntries),
      'averageSleepQuality': _calculateAverageSleepQuality(sleepEntries),
      'averageSleepHours': _calculateAverageSleepHours(sleepEntries),
      'averageStressLevel': _calculateAverageStressLevel(stressEntries),
      'moodImprovementRate': _calculateMoodImprovementRate(moodEntries),
    };
  }

  // Helper methods for statistics
  double _calculateAverageMoodRating(List<MoodJournalEntry> entries) {
    if (entries.isEmpty) return 0;
    final sum = entries.fold<int>(0, (sum, e) => sum + (e.preMood.index + 1));
    return sum / entries.length;
  }

  double _calculateAverageSleepQuality(List<SleepEntry> entries) {
    if (entries.isEmpty) return 0;
    final sum = entries.fold<int>(0, (sum, e) => sum + (e.quality.index + 1));
    return sum / entries.length;
  }

  double _calculateAverageSleepHours(List<SleepEntry> entries) {
    if (entries.isEmpty) return 0;
    final sum = entries.fold<double>(0, (sum, e) => sum + e.hoursSlept);
    return sum / entries.length;
  }

  double _calculateAverageStressLevel(List<StressEntry> entries) {
    if (entries.isEmpty) return 0;
    final sum = entries.fold<int>(0, (sum, e) => sum + (e.level.index + 1));
    return sum / entries.length;
  }

  double _calculateMoodImprovementRate(List<MoodJournalEntry> entries) {
    final entriesWithPostMood = entries.where((e) => e.hasPostMood).toList();
    if (entriesWithPostMood.isEmpty) return 0;

    final improvements = entriesWithPostMood.where(
      (e) => e.moodImprovement > 0,
    );
    return improvements.length / entriesWithPostMood.length;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    final moodBox = await _getMoodJournalBox();
    final sleepBox = await _getSleepEntriesBox();
    final stressBox = await _getStressEntriesBox();
    final checkInsBox = await _getDailyCheckInsBox();

    await moodBox.clear();
    await sleepBox.clear();
    await stressBox.clear();
    await checkInsBox.clear();
  }
}
