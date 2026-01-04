import 'package:flutter/material.dart';
import '../models/tracking_model.dart';
import '../services/tracking_service.dart';

/// Provider for managing all tracking features
/// Handles mood journal, sleep tracking, stress monitoring, and daily check-ins
class TrackingProvider extends ChangeNotifier {
  final TrackingService _trackingService;

  // Cached data for performance
  List<MoodJournalEntry>? _recentMoodEntries;
  List<SleepEntry>? _recentSleepEntries;
  List<StressEntry>? _recentStressEntries;
  List<DailyCheckIn>? _recentCheckIns;
  Map<String, dynamic>? _currentStatistics;

  bool _isLoading = false;
  String? _error;

  TrackingProvider({TrackingService? trackingService})
    : _trackingService = trackingService ?? TrackingService();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<MoodJournalEntry> get recentMoodEntries => _recentMoodEntries ?? [];
  List<SleepEntry> get recentSleepEntries => _recentSleepEntries ?? [];
  List<StressEntry> get recentStressEntries => _recentStressEntries ?? [];
  List<DailyCheckIn> get recentCheckIns => _recentCheckIns ?? [];
  Map<String, dynamic>? get currentStatistics => _currentStatistics;

  /// Initialize provider by loading recent data
  Future<void> initialize() async {
    await Future.wait([
      loadRecentMoodEntries(),
      loadRecentSleepEntries(),
      loadRecentStressEntries(),
      loadRecentCheckIns(),
      loadStatistics(),
    ]);
  }

  // ==================== MOOD JOURNAL ====================

  /// Add a new mood journal entry
  Future<void> addMoodEntry({
    required MoodRating preMood,
    MoodRating? postMood,
    String? practiceId,
    String? practiceName,
    List<String>? tags,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final entry = MoodJournalEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        preMood: preMood,
        postMood: postMood,
        practiceId: practiceId,
        practiceName: practiceName,
        tags: tags ?? [],
        notes: notes,
      );

      await _trackingService.saveMoodEntry(entry);
      await loadRecentMoodEntries();
      await loadStatistics();
    } catch (e) {
      _setError('Failed to add mood entry: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing mood entry (e.g., add post-practice mood)
  Future<void> updateMoodEntry({
    required String id,
    MoodRating? postMood,
    List<String>? tags,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final existing = await _trackingService.getMoodEntry(id);
      if (existing == null) {
        throw Exception('Mood entry not found');
      }

      final updated = MoodJournalEntry(
        id: existing.id,
        timestamp: existing.timestamp,
        preMood: existing.preMood,
        postMood: postMood ?? existing.postMood,
        practiceId: existing.practiceId,
        practiceName: existing.practiceName,
        tags: tags ?? existing.tags,
        notes: notes ?? existing.notes,
      );

      await _trackingService.updateMoodEntry(updated);
      await loadRecentMoodEntries();
      await loadStatistics();
    } catch (e) {
      _setError('Failed to update mood entry: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load recent mood entries (last 30 days)
  Future<void> loadRecentMoodEntries({int days = 30}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      _recentMoodEntries = await _trackingService.getMoodEntries(
        startDate: startDate,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load mood entries: $e');
    }
  }

  /// Delete a mood entry
  Future<void> deleteMoodEntry(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _trackingService.deleteMoodEntry(id);
      await loadRecentMoodEntries();
      await loadStatistics();
    } catch (e) {
      _setError('Failed to delete mood entry: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get mood entries for a specific date range
  Future<List<MoodJournalEntry>> getMoodEntriesForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _trackingService.getMoodEntries(
      startDate: startDate,
      endDate: endDate,
    );
  }

  // ==================== SLEEP TRACKING ====================

  /// Add a new sleep entry
  Future<void> addSleepEntry({
    required DateTime bedtime,
    required DateTime wakeTime,
    required SleepQuality quality,
    int? awakeDuringNight,
    bool? feltRested,
    List<String>? practicesBeforeSleep,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final entry = SleepEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime(wakeTime.year, wakeTime.month, wakeTime.day),
        bedtime: bedtime,
        wakeTime: wakeTime,
        quality: quality,
        awakeDuringNight: awakeDuringNight,
        feltRested: feltRested,
        practicesBeforeSleep: practicesBeforeSleep ?? [],
        notes: notes,
      );

      await _trackingService.saveSleepEntry(entry);
      await loadRecentSleepEntries();
      await loadStatistics();
    } catch (e) {
      _setError('Failed to add sleep entry: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load recent sleep entries (last 30 days)
  Future<void> loadRecentSleepEntries({int days = 30}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      _recentSleepEntries = await _trackingService.getSleepEntries(
        startDate: startDate,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load sleep entries: $e');
    }
  }

  /// Delete a sleep entry
  Future<void> deleteSleepEntry(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _trackingService.deleteSleepEntry(id);
      await loadRecentSleepEntries();
      await loadStatistics();
    } catch (e) {
      _setError('Failed to delete sleep entry: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get sleep entries for a specific date range
  Future<List<SleepEntry>> getSleepEntriesForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _trackingService.getSleepEntries(
      startDate: startDate,
      endDate: endDate,
    );
  }

  // ==================== STRESS MONITORING ====================

  /// Add a new stress entry
  Future<void> addStressEntry({
    required StressLevel level,
    List<String>? triggers,
    List<String>? symptoms,
    String? copingStrategy,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final entry = StressEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        level: level,
        triggers: triggers ?? [],
        symptoms: symptoms ?? [],
        copingStrategy: copingStrategy,
        notes: notes,
      );

      await _trackingService.saveStressEntry(entry);
      await loadRecentStressEntries();
      await loadStatistics();
    } catch (e) {
      _setError('Failed to add stress entry: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Load recent stress entries (last 30 days)
  Future<void> loadRecentStressEntries({int days = 30}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      _recentStressEntries = await _trackingService.getStressEntries(
        startDate: startDate,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load stress entries: $e');
    }
  }

  /// Delete a stress entry
  Future<void> deleteStressEntry(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _trackingService.deleteStressEntry(id);
      await loadRecentStressEntries();
      await loadStatistics();
    } catch (e) {
      _setError('Failed to delete stress entry: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get stress entries for a specific date range
  Future<List<StressEntry>> getStressEntriesForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _trackingService.getStressEntries(
      startDate: startDate,
      endDate: endDate,
    );
  }

  // ==================== DAILY CHECK-INS ====================

  /// Add or update daily check-in
  Future<void> saveDailyCheckIn({
    required MoodRating overallMood,
    required StressLevel stressLevel,
    required int energyLevel,
    required SleepQuality lastNightSleep,
    int practiceCount = 0,
    String? highlights,
    String? challenges,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final today = DateTime.now();
      final checkIn = DailyCheckIn(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime(today.year, today.month, today.day),
        overallMood: overallMood,
        stressLevel: stressLevel,
        energyLevel: energyLevel,
        lastNightSleep: lastNightSleep,
        practiceCount: practiceCount,
        highlights: highlights,
        challenges: challenges,
      );

      await _trackingService.saveDailyCheckIn(checkIn);
      await loadRecentCheckIns();
      await loadStatistics();
    } catch (e) {
      _setError('Failed to save daily check-in: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get check-in for today
  Future<DailyCheckIn?> getTodayCheckIn() async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return await _trackingService.getCheckInForDate(todayDate);
  }

  /// Load recent check-ins (last 30 days)
  Future<void> loadRecentCheckIns({int days = 30}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      _recentCheckIns = await _trackingService.getDailyCheckIns(
        startDate: startDate,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load check-ins: $e');
    }
  }

  /// Delete a check-in
  Future<void> deleteCheckIn(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _trackingService.deleteDailyCheckIn(id);
      await loadRecentCheckIns();
      await loadStatistics();
    } catch (e) {
      _setError('Failed to delete check-in: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get check-ins for a specific date range
  Future<List<DailyCheckIn>> getCheckInsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _trackingService.getDailyCheckIns(
      startDate: startDate,
      endDate: endDate,
    );
  }

  // ==================== STATISTICS ====================

  /// Load current statistics (last 30 days)
  Future<void> loadStatistics({int days = 30}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: days));
      final endDate = DateTime.now();
      _currentStatistics = await _trackingService.getStatistics(
        startDate: startDate,
        endDate: endDate,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load statistics: $e');
    }
  }

  /// Get statistics for a specific date range
  Future<Map<String, dynamic>> getStatisticsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _trackingService.getStatistics(
      startDate: startDate,
      endDate: endDate,
    );
  }

  // ==================== HELPER METHODS ====================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Clear all cached data
  void clearCache() {
    _recentMoodEntries = null;
    _recentSleepEntries = null;
    _recentStressEntries = null;
    _recentCheckIns = null;
    _currentStatistics = null;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await initialize();
  }
}
