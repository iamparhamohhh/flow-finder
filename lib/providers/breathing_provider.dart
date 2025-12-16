import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

enum BreathingPhase { inhale, hold, exhale, rest }

class BreathingProvider extends ChangeNotifier {
  // ⚠️ START: Callback برای Quest
  final VoidCallback? onQuestCompleted;

  BreathingProvider({this.onQuestCompleted});
  // ⚠️ END

  // ========== حالت تمرین ==========
  bool _isActive = false;
  bool _isPaused = false;
  BreathingPhase _currentPhase = BreathingPhase.inhale;
  int _remainingSeconds = 4;
  int _cyclesCompleted = 0;
  double _progress = 0.0;

  Timer? _mainTimer;
  Timer? _phaseTimer;

  // ========== صدا ==========
  final AudioPlayer _ambientPlayer = AudioPlayer();
  bool _isSoundEnabled = true;
  double _volume = 0.5;

  // ========== Getters ==========
  bool get isActive => _isActive;
  bool get isPaused => _isPaused;
  BreathingPhase get currentPhase => _currentPhase;
  int get remainingSeconds => _remainingSeconds;
  int get cyclesCompleted => _cyclesCompleted;
  double get progress => _progress;
  bool get isSoundEnabled => _isSoundEnabled;
  double get volume => _volume;

  String get phaseText {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        return 'Breathe In';
      case BreathingPhase.hold:
        return 'Hold';
      case BreathingPhase.exhale:
        return 'Breathe Out';
      case BreathingPhase.rest:
        return 'Rest';
    }
  }

  // ========== شروع تمرین ==========
  void startExercise() {
    _isActive = true;
    _isPaused = false;
    _cyclesCompleted = 0;
    _currentPhase = BreathingPhase.inhale;
    _remainingSeconds = 4;
    _progress = 0.0;

    _playAmbientSound();
    _startPhaseTimer();

    notifyListeners();
  }

  // ========== توقف تمرین ==========
  void stopExercise() {
    if (!_isActive) return;

    _mainTimer?.cancel();
    _phaseTimer?.cancel();
    _ambientPlayer.stop();

    // ⚠️ START: اگر حداقل 1 چرخه تمام شده، Quest رو آپدیت کن
    if (_cyclesCompleted > 0 && onQuestCompleted != null) {
      onQuestCompleted!();
    }
    // ⚠️ END

    _isActive = false;
    _isPaused = false;

    notifyListeners();
  }

  // ========== Pause/Resume ==========
  void pauseExercise() {
    if (!_isActive || _isPaused) return;

    _isPaused = true;
    _phaseTimer?.cancel();
    _ambientPlayer.pause();

    notifyListeners();
  }

  void resumeExercise() {
    if (!_isActive || !_isPaused) return;

    _isPaused = false;
    _ambientPlayer.resume();
    _startPhaseTimer();

    notifyListeners();
  }

  // ========== تایمر فاز ==========
  void _startPhaseTimer() {
    _phaseTimer?.cancel();

    _phaseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      if (_remainingSeconds > 1) {
        _remainingSeconds--;
        _updateProgress();
        notifyListeners();
      } else {
        _nextPhase();
      }
    });
  }

  void _nextPhase() {
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        _currentPhase = BreathingPhase.hold;
        _remainingSeconds = 4;
        break;
      case BreathingPhase.hold:
        _currentPhase = BreathingPhase.exhale;
        _remainingSeconds = 6;
        break;
      case BreathingPhase.exhale:
        _currentPhase = BreathingPhase.rest;
        _remainingSeconds = 2;
        break;
      case BreathingPhase.rest:
        _cyclesCompleted++;
        _currentPhase = BreathingPhase.inhale;
        _remainingSeconds = 4;
        break;
    }

    _updateProgress();
    notifyListeners();
  }

  void _updateProgress() {
    final totalSecondsPerCycle = 4 + 4 + 6 + 2; // 16 ثانیه
    int elapsedInCycle = 0;

    switch (_currentPhase) {
      case BreathingPhase.inhale:
        elapsedInCycle = 4 - _remainingSeconds;
        break;
      case BreathingPhase.hold:
        elapsedInCycle = 4 + (4 - _remainingSeconds);
        break;
      case BreathingPhase.exhale:
        elapsedInCycle = 8 + (6 - _remainingSeconds);
        break;
      case BreathingPhase.rest:
        elapsedInCycle = 14 + (2 - _remainingSeconds);
        break;
    }

    _progress = elapsedInCycle / totalSecondsPerCycle;
  }

  // ========== صدا ==========
  Future<void> _playAmbientSound() async {
    if (!_isSoundEnabled) return;

    try {
      await _ambientPlayer.setVolume(_volume);
      await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
      await _ambientPlayer.play(AssetSource('sounds/ambient.mp3'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;

    if (_isSoundEnabled && _isActive) {
      _playAmbientSound();
    } else {
      _ambientPlayer.stop();
    }

    notifyListeners();
  }

  void setVolume(double value) {
    _volume = value;
    _ambientPlayer.setVolume(_volume);
    notifyListeners();
  }

  @override
  void dispose() {
    _mainTimer?.cancel();
    _phaseTimer?.cancel();
    _ambientPlayer.dispose();
    super.dispose();
  }
}
