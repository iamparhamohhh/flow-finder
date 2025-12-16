// ⚠️ START: Complete Updated breathing_screen.dart with Audio Controls
// lib/screens/breathing_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/breathing_provider.dart';

class BreathingScreen extends StatelessWidget {
  const BreathingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BreathingProvider(),
      child: const _BreathingContent(),
    );
  }
}

class _BreathingContent extends StatelessWidget {
  const _BreathingContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Breathing Exercise'),
        centerTitle: true,
      ),
      body: Consumer<BreathingProvider>(
        builder: (context, provider, child) {
          if (!provider.isActive) {
            return _IntroScreen(onStart: () => provider.startExercise());
          }
          return _ExerciseScreen(provider: provider);
        },
      ),
    );
  }
}

// ========== صفحه معرفی (قبل از شروع) ==========
class _IntroScreen extends StatelessWidget {
  final VoidCallback onStart;

  const _IntroScreen({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // آیکون تنفس
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.air_rounded,
                size: 80,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 32),

            // عنوان
            Text(
              'Box Breathing',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // توضیحات فواید
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Benefits',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const _BenefitItem(
                      icon: Icons.psychology_rounded,
                      text: 'Reduces stress and anxiety',
                    ),
                    const _BenefitItem(
                      icon: Icons.favorite_rounded,
                      text: 'Lowers heart rate and blood pressure',
                    ),
                    const _BenefitItem(
                      icon: Icons.self_improvement_rounded,
                      text: 'Improves focus and concentration',
                    ),
                    const _BenefitItem(
                      icon: Icons.bedtime_rounded,
                      text: 'Enhances sleep quality',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // راهنمای ریتم
            Text(
              'Follow the rhythm:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              '4s Inhale → 4s Hold → 6s Exhale → 2s Rest',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // دکمه شروع
            ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 28),
                  SizedBox(width: 8),
                  Text('Start Exercise', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}

// ========== صفحه تمرین (حین انجام) ==========
class _ExerciseScreen extends StatelessWidget {
  final BreathingProvider provider;

  const _ExerciseScreen({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // آمار بالای صفحه
          _StatsBar(provider: provider),

          // دایره انیمیشنی
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Center(child: _BreathingCircle(provider: provider)),
          ),

          // ⚠️ START: Sound Control Widget Added
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SoundControl(provider: provider),
          ),
          const SizedBox(height: 16),
          // ⚠️ END: Sound Control Widget Added

          // کنترل‌ها (Pause/Resume/Stop)
          _ControlsBar(provider: provider),
        ],
      ),
    );
  }
}

// ⚠️ START: Sound Control Widget
class _SoundControl extends StatelessWidget {
  final BreathingProvider provider;

  const _SoundControl({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // دکمه روشن/خاموش صدا
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      provider.isSoundEnabled
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      color: provider.isSoundEnabled
                          ? Colors.blue
                          : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Ambient Sound',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: provider.isSoundEnabled,
                  onChanged: (_) => provider.toggleSound(),
                  activeColor: Colors.blue,
                ),
              ],
            ),

            // اسلایدر صدا
            if (provider.isSoundEnabled) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.volume_down_rounded, size: 20),
                  Expanded(
                    child: Slider(
                      value: provider.volume,
                      onChanged: (value) => provider.setVolume(value),
                      activeColor: Colors.blue,
                      min: 0.0,
                      max: 1.0,
                    ),
                  ),
                  const Icon(Icons.volume_up_rounded, size: 20),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Volume: ${(provider.volume * 100).toInt()}%',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
// ⚠️ END: Sound Control Widget

// ========== نوار آمار بالای صفحه ==========
class _StatsBar extends StatelessWidget {
  final BreathingProvider provider;

  const _StatsBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.repeat_rounded,
            label: 'Cycles',
            value: '${provider.cyclesCompleted}',
          ),
          _StatItem(
            icon: Icons.timer_rounded,
            label: 'Time',
            value: '${provider.remainingSeconds}s',
          ),
          _StatItem(
            icon: Icons.show_chart_rounded,
            label: 'Progress',
            value: '${(provider.progress * 100).toInt()}%',
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// ========== دایره انیمیشنی تنفس ==========
class _BreathingCircle extends StatefulWidget {
  final BreathingProvider provider;

  const _BreathingCircle({required this.provider});

  @override
  State<_BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends State<_BreathingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _updateAnimation();
  }

  @override
  void didUpdateWidget(_BreathingCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.provider.currentPhase != widget.provider.currentPhase) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    final duration = _getPhaseDuration(widget.provider.currentPhase);

    _controller.duration = Duration(milliseconds: duration);

    switch (widget.provider.currentPhase) {
      case BreathingPhase.inhale:
        // دم: دایره از 0.6 به 1.0 میره (بزرگ میشه)
        _controller.forward(from: 0);
        break;

      case BreathingPhase.hold:
        // حبس: دایره در سایز 1.0 ثابت میمونه
        _controller.value = 1.0;
        break;

      case BreathingPhase.exhale:
        // بازدم: دایره از 1.0 به 0.6 برمیگرده (کوچیک میشه)
        _controller.reverse(from: 1.0);
        break;

      case BreathingPhase.rest:
        // استراحت: دایره در سایز 0.6 ثابت میمونه
        _controller.value = 0;
        break;
    }
  }

  int _getPhaseDuration(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.inhale:
        return 4000; // 4 ثانیه
      case BreathingPhase.hold:
        return 4000; // 4 ثانیه
      case BreathingPhase.exhale:
        return 6000; // 6 ثانیه
      case BreathingPhase.rest:
        return 2000; // 2 ثانیه
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phase = widget.provider.currentPhase;
    final phaseText = widget.provider.phaseText;

    Color circleColor;
    switch (phase) {
      case BreathingPhase.inhale:
        circleColor = Colors.blue.shade400;
        break;
      case BreathingPhase.hold:
        circleColor = Colors.purple.shade400;
        break;
      case BreathingPhase.exhale:
        circleColor = Colors.green.shade400;
        break;
      case BreathingPhase.rest:
        circleColor = Colors.grey.shade400;
        break;
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        // Calculate base size responsively
        final screenWidth = MediaQuery.of(context).size.width;
        final baseSize = (screenWidth * 0.5).clamp(120.0, 280.0);
        final animatedSize = baseSize * (0.6 + (_scaleAnimation.value * 0.4));

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // متن فاز
            Text(
              phaseText,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: circleColor,
              ),
            ),
            const SizedBox(height: 24),

            // دایره انیمیشنی با Smooth Transition
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: animatedSize,
              height: animatedSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    circleColor.withOpacity(0.7),
                    circleColor.withOpacity(0.3),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: circleColor.withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${widget.provider.remainingSeconds}',
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ========== نوار کنترل (Pause/Resume/Stop) ==========
class _ControlsBar extends StatelessWidget {
  final BreathingProvider provider;

  const _ControlsBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // دکمه Pause/Resume
          ElevatedButton.icon(
            onPressed: () {
              if (provider.isPaused) {
                provider.resumeExercise();
              } else {
                provider.pauseExercise();
              }
            },
            icon: Icon(
              provider.isPaused
                  ? Icons.play_arrow_rounded
                  : Icons.pause_rounded,
              size: 28,
            ),
            label: Text(
              provider.isPaused ? 'Resume' : 'Pause',
              style: const TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(140, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),

          // دکمه Stop
          OutlinedButton.icon(
            onPressed: () {
              provider.stopExercise();
            },
            icon: const Icon(Icons.stop_rounded, size: 28),
            label: const Text('Stop', style: TextStyle(fontSize: 16)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(140, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ⚠️ END: Complete Updated breathing_screen.dart
