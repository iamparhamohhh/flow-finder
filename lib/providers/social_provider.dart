// lib/providers/social_provider.dart

import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/friend_model.dart';
import '../services/social_service.dart';

class SocialProvider with ChangeNotifier {
  final SocialService _socialService = SocialService();

  UserModel? _currentUser;
  List<Friendship> _friends = [];
  List<FriendRequest> _pendingRequests = [];
  List<UserModel> _searchResults = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get currentUser => _currentUser;
  List<Friendship> get friends => _friends;
  List<FriendRequest> get pendingRequests => _pendingRequests;
  List<UserModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get friendCount => _friends.length;
  int get pendingRequestCount => _pendingRequests.length;

  // Initialize
  Future<void> init() async {
    await loadCurrentUser();
    await loadFriends();
    await loadPendingRequests();
  }

  // Load current user
  Future<void> loadCurrentUser() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentUser = await _socialService.getCurrentUser();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user profile';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading current user: $e');
    }
  }

  // Load friends list
  Future<void> loadFriends() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _friends = await _socialService.getFriends();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load friends';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading friends: $e');
    }
  }

  // Load pending friend requests
  Future<void> loadPendingRequests() async {
    try {
      _pendingRequests = await _socialService.getPendingFriendRequests();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading pending requests: $e');
    }
  }

  // Search users
  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _searchResults = await _socialService.searchUsers(query);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to search users';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error searching users: $e');
    }
  }

  // Send friend request
  Future<bool> sendFriendRequest(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _socialService.sendFriendRequest(userId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to send friend request';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error sending friend request: $e');
      return false;
    }
  }

  // Accept friend request
  Future<bool> acceptFriendRequest(String requestId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _socialService.acceptFriendRequest(requestId);

      // Refresh lists
      await loadFriends();
      await loadPendingRequests();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to accept friend request';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error accepting friend request: $e');
      return false;
    }
  }

  // Reject friend request
  Future<bool> rejectFriendRequest(String requestId) async {
    try {
      await _socialService.rejectFriendRequest(requestId);
      await loadPendingRequests();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to reject friend request';
      notifyListeners();
      debugPrint('Error rejecting friend request: $e');
      return false;
    }
  }

  // Remove friend
  Future<bool> removeFriend(String friendshipId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _socialService.removeFriend(friendshipId);
      await loadFriends();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to remove friend';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error removing friend: $e');
      return false;
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      return await _socialService.getUserProfile(userId);
    } catch (e) {
      debugPrint('Error getting user profile: $e');
      return null;
    }
  }

  // Clear search results
  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
