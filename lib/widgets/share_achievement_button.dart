// lib/widgets/share_achievement_button.dart

import 'package:flutter/material.dart';
import '../services/share_service.dart';

/// Reusable widget for sharing achievements
class ShareAchievementButton extends StatelessWidget {
  final String achievementTitle;
  final String achievementDescription;

  const ShareAchievementButton({
    super.key,
    required this.achievementTitle,
    required this.achievementDescription,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.share),
      tooltip: 'Share Achievement',
      onPressed: () {
        ShareService().shareAchievement(
          achievementTitle: achievementTitle,
          achievementDescription: achievementDescription,
          context: context,
        );
      },
    );
  }
}

/// Share streak button
class ShareStreakButton extends StatelessWidget {
  final int streakDays;
  final int totalSessions;
  final int totalMinutes;

  const ShareStreakButton({
    super.key,
    required this.streakDays,
    required this.totalSessions,
    required this.totalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.share),
      label: const Text('Share My Streak'),
      onPressed: () {
        ShareService().shareStreak(
          streakDays: streakDays,
          totalSessions: totalSessions,
          totalMinutes: totalMinutes,
          context: context,
        );
      },
    );
  }
}
