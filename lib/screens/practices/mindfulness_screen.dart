// ⚠️ START: lib/screens/practices/mindfulness_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mindfulness_provider.dart';

class MindfulnessScreen extends StatelessWidget {
  const MindfulnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MindfulnessProvider(),
      child: const _MindfulnessContent(),
    );
  }
}

class _MindfulnessContent extends StatelessWidget {
  const _MindfulnessContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mindfulness Meditation'),
        centerTitle: true,
      ),
      body: Consumer<MindfulnessProvider>(
        builder: (context, provider, child) {
          if (!provider.isActive) {
            return _IntroScreen(provider: provider);
          }
          return _MeditationScreen(provider: provider);
        },
      ),
    );
  }
}

// ========== صفحه معرفی ==========
class _IntroScreen extends StatelessWidget {
  final MindfulnessProvider provider;

  const _IntroScreen({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // آیکون
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.self_improvement_rounded,
                size: 80,
                color: Colors.purple.shade700,
              ),
            ),
            const SizedBox(height: 32),

            // عنوان
            Text(
              'Mindfulness\nMeditation',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // توضیحات
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
                        Icon(Icons.info_outline,
                            color: Colors.purple.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'About this practice',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      'Mindfulness meditation helps you cultivate present-moment awareness and a non-judgmental attitude toward your thoughts and feelings.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _BenefitItem(
                      icon: Icons.spa_rounded,
                      text: 'Reduces stress and rumination',
                    ),
                    _BenefitItem(
                      icon: Icons.psychology_rounded,
                      text: 'Improves emotional regulation',
                    ),
                    _BenefitItem(
                      icon: Icons.favorite_rounded,
                      text: 'Enhances self-awareness',
                    ),
                    _BenefitItem(
                      icon: Icons.trending_up_rounded,
                      text: 'Increases focus and clarity',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // انتخاب مدت زمان
            _DurationSelector(provider: provider),
            const SizedBox(height: 32),

            // دکمه شروع
            ElevatedButton(
              onPressed: () => provider.startMeditation(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 56),
                backgroundColor: Colors.purple.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 28),
                  SizedBox(width: 8),
                  Text('Begin Meditation', style: TextStyle(fontSize: 18)),
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
          Icon(icon, size: 20, color: Colors.purple.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

// ========== انتخابگر مدت زمان ==========
class _DurationSelector extends StatelessWidget {
  final MindfulnessProvider provider;

  const _DurationSelector({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_rounded, color: Colors.purple.shade700),
                const SizedBox(width: 8),
                Text(
                  'Choose Duration',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _DurationButton(
                  minutes: 5,
                  isSelected: provider.selectedDuration == 5,
                  onTap: () => provider.setDuration(5),
                ),
                _DurationButton(
                  minutes: 10,
                  isSelected: provider.selectedDuration == 10,
                  onTap: () => provider.setDuration(10),
                ),
                _DurationButton(
                  minutes: 15,
                  isSelected: provider.selectedDuration == 15,
                  onTap: () => provider.setDuration(15),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DurationButton extends StatelessWidget {
  final int minutes;
  final bool isSelected;
  final VoidCallback onTap;

  const _DurationButton({
    required this.minutes,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? Colors.purple.shade700 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$minutes',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
            Text(
              'min',
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== صفحه مدیتیشن ==========
class _MeditationScreen extends StatelessWidget {
  final MindfulnessProvider provider;

  const _MeditationScreen({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // نوار پیشرفت
        _ProgressBar(provider: provider),

        // محتوای اصلی
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // دایره انیمیشنی
                _AnimatedCircle(provider: provider),
                const SizedBox(height: 40),

                // نام فاز
                _PhaseTitle(provider: provider),
                const SizedBox(height: 16),

                // تایمر
                _TimerDisplay(provider: provider),
                const SizedBox(height: 32),

                // راهنمایی
                _GuidanceCard(provider: provider),
              ],
            ),
          ),
        ),

        // کنترل‌ها
        _ControlsBar(provider: provider),
      ],
    );
  }
}

// ========== نوار پیشرفت ==========
class _ProgressBar extends StatelessWidget {
  final MindfulnessProvider provider;

  const _ProgressBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Column(
        children: [
          LinearProgressIndicator(
            value: provider.progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(provider.phaseColor),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

// ========== دایره انیمیشنی ==========
class _AnimatedCircle extends StatefulWidget {
  final MindfulnessProvider provider;

  const _AnimatedCircle({required this.provider});

  @override
  State<_AnimatedCircle> createState() => _AnimatedCircleState();
}

class _AnimatedCircleState extends State<_AnimatedCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final pulseValue = 0.9 + (_controller.value * 0.1);

        return Transform.scale(
          scale: pulseValue,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.provider.phaseColor.withOpacity(0.6),
                  widget.provider.phaseColor.withOpacity(0.2),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.provider.phaseColor.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                widget.provider.phaseIcon,
                size: 64,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ========== عنوان فاز ==========
class _PhaseTitle extends StatelessWidget {
  final MindfulnessProvider provider;

  const _PhaseTitle({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Text(
      provider.phaseTitle,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: provider.phaseColor,
          ),
      textAlign: TextAlign.center,
    );
  }
}

// ========== نمایشگر تایمر ==========
class _TimerDisplay extends StatelessWidget {
  final MindfulnessProvider provider;

  const _TimerDisplay({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Text(
      provider.formattedTime,
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade700,
      ),
    );
  }
}

// ========== کارت راهنمایی ==========
class _GuidanceCard extends StatelessWidget {
  final MindfulnessProvider provider;

  const _GuidanceCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          provider.currentGuidance,
          style: const TextStyle(
            fontSize: 16,
            height: 1.8,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ========== نوار کنترل ==========
class _ControlsBar extends StatelessWidget {
  final MindfulnessProvider provider;

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
                provider.resumeMeditation();
              } else {
                provider.pauseMeditation();
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
              backgroundColor: Colors.purple.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),

          // دکمه Stop
          OutlinedButton.icon(
            onPressed: () {
              provider.stopMeditation();
            },
            icon: const Icon(Icons.stop_rounded, size: 28),
            label: const Text('Stop', style: TextStyle(fontSize: 16)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(140, 50),
              foregroundColor: Colors.purple.shade700,
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
// ⚠️ END: lib/screens/practices/mindfulness_screen.dart