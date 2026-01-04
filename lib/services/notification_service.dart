// lib/services/notification_service.dart

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_model.dart';
import '../models/tracking_model.dart';
import 'tracking_service.dart';

class NotificationService {
  static const String _notificationsBox = 'notifications';
  static const String _remindersBox = 'reminders';
  static const String _nudgesBox = 'nudges';
  static const String _schedulesBox = 'schedules';
  static const String _settingsBox = 'notification_settings';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final Uuid _uuid = const Uuid();
  final TrackingService _trackingService;

  bool _isInitialized = false;

  NotificationService({TrackingService? trackingService})
    : _trackingService = trackingService ?? TrackingService();

  // Initialize notification service
  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Open Hive boxes
    await _openBoxes();

    // Initialize default nudges if not exists
    await _initializeDefaultNudges();

    _isInitialized = true;
  }

  Future<void> _openBoxes() async {
    if (!Hive.isBoxOpen(_notificationsBox)) {
      await Hive.openBox(_notificationsBox);
    }
    if (!Hive.isBoxOpen(_remindersBox)) {
      await Hive.openBox(_remindersBox);
    }
    if (!Hive.isBoxOpen(_nudgesBox)) {
      await Hive.openBox(_nudgesBox);
    }
    if (!Hive.isBoxOpen(_schedulesBox)) {
      await Hive.openBox(_schedulesBox);
    }
    if (!Hive.isBoxOpen(_settingsBox)) {
      await Hive.openBox(_settingsBox);
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // This could navigate to specific screens based on payload
  }

  // ========== Smart Reminders ==========

  Future<SmartReminder> createReminder(SmartReminder reminder) async {
    await _openBoxes();
    final box = Hive.box(_remindersBox);
    await box.put(reminder.id, reminder.toJson());

    if (reminder.isEnabled) {
      await _scheduleReminderNotifications(reminder);
    }

    return reminder;
  }

  Future<List<SmartReminder>> getAllReminders() async {
    await _openBoxes();
    final box = Hive.box(_remindersBox);
    final List<SmartReminder> reminders = [];

    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        reminders.add(SmartReminder.fromJson(Map<String, dynamic>.from(data)));
      }
    }

    return reminders;
  }

  Future<void> updateReminder(SmartReminder reminder) async {
    await _openBoxes();
    final box = Hive.box(_remindersBox);
    await box.put(reminder.id, reminder.toJson());

    // Cancel old notifications
    await _cancelReminderNotifications(reminder.id);

    // Schedule new ones if enabled
    if (reminder.isEnabled) {
      await _scheduleReminderNotifications(reminder);
    }
  }

  Future<void> deleteReminder(String id) async {
    await _openBoxes();
    final box = Hive.box(_remindersBox);
    await box.delete(id);
    await _cancelReminderNotifications(id);
  }

  Future<void> _scheduleReminderNotifications(SmartReminder reminder) async {
    // Cancel existing notifications for this reminder
    await _cancelReminderNotifications(reminder.id);

    DateTime scheduledTime;

    if (reminder.useMLSuggestion) {
      // Get ML-based suggestion
      final suggestion = await _getMLSuggestedTime(reminder.practiceType);
      scheduledTime = suggestion.suggestedTime;
    } else if (reminder.specificTime != null) {
      scheduledTime = reminder.specificTime!;
    } else {
      return; // No time specified
    }

    // Schedule based on frequency
    switch (reminder.frequency) {
      case ReminderFrequency.once:
        await _scheduleNotification(
          id: reminder.id.hashCode,
          title: reminder.title,
          body: reminder.description ?? 'Time for your practice!',
          scheduledTime: scheduledTime,
        );
        break;

      case ReminderFrequency.daily:
        await _scheduleDailyNotification(
          id: reminder.id.hashCode,
          title: reminder.title,
          body: reminder.description ?? 'Time for your daily practice!',
          time: scheduledTime,
        );
        break;

      case ReminderFrequency.weekly:
        if (reminder.daysOfWeek != null) {
          for (var day in reminder.daysOfWeek!) {
            await _scheduleWeeklyNotification(
              id: '${reminder.id}_$day'.hashCode,
              title: reminder.title,
              body: reminder.description ?? 'Time for your practice!',
              dayOfWeek: day,
              time: scheduledTime,
            );
          }
        }
        break;

      case ReminderFrequency.custom:
        // Custom frequency logic
        break;
    }
  }

  Future<void> _cancelReminderNotifications(String reminderId) async {
    await _localNotifications.cancel(reminderId.hashCode);
    // Cancel all variations for weekly reminders
    for (var i = 1; i <= 7; i++) {
      await _localNotifications.cancel('${reminderId}_$i'.hashCode);
    }
  }

  // ========== ML-Based Time Suggestions ==========

  Future<MLPracticeTimeSuggestion> _getMLSuggestedTime(
    String? practiceType,
  ) async {
    // Analyze user's practice history to find optimal time
    final now = DateTime.now();
    final last30Days = now.subtract(const Duration(days: 30));

    final moodEntries = await _trackingService.getMoodEntries(
      startDate: last30Days,
      endDate: now,
    );

    final stressEntries = await _trackingService.getStressEntries(
      startDate: last30Days,
      endDate: now,
    );

    // Analyze patterns
    final timeSlotScores = <int, double>{}; // hour -> score

    // Score based on mood improvement
    for (var entry in moodEntries) {
      if (entry.hasPostMood && entry.moodImprovement > 0) {
        final hour = entry.timestamp.hour;
        timeSlotScores[hour] =
            (timeSlotScores[hour] ?? 0) + entry.moodImprovement;
      }
    }

    // Score based on stress patterns (suggest practice before high stress)
    for (var entry in stressEntries) {
      if (entry.level == StressLevel.high ||
          entry.level == StressLevel.veryHigh) {
        final hour = entry.timestamp.hour - 1; // Suggest 1 hour before
        if (hour >= 0) {
          timeSlotScores[hour] = (timeSlotScores[hour] ?? 0) + 2.0;
        }
      }
    }

    // Find best time slot
    int bestHour = 9; // Default: 9 AM
    double bestScore = 0;
    double confidence = 0.5;

    if (timeSlotScores.isNotEmpty) {
      timeSlotScores.forEach((hour, score) {
        if (score > bestScore) {
          bestScore = score;
          bestHour = hour;
        }
      });
      confidence = (bestScore / (moodEntries.length + stressEntries.length))
          .clamp(0.5, 1.0);
    }

    final suggestedTime = DateTime(now.year, now.month, now.day, bestHour, 0);

    return MLPracticeTimeSuggestion(
      suggestedTime: suggestedTime.isAfter(now)
          ? suggestedTime
          : suggestedTime.add(const Duration(days: 1)),
      practiceType: practiceType ?? 'Mindfulness',
      confidence: confidence,
      reason: confidence > 0.7
          ? 'Based on your practice history, this time shows the best results'
          : 'Suggested based on general wellness patterns',
      metadata: {
        'analysisWindowDays': 30,
        'entriesAnalyzed': moodEntries.length + stressEntries.length,
      },
    );
  }

  Future<List<MLPracticeTimeSuggestion>> getMLSuggestions() async {
    final suggestions = <MLPracticeTimeSuggestion>[];

    // Get suggestions for different practice types
    final practiceTypes = [
      'Breathing',
      'Mindfulness',
      'Body Scan',
      'Progressive Muscle Relaxation',
    ];

    for (var type in practiceTypes) {
      final suggestion = await _getMLSuggestedTime(type);
      suggestions.add(suggestion);
    }

    // Sort by confidence
    suggestions.sort((a, b) => b.confidence.compareTo(a.confidence));

    return suggestions;
  }

  // ========== Gentle Nudges ==========

  Future<void> _initializeDefaultNudges() async {
    await _openBoxes();
    final box = Hive.box(_nudgesBox);

    if (box.isEmpty) {
      final defaultNudges = [
        GentleNudge(
          id: _uuid.v4(),
          trigger: NudgeTrigger.stressDetection,
          message: 'Feeling stressed? Take a moment to breathe 🌬️',
          practiceRecommendation: 'Breathing',
          cooldownMinutes: 60,
        ),
        GentleNudge(
          id: _uuid.v4(),
          trigger: NudgeTrigger.inactivity,
          message: 'You haven\'t practiced today. A quick session? ✨',
          practiceRecommendation: 'Mindfulness',
          cooldownMinutes: 240,
        ),
        GentleNudge(
          id: _uuid.v4(),
          trigger: NudgeTrigger.timeOfDay,
          message: 'Good morning! Start your day with mindfulness ☀️',
          practiceRecommendation: 'Morning Meditation',
          cooldownMinutes: 1440, // Once per day
        ),
      ];

      for (var nudge in defaultNudges) {
        await box.put(nudge.id, nudge.toJson());
      }
    }
  }

  Future<List<GentleNudge>> getAllNudges() async {
    await _openBoxes();
    final box = Hive.box(_nudgesBox);
    final List<GentleNudge> nudges = [];

    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        nudges.add(GentleNudge.fromJson(Map<String, dynamic>.from(data)));
      }
    }

    return nudges;
  }

  Future<void> updateNudge(GentleNudge nudge) async {
    await _openBoxes();
    final box = Hive.box(_nudgesBox);
    await box.put(nudge.id, nudge.toJson());
  }

  Future<void> triggerNudge(GentleNudge nudge) async {
    if (!nudge.canTrigger) return;

    await _showNotification(
      id: nudge.id.hashCode,
      title: '🌟 Gentle Reminder',
      body: nudge.message,
      payload: 'nudge:${nudge.id}',
    );

    // Update last triggered time
    final updatedNudge = nudge.copyWith(lastTriggered: DateTime.now());
    await updateNudge(updatedNudge);
  }

  Future<void> checkAndTriggerNudges() async {
    final nudges = await getAllNudges();
    final now = DateTime.now();

    for (var nudge in nudges) {
      if (!nudge.isEnabled || !nudge.canTrigger) continue;

      bool shouldTrigger = false;

      switch (nudge.trigger) {
        case NudgeTrigger.stressDetection:
          shouldTrigger = await _checkStressLevel();
          break;
        case NudgeTrigger.inactivity:
          shouldTrigger = await _checkInactivity();
          break;
        case NudgeTrigger.timeOfDay:
          shouldTrigger = now.hour == 9; // Morning nudge
          break;
        case NudgeTrigger.heartRate:
          // Would integrate with health APIs
          shouldTrigger = false;
          break;
      }

      if (shouldTrigger) {
        await triggerNudge(nudge);
      }
    }
  }

  Future<bool> _checkStressLevel() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final stressEntries = await _trackingService.getStressEntries(
      startDate: startOfDay,
      endDate: today,
      limit: 1,
    );

    if (stressEntries.isEmpty) return false;

    final latest = stressEntries.first;
    return latest.level == StressLevel.high ||
        latest.level == StressLevel.veryHigh;
  }

  Future<bool> _checkInactivity() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final moodEntries = await _trackingService.getMoodEntries(
      startDate: startOfDay,
      endDate: today,
    );

    // Check if user hasn't practiced today (no mood entries)
    return moodEntries.isEmpty && today.hour >= 12; // After noon
  }

  // ========== Streak Notifications ==========

  Future<void> sendStreakNotification(int currentStreak, String message) async {
    await _showNotification(
      id: 'streak_${DateTime.now().millisecondsSinceEpoch}'.hashCode,
      title: '🔥 Streak Milestone!',
      body: message,
      payload: 'streak:$currentStreak',
    );
  }

  // ========== Practice Schedules ==========

  Future<PracticeSchedule> createSchedule(PracticeSchedule schedule) async {
    await _openBoxes();
    final box = Hive.box(_schedulesBox);
    await box.put(schedule.id, schedule.toJson());

    if (schedule.isEnabled && schedule.sendReminder) {
      await _scheduleReminder(schedule);
    }

    return schedule;
  }

  Future<List<PracticeSchedule>> getAllSchedules() async {
    await _openBoxes();
    final box = Hive.box(_schedulesBox);
    final List<PracticeSchedule> schedules = [];

    for (var key in box.keys) {
      final data = box.get(key);
      if (data != null) {
        schedules.add(
          PracticeSchedule.fromJson(Map<String, dynamic>.from(data)),
        );
      }
    }

    // Sort by next occurrence
    schedules.sort((a, b) => a.nextOccurrence.compareTo(b.nextOccurrence));

    return schedules;
  }

  Future<void> updateSchedule(PracticeSchedule schedule) async {
    await _openBoxes();
    final box = Hive.box(_schedulesBox);
    await box.put(schedule.id, schedule.toJson());

    // Cancel old notification
    await _localNotifications.cancel(schedule.id.hashCode);

    // Schedule new one if enabled
    if (schedule.isEnabled && schedule.sendReminder) {
      await _scheduleReminder(schedule);
    }
  }

  Future<void> deleteSchedule(String id) async {
    await _openBoxes();
    final box = Hive.box(_schedulesBox);
    await box.delete(id);
    await _localNotifications.cancel(id.hashCode);
  }

  Future<void> _scheduleReminder(PracticeSchedule schedule) async {
    final reminderTime = schedule.nextOccurrence.subtract(
      Duration(minutes: schedule.reminderMinutesBefore),
    );

    await _scheduleNotification(
      id: schedule.id.hashCode,
      title: '⏰ Practice Reminder',
      body:
          '${schedule.practiceType} in ${schedule.reminderMinutesBefore} minutes',
      scheduledTime: reminderTime,
    );
  }

  // ========== Notification Helpers ==========

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'flow_finder_channel',
      'Flow Finder Notifications',
      channelDescription: 'Notifications for Flow Finder app',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'flow_finder_channel',
      'Flow Finder Notifications',
      channelDescription: 'Scheduled notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      _convertToTZDateTime(scheduledTime),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    await _scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledTime: time,
    );
  }

  Future<void> _scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required int dayOfWeek,
    required DateTime time,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Find next occurrence of the specified day
    while (scheduledDate.weekday != dayOfWeek || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledTime: scheduledDate,
    );
  }

  // Helper to convert DateTime to TZDateTime
  dynamic _convertToTZDateTime(DateTime dateTime) {
    // This would use timezone package in production
    return dateTime;
  }

  // ========== Settings ==========

  Future<Map<String, dynamic>> getSettings() async {
    await _openBoxes();
    final box = Hive.box(_settingsBox);
    return Map<String, dynamic>.from(
      box.get(
        'settings',
        defaultValue: {
          'notificationsEnabled': true,
          'streakNotifications': true,
          'nudgesEnabled': true,
          'mlSuggestionsEnabled': true,
          'quietHoursStart': 22, // 10 PM
          'quietHoursEnd': 8, // 8 AM
        },
      ),
    );
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    await _openBoxes();
    final box = Hive.box(_settingsBox);
    await box.put('settings', settings);
  }

  // ========== Cleanup ==========

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  Future<void> clearAllData() async {
    await _openBoxes();
    await Hive.box(_notificationsBox).clear();
    await Hive.box(_remindersBox).clear();
    await Hive.box(_nudgesBox).clear();
    await Hive.box(_schedulesBox).clear();
  }
}
