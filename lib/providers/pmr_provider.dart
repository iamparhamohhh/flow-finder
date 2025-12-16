// ⚠️ START: lib/providers/pmr_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';

enum PMRPhase { tension, relaxation }

class MuscleGroup {
  final String name;
  final String instruction;
  final IconData icon;

  MuscleGroup({
    required this.name,
    required this.instruction,
    required this.icon,
  });
}

class PMRProvider with ChangeNotifier {
  // تنظیمات زمان‌بندی
  final int tensionDuration = 30; // 30 ثانیه تنش
  final int relaxationDuration = 30; // 30 ثانیه شل‌کردن
  final int finalRelaxationDuration = 60; // 60 ثانیه آرامش نهایی

  // گروه‌های عضلانی
  final List<MuscleGroup> muscleGroups = [
    MuscleGroup(
      name: 'Face & Head',
      instruction:
          'Squeeze your eyes shut, wrinkle your nose, and clench your jaw tightly.',
      icon: Icons.face_rounded,
    ),
    MuscleGroup(
      name: 'Shoulders & Neck',
      instruction:
          'Raise your shoulders up to your ears and tense your neck muscles.',
      icon: Icons.accessibility_new_rounded,
    ),
    MuscleGroup(
      name: 'Arms',
      instruction:
          'Make tight fists and tense your arms from shoulders to hands.',
      icon: Icons.fitness_center_rounded,
    ),
    MuscleGroup(
      name: 'Chest & Abdomen',
      instruction:
          'Take a deep breath, hold it, and tighten your chest and stomach muscles.',
      icon: Icons.favorite_rounded,
    ),
    MuscleGroup(
      name: 'Legs',
      instruction:
          'Tense your thighs, calves, and curl your toes downward.',
      icon: Icons.directions_walk_rounded,
    ),
  ];

  // وضعیت‌ها
  bool _isActive = false;
  bool _isPaused = false;
  PMRPhase _currentPhase = PMRPhase.tension;
  int _currentGroupIndex = 0;
  int _remainingSeconds = 0;
  bool _isFinalRelaxation = false;

  Timer? _timer;

  // Getters
  bool get isActive => _isActive;
  bool get isPaused => _isPaused;
  PMRPhase get currentPhase => _currentPhase;
  int get currentGroupIndex => _currentGroupIndex;
  int get remainingSeconds => _remainingSeconds;
  bool get isFinalRelaxation => _isFinalRelaxation;

  MuscleGroup get currentGroup => muscleGroups[_currentGroupIndex];

  int get totalGroups => muscleGroups.length;

  int get completedGroups => _currentGroupIndex;

  String get phaseText {
    if (_isFinalRelaxation) return 'Final Relaxation';
    return _currentPhase == PMRPhase.tension ? 'Tense' : 'Release';
  }

  String get instruction {
    if (_isFinalRelaxation) {
      return 'Take a moment to feel the deep relaxation throughout your entire body.';
    }
    if (_currentPhase == PMRPhase.tension) {
      return currentGroup.instruction;
    } else {
      return 'Now slowly release the tension and feel the muscles relax completely.';
    }
  }

  double get progress {
    if (_isFinalRelaxation) {
      return (_currentGroupIndex + 1) / (totalGroups + 1);
    }
    final groupProgress = _currentGroupIndex / totalGroups;
    final phaseProgress = _currentPhase == PMRPhase.tension ? 0.0 : 0.5;
    return groupProgress + (phaseProgress / totalGroups);
  }

  // شروع تمرین
  void startExercise() {
    _isActive = true;
    _isPaused = false;
    _currentPhase = PMRPhase.tension;
    _currentGroupIndex = 0;
    _remainingSeconds = tensionDuration;
    _isFinalRelaxation = false;
    _startTimer();
    notifyListeners();
  }

  // توقف موقت
  void pauseExercise() {
    _isPaused = true;
    _timer?.cancel();
    notifyListeners();
  }

  // ادامه
  void resumeExercise() {
    _isPaused = false;
    _startTimer();
    notifyListeners();
  }

  // پایان
  void stopExercise() {
    _isActive = false;
    _isPaused = false;
    _timer?.cancel();
    _isFinalRelaxation = false;
    notifyListeners();
  }

  // تایمر اصلی
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _nextPhase();
      }
    });
  }

  // مرحله بعدی
  void _nextPhase() {
    if (_isFinalRelaxation) {
      // پایان تمرین
      stopExercise();
      return;
    }

    if (_currentPhase == PMRPhase.tension) {
      // از تنش به شل‌کردن
      _currentPhase = PMRPhase.relaxation;
      _remainingSeconds = relaxationDuration;
    } else {
      // از شل‌کردن به گروه بعدی
      _currentGroupIndex++;

      if (_currentGroupIndex >= totalGroups) {
        // شروع آرامش نهایی
        _isFinalRelaxation = true;
        _remainingSeconds = finalRelaxationDuration;
      } else {
        // گروه بعدی
        _currentPhase = PMRPhase.tension;
        _remainingSeconds = tensionDuration;
      }
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
// ⚠️ END: lib/providers/pmr_provider.dart
