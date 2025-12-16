// ⚠️ START: lib/providers/mindfulness_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';

enum MindfulnessPhase {
  settlingIn,
  breathAwareness,
  bodyAwareness,
  thoughtAwareness,
  closing,
}

class MindfulnessProvider with ChangeNotifier {
  // تنظیمات
  int _selectedDuration = 5; // پیش‌فرض 5 دقیقه
  bool _isActive = false;
  bool _isPaused = false;
  int _remainingSeconds = 0;
  MindfulnessPhase _currentPhase = MindfulnessPhase.settlingIn;

  Timer? _timer;

  // Getters
  int get selectedDuration => _selectedDuration;
  bool get isActive => _isActive;
  bool get isPaused => _isPaused;
  int get remainingSeconds => _remainingSeconds;
  MindfulnessPhase get currentPhase => _currentPhase;

  // محاسبه پیشرفت
  double get progress {
    final totalSeconds = _selectedDuration * 60;
    if (totalSeconds == 0) return 0;
    return 1 - (_remainingSeconds / totalSeconds);
  }

  // دریافت متن فاز فعلی
  String get phaseTitle {
    switch (_currentPhase) {
      case MindfulnessPhase.settlingIn:
        return 'Settling In';
      case MindfulnessPhase.breathAwareness:
        return 'Breath Awareness';
      case MindfulnessPhase.bodyAwareness:
        return 'Body Awareness';
      case MindfulnessPhase.thoughtAwareness:
        return 'Thought Awareness';
      case MindfulnessPhase.closing:
        return 'Closing';
    }
  }

  // دستورالعمل هر فاز
  String get currentGuidance {
    switch (_currentPhase) {
      case MindfulnessPhase.settlingIn:
        return 'Find a comfortable position. Close your eyes gently. '
            'Take a few deep breaths and allow your body to relax.';
      case MindfulnessPhase.breathAwareness:
        return 'Bring your attention to your breath. '
            'Notice the natural rhythm of inhaling and exhaling. '
            'No need to change it, just observe.';
      case MindfulnessPhase.bodyAwareness:
        return 'Expand your awareness to your whole body. '
            'Notice any sensations, tensions, or areas of comfort. '
            'Accept whatever you feel without judgment.';
      case MindfulnessPhase.thoughtAwareness:
        return 'Notice any thoughts that arise. '
            'Imagine them as clouds passing through the sky. '
            'Gently return your focus to your breath.';
      case MindfulnessPhase.closing:
        return 'Slowly bring your awareness back to the present moment. '
            'Wiggle your fingers and toes. When ready, open your eyes.';
    }
  }

  // آیکون هر فاز
  IconData get phaseIcon {
    switch (_currentPhase) {
      case MindfulnessPhase.settlingIn:
        return Icons.self_improvement_rounded;
      case MindfulnessPhase.breathAwareness:
        return Icons.air_rounded;
      case MindfulnessPhase.bodyAwareness:
        return Icons.accessibility_new_rounded;
      case MindfulnessPhase.thoughtAwareness:
        return Icons.psychology_rounded;
      case MindfulnessPhase.closing:
        return Icons.wb_sunny_rounded;
    }
  }

  // رنگ هر فاز
  Color get phaseColor {
    switch (_currentPhase) {
      case MindfulnessPhase.settlingIn:
        return Colors.purple;
      case MindfulnessPhase.breathAwareness:
        return Colors.blue;
      case MindfulnessPhase.bodyAwareness:
        return Colors.green;
      case MindfulnessPhase.thoughtAwareness:
        return Colors.orange;
      case MindfulnessPhase.closing:
        return Colors.amber;
    }
  }

  // تنظیم مدت زمان
  void setDuration(int minutes) {
    _selectedDuration = minutes;
    notifyListeners();
  }

  // شروع تمرین
  void startMeditation() {
    _isActive = true;
    _isPaused = false;
    _remainingSeconds = _selectedDuration * 60;
    _currentPhase = MindfulnessPhase.settlingIn;
    _startTimer();
    notifyListeners();
  }

  // توقف موقت
  void pauseMeditation() {
    _isPaused = true;
    _timer?.cancel();
    notifyListeners();
  }

  // ادامه
  void resumeMeditation() {
    _isPaused = false;
    _startTimer();
    notifyListeners();
  }

  // پایان
  void stopMeditation() {
    _isActive = false;
    _isPaused = false;
    _timer?.cancel();
    notifyListeners();
  }

  // تایمر اصلی
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _updatePhase();
        notifyListeners();
      } else {
        stopMeditation();
      }
    });
  }

  // به‌روزرسانی فاز بر اساس زمان باقی‌مانده
  void _updatePhase() {
    final elapsed = (_selectedDuration * 60) - _remainingSeconds;
    final totalDuration = _selectedDuration * 60;

    if (elapsed < totalDuration * 0.15) {
      _currentPhase = MindfulnessPhase.settlingIn;
    } else if (elapsed < totalDuration * 0.35) {
      _currentPhase = MindfulnessPhase.breathAwareness;
    } else if (elapsed < totalDuration * 0.60) {
      _currentPhase = MindfulnessPhase.bodyAwareness;
    } else if (elapsed < totalDuration * 0.85) {
      _currentPhase = MindfulnessPhase.thoughtAwareness;
    } else {
      _currentPhase = MindfulnessPhase.closing;
    }
  }

  // فرمت زمان به صورت mm:ss
  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
// ⚠️ END: lib/providers/mindfulness_provider.dart
