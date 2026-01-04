// lib/models/leaderboard_model.dart

import 'user_model.dart';

enum LeaderboardPeriod { daily, weekly, monthly, allTime }

enum LeaderboardCategory { totalPoints, streak, sessions, minutes, challenges }

class LeaderboardEntry {
  final int rank;
  final String userId;
  final UserModel user;
  final int score;
  final String? badge;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.user,
    required this.score,
    this.badge,
    this.isCurrentUser = false,
  });

  String get rankDisplay {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '#$rank';
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'],
      userId: json['userId'],
      user: UserModel.fromJson(json['user']),
      score: json['score'],
      badge: json['badge'],
      isCurrentUser: json['isCurrentUser'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'userId': userId,
      'user': user.toJson(),
      'score': score,
      'badge': badge,
      'isCurrentUser': isCurrentUser,
    };
  }
}

class Leaderboard {
  final LeaderboardPeriod period;
  final LeaderboardCategory category;
  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? currentUserEntry;
  final DateTime lastUpdated;

  Leaderboard({
    required this.period,
    required this.category,
    required this.entries,
    this.currentUserEntry,
    required this.lastUpdated,
  });

  factory Leaderboard.fromJson(Map<String, dynamic> json) {
    return Leaderboard(
      period: LeaderboardPeriod.values.firstWhere(
        (e) => e.name == json['period'],
        orElse: () => LeaderboardPeriod.weekly,
      ),
      category: LeaderboardCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => LeaderboardCategory.totalPoints,
      ),
      entries: (json['entries'] as List)
          .map((e) => LeaderboardEntry.fromJson(e))
          .toList(),
      currentUserEntry: json['currentUserEntry'] != null
          ? LeaderboardEntry.fromJson(json['currentUserEntry'])
          : null,
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period.name,
      'category': category.name,
      'entries': entries.map((e) => e.toJson()).toList(),
      'currentUserEntry': currentUserEntry?.toJson(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
