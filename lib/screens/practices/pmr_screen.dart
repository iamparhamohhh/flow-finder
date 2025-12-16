// ⚠️ START: lib/screens/practices/pmr_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pmr_provider.dart';

class PMRScreen extends StatelessWidget {
  const PMRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PMRProvider(),
      child: const _PMRContent(),
    );
  }
}

class _PMRContent extends StatelessWidget {
  const _PMRContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progressive Muscle Relaxation'),
        centerTitle: true,
      ),
      body: Consumer<PMRProvider>(
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

// ========== صفحه معرفی ==========
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
            // آیکون
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fitness_center_rounded,
                size: 80,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 32),

            // عنوان
            Text(
              'Progressive Muscle\nRelaxation',
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
                            color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'How it works',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      'This exercise guides you through systematically tensing and relaxing different muscle groups in your body.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _BenefitItem(
                      icon: Icons.spa_rounded,
                      text: 'Releases physical tension',
                    ),
                    _BenefitItem(
                      icon: Icons.psychology_rounded,
                      text: 'Reduces anxiety and stress',
                    ),
                    _BenefitItem(
                      icon: Icons.bedtime_rounded,
                      text: 'Improves sleep quality',
                    ),
                    _BenefitItem(
                      icon: Icons.self_improvement_rounded,
                      text: 'Enhances body awareness',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // مدت زمان
            Card(
              elevation: 1,
              color: Colors.orange.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer_rounded, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Duration: ~11 minutes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // دکمه شروع
            ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 56),
                backgroundColor: Colors.orange.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 28),
                  SizedBox(width: 8),
                  Text('Begin Exercise', style: TextStyle(fontSize: 18)),
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
          Icon(icon, size: 20, color: Colors.orange.shade700),
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

// ========== صفحه تمرین ==========
class _ExerciseScreen extends StatelessWidget {
  final PMRProvider provider;

  const _ExerciseScreen({required this.provider});

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
                // آیکون گروه عضلانی
                _MuscleGroupIcon(provider: provider),
                const SizedBox(height: 24),

                // نام گروه
                _GroupName(provider: provider),
                const SizedBox(height: 16),

                // فاز (Tense/Release/Final)
                _PhaseIndicator(provider: provider),
                const SizedBox(height: 32),

                // تایمر بزرگ
                _Timer(provider: provider),
                const SizedBox(height: 32),

                // دستورالعمل
                _InstructionCard(provider: provider),
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
  final PMRProvider provider;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${provider.completedGroups} / ${provider.totalGroups} groups',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: provider.progress,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(Colors.orange.shade700),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

// ========== آیکون گروه عضلانی ==========
class _MuscleGroupIcon extends StatelessWidget {
  final PMRProvider provider;

  const _MuscleGroupIcon({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isFinalRelaxation) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.spa_rounded,
          size: 64,
          color: Colors.green.shade700,
        ),
      );
    }

    final color = provider.currentPhase == PMRPhase.tension
        ? Colors.orange.shade700
        : Colors.green.shade700;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        provider.currentGroup.icon,
        size: 64,
        color: color,
      ),
    );
  }
}

// ========== نام گروه ==========
class _GroupName extends StatelessWidget {
  final PMRProvider provider;

  const _GroupName({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isFinalRelaxation) {
      return Text(
        'Whole Body',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
        textAlign: TextAlign.center,
      );
    }

    return Text(
      provider.currentGroup.name,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
      textAlign: TextAlign.center,
    );
  }
}

// ========== نمایشگر فاز ==========
class _PhaseIndicator extends StatelessWidget {
  final PMRProvider provider;

  const _PhaseIndicator({required this.provider});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (provider.isFinalRelaxation) {
      color = Colors.green.shade700;
    } else if (provider.currentPhase == PMRPhase.tension) {
      color = Colors.orange.shade700;
    } else {
      color = Colors.green.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Text(
        provider.phaseText.toUpperCase(),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

// ========== تایمر ==========
class _Timer extends StatelessWidget {
  final PMRProvider provider;

  const _Timer({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.orange.shade100,
            Colors.orange.shade50,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '${provider.remainingSeconds}',
          style: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade700,
          ),
        ),
      ),
    );
  }
}

// ========== کارت دستورالعمل ==========
class _InstructionCard extends StatelessWidget {
  final PMRProvider provider;

  const _InstructionCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 8),
                Text(
                  'Instruction',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              provider.instruction,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ========== نوار کنترل ==========
class _ControlsBar extends StatelessWidget {
  final PMRProvider provider;

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
              backgroundColor: Colors.orange.shade700,
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
              foregroundColor: Colors.orange.shade700,
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
// ⚠️ END: lib/screens/practices/pmr_screen.dart
