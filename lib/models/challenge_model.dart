// lib/models/challenge_model.dart

enum ChallengeType { daily, weekly, monthly, special }

enum ChallengeDifficulty { easy, medium, hard, expert }

class CommunityChallenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final ChallengeDifficulty difficulty;
  final DateTime startDate;
  final DateTime endDate;
  final int targetValue;
  final String targetUnit; // "sessions", "minutes", "practices"
  final int rewardPoints;
  final String? badgeIcon;
  final int participantCount;
  final bool isActive;
  final ChallengeProgress? userProgress;

  CommunityChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.startDate,
    required this.endDate,
    required this.targetValue,
    required this.targetUnit,
    required this.rewardPoints,
    this.badgeIcon,
    this.participantCount = 0,
    this.isActive = true,
    this.userProgress,
  });

  bool get isCompleted => userProgress?.isCompleted ?? false;
  bool get isExpired => DateTime.now().isAfter(endDate);
  Duration get timeRemaining => endDate.difference(DateTime.now());

  String get difficultyLabel {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return '⭐ Easy';
      case ChallengeDifficulty.medium:
        return '⭐⭐ Medium';
      case ChallengeDifficulty.hard:
        return '⭐⭐⭐ Hard';
      case ChallengeDifficulty.expert:
        return '⭐⭐⭐⭐ Expert';
    }
  }

  factory CommunityChallenge.fromJson(Map<String, dynamic> json) {
    return CommunityChallenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: ChallengeType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChallengeType.daily,
      ),
      difficulty: ChallengeDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => ChallengeDifficulty.medium,
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      targetValue: json['targetValue'],
      targetUnit: json['targetUnit'],
      rewardPoints: json['rewardPoints'],
      badgeIcon: json['badgeIcon'],
      participantCount: json['participantCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      userProgress: json['userProgress'] != null
          ? ChallengeProgress.fromJson(json['userProgress'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'difficulty': difficulty.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'targetValue': targetValue,
      'targetUnit': targetUnit,
      'rewardPoints': rewardPoints,
      'badgeIcon': badgeIcon,
      'participantCount': participantCount,
      'isActive': isActive,
      'userProgress': userProgress?.toJson(),
    };
  }
}

class ChallengeProgress {
  final String id;
  final String challengeId;
  final String userId;
  final int currentValue;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime lastUpdated;

  ChallengeProgress({
    required this.id,
    required this.challengeId,
    required this.userId,
    this.currentValue = 0,
    this.isCompleted = false,
    this.completedAt,
    required this.lastUpdated,
  });

  double getProgress(int targetValue) {
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  factory ChallengeProgress.fromJson(Map<String, dynamic> json) {
    return ChallengeProgress(
      id: json['id'],
      challengeId: json['challengeId'],
      userId: json['userId'],
      currentValue: json['currentValue'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'challengeId': challengeId,
      'userId': userId,
      'currentValue': currentValue,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  ChallengeProgress copyWith({
    int? currentValue,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? lastUpdated,
  }) {
    return ChallengeProgress(
      id: id,
      challengeId: challengeId,
      userId: userId,
      currentValue: currentValue ?? this.currentValue,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
