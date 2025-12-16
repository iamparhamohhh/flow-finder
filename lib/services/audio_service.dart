// ⚠️ START: Audio Service for breathing exercises
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _ambientPlayer = AudioPlayer();
  final AudioPlayer _bellPlayer = AudioPlayer();

  bool _isAmbientPlaying = false;
  double _volume = 0.5;

  bool get isAmbientPlaying => _isAmbientPlaying;
  double get volume => _volume;

  /// پخش صدای محیطی (loop)
  Future<void> playAmbient() async {
    try {
      await _ambientPlayer.setReleaseMode(ReleaseMode.loop);
      await _ambientPlayer.setVolume(_volume);
      await _ambientPlayer.play(AssetSource('sounds/ambient.mp3'));
      _isAmbientPlaying = true;
    } catch (e) {
      print('Error playing ambient: $e');
    }
  }

  /// توقف صدای محیطی
  Future<void> stopAmbient() async {
    await _ambientPlayer.stop();
    _isAmbientPlaying = false;
  }

  /// پخش/توقف صدای محیطی (toggle)
  Future<void> toggleAmbient() async {
    if (_isAmbientPlaying) {
      await stopAmbient();
    } else {
      await playAmbient();
    }
  }

  /// پخش صدای زنگ پایان
  Future<void> playBell() async {
    try {
      await _bellPlayer.setVolume(_volume);
      await _bellPlayer.play(AssetSource('sounds/bell.mp3'));
    } catch (e) {
      print('Error playing bell: $e');
    }
  }

  /// تنظیم صدا
  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    await _ambientPlayer.setVolume(_volume);
    await _bellPlayer.setVolume(_volume);
  }

  /// Pause صدای محیطی
  Future<void> pauseAmbient() async {
    await _ambientPlayer.pause();
    _isAmbientPlaying = false;
  }

  /// Resume صدای محیطی
  Future<void> resumeAmbient() async {
    await _ambientPlayer.resume();
    _isAmbientPlaying = true;
  }

  /// آزادسازی منابع
  Future<void> dispose() async {
    await _ambientPlayer.dispose();
    await _bellPlayer.dispose();
  }
}
// ⚠️ END: Audio Service
