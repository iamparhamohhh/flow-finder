// lib/services/share_service.dart

import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';

class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  /// Share achievement text
  Future<void> shareAchievement({
    required String achievementTitle,
    required String achievementDescription,
    BuildContext? context,
  }) async {
    final text =
        '''
🏆 Achievement Unlocked!

$achievementTitle

$achievementDescription

Join me on Flow Finder - Your mindfulness companion! 🧘‍♂️
#FlowFinder #Mindfulness #Achievement
    ''';

    try {
      if (context != null) {
        final box = context.findRenderObject() as RenderBox?;
        await Share.share(
          text,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        );
      } else {
        await Share.share(text);
      }
    } catch (e) {
      debugPrint('Error sharing achievement: $e');
    }
  }

  /// Share streak progress
  Future<void> shareStreak({
    required int streakDays,
    required int totalSessions,
    required int totalMinutes,
    BuildContext? context,
  }) async {
    final text =
        '''
🔥 $streakDays Day Streak! 🔥

I've been consistent with my mindfulness practice!
📊 $totalSessions sessions completed
⏱️ $totalMinutes minutes of peace

Stay focused with Flow Finder! 🧘
#FlowFinder #MindfulnessStreak #Consistency
    ''';

    try {
      if (context != null) {
        final box = context.findRenderObject() as RenderBox?;
        await Share.share(
          text,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        );
      } else {
        await Share.share(text);
      }
    } catch (e) {
      debugPrint('Error sharing streak: $e');
    }
  }

  /// Share challenge completion
  Future<void> shareChallengeCompletion({
    required String challengeTitle,
    required int rewardPoints,
    required int participantCount,
    BuildContext? context,
  }) async {
    final text =
        '''
🎯 Challenge Completed! 🎯

$challengeTitle

✅ Earned $rewardPoints points
👥 Competed with $participantCount other mindful souls

Keep growing with Flow Finder! 🌱
#FlowFinder #Challenge #MindfulnessJourney
    ''';

    try {
      if (context != null) {
        final box = context.findRenderObject() as RenderBox?;
        await Share.share(
          text,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        );
      } else {
        await Share.share(text);
      }
    } catch (e) {
      debugPrint('Error sharing challenge: $e');
    }
  }

  /// Share leaderboard rank
  Future<void> shareLeaderboardRank({
    required int rank,
    required int score,
    required String period,
    BuildContext? context,
  }) async {
    String emoji = rank <= 3 ? ['🥇', '🥈', '🥉'][rank - 1] : '🏅';

    final text =
        '''
$emoji Leaderboard Achievement! $emoji

I ranked #$rank on the $period leaderboard!
Score: $score points

Challenge yourself with Flow Finder! 💪
#FlowFinder #Leaderboard #MindfulCompetition
    ''';

    try {
      if (context != null) {
        final box = context.findRenderObject() as RenderBox?;
        await Share.share(
          text,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        );
      } else {
        await Share.share(text);
      }
    } catch (e) {
      debugPrint('Error sharing leaderboard rank: $e');
    }
  }

  /// Share practice session stats
  Future<void> shareSessionStats({
    required String practiceType,
    required int durationMinutes,
    required String mood,
    BuildContext? context,
  }) async {
    final text =
        '''
🧘 Just completed a $practiceType session! 

⏱️ Duration: $durationMinutes minutes
😊 Feeling: $mood

Find your flow with Flow Finder! 🌊
#FlowFinder #Mindfulness #$practiceType
    ''';

    try {
      if (context != null) {
        final box = context.findRenderObject() as RenderBox?;
        await Share.share(
          text,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        );
      } else {
        await Share.share(text);
      }
    } catch (e) {
      debugPrint('Error sharing session stats: $e');
    }
  }

  /// Share weekly summary
  Future<void> shareWeeklySummary({
    required int sessionsCompleted,
    required int totalMinutes,
    required int pointsEarned,
    required List<String> topPractices,
    BuildContext? context,
  }) async {
    final practicesText = topPractices.join(', ');

    final text =
        '''
📊 My Weekly Mindfulness Summary

✅ $sessionsCompleted sessions completed
⏱️ $totalMinutes minutes of practice
⭐ $pointsEarned points earned
🎯 Top practices: $practicesText

Track your journey with Flow Finder! 📈
#FlowFinder #WeeklySummary #MindfulnessProgress
    ''';

    try {
      if (context != null) {
        final box = context.findRenderObject() as RenderBox?;
        await Share.share(
          text,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        );
      } else {
        await Share.share(text);
      }
    } catch (e) {
      debugPrint('Error sharing weekly summary: $e');
    }
  }

  /// Invite friends to app
  Future<void> inviteFriends({BuildContext? context}) async {
    final text = '''
🌊 Discover Your Flow State! 🧘

I've been using Flow Finder to improve my mindfulness practice and I think you'd love it too!

Features:
✨ Guided breathing exercises
🧘 Meditation sessions
📊 Progress tracking
🏆 Challenges & achievements
👥 Community support

Download Flow Finder and join me on this mindfulness journey!

#FlowFinder #Mindfulness #InnerPeace
    ''';

    try {
      if (context != null) {
        final box = context.findRenderObject() as RenderBox?;
        await Share.share(
          text,
          subject: 'Join me on Flow Finder!',
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
        );
      } else {
        await Share.share(text, subject: 'Join me on Flow Finder!');
      }
    } catch (e) {
      debugPrint('Error inviting friends: $e');
    }
  }
}
