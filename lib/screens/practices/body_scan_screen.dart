// ⚠️ START: lib/screens/practices/body_scan_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/body_scan_provider.dart';

class BodyScanScreen extends StatelessWidget {
  const BodyScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BodyScanProvider(),
      child: const _BodyScanContent(),
    );
  }
}

class _BodyScanContent extends StatelessWidget {
  const _BodyScanContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Scan Meditation'),
        centerTitle: true,
      ),
      body: Consumer<BodyScanProvider>(
        builder: (context, provider, child) {
          if (!provider.isActive) {
            return _IntroScreen(provider: provider);
          }
          return _ScanScreen(provider: provider);
        },
      ),
    );
  }
}

// ========== صفحه معرفی ==========
class _IntroScreen extends StatelessWidget {
  final BodyScanProvider provider;

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
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.withOpacity(0.2),
                    Colors.orange.withOpacity(0.2),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.accessibility_new_rounded,
                size: 80,
                color: Colors.deepPurple.shade700,
              ),
            ),
            const SizedBox(height: 32),

            // عنوان
            Text(
              'Body Scan\nMeditation',
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
                            color: Colors.deepPurple.shade700),
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
                      'Body scan meditation systematically guides your attention through different parts of your body, '
                      'helping you develop awareness of physical sensations and release accumulated tension.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _BenefitItem(
                      icon: Icons.healing_rounded,
                      text: 'Releases physical tension',
                    ),
                    _BenefitItem(
                      icon: Icons.psychology_rounded,
                      text: 'Improves mind-body connection',
                    ),
                    _BenefitItem(
                      icon: Icons.bedtime_rounded,
                      text: 'Promotes deep relaxation',
                    ),
                    _BenefitItem(
                      icon: Icons.spa_rounded,
                      text: 'Reduces chronic pain',
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
              onPressed: () => provider.startScan(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 56),
                backgroundColor: Colors.deepPurple.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 28),
                  SizedBox(width: 8),
                  Text('Begin Scan', style: TextStyle(fontSize: 18)),
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
          Icon(icon, size: 20, color: Colors.deepPurple.shade700),
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
  final BodyScanProvider provider;

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
                Icon(Icons.timer_rounded, color: Colors.deepPurple.shade700),
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
                  minutes: 10,
                  isSelected: provider.selectedDuration == 10,
                  onTap: () => provider.setDuration(10),
                ),
                _DurationButton(
                  minutes: 15,
                  isSelected: provider.selectedDuration == 15,
                  onTap: () => provider.setDuration(15),
                ),
                _DurationButton(
                  minutes: 20,
                  isSelected: provider.selectedDuration == 20,
                  onTap: () => provider.setDuration(20),
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
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    Colors.deepPurple.shade700,
                    Colors.deepPurple.shade500,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
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

// ========== صفحه اسکن ==========
class _ScanScreen extends StatelessWidget {
  final BodyScanProvider provider;

  const _ScanScreen({required this.provider});

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

                // نمایش بدن (تصویری ساده با هایلایت ناحیه فعلی)
                _BodyVisualization(provider: provider),
                const SizedBox(height: 32),

                // نام ناحیه
                _RegionTitle(provider: provider),
                const SizedBox(height: 16),

                // تایمر
                _TimerDisplay(provider: provider),
                const SizedBox(height: 32),

                // راهنمایی
                _GuidanceCard(provider: provider),
                const SizedBox(height: 24),

                // پیشرفت نواحی
                _RegionProgress(provider: provider),
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
  final BodyScanProvider provider;

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
      child: LinearProgressIndicator(
        value: provider.timeProgress,
        backgroundColor: Colors.grey.shade300,
        valueColor: AlwaysStoppedAnimation(provider.regionColor),
        minHeight: 8,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ========== نمایش تصویری بدن ==========
class _BodyVisualization extends StatelessWidget {
  final BodyScanProvider provider;

  const _BodyVisualization({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.1),
            Colors.blue.withOpacity(0.1),
            Colors.green.withOpacity(0.1),
            Colors.orange.withOpacity(0.1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(60),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // نقطه هایلایت ناحیه فعلی
          Positioned(
            top: _getRegionPosition(provider.currentRegion),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: provider.regionColor.withOpacity(0.6),
                boxShadow: [
                  BoxShadow(
                    color: provider.regionColor.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                provider.regionIcon,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // موقعیت ناحیه در بدن (درصد از بالا)
  double _getRegionPosition(BodyScanRegion region) {
    switch (region) {
      case BodyScanRegion.introduction:
        return 10;
      case BodyScanRegion.head:
        return 10;
      case BodyScanRegion.face:
        return 25;
      case BodyScanRegion.neck:
        return 40;
      case BodyScanRegion.shoulders:
        return 50;
      case BodyScanRegion.arms:
        return 65;
      case BodyScanRegion.hands:
        return 80;
      case BodyScanRegion.chest:
        return 55;
      case BodyScanRegion.abdomen:
        return 70;
      case BodyScanRegion.back:
        return 60;
      case BodyScanRegion.hips:
        return 85;
      case BodyScanRegion.legs:
        return 110;
      case BodyScanRegion.feet:
        return 140;
      case BodyScanRegion.closing:
        return 80;
    }
  }
}

// ========== عنوان ناحیه ==========
class _RegionTitle extends StatelessWidget {
  final BodyScanProvider provider;

  const _RegionTitle({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Text(
      provider.regionName,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: provider.regionColor,
          ),
      textAlign: TextAlign.center,
    );
  }
}

// ========== نمایشگر تایمر ==========
class _TimerDisplay extends StatelessWidget {
  final BodyScanProvider provider;

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
  final BodyScanProvider provider;

  const _GuidanceCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: provider.regionColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              provider.regionIcon,
              size: 40,
              color: provider.regionColor,
            ),
            const SizedBox(height: 16),
            Text(
              provider.currentGuidance,
              style: const TextStyle(
                fontSize: 16,
                height: 1.8,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ========== پیشرفت نواحی ==========
class _RegionProgress extends StatelessWidget {
  final BodyScanProvider provider;

  const _RegionProgress({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.psychology_rounded,
                size: 20, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(
              'Region ${provider.currentRegionIndex + 1} of ${provider.totalRegions}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== نوار کنترل ==========
class _ControlsBar extends StatelessWidget {
  final BodyScanProvider provider;

  const _ControlsBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // دکمه Pause/Resume
          ElevatedButton.icon(
            onPressed: () {
              if (provider.isPaused) {
                provider.resumeScan();
              } else {
                provider.pauseScan();
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
              backgroundColor: Colors.deepPurple.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),

          // دکمه Stop
          OutlinedButton.icon(
            onPressed: () {
              provider.stopScan();
            },
            icon: const Icon(Icons.stop_rounded, size: 28),
            label: const Text('Stop', style: TextStyle(fontSize: 16)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(140, 50),
              side: BorderSide(color: Colors.deepPurple.shade700, width: 2),
              foregroundColor: Colors.deepPurple.shade700,
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

// ⚠️ END: lib/screens/practices/body_scan_screen.dart
