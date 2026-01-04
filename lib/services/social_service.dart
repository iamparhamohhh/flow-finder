// lib/services/social_service.dart

import 'dart:convert';
import 'dart:math';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/friend_model.dart';
import '../models/challenge_model.dart';
import '../models/leaderboard_model.dart';
import '../models/live_session_model.dart';

/// Mock Social Service
/// In production, replace with real API calls using http package
class SocialService {
  static final SocialService _instance = SocialService._internal();
  factory SocialService() => _instance;
  SocialService._internal();

  final _uuid = const Uuid();
  final _random = Random();

  // Mock current user
  String get currentUserId => 'user_current';

  // ========== USER METHODS ==========

  Future<UserModel> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return UserModel(
      id: currentUserId,
      username: 'mindful_user',
      displayName: 'Flow Master',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      bio: 'On a journey to inner peace 🧘‍♂️',
      totalPoints: 1250,
      currentStreak: 7,
      longestStreak: 21,
      joinedDate: DateTime.now().subtract(const Duration(days: 90)),
      lastActive: DateTime.now(),
      isOnline: true,
      stats: UserStats(
        totalSessions: 45,
        totalMinutes: 675,
        breathingSessions: 20,
        meditationSessions: 15,
        bodyScanSessions: 6,
        pmrSessions: 4,
        completedChallenges: 8,
        achievementsUnlocked: 12,
      ),
    );
  }

  Future<List<UserModel>> searchUsers(String query) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock users
    return List.generate(
      5,
      (i) => UserModel(
        id: 'user_$i',
        username: 'user_${query}_$i',
        displayName: 'User ${query.toUpperCase()} $i',
        avatarUrl: 'https://i.pravatar.cc/150?img=${i + 10}',
        totalPoints: _random.nextInt(2000),
        currentStreak: _random.nextInt(15),
        longestStreak: _random.nextInt(30),
        joinedDate: DateTime.now().subtract(
          Duration(days: _random.nextInt(365)),
        ),
        lastActive: DateTime.now().subtract(
          Duration(minutes: _random.nextInt(60)),
        ),
        isOnline: _random.nextBool(),
        stats: UserStats(
          totalSessions: _random.nextInt(100),
          totalMinutes: _random.nextInt(1500),
        ),
      ),
    );
  }

  Future<UserModel> getUserProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return UserModel(
      id: userId,
      username: 'user_profile',
      displayName: 'Profile User',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      bio: 'Finding my flow every day',
      totalPoints: 850,
      currentStreak: 3,
      longestStreak: 10,
      joinedDate: DateTime.now().subtract(const Duration(days: 60)),
      lastActive: DateTime.now(),
      isOnline: true,
      stats: UserStats(
        totalSessions: 30,
        totalMinutes: 450,
        breathingSessions: 15,
        meditationSessions: 10,
        bodyScanSessions: 3,
        pmrSessions: 2,
      ),
    );
  }

  // ========== FRIEND METHODS ==========

  Future<List<Friendship>> getFriends() async {
    await Future.delayed(const Duration(milliseconds: 600));

    return List.generate(
      8,
      (i) => Friendship(
        id: 'friendship_$i',
        userId1: currentUserId,
        userId2: 'friend_$i',
        createdAt: DateTime.now().subtract(Duration(days: i * 10)),
        friend: UserModel(
          id: 'friend_$i',
          username: 'friend_$i',
          displayName: 'Friend $i',
          avatarUrl: 'https://i.pravatar.cc/150?img=${i + 20}',
          totalPoints: _random.nextInt(1500),
          currentStreak: _random.nextInt(10),
          longestStreak: _random.nextInt(20),
          joinedDate: DateTime.now().subtract(
            Duration(days: _random.nextInt(200)),
          ),
          lastActive: DateTime.now().subtract(
            Duration(minutes: _random.nextInt(120)),
          ),
          isOnline: _random.nextBool(),
          stats: UserStats(
            totalSessions: _random.nextInt(80),
            totalMinutes: _random.nextInt(1200),
          ),
        ),
      ),
    );
  }

  Future<List<FriendRequest>> getPendingFriendRequests() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return List.generate(
      3,
      (i) => FriendRequest(
        id: 'request_$i',
        fromUserId: 'user_${i + 50}',
        toUserId: currentUserId,
        createdAt: DateTime.now().subtract(Duration(hours: i * 3)),
        status: FriendshipStatus.pending,
        fromUser: UserModel(
          id: 'user_${i + 50}',
          username: 'newuser_$i',
          displayName: 'New Friend $i',
          avatarUrl: 'https://i.pravatar.cc/150?img=${i + 30}',
          totalPoints: _random.nextInt(500),
          currentStreak: _random.nextInt(5),
          longestStreak: _random.nextInt(10),
          joinedDate: DateTime.now().subtract(
            Duration(days: _random.nextInt(30)),
          ),
          lastActive: DateTime.now(),
          isOnline: true,
          stats: UserStats(),
        ),
      ),
    );
  }

  Future<void> sendFriendRequest(String userId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // In production: POST /api/friends/request
  }

  Future<void> acceptFriendRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // In production: PUT /api/friends/request/{id}/accept
  }

  Future<void> rejectFriendRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // In production: DELETE /api/friends/request/{id}
  }

  Future<void> removeFriend(String friendshipId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // In production: DELETE /api/friends/{id}
  }

  // ========== CHALLENGE METHODS ==========

  Future<List<CommunityChallenge>> getActiveChallenges() async {
    await Future.delayed(const Duration(milliseconds: 700));

    final now = DateTime.now();

    return [
      CommunityChallenge(
        id: 'challenge_daily_1',
        title: '7-Day Breathing Streak',
        description:
            'Complete at least one breathing exercise every day for 7 consecutive days',
        type: ChallengeType.daily,
        difficulty: ChallengeDifficulty.easy,
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 5)),
        targetValue: 7,
        targetUnit: 'days',
        rewardPoints: 150,
        badgeIcon: '🏆',
        participantCount: 234,
        userProgress: ChallengeProgress(
          id: 'progress_1',
          challengeId: 'challenge_daily_1',
          userId: currentUserId,
          currentValue: 2,
          lastUpdated: now,
        ),
      ),
      CommunityChallenge(
        id: 'challenge_weekly_1',
        title: 'Weekly Meditation Master',
        description: 'Complete 15 meditation sessions this week',
        type: ChallengeType.weekly,
        difficulty: ChallengeDifficulty.medium,
        startDate: now.subtract(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 4)),
        targetValue: 15,
        targetUnit: 'sessions',
        rewardPoints: 300,
        badgeIcon: '🧘',
        participantCount: 156,
        userProgress: ChallengeProgress(
          id: 'progress_2',
          challengeId: 'challenge_weekly_1',
          userId: currentUserId,
          currentValue: 8,
          lastUpdated: now,
        ),
      ),
      CommunityChallenge(
        id: 'challenge_monthly_1',
        title: 'Mindful Minutes Marathon',
        description: 'Accumulate 500 minutes of practice this month',
        type: ChallengeType.monthly,
        difficulty: ChallengeDifficulty.hard,
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0),
        targetValue: 500,
        targetUnit: 'minutes',
        rewardPoints: 1000,
        badgeIcon: '⏱️',
        participantCount: 89,
        userProgress: ChallengeProgress(
          id: 'progress_3',
          challengeId: 'challenge_monthly_1',
          userId: currentUserId,
          currentValue: 245,
          lastUpdated: now,
        ),
      ),
    ];
  }

  Future<void> joinChallenge(String challengeId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // In production: POST /api/challenges/{id}/join
  }

  Future<void> leaveChallenge(String challengeId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    // In production: DELETE /api/challenges/{id}/leave
  }

  // ========== LEADERBOARD METHODS ==========

  Future<Leaderboard> getLeaderboard({
    LeaderboardPeriod period = LeaderboardPeriod.weekly,
    LeaderboardCategory category = LeaderboardCategory.totalPoints,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final entries = List.generate(20, (i) {
      final isCurrentUser = i == 5; // Current user is rank 6
      return LeaderboardEntry(
        rank: i + 1,
        userId: isCurrentUser ? currentUserId : 'user_${i + 100}',
        user: UserModel(
          id: isCurrentUser ? currentUserId : 'user_${i + 100}',
          username: isCurrentUser ? 'mindful_user' : 'leaderboard_user_$i',
          displayName: isCurrentUser ? 'Flow Master' : 'Leader $i',
          avatarUrl: 'https://i.pravatar.cc/150?img=${i + 40}',
          totalPoints: 2000 - (i * 80),
          currentStreak: 15 - i,
          longestStreak: 30 - i,
          joinedDate: DateTime.now().subtract(
            Duration(days: _random.nextInt(365)),
          ),
          lastActive: DateTime.now(),
          isOnline: _random.nextBool(),
          stats: UserStats(
            totalSessions: 100 - (i * 3),
            totalMinutes: 1500 - (i * 50),
          ),
        ),
        score: 2000 - (i * 80),
        badge: i < 3 ? ['🥇', '🥈', '🥉'][i] : null,
        isCurrentUser: isCurrentUser,
      );
    });

    return Leaderboard(
      period: period,
      category: category,
      entries: entries,
      currentUserEntry: entries.firstWhere((e) => e.isCurrentUser),
      lastUpdated: DateTime.now(),
    );
  }

  // ========== LIVE SESSION METHODS ==========

  Future<List<LiveSession>> getUpcomingSessions() async {
    await Future.delayed(const Duration(milliseconds: 700));

    final now = DateTime.now();

    return [
      LiveSession(
        id: 'session_1',
        title: 'Morning Meditation',
        description: 'Start your day with a peaceful guided meditation session',
        type: SessionType.meditation,
        scheduledStart: now.add(const Duration(hours: 1)),
        durationMinutes: 20,
        hostId: 'host_1',
        host: UserModel(
          id: 'host_1',
          username: 'meditation_guide',
          displayName: 'Sarah Johnson',
          avatarUrl: 'https://i.pravatar.cc/150?img=50',
          totalPoints: 5000,
          currentStreak: 50,
          longestStreak: 100,
          joinedDate: DateTime.now().subtract(const Duration(days: 500)),
          lastActive: DateTime.now(),
          isOnline: true,
          stats: UserStats(),
        ),
        maxParticipants: 30,
        currentParticipants: 12,
        status: SessionStatus.scheduled,
        thumbnailUrl: 'https://picsum.photos/300/200?random=1',
        tags: ['beginner', 'morning', 'guided'],
      ),
      LiveSession(
        id: 'session_2',
        title: '4-7-8 Breathing Workshop',
        description:
            'Learn and practice the powerful 4-7-8 breathing technique',
        type: SessionType.breathing,
        scheduledStart: now.add(const Duration(hours: 3)),
        durationMinutes: 15,
        hostId: 'host_2',
        host: UserModel(
          id: 'host_2',
          username: 'breath_expert',
          displayName: 'Dr. Michael Chen',
          avatarUrl: 'https://i.pravatar.cc/150?img=51',
          totalPoints: 8000,
          currentStreak: 75,
          longestStreak: 150,
          joinedDate: DateTime.now().subtract(const Duration(days: 700)),
          lastActive: DateTime.now(),
          isOnline: true,
          stats: UserStats(),
        ),
        maxParticipants: 50,
        currentParticipants: 28,
        status: SessionStatus.scheduled,
        thumbnailUrl: 'https://picsum.photos/300/200?random=2',
        tags: ['breathing', 'technique', 'intermediate'],
      ),
    ];
  }

  Future<List<LiveSession>> getLiveSessions() async {
    await Future.delayed(const Duration(milliseconds: 600));

    return [
      LiveSession(
        id: 'session_live_1',
        title: 'Evening Body Scan',
        description: 'Relax and unwind with a full body scan meditation',
        type: SessionType.bodyScan,
        scheduledStart: DateTime.now().subtract(const Duration(minutes: 5)),
        durationMinutes: 30,
        hostId: 'host_3',
        host: UserModel(
          id: 'host_3',
          username: 'wellness_coach',
          displayName: 'Emma Wilson',
          avatarUrl: 'https://i.pravatar.cc/150?img=52',
          totalPoints: 6000,
          currentStreak: 60,
          longestStreak: 120,
          joinedDate: DateTime.now().subtract(const Duration(days: 600)),
          lastActive: DateTime.now(),
          isOnline: true,
          stats: UserStats(),
        ),
        maxParticipants: 40,
        currentParticipants: 35,
        status: SessionStatus.live,
        streamUrl: 'mock_stream_url',
        thumbnailUrl: 'https://picsum.photos/300/200?random=3',
        isRecorded: true,
        tags: ['evening', 'relaxation', 'body-scan'],
      ),
    ];
  }

  Future<void> joinSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // In production: POST /api/sessions/{id}/join
  }

  Future<void> leaveSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In production: POST /api/sessions/{id}/leave
  }
}
