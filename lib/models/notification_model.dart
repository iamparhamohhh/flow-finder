// lib/models/notification_model.dart

enum NotificationType { reminder, streak, nudge, achievement, custom }

enum ReminderFrequency { once, daily, weekly, custom }

enum NudgeTrigger { stressDetection, inactivity, timeOfDay, heartRate }

// Notification Model
class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final bool isRead;
  final bool isDismissed;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.scheduledTime,
    this.isRead = false,
    this.isDismissed = false,
    this.data,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'body': body,
      'scheduledTime': scheduledTime.toIso8601String(),
      'isRead': isRead,
      'isDismissed': isDismissed,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      type: NotificationType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'],
      body: json['body'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      isRead: json['isRead'] ?? false,
      isDismissed: json['isDismissed'] ?? false,
      data: json['data'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  AppNotification copyWith({bool? isRead, bool? isDismissed}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
      isRead: isRead ?? this.isRead,
      isDismissed: isDismissed ?? this.isDismissed,
      data: data,
      createdAt: createdAt,
    );
  }
}

// Smart Reminder Model
class SmartReminder {
  final String id;
  final String title;
  final String? description;
  final ReminderFrequency frequency;
  final List<int>? daysOfWeek; // 1-7 for Monday-Sunday
  final DateTime? specificTime;
  final bool useMLSuggestion;
  final String? practiceType;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime? lastTriggered;
  final int triggerCount;

  SmartReminder({
    required this.id,
    required this.title,
    this.description,
    required this.frequency,
    this.daysOfWeek,
    this.specificTime,
    this.useMLSuggestion = false,
    this.practiceType,
    this.isEnabled = true,
    required this.createdAt,
    this.lastTriggered,
    this.triggerCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'frequency': frequency.name,
      'daysOfWeek': daysOfWeek,
      'specificTime': specificTime?.toIso8601String(),
      'useMLSuggestion': useMLSuggestion,
      'practiceType': practiceType,
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
      'lastTriggered': lastTriggered?.toIso8601String(),
      'triggerCount': triggerCount,
    };
  }

  factory SmartReminder.fromJson(Map<String, dynamic> json) {
    return SmartReminder(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      frequency: ReminderFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
      ),
      daysOfWeek: json['daysOfWeek'] != null
          ? List<int>.from(json['daysOfWeek'])
          : null,
      specificTime: json['specificTime'] != null
          ? DateTime.parse(json['specificTime'])
          : null,
      useMLSuggestion: json['useMLSuggestion'] ?? false,
      practiceType: json['practiceType'],
      isEnabled: json['isEnabled'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      lastTriggered: json['lastTriggered'] != null
          ? DateTime.parse(json['lastTriggered'])
          : null,
      triggerCount: json['triggerCount'] ?? 0,
    );
  }

  SmartReminder copyWith({
    String? title,
    String? description,
    ReminderFrequency? frequency,
    List<int>? daysOfWeek,
    DateTime? specificTime,
    bool? useMLSuggestion,
    String? practiceType,
    bool? isEnabled,
    DateTime? lastTriggered,
    int? triggerCount,
  }) {
    return SmartReminder(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      specificTime: specificTime ?? this.specificTime,
      useMLSuggestion: useMLSuggestion ?? this.useMLSuggestion,
      practiceType: practiceType ?? this.practiceType,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt,
      lastTriggered: lastTriggered ?? this.lastTriggered,
      triggerCount: triggerCount ?? this.triggerCount,
    );
  }
}

// Gentle Nudge Model
class GentleNudge {
  final String id;
  final NudgeTrigger trigger;
  final String message;
  final String? practiceRecommendation;
  final bool isEnabled;
  final int cooldownMinutes; // Minimum time between nudges
  final DateTime? lastTriggered;

  GentleNudge({
    required this.id,
    required this.trigger,
    required this.message,
    this.practiceRecommendation,
    this.isEnabled = true,
    this.cooldownMinutes = 30,
    this.lastTriggered,
  });

  bool get canTrigger {
    if (!isEnabled) return false;
    if (lastTriggered == null) return true;
    final now = DateTime.now();
    final difference = now.difference(lastTriggered!);
    return difference.inMinutes >= cooldownMinutes;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trigger': trigger.name,
      'message': message,
      'practiceRecommendation': practiceRecommendation,
      'isEnabled': isEnabled,
      'cooldownMinutes': cooldownMinutes,
      'lastTriggered': lastTriggered?.toIso8601String(),
    };
  }

  factory GentleNudge.fromJson(Map<String, dynamic> json) {
    return GentleNudge(
      id: json['id'],
      trigger: NudgeTrigger.values.firstWhere((e) => e.name == json['trigger']),
      message: json['message'],
      practiceRecommendation: json['practiceRecommendation'],
      isEnabled: json['isEnabled'] ?? true,
      cooldownMinutes: json['cooldownMinutes'] ?? 30,
      lastTriggered: json['lastTriggered'] != null
          ? DateTime.parse(json['lastTriggered'])
          : null,
    );
  }

  GentleNudge copyWith({
    String? message,
    String? practiceRecommendation,
    bool? isEnabled,
    int? cooldownMinutes,
    DateTime? lastTriggered,
  }) {
    return GentleNudge(
      id: id,
      trigger: trigger,
      message: message ?? this.message,
      practiceRecommendation:
          practiceRecommendation ?? this.practiceRecommendation,
      isEnabled: isEnabled ?? this.isEnabled,
      cooldownMinutes: cooldownMinutes ?? this.cooldownMinutes,
      lastTriggered: lastTriggered ?? this.lastTriggered,
    );
  }
}

// Practice Schedule Model
class PracticeSchedule {
  final String id;
  final String practiceType;
  final DateTime startTime;
  final int durationMinutes;
  final ReminderFrequency frequency;
  final List<int>? daysOfWeek;
  final bool sendReminder;
  final int reminderMinutesBefore;
  final bool isEnabled;
  final String? notes;
  final DateTime createdAt;

  PracticeSchedule({
    required this.id,
    required this.practiceType,
    required this.startTime,
    required this.durationMinutes,
    required this.frequency,
    this.daysOfWeek,
    this.sendReminder = true,
    this.reminderMinutesBefore = 10,
    this.isEnabled = true,
    this.notes,
    required this.createdAt,
  });

  DateTime get nextOccurrence {
    final now = DateTime.now();
    var next = DateTime(
      now.year,
      now.month,
      now.day,
      startTime.hour,
      startTime.minute,
    );

    // If time has passed today, start from tomorrow
    if (next.isBefore(now)) {
      next = next.add(const Duration(days: 1));
    }

    // Handle frequency
    switch (frequency) {
      case ReminderFrequency.daily:
        return next;
      case ReminderFrequency.weekly:
        if (daysOfWeek != null && daysOfWeek!.isNotEmpty) {
          while (!daysOfWeek!.contains(next.weekday)) {
            next = next.add(const Duration(days: 1));
          }
        }
        return next;
      case ReminderFrequency.once:
        return startTime;
      case ReminderFrequency.custom:
        return next;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'practiceType': practiceType,
      'startTime': startTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'frequency': frequency.name,
      'daysOfWeek': daysOfWeek,
      'sendReminder': sendReminder,
      'reminderMinutesBefore': reminderMinutesBefore,
      'isEnabled': isEnabled,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PracticeSchedule.fromJson(Map<String, dynamic> json) {
    return PracticeSchedule(
      id: json['id'],
      practiceType: json['practiceType'],
      startTime: DateTime.parse(json['startTime']),
      durationMinutes: json['durationMinutes'],
      frequency: ReminderFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
      ),
      daysOfWeek: json['daysOfWeek'] != null
          ? List<int>.from(json['daysOfWeek'])
          : null,
      sendReminder: json['sendReminder'] ?? true,
      reminderMinutesBefore: json['reminderMinutesBefore'] ?? 10,
      isEnabled: json['isEnabled'] ?? true,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  PracticeSchedule copyWith({
    String? practiceType,
    DateTime? startTime,
    int? durationMinutes,
    ReminderFrequency? frequency,
    List<int>? daysOfWeek,
    bool? sendReminder,
    int? reminderMinutesBefore,
    bool? isEnabled,
    String? notes,
  }) {
    return PracticeSchedule(
      id: id,
      practiceType: practiceType ?? this.practiceType,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      frequency: frequency ?? this.frequency,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      sendReminder: sendReminder ?? this.sendReminder,
      reminderMinutesBefore:
          reminderMinutesBefore ?? this.reminderMinutesBefore,
      isEnabled: isEnabled ?? this.isEnabled,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}

// ML Suggestion Model
class MLPracticeTimeSuggestion {
  final DateTime suggestedTime;
  final String practiceType;
  final double confidence; // 0.0 to 1.0
  final String reason;
  final Map<String, dynamic> metadata;

  MLPracticeTimeSuggestion({
    required this.suggestedTime,
    required this.practiceType,
    required this.confidence,
    required this.reason,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'suggestedTime': suggestedTime.toIso8601String(),
      'practiceType': practiceType,
      'confidence': confidence,
      'reason': reason,
      'metadata': metadata,
    };
  }

  factory MLPracticeTimeSuggestion.fromJson(Map<String, dynamic> json) {
    return MLPracticeTimeSuggestion(
      suggestedTime: DateTime.parse(json['suggestedTime']),
      practiceType: json['practiceType'],
      confidence: json['confidence'].toDouble(),
      reason: json['reason'],
      metadata: json['metadata'] ?? {},
    );
  }
}
