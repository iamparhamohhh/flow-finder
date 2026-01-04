// lib/providers/notification_provider.dart

import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService;

  NotificationProvider({NotificationService? notificationService})
    : _notificationService = notificationService ?? NotificationService();

  // State
  List<SmartReminder>? _reminders;
  List<GentleNudge>? _nudges;
  List<PracticeSchedule>? _schedules;
  List<MLPracticeTimeSuggestion>? _mlSuggestions;
  Map<String, dynamic>? _settings;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<SmartReminder> get reminders => _reminders ?? [];
  List<GentleNudge> get nudges => _nudges ?? [];
  List<PracticeSchedule> get schedules => _schedules ?? [];
  List<MLPracticeTimeSuggestion> get mlSuggestions => _mlSuggestions ?? [];
  Map<String, dynamic> get settings => _settings ?? {};
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get notificationsEnabled => settings['notificationsEnabled'] ?? true;
  bool get streakNotificationsEnabled =>
      settings['streakNotifications'] ?? true;
  bool get nudgesEnabled => settings['nudgesEnabled'] ?? true;
  bool get mlSuggestionsEnabled => settings['mlSuggestionsEnabled'] ?? true;

  // Initialize
  Future<void> init() async {
    await _notificationService.init();
    await loadAll();
  }

  Future<void> loadAll() async {
    _setLoading(true);
    try {
      await Future.wait([
        loadReminders(),
        loadNudges(),
        loadSchedules(),
        loadMLSuggestions(),
        loadSettings(),
      ]);
    } catch (e) {
      _setError('Failed to load notification data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ========== Reminders ==========

  Future<void> loadReminders() async {
    try {
      _reminders = await _notificationService.getAllReminders();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load reminders: $e');
    }
  }

  Future<void> createReminder({
    required String title,
    String? description,
    required ReminderFrequency frequency,
    List<int>? daysOfWeek,
    DateTime? specificTime,
    bool useMLSuggestion = false,
    String? practiceType,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final reminder = SmartReminder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        frequency: frequency,
        daysOfWeek: daysOfWeek,
        specificTime: specificTime,
        useMLSuggestion: useMLSuggestion,
        practiceType: practiceType,
        createdAt: DateTime.now(),
      );

      await _notificationService.createReminder(reminder);
      await loadReminders();
    } catch (e) {
      _setError('Failed to create reminder: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateReminder(SmartReminder reminder) async {
    _setLoading(true);
    _clearError();

    try {
      await _notificationService.updateReminder(reminder);
      await loadReminders();
    } catch (e) {
      _setError('Failed to update reminder: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleReminder(String id, bool isEnabled) async {
    final reminder = reminders.firstWhere((r) => r.id == id);
    await updateReminder(reminder.copyWith(isEnabled: isEnabled));
  }

  Future<void> deleteReminder(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _notificationService.deleteReminder(id);
      await loadReminders();
    } catch (e) {
      _setError('Failed to delete reminder: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ========== Nudges ==========

  Future<void> loadNudges() async {
    try {
      _nudges = await _notificationService.getAllNudges();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load nudges: $e');
    }
  }

  Future<void> updateNudge(GentleNudge nudge) async {
    _setLoading(true);
    _clearError();

    try {
      await _notificationService.updateNudge(nudge);
      await loadNudges();
    } catch (e) {
      _setError('Failed to update nudge: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleNudge(String id, bool isEnabled) async {
    final nudge = nudges.firstWhere((n) => n.id == id);
    await updateNudge(nudge.copyWith(isEnabled: isEnabled));
  }

  Future<void> checkAndTriggerNudges() async {
    try {
      await _notificationService.checkAndTriggerNudges();
    } catch (e) {
      // Silent fail for background checks
      debugPrint('Failed to check nudges: $e');
    }
  }

  // ========== Schedules ==========

  Future<void> loadSchedules() async {
    try {
      _schedules = await _notificationService.getAllSchedules();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load schedules: $e');
    }
  }

  Future<void> createSchedule({
    required String practiceType,
    required DateTime startTime,
    required int durationMinutes,
    required ReminderFrequency frequency,
    List<int>? daysOfWeek,
    bool sendReminder = true,
    int reminderMinutesBefore = 10,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final schedule = PracticeSchedule(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        practiceType: practiceType,
        startTime: startTime,
        durationMinutes: durationMinutes,
        frequency: frequency,
        daysOfWeek: daysOfWeek,
        sendReminder: sendReminder,
        reminderMinutesBefore: reminderMinutesBefore,
        notes: notes,
        createdAt: DateTime.now(),
      );

      await _notificationService.createSchedule(schedule);
      await loadSchedules();
    } catch (e) {
      _setError('Failed to create schedule: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateSchedule(PracticeSchedule schedule) async {
    _setLoading(true);
    _clearError();

    try {
      await _notificationService.updateSchedule(schedule);
      await loadSchedules();
    } catch (e) {
      _setError('Failed to update schedule: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleSchedule(String id, bool isEnabled) async {
    final schedule = schedules.firstWhere((s) => s.id == id);
    await updateSchedule(schedule.copyWith(isEnabled: isEnabled));
  }

  Future<void> deleteSchedule(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _notificationService.deleteSchedule(id);
      await loadSchedules();
    } catch (e) {
      _setError('Failed to delete schedule: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ========== ML Suggestions ==========

  Future<void> loadMLSuggestions() async {
    if (!mlSuggestionsEnabled) return;

    try {
      _mlSuggestions = await _notificationService.getMLSuggestions();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load ML suggestions: $e');
    }
  }

  Future<void> createReminderFromSuggestion(
    MLPracticeTimeSuggestion suggestion,
  ) async {
    await createReminder(
      title: '${suggestion.practiceType} Practice',
      description: suggestion.reason,
      frequency: ReminderFrequency.daily,
      specificTime: suggestion.suggestedTime,
      practiceType: suggestion.practiceType,
    );
  }

  // ========== Settings ==========

  Future<void> loadSettings() async {
    try {
      _settings = await _notificationService.getSettings();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load settings: $e');
    }
  }

  Future<void> updateSettings(Map<String, dynamic> newSettings) async {
    _setLoading(true);
    _clearError();

    try {
      await _notificationService.updateSettings(newSettings);
      await loadSettings();
    } catch (e) {
      _setError('Failed to update settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleNotifications(bool enabled) async {
    final newSettings = Map<String, dynamic>.from(settings);
    newSettings['notificationsEnabled'] = enabled;
    await updateSettings(newSettings);
  }

  Future<void> toggleStreakNotifications(bool enabled) async {
    final newSettings = Map<String, dynamic>.from(settings);
    newSettings['streakNotifications'] = enabled;
    await updateSettings(newSettings);
  }

  Future<void> toggleNudgesGlobal(bool enabled) async {
    final newSettings = Map<String, dynamic>.from(settings);
    newSettings['nudgesEnabled'] = enabled;
    await updateSettings(newSettings);
  }

  Future<void> toggleMLSuggestions(bool enabled) async {
    final newSettings = Map<String, dynamic>.from(settings);
    newSettings['mlSuggestionsEnabled'] = enabled;
    await updateSettings(newSettings);

    if (enabled) {
      await loadMLSuggestions();
    }
  }

  Future<void> setQuietHours(int startHour, int endHour) async {
    final newSettings = Map<String, dynamic>.from(settings);
    newSettings['quietHoursStart'] = startHour;
    newSettings['quietHoursEnd'] = endHour;
    await updateSettings(newSettings);
  }

  // ========== Streak Notifications ==========

  Future<void> sendStreakNotification(int streak) async {
    if (!streakNotificationsEnabled) return;

    String message;
    if (streak == 7) {
      message = '🎉 One week streak! You\'re on fire!';
    } else if (streak == 30) {
      message = '🏆 30 days! You\'re a mindfulness champion!';
    } else if (streak == 100) {
      message = '⭐ 100 days! Incredible dedication!';
    } else if (streak % 10 == 0) {
      message = '🔥 $streak day streak! Keep it going!';
    } else {
      return; // Don't send notification for non-milestone streaks
    }

    try {
      await _notificationService.sendStreakNotification(streak, message);
    } catch (e) {
      debugPrint('Failed to send streak notification: $e');
    }
  }

  // ========== Helper Methods ==========

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

  Future<void> refresh() async {
    await loadAll();
  }
}
