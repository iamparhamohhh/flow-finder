// lib/models/user_model.dart

class UserModel {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final int totalPoints;
  final int currentStreak;
  final int longestStreak;
  final DateTime joinedDate;
  final DateTime lastActive;
  final UserStats stats;
  final bool isOnline;

  UserModel({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    this.totalPoints = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.joinedDate,
    required this.lastActive,
    required this.stats,
    this.isOnline = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      displayName: json['displayName'],
      avatarUrl: json['avatarUrl'],
      bio: json['bio'],
      totalPoints: json['totalPoints'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      joinedDate: DateTime.parse(json['joinedDate']),
      lastActive: DateTime.parse(json['lastActive']),
      stats: UserStats.fromJson(json['stats'] ?? {}),
      isOnline: json['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'totalPoints': totalPoints,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'joinedDate': joinedDate.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'stats': stats.toJson(),
      'isOnline': isOnline,
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatarUrl,
    String? bio,
    int? totalPoints,
    int? currentStreak,
    int? longestStreak,
    DateTime? joinedDate,
    DateTime? lastActive,
    UserStats? stats,
    bool? isOnline,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      totalPoints: totalPoints ?? this.totalPoints,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      joinedDate: joinedDate ?? this.joinedDate,
      lastActive: lastActive ?? this.lastActive,
      stats: stats ?? this.stats,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class UserStats {
  final int totalSessions;
  final int totalMinutes;
  final int breathingSessions;
  final int meditationSessions;
  final int bodyScanSessions;
  final int pmrSessions;
  final int completedChallenges;
  final int achievementsUnlocked;

  UserStats({
    this.totalSessions = 0,
    this.totalMinutes = 0,
    this.breathingSessions = 0,
    this.meditationSessions = 0,
    this.bodyScanSessions = 0,
    this.pmrSessions = 0,
    this.completedChallenges = 0,
    this.achievementsUnlocked = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalSessions: json['totalSessions'] ?? 0,
      totalMinutes: json['totalMinutes'] ?? 0,
      breathingSessions: json['breathingSessions'] ?? 0,
      meditationSessions: json['meditationSessions'] ?? 0,
      bodyScanSessions: json['bodyScanSessions'] ?? 0,
      pmrSessions: json['pmrSessions'] ?? 0,
      completedChallenges: json['completedChallenges'] ?? 0,
      achievementsUnlocked: json['achievementsUnlocked'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSessions': totalSessions,
      'totalMinutes': totalMinutes,
      'breathingSessions': breathingSessions,
      'meditationSessions': meditationSessions,
      'bodyScanSessions': bodyScanSessions,
      'pmrSessions': pmrSessions,
      'completedChallenges': completedChallenges,
      'achievementsUnlocked': achievementsUnlocked,
    };
  }
}
