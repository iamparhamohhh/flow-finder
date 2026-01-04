// lib/providers/challenge_provider.dart

import 'package:flutter/foundation.dart';
import '../models/challenge_model.dart';
import '../models/leaderboard_model.dart';
import '../services/social_service.dart';

class ChallengeProvider with ChangeNotifier {
  final SocialService _socialService = SocialService();

  List<CommunityChallenge> _challenges = [];
  Leaderboard? _leaderboard;

  bool _isLoading = false;
  String? _error;

  LeaderboardPeriod _selectedPeriod = LeaderboardPeriod.weekly;
  LeaderboardCategory _selectedCategory = LeaderboardCategory.totalPoints;

  // Getters
  List<CommunityChallenge> get challenges => _challenges;
  List<CommunityChallenge> get activeChallenges =>
      _challenges.where((c) => c.isActive && !c.isExpired).toList();
  List<CommunityChallenge> get completedChallenges =>
      _challenges.where((c) => c.isCompleted).toList();
  Leaderboard? get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  String? get error => _error;
  LeaderboardPeriod get selectedPeriod => _selectedPeriod;
  LeaderboardCategory get selectedCategory => _selectedCategory;

  int get totalChallengesCompleted => completedChallenges.length;
  int get totalPointsFromChallenges => completedChallenges.fold(
    0,
    (sum, challenge) => sum + challenge.rewardPoints,
  );

  // Initialize
  Future<void> init() async {
    await loadChallenges();
    await loadLeaderboard();
  }

  // Load challenges
  Future<void> loadChallenges() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _challenges = await _socialService.getActiveChallenges();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load challenges';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading challenges: $e');
    }
  }

  // Load leaderboard
  Future<void> loadLeaderboard({
    LeaderboardPeriod? period,
    LeaderboardCategory? category,
  }) async {
    try {
      _isLoading = true;
      _error = null;

      if (period != null) _selectedPeriod = period;
      if (category != null) _selectedCategory = category;

      notifyListeners();

      _leaderboard = await _socialService.getLeaderboard(
        period: _selectedPeriod,
        category: _selectedCategory,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load leaderboard';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading leaderboard: $e');
    }
  }

  // Join challenge
  Future<bool> joinChallenge(String challengeId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _socialService.joinChallenge(challengeId);
      await loadChallenges();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to join challenge';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error joining challenge: $e');
      return false;
    }
  }

  // Leave challenge
  Future<bool> leaveChallenge(String challengeId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _socialService.leaveChallenge(challengeId);
      await loadChallenges();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to leave challenge';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error leaving challenge: $e');
      return false;
    }
  }

  // Update challenge progress (called after completing an activity)
  Future<void> updateChallengeProgress({
    required String challengeId,
    required int incrementBy,
  }) async {
    final challengeIndex = _challenges.indexWhere((c) => c.id == challengeId);
    if (challengeIndex == -1) return;

    final challenge = _challenges[challengeIndex];
    if (challenge.userProgress == null) return;

    final newProgress = challenge.userProgress!.copyWith(
      currentValue: challenge.userProgress!.currentValue + incrementBy,
      lastUpdated: DateTime.now(),
      isCompleted:
          (challenge.userProgress!.currentValue + incrementBy) >=
          challenge.targetValue,
      completedAt:
          (challenge.userProgress!.currentValue + incrementBy) >=
              challenge.targetValue
          ? DateTime.now()
          : null,
    );

    _challenges[challengeIndex] = CommunityChallenge(
      id: challenge.id,
      title: challenge.title,
      description: challenge.description,
      type: challenge.type,
      difficulty: challenge.difficulty,
      startDate: challenge.startDate,
      endDate: challenge.endDate,
      targetValue: challenge.targetValue,
      targetUnit: challenge.targetUnit,
      rewardPoints: challenge.rewardPoints,
      badgeIcon: challenge.badgeIcon,
      participantCount: challenge.participantCount,
      isActive: challenge.isActive,
      userProgress: newProgress,
    );

    notifyListeners();
  }

  // Refresh all data
  Future<void> refresh() async {
    await Future.wait([loadChallenges(), loadLeaderboard()]);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
