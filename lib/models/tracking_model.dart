// lib/models/tracking_model.dart

enum MoodRating {
  veryBad, // 😢
  bad, // 😟
  neutral, // 😐
  good, // 🙂
  veryGood, // 😄
}

enum SleepQuality {
  terrible, // 1 star
  poor, // 2 stars
  fair, // 3 stars
  good, // 4 stars
  excellent, // 5 stars
}

enum StressLevel {
  veryLow, // 1
  low, // 2
  moderate, // 3
  high, // 4
  veryHigh, // 5
}

// Mood Journal Entry (Pre/Post Practice)
class MoodJournalEntry {
  final String id;
  final DateTime timestamp;
  final MoodRating preMood;
  final MoodRating? postMood;
  final String? practiceId;
  final String? practiceName;
  final String? notes;
  final List<String> tags; // e.g., "anxious", "energetic", "peaceful"

  MoodJournalEntry({
    required this.id,
    required this.timestamp,
    required this.preMood,
    this.postMood,
    this.practiceId,
    this.practiceName,
    this.notes,
    this.tags = const [],
  });

  bool get hasPostMood => postMood != null;

  int get moodImprovement {
    if (postMood == null) return 0;
    return postMood!.index - preMood.index;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'preMood': preMood.name,
      'postMood': postMood?.name,
      'practiceId': practiceId,
      'practiceName': practiceName,
      'notes': notes,
      'tags': tags,
    };
  }

  factory MoodJournalEntry.fromJson(Map<String, dynamic> json) {
    return MoodJournalEntry(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      preMood: MoodRating.values.firstWhere((e) => e.name == json['preMood']),
      postMood: json['postMood'] != null
          ? MoodRating.values.firstWhere((e) => e.name == json['postMood'])
          : null,
      practiceId: json['practiceId'],
      practiceName: json['practiceName'],
      notes: json['notes'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
    );
  }
}

// Sleep Tracking Entry
class SleepEntry {
  final String id;
  final DateTime date; // The date you went to sleep
  final DateTime bedtime;
  final DateTime wakeTime;
  final SleepQuality quality;
  final int? awakeDuringNight; // Number of times woke up
  final bool? feltRested;
  final String? notes;
  final List<String> practicesBeforeSleep; // Practice IDs done before bed

  SleepEntry({
    required this.id,
    required this.date,
    required this.bedtime,
    required this.wakeTime,
    required this.quality,
    this.awakeDuringNight,
    this.feltRested,
    this.notes,
    this.practicesBeforeSleep = const [],
  });

  Duration get totalSleepDuration => wakeTime.difference(bedtime);

  double get hoursSlept => totalSleepDuration.inMinutes / 60.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'bedtime': bedtime.toIso8601String(),
      'wakeTime': wakeTime.toIso8601String(),
      'quality': quality.name,
      'awakeDuringNight': awakeDuringNight,
      'feltRested': feltRested,
      'notes': notes,
      'practicesBeforeSleep': practicesBeforeSleep,
    };
  }

  factory SleepEntry.fromJson(Map<String, dynamic> json) {
    return SleepEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      bedtime: DateTime.parse(json['bedtime']),
      wakeTime: DateTime.parse(json['wakeTime']),
      quality: SleepQuality.values.firstWhere((e) => e.name == json['quality']),
      awakeDuringNight: json['awakeDuringNight'],
      feltRested: json['feltRested'],
      notes: json['notes'],
      practicesBeforeSleep: json['practicesBeforeSleep'] != null
          ? List<String>.from(json['practicesBeforeSleep'])
          : [],
    );
  }
}

// Stress Level Entry
class StressEntry {
  final String id;
  final DateTime timestamp;
  final StressLevel level;
  final List<String> triggers; // e.g., "work", "family", "health"
  final List<String> symptoms; // e.g., "headache", "tension", "irritability"
  final String? copingStrategy;
  final String? notes;

  StressEntry({
    required this.id,
    required this.timestamp,
    required this.level,
    this.triggers = const [],
    this.symptoms = const [],
    this.copingStrategy,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'triggers': triggers,
      'symptoms': symptoms,
      'copingStrategy': copingStrategy,
      'notes': notes,
    };
  }

  factory StressEntry.fromJson(Map<String, dynamic> json) {
    return StressEntry(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      level: StressLevel.values.firstWhere((e) => e.name == json['level']),
      triggers: json['triggers'] != null
          ? List<String>.from(json['triggers'])
          : [],
      symptoms: json['symptoms'] != null
          ? List<String>.from(json['symptoms'])
          : [],
      copingStrategy: json['copingStrategy'],
      notes: json['notes'],
    );
  }
}

// Daily Check-in (combines multiple metrics)
class DailyCheckIn {
  final String id;
  final DateTime date;
  final MoodRating? overallMood;
  final StressLevel? stressLevel;
  final int? energyLevel; // 1-5
  final SleepQuality? lastNightSleep;
  final int? practiceCount;
  final String? highlights;
  final String? challenges;

  DailyCheckIn({
    required this.id,
    required this.date,
    this.overallMood,
    this.stressLevel,
    this.energyLevel,
    this.lastNightSleep,
    this.practiceCount,
    this.highlights,
    this.challenges,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'overallMood': overallMood?.name,
      'stressLevel': stressLevel?.name,
      'energyLevel': energyLevel,
      'lastNightSleep': lastNightSleep?.name,
      'practiceCount': practiceCount,
      'highlights': highlights,
      'challenges': challenges,
    };
  }

  factory DailyCheckIn.fromJson(Map<String, dynamic> json) {
    return DailyCheckIn(
      id: json['id'],
      date: DateTime.parse(json['date']),
      overallMood: json['overallMood'] != null
          ? MoodRating.values.firstWhere((e) => e.name == json['overallMood'])
          : null,
      stressLevel: json['stressLevel'] != null
          ? StressLevel.values.firstWhere((e) => e.name == json['stressLevel'])
          : null,
      energyLevel: json['energyLevel'],
      lastNightSleep: json['lastNightSleep'] != null
          ? SleepQuality.values.firstWhere(
              (e) => e.name == json['lastNightSleep'],
            )
          : null,
      practiceCount: json['practiceCount'],
      highlights: json['highlights'],
      challenges: json['challenges'],
    );
  }
}

// Correlation Data (linking practices with outcomes)
class PracticeSleepCorrelation {
  final String practiceId;
  final String practiceName;
  final int timesUsedBeforeSleep;
  final double averageSleepQuality; // 1-5
  final double averageSleepHours;

  PracticeSleepCorrelation({
    required this.practiceId,
    required this.practiceName,
    required this.timesUsedBeforeSleep,
    required this.averageSleepQuality,
    required this.averageSleepHours,
  });
}

// Helper extension for emoji display
extension MoodRatingEmoji on MoodRating {
  String get emoji {
    switch (this) {
      case MoodRating.veryBad:
        return '😢';
      case MoodRating.bad:
        return '😟';
      case MoodRating.neutral:
        return '😐';
      case MoodRating.good:
        return '🙂';
      case MoodRating.veryGood:
        return '😄';
    }
  }

  String get label {
    switch (this) {
      case MoodRating.veryBad:
        return 'Very Bad';
      case MoodRating.bad:
        return 'Bad';
      case MoodRating.neutral:
        return 'Neutral';
      case MoodRating.good:
        return 'Good';
      case MoodRating.veryGood:
        return 'Very Good';
    }
  }
}

extension SleepQualityDisplay on SleepQuality {
  int get stars {
    return index + 1;
  }

  String get label {
    switch (this) {
      case SleepQuality.terrible:
        return 'Terrible';
      case SleepQuality.poor:
        return 'Poor';
      case SleepQuality.fair:
        return 'Fair';
      case SleepQuality.good:
        return 'Good';
      case SleepQuality.excellent:
        return 'Excellent';
    }
  }
}

extension StressLevelDisplay on StressLevel {
  int get value {
    return index + 1;
  }

  String get label {
    switch (this) {
      case StressLevel.veryLow:
        return 'Very Low';
      case StressLevel.low:
        return 'Low';
      case StressLevel.moderate:
        return 'Moderate';
      case StressLevel.high:
        return 'High';
      case StressLevel.veryHigh:
        return 'Very High';
    }
  }

  String get emoji {
    switch (this) {
      case StressLevel.veryLow:
        return '😌';
      case StressLevel.low:
        return '🙂';
      case StressLevel.moderate:
        return '😐';
      case StressLevel.high:
        return '😰';
      case StressLevel.veryHigh:
        return '😱';
    }
  }
}
