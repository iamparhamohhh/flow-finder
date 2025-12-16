// lib/screens/practices/practices_main_screen.dart

import 'package:flow_finder/screens/practices/mindfulness_screen.dart';
import 'package:flow_finder/screens/quests/daily_quest_screen.dart';
import 'package:flutter/material.dart';
import 'breathing_screen.dart';
import 'pmr_screen.dart';
import 'body_scan_screen.dart';

class PracticesMainScreen extends StatelessWidget {
  const PracticesMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice & Exercises'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // توضیحات کلی
          _HeaderSection(),
          const SizedBox(height: 24),

          // کارت‌های تمرین‌ها
          _PracticeCard(
            title: 'Box Breathing',
            subtitle: '4-4-6-2 Breathing Pattern',
            description:
                'Calm your mind and reduce stress with controlled breathing',
            duration: '5-10 min',
            difficulty: 'Beginner',
            icon: Icons.air_rounded,
            color: Colors.blue,
            benefits: [
              'Reduces anxiety',
              'Improves focus',
              'Lowers blood pressure',
            ],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BreathingScreen()),
            ),
          ),
          const SizedBox(height: 16),

          _PracticeCard(
            title: 'Progressive Muscle Relaxation',
            subtitle: 'Tension & Release',
            description:
                'Release physical tension by systematically tensing and relaxing muscles',
            duration: '10-15 min',
            difficulty: 'Beginner',
            icon: Icons.fitness_center_rounded,
            color: Colors.orange,
            benefits: [
              'Reduces muscle tension',
              'Improves sleep',
              'Decreases anxiety',
            ],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PMRScreen()),
            ),
          ),
          const SizedBox(height: 16),

          _PracticeCard(
            title: 'Mindfulness Meditation',
            subtitle: 'Present Moment Awareness',
            description:
                'Cultivate awareness and presence through guided meditation',
            duration: '5-20 min',
            difficulty: 'Intermediate',
            icon: Icons.self_improvement_rounded,
            color: Colors.purple,
            benefits: [
              'Enhances focus',
              'Reduces stress',
              'Increases self-awareness',
            ],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MindfulnessScreen()),
            ),
          ),
          const SizedBox(height: 16),

          _PracticeCard(
            title: 'Body Scan',
            subtitle: 'Full Body Awareness',
            description:
                'Systematically scan your body to release tension and increase awareness',
            duration: '10-20 min',
            difficulty: 'Intermediate',
            icon: Icons.accessibility_new_rounded,
            color: Colors.green,
            benefits: [
              'Releases tension',
              'Improves body awareness',
              'Promotes relaxation',
            ],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BodyScanScreen()),
            ),
          ),
          const SizedBox(height: 16),
          _PracticeCard(
  title: 'Daily Quests',
  subtitle: 'Stay on Track',
  description: 'Complete daily challenges',
  duration: 'Varies',
  difficulty: 'All Levels',
  icon: Icons.flag_rounded,
  color: Colors.orange,
  benefits: [
    'Builds consistency',
    'Enhances motivation',
    'Tracks progress',
  ],
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DailyQuestsScreen(),
      ),
    );
  },
),
        ],
      ),
    );
  }
}

// ========== Header Section ==========
class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.spa_rounded, color: Colors.blue.shade700, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Daily Practices',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Choose a practice to enhance your mental wellbeing and maintain your flow state. '
              'Regular practice helps reduce stress, improve focus, and increase overall happiness.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== Practice Card Widget ==========
class _PracticeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String duration;
  final String difficulty;
  final IconData icon;
  final Color color;
  final List<String> benefits;
  final VoidCallback onTap;

  const _PracticeCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.duration,
    required this.difficulty,
    required this.icon,
    required this.color,
    required this.benefits,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withOpacity(0.3), width: 2),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.05), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                          ),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),

                // Metadata
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _MetaChip(
                      icon: Icons.timer_outlined,
                      label: duration,
                      color: color,
                    ),
                    _MetaChip(
                      icon: Icons.signal_cellular_alt,
                      label: difficulty,
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Benefits
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Benefits:',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...benefits.map(
                        (benefit) => Padding(
                          padding: const EdgeInsets.only(left: 22, top: 4),
                          child: Text(
                            '• $benefit',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(height: 1.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========== Meta Chip ==========
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
