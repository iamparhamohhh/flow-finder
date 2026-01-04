// lib/providers/live_session_provider.dart

import 'package:flutter/foundation.dart';
import '../models/live_session_model.dart';
import '../services/social_service.dart';

class LiveSessionProvider with ChangeNotifier {
  final SocialService _socialService = SocialService();

  List<LiveSession> _upcomingSessions = [];
  List<LiveSession> _liveSessions = [];
  LiveSession? _currentSession;

  bool _isLoading = false;
  String? _error;

  // Getters
  List<LiveSession> get upcomingSessions => _upcomingSessions;
  List<LiveSession> get liveSessions => _liveSessions;
  LiveSession? get currentSession => _currentSession;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInSession => _currentSession != null;

  // Get all sessions combined
  List<LiveSession> get allSessions => [..._liveSessions, ..._upcomingSessions];

  // Initialize
  Future<void> init() async {
    await loadSessions();
  }

  // Load all sessions
  Future<void> loadSessions() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final results = await Future.wait([
        _socialService.getUpcomingSessions(),
        _socialService.getLiveSessions(),
      ]);

      _upcomingSessions = results[0];
      _liveSessions = results[1];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load sessions';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading sessions: $e');
    }
  }

  // Join session
  Future<bool> joinSession(String sessionId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _socialService.joinSession(sessionId);

      // Find and set current session
      final session = allSessions.firstWhere(
        (s) => s.id == sessionId,
        orElse: () => throw Exception('Session not found'),
      );

      _currentSession = session.copyWith(
        currentParticipants: session.currentParticipants + 1,
      );

      await loadSessions();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to join session';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error joining session: $e');
      return false;
    }
  }

  // Leave session
  Future<bool> leaveSession() async {
    if (_currentSession == null) return false;

    try {
      _isLoading = true;
      notifyListeners();

      await _socialService.leaveSession(_currentSession!.id);
      _currentSession = null;

      await loadSessions();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to leave session';
      _isLoading = false;
      notifyListeners();
      debugPrint('Error leaving session: $e');
      return false;
    }
  }

  // Get sessions by type
  List<LiveSession> getSessionsByType(SessionType type) {
    return allSessions.where((s) => s.type == type).toList();
  }

  // Get sessions starting soon (within 30 minutes)
  List<LiveSession> getSessionsStartingSoon() {
    final now = DateTime.now();
    return _upcomingSessions.where((s) {
      final diff = s.scheduledStart.difference(now);
      return diff.inMinutes >= 0 && diff.inMinutes <= 30;
    }).toList();
  }

  // Refresh sessions
  Future<void> refresh() async {
    await loadSessions();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear current session (when session ends)
  void clearCurrentSession() {
    _currentSession = null;
    notifyListeners();
  }
}
