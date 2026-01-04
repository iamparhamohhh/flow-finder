// lib/models/custom_practice_model.dart

enum PracticeType { breathing, meditation, bodyScan, pmr, custom }

class CustomBreathingPattern {
  final String id;
  final String name;
  final String description;
  final int inhaleSeconds;
  final int holdInSeconds;
  final int exhaleSeconds;
  final int holdOutSeconds;
  final int cycles;
  final bool isDefault;
  final DateTime createdAt;

  CustomBreathingPattern({
    required this.id,
    required this.name,
    required this.description,
    required this.inhaleSeconds,
    required this.holdInSeconds,
    required this.exhaleSeconds,
    required this.holdOutSeconds,
    required this.cycles,
    this.isDefault = false,
    required this.createdAt,
  });

  int get totalCycleSeconds =>
      inhaleSeconds + holdInSeconds + exhaleSeconds + holdOutSeconds;

  int get totalDurationSeconds => totalCycleSeconds * cycles;

  String get patternString =>
      '$inhaleSeconds-$holdInSeconds-$exhaleSeconds-$holdOutSeconds';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'inhaleSeconds': inhaleSeconds,
      'holdInSeconds': holdInSeconds,
      'exhaleSeconds': exhaleSeconds,
      'holdOutSeconds': holdOutSeconds,
      'cycles': cycles,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CustomBreathingPattern.fromJson(Map<String, dynamic> json) {
    return CustomBreathingPattern(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      inhaleSeconds: json['inhaleSeconds'],
      holdInSeconds: json['holdInSeconds'],
      exhaleSeconds: json['exhaleSeconds'],
      holdOutSeconds: json['holdOutSeconds'],
      cycles: json['cycles'],
      isDefault: json['isDefault'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  CustomBreathingPattern copyWith({
    String? name,
    String? description,
    int? inhaleSeconds,
    int? holdInSeconds,
    int? exhaleSeconds,
    int? holdOutSeconds,
    int? cycles,
  }) {
    return CustomBreathingPattern(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      inhaleSeconds: inhaleSeconds ?? this.inhaleSeconds,
      holdInSeconds: holdInSeconds ?? this.holdInSeconds,
      exhaleSeconds: exhaleSeconds ?? this.exhaleSeconds,
      holdOutSeconds: holdOutSeconds ?? this.holdOutSeconds,
      cycles: cycles ?? this.cycles,
      isDefault: isDefault,
      createdAt: createdAt,
    );
  }

  static List<CustomBreathingPattern> getDefaultPatterns() {
    final now = DateTime.now();
    return [
      CustomBreathingPattern(
        id: 'box_breathing',
        name: 'Box Breathing',
        description: 'Equal parts breathing for balance and focus',
        inhaleSeconds: 4,
        holdInSeconds: 4,
        exhaleSeconds: 4,
        holdOutSeconds: 4,
        cycles: 8,
        isDefault: true,
        createdAt: now,
      ),
      CustomBreathingPattern(
        id: '478_breathing',
        name: '4-7-8 Breathing',
        description: 'Relaxing technique for better sleep',
        inhaleSeconds: 4,
        holdInSeconds: 7,
        exhaleSeconds: 8,
        holdOutSeconds: 0,
        cycles: 4,
        isDefault: true,
        createdAt: now,
      ),
      CustomBreathingPattern(
        id: 'coherent_breathing',
        name: 'Coherent Breathing',
        description: 'Balanced breathing at 5 breaths per minute',
        inhaleSeconds: 6,
        holdInSeconds: 0,
        exhaleSeconds: 6,
        holdOutSeconds: 0,
        cycles: 10,
        isDefault: true,
        createdAt: now,
      ),
      CustomBreathingPattern(
        id: 'energizing_breath',
        name: 'Energizing Breath',
        description: 'Quick inhales for energy boost',
        inhaleSeconds: 2,
        holdInSeconds: 0,
        exhaleSeconds: 4,
        holdOutSeconds: 0,
        cycles: 12,
        isDefault: true,
        createdAt: now,
      ),
      CustomBreathingPattern(
        id: 'calming_breath',
        name: 'Calming Breath',
        description: 'Extended exhale for deep relaxation',
        inhaleSeconds: 4,
        holdInSeconds: 2,
        exhaleSeconds: 6,
        holdOutSeconds: 2,
        cycles: 6,
        isDefault: true,
        createdAt: now,
      ),
    ];
  }
}

class CustomPracticeRoutine {
  final String id;
  final String name;
  final String description;
  final List<PracticeStep> steps;
  final int totalDurationMinutes;
  final PracticeType primaryType;
  final DateTime createdAt;
  final DateTime? lastUsed;
  final int usageCount;

  CustomPracticeRoutine({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
    required this.totalDurationMinutes,
    required this.primaryType,
    required this.createdAt,
    this.lastUsed,
    this.usageCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'steps': steps.map((s) => s.toJson()).toList(),
      'totalDurationMinutes': totalDurationMinutes,
      'primaryType': primaryType.name,
      'createdAt': createdAt.toIso8601String(),
      'lastUsed': lastUsed?.toIso8601String(),
      'usageCount': usageCount,
    };
  }

  factory CustomPracticeRoutine.fromJson(Map<String, dynamic> json) {
    return CustomPracticeRoutine(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      steps: (json['steps'] as List)
          .map((s) => PracticeStep.fromJson(s))
          .toList(),
      totalDurationMinutes: json['totalDurationMinutes'],
      primaryType: PracticeType.values.firstWhere(
        (e) => e.name == json['primaryType'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      lastUsed: json['lastUsed'] != null
          ? DateTime.parse(json['lastUsed'])
          : null,
      usageCount: json['usageCount'] ?? 0,
    );
  }
}

class PracticeStep {
  final PracticeType type;
  final String title;
  final int durationMinutes;
  final String? breathingPatternId;
  final Map<String, dynamic>? settings;

  PracticeStep({
    required this.type,
    required this.title,
    required this.durationMinutes,
    this.breathingPatternId,
    this.settings,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'title': title,
      'durationMinutes': durationMinutes,
      'breathingPatternId': breathingPatternId,
      'settings': settings,
    };
  }

  factory PracticeStep.fromJson(Map<String, dynamic> json) {
    return PracticeStep(
      type: PracticeType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'],
      durationMinutes: json['durationMinutes'],
      breathingPatternId: json['breathingPatternId'],
      settings: json['settings'],
    );
  }
}
