// ⚠️ START: lib/providers/body_scan_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';

enum BodyScanRegion {
  introduction,
  head,
  face,
  neck,
  shoulders,
  arms,
  hands,
  chest,
  abdomen,
  back,
  hips,
  legs,
  feet,
  closing,
}

class BodyScanProvider with ChangeNotifier {
  // تنظیمات
  int _selectedDuration = 10; // پیش‌فرض 10 دقیقه
  bool _isActive = false;
  bool _isPaused = false;
  int _remainingSeconds = 0;
  BodyScanRegion _currentRegion = BodyScanRegion.introduction;
  int _currentRegionIndex = 0;

  Timer? _timer;

  // لیست مناطق بدن (به ترتیب)
  final List<BodyScanRegion> _regions = [
    BodyScanRegion.introduction,
    BodyScanRegion.head,
    BodyScanRegion.face,
    BodyScanRegion.neck,
    BodyScanRegion.shoulders,
    BodyScanRegion.arms,
    BodyScanRegion.hands,
    BodyScanRegion.chest,
    BodyScanRegion.abdomen,
    BodyScanRegion.back,
    BodyScanRegion.hips,
    BodyScanRegion.legs,
    BodyScanRegion.feet,
    BodyScanRegion.closing,
  ];

  // Getters
  int get selectedDuration => _selectedDuration;
  bool get isActive => _isActive;
  bool get isPaused => _isPaused;
  int get remainingSeconds => _remainingSeconds;
  BodyScanRegion get currentRegion => _currentRegion;
  int get currentRegionIndex => _currentRegionIndex;
  int get totalRegions => _regions.length;

  // محاسبه پیشرفت
  double get progress {
    if (_regions.isEmpty) return 0;
    return _currentRegionIndex / _regions.length;
  }

  // محاسبه پیشرفت کلی زمانی
  double get timeProgress {
    final totalSeconds = _selectedDuration * 60;
    if (totalSeconds == 0) return 0;
    return 1 - (_remainingSeconds / totalSeconds);
  }

  // دریافت نام ناحیه فعلی
  String get regionName {
    switch (_currentRegion) {
      case BodyScanRegion.introduction:
        return 'Introduction';
      case BodyScanRegion.head:
        return 'Head & Crown';
      case BodyScanRegion.face:
        return 'Face';
      case BodyScanRegion.neck:
        return 'Neck';
      case BodyScanRegion.shoulders:
        return 'Shoulders';
      case BodyScanRegion.arms:
        return 'Arms';
      case BodyScanRegion.hands:
        return 'Hands & Fingers';
      case BodyScanRegion.chest:
        return 'Chest';
      case BodyScanRegion.abdomen:
        return 'Abdomen';
      case BodyScanRegion.back:
        return 'Back';
      case BodyScanRegion.hips:
        return 'Hips & Pelvis';
      case BodyScanRegion.legs:
        return 'Legs';
      case BodyScanRegion.feet:
        return 'Feet & Toes';
      case BodyScanRegion.closing:
        return 'Closing';
    }
  }

  // راهنمایی برای هر ناحیه
  String get currentGuidance {
    switch (_currentRegion) {
      case BodyScanRegion.introduction:
        return 'Lie down in a comfortable position. Close your eyes. '
            'Take a few deep breaths and allow your body to settle.';
      case BodyScanRegion.head:
        return 'Bring your attention to the top of your head. '
            'Notice any sensations—warmth, coolness, tingling, or nothing at all. '
            'Simply observe without judgment.';
      case BodyScanRegion.face:
        return 'Move your awareness to your face. Notice your forehead, eyebrows, eyes, cheeks, nose, mouth, and jaw. '
            'Are there any areas of tension? Gently release any tightness.';
      case BodyScanRegion.neck:
        return 'Shift attention to your neck. Notice the front, sides, and back. '
            'This area often holds tension. Breathe into any tightness and let it soften.';
      case BodyScanRegion.shoulders:
        return 'Focus on your shoulders. Notice if they feel raised, tight, or relaxed. '
            'With each exhale, imagine releasing any burden they carry.';
      case BodyScanRegion.arms:
        return 'Scan down both arms from shoulders to elbows. '
            'Notice the upper arms, elbows, and forearms. Observe any sensations.';
      case BodyScanRegion.hands:
        return 'Bring awareness to your hands, palms, and each finger. '
            'Notice the contact with the surface beneath you. Feel the subtle energy in your fingertips.';
      case BodyScanRegion.chest:
        return 'Move to your chest. Feel the gentle rise and fall with each breath. '
            'Notice your heart beating. Allow this area to feel open and spacious.';
      case BodyScanRegion.abdomen:
        return 'Shift to your abdomen. Notice the expansion on inhale and contraction on exhale. '
            'This is your body\'s natural rhythm. Simply observe.';
      case BodyScanRegion.back:
        return 'Bring attention to your entire back—upper, middle, and lower. '
            'Notice the contact with the surface supporting you. Allow your back to fully relax into this support.';
      case BodyScanRegion.hips:
        return 'Focus on your hips and pelvis. This area connects your upper and lower body. '
            'Notice any sensations, tightness, or ease. Breathe space into this area.';
      case BodyScanRegion.legs:
        return 'Scan down both legs—thighs, knees, calves, and shins. '
            'Notice the weight of your legs. Feel them supported by the ground beneath you.';
      case BodyScanRegion.feet:
        return 'Finally, bring awareness to your feet. Notice your heels, arches, and each toe. '
            'Feel the connection between your body and the earth.';
      case BodyScanRegion.closing:
        return 'Take a moment to feel your body as a whole. Notice the sense of completeness. '
            'Slowly wiggle your fingers and toes. When ready, gently open your eyes.';
    }
  }

  // آیکون هر ناحیه
  IconData get regionIcon {
    switch (_currentRegion) {
      case BodyScanRegion.introduction:
        return Icons.self_improvement_rounded;
      case BodyScanRegion.head:
        return Icons.face_rounded;
      case BodyScanRegion.face:
        return Icons.emoji_emotions_rounded;
      case BodyScanRegion.neck:
        return Icons.accessibility_new_rounded;
      case BodyScanRegion.shoulders:
        return Icons.airline_seat_recline_normal_rounded;
      case BodyScanRegion.arms:
        return Icons.back_hand_rounded;
      case BodyScanRegion.hands:
        return Icons.front_hand_rounded;
      case BodyScanRegion.chest:
        return Icons.favorite_rounded;
      case BodyScanRegion.abdomen:
        return Icons.circle_outlined;
      case BodyScanRegion.back:
        return Icons.airline_seat_flat_rounded;
      case BodyScanRegion.hips:
        return Icons.airline_seat_legroom_normal_rounded;
      case BodyScanRegion.legs:
        return Icons.directions_walk_rounded;
      case BodyScanRegion.feet:
        return Icons.directions_run_rounded;
      case BodyScanRegion.closing:
        return Icons.wb_sunny_rounded;
    }
  }

  // رنگ هر ناحیه (گرادیانت از بالا به پایین بدن)
  Color get regionColor {
    switch (_currentRegion) {
      case BodyScanRegion.introduction:
        return Colors.deepPurple;
      case BodyScanRegion.head:
        return Colors.purple;
      case BodyScanRegion.face:
        return Colors.deepPurple.shade400;
      case BodyScanRegion.neck:
        return Colors.blue;
      case BodyScanRegion.shoulders:
        return Colors.lightBlue;
      case BodyScanRegion.arms:
        return Colors.cyan;
      case BodyScanRegion.hands:
        return Colors.teal;
      case BodyScanRegion.chest:
        return Colors.green;
      case BodyScanRegion.abdomen:
        return Colors.lightGreen;
      case BodyScanRegion.back:
        return Colors.lime;
      case BodyScanRegion.hips:
        return Colors.amber;
      case BodyScanRegion.legs:
        return Colors.orange;
      case BodyScanRegion.feet:
        return Colors.deepOrange;
      case BodyScanRegion.closing:
        return Colors.pink;
    }
  }

  // تنظیم مدت زمان
  void setDuration(int minutes) {
    _selectedDuration = minutes;
    notifyListeners();
  }

  // شروع تمرین
  void startScan() {
    _isActive = true;
    _isPaused = false;
    _remainingSeconds = _selectedDuration * 60;
    _currentRegionIndex = 0;
    _currentRegion = _regions[0];
    _startTimer();
    notifyListeners();
  }

  // توقف موقت
  void pauseScan() {
    _isPaused = true;
    _timer?.cancel();
    notifyListeners();
  }

  // ادامه
  void resumeScan() {
    _isPaused = false;
    _startTimer();
    notifyListeners();
  }

  // پایان
  void stopScan() {
    _isActive = false;
    _isPaused = false;
    _timer?.cancel();
    notifyListeners();
  }

  // رفتن به ناحیه بعدی (اختیاری برای دکمه Next)
  void nextRegion() {
    if (_currentRegionIndex < _regions.length - 1) {
      _currentRegionIndex++;
      _currentRegion = _regions[_currentRegionIndex];
      notifyListeners();
    }
  }

  // تایمر اصلی
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        _updateRegion();
        notifyListeners();
      } else {
        stopScan();
      }
    });
  }

  // به‌روزرسانی ناحیه بر اساس زمان
  void _updateRegion() {
    final totalSeconds = _selectedDuration * 60;
    final elapsed = totalSeconds - _remainingSeconds;

    // تقسیم زمان بین نواحی
    final secondsPerRegion = totalSeconds / _regions.length;
    final newIndex = (elapsed / secondsPerRegion).floor().clamp(
      0,
      _regions.length - 1,
    );

    if (newIndex != _currentRegionIndex) {
      _currentRegionIndex = newIndex;
      _currentRegion = _regions[_currentRegionIndex];
    }
  }

  // فرمت زمان mm:ss
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

// ⚠️ END: lib/providers/body_scan_provider.dart
