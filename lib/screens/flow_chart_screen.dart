import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../models/activity_model.dart';
import '../providers/activity_provider.dart';
import '../providers/simulation_provider.dart';

class FlowChartScreen extends StatefulWidget {
  const FlowChartScreen({super.key});

  @override
  State<FlowChartScreen> createState() => _FlowChartScreenState();
}

class _FlowChartScreenState extends State<FlowChartScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Flow'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Flow Map'),
            Tab(text: 'Simulation'),
            Tab(text: 'Pairings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FlowMapTab(),
          _SimulationTab(),
          const Center(
            child: Text(
              'Pairings - Coming Soon',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

// ================ تب Flow Map (بدون تغییر) ================
class _FlowMapTab extends StatefulWidget {
  @override
  State<_FlowMapTab> createState() => _FlowMapTabState();
}

class _FlowMapTabState extends State<_FlowMapTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onTapDown: (details) {
                        _handleTap(
                          context,
                          details.localPosition,
                          constraints.biggest,
                          activityProvider.activities,
                        );
                      },
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: FlowChartPainter(
                              activities: activityProvider.activities,
                              animationValue: _animationController.value,
                            ),
                            child: Container(),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  _showAddActivityDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('+ Add Activity'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleTap(
    BuildContext context,
    Offset position,
    Size chartSize,
    List<Activity> activities,
  ) {
    for (var activity in activities) {
      final x = chartSize.width * (activity.skillLevel / 10);
      final y = chartSize.height * (1 - activity.challengeLevel / 10);

      final distance = (Offset(x, y) - position).distance;

      if (distance < 30) {
        _showActivityOptions(context, activity);
        return;
      }
    }
  }

  void _showActivityOptions(BuildContext context, Activity activity) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info, color: Colors.blue),
                title: Text(activity.name),
                subtitle: Text(
                  'Skill: ${activity.skillLevel.toInt()} | '
                  'Challenge: ${activity.challengeLevel.toInt()}\n'
                  'State: ${activity.flowState}',
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.orange),
                title: const Text('Edit Activity'),
                onTap: () {
                  Navigator.pop(context);
                  _showEditActivityDialog(context, activity);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Activity'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, activity);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Activity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Activity'),
        content: Text('Are you sure you want to delete "${activity.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<ActivityProvider>(
                context,
                listen: false,
              ).deleteActivity(activity.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${activity.name} deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditActivityDialog(BuildContext context, Activity activity) {
    final nameController = TextEditingController(text: activity.name);
    double skillLevel = activity.skillLevel;
    double challengeLevel = activity.challengeLevel;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Activity'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Activity Name'),
                ),
                const SizedBox(height: 20),
                Text('Skill Level: ${skillLevel.toInt()}'),
                Slider(
                  value: skillLevel,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (value) {
                    setState(() => skillLevel = value);
                  },
                ),
                const SizedBox(height: 10),
                Text('Challenge Level: ${challengeLevel.toInt()}'),
                Slider(
                  value: challengeLevel,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (value) {
                    setState(() => challengeLevel = value);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    final updatedActivity = Activity(
                      id: activity.id,
                      name: nameController.text,
                      skillLevel: skillLevel,
                      challengeLevel: challengeLevel,
                      createdAt: activity.createdAt,
                    );

                    Provider.of<ActivityProvider>(
                      dialogContext,
                      listen: false,
                    ).updateActivity(updatedActivity);

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Activity updated')),
                    );
                  }
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddActivityDialog(BuildContext context) {
    final nameController = TextEditingController();
    double skillLevel = 5;
    double challengeLevel = 5;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('New Activity'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Activity Name',
                    hintText: 'e.g., Guitar',
                  ),
                ),
                const SizedBox(height: 20),
                Text('Skill Level: ${skillLevel.toInt()}'),
                Slider(
                  value: skillLevel,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (value) {
                    setState(() => skillLevel = value);
                  },
                ),
                const SizedBox(height: 10),
                Text('Challenge Level: ${challengeLevel.toInt()}'),
                Slider(
                  value: challengeLevel,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (value) {
                    setState(() => challengeLevel = value);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    final activity = Activity(
                      id: DateTime.now().toString(),
                      name: nameController.text,
                      skillLevel: skillLevel,
                      challengeLevel: challengeLevel,
                      createdAt: DateTime.now(),
                    );

                    // ✅ فقط addActivity فراخوانی می‌شود
                    // Quest update خودکار توسط ActivityProvider انجام می‌شود
                    Provider.of<ActivityProvider>(
                      dialogContext,
                      listen: false,
                    ).addActivity(activity);

                    Navigator.pop(context);

                    // نمایش پیام ساده
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Activity added successfully! ✨'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: const Text('Add to Map'),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ================ تب Simulation با انیمیشن و Definition Card ================
class _SimulationTab extends StatefulWidget {
  @override
  State<_SimulationTab> createState() => _SimulationTabState();
}

class _SimulationTabState extends State<_SimulationTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SimulationProvider>(
      builder: (context, provider, child) {
        final stateInfo = provider.getStateInfo();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Discover Your Mental State',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Adjust the sliders to explore different states',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // کارت حالت با انیمیشن
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_animationController.value * 0.05),
                    child: Opacity(
                      opacity: 0.7 + (_animationController.value * 0.3),
                      child: _StateCard(stateInfo: stateInfo),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // اسلایدرها
              _SliderSection(
                title: 'Your Skill',
                value: provider.skill,
                onChanged: (value) {
                  provider.setSkill(value);
                  _triggerAnimation();
                },
                color: Colors.blue,
                icon: Icons.star_rounded,
              ),
              const SizedBox(height: 24),

              _SliderSection(
                title: 'The Challenge',
                value: provider.challenge,
                onChanged: (value) {
                  provider.setChallenge(value);
                  _triggerAnimation();
                },
                color: Colors.orange,
                icon: Icons.whatshot_rounded,
              ),
              const SizedBox(height: 32),

              // Definition Card
              _DefinitionCard(stateInfo: stateInfo),
              const SizedBox(height: 24),

              // راهنمای حالت‌ها
              _StatesGuide(),
            ],
          ),
        );
      },
    );
  }
}

// ================ کارت Definition با محتوای کامل ================
class _DefinitionCard extends StatelessWidget {
  final MentalStateInfo stateInfo;

  const _DefinitionCard({required this.stateInfo});

  Map<String, Map<String, String>> get _definitions => {
    'Flow': {
      'definition':
          'A state of complete immersion where skill and challenge are perfectly balanced. Time seems to fly, and you perform at your peak with effortless concentration.',
      'characteristics':
          '• Deep focus and concentration\n• Loss of self-consciousness\n• Clear goals and immediate feedback\n• Sense of control and confidence\n• Intrinsic motivation',
      'tips':
          'To maintain flow: match challenges to skills, minimize distractions, set clear goals, and embrace the process.',
    },
    'Anxiety': {
      'definition':
          'A state of stress and worry when challenges significantly exceed your current skills. You may feel overwhelmed and struggle to perform effectively.',
      'characteristics':
          '• Excessive worry and tension\n• Difficulty concentrating\n• Physical symptoms (racing heart, sweating)\n• Feeling of being overwhelmed\n• Reduced performance',
      'tips':
          'To reduce anxiety: break tasks into smaller steps, develop relevant skills, practice relaxation techniques, or choose less challenging activities.',
    },
    'Boredom': {
      'definition':
          'A state of disengagement when your skills far exceed the challenge. Activities feel tedious and fail to capture your interest or motivation.',
      'characteristics':
          '• Lack of interest and motivation\n• Restlessness and impatience\n• Mind wandering\n• Desire for stimulation\n• Underutilization of abilities',
      'tips':
          'To overcome boredom: seek greater challenges, add complexity to tasks, set personal goals, or explore new aspects of the activity.',
    },
    'Arousal': {
      'definition':
          'A state of heightened energy and alertness when challenges slightly exceed skills. You feel engaged and motivated, with a healthy sense of excitement.',
      'characteristics':
          '• Increased energy and alertness\n• Positive excitement\n• Motivation to improve\n• Good focus with some tension\n• Growth-oriented mindset',
      'tips':
          'To leverage arousal: embrace the challenge, focus on skill development, maintain confidence, and use the energy productively.',
    },
    'Relaxation': {
      'definition':
          'A comfortable state when your skills exceed the challenge. You feel at ease and confident, performing with minimal effort or stress.',
      'characteristics':
          '• Calm and comfortable\n• Confident performance\n• Low stress levels\n• Effortless execution\n• Pleasant experience',
      'tips':
          'To maintain engagement: gradually increase difficulty, set new goals, help others, or use this state for recovery and consolidation.',
    },
  };

  @override
  Widget build(BuildContext context) {
    final def = _definitions[stateInfo.title] ?? {};

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: stateInfo.color.withOpacity(0.3), width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [stateInfo.color.withOpacity(0.05), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    color: stateInfo.color,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Definition of ${stateInfo.title}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: stateInfo.color,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              if (def['definition'] != null) ...[
                Text(
                  def['definition']!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 16),
              ],
              if (def['characteristics'] != null) ...[
                Text(
                  'Key Characteristics:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: stateInfo.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  def['characteristics']!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(height: 1.6),
                ),
                const SizedBox(height: 16),
              ],
              if (def['tips'] != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: stateInfo.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        color: stateInfo.color,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          def['tips']!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                height: 1.5,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  final MentalStateInfo stateInfo;

  const _StateCard({required this.stateInfo});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            stateInfo.color.withOpacity(0.15),
            stateInfo.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: stateInfo.color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: stateInfo.color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: stateInfo.color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(stateInfo.icon, size: 48, color: stateInfo.color),
          ),
          const SizedBox(height: 16),
          Text(
            stateInfo.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: stateInfo.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stateInfo.description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SliderSection extends StatelessWidget {
  final String title;
  final double value;
  final ValueChanged<double> onChanged;
  final Color color;
  final IconData icon;

  const _SliderSection({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            thumbColor: color,
            overlayColor: color.withOpacity(0.2),
            trackHeight: 6,
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 10,
            divisions: 20,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _StatesGuide extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'States Guide',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _GuideItem(
              color: const Color(0xFF4CAF50),
              title: 'Flow',
              description: 'Difference: ±2',
            ),
            _GuideItem(
              color: const Color(0xFFFF9800),
              title: 'Arousal',
              description: 'Challenge 2-4 units higher',
            ),
            _GuideItem(
              color: const Color(0xFF9E9E9E),
              title: 'Boredom',
              description: 'Skill 2-4 units higher',
            ),
            _GuideItem(
              color: const Color(0xFFF44336),
              title: 'Anxiety',
              description: 'Challenge >4 units higher',
            ),
            _GuideItem(
              color: const Color(0xFF2196F3),
              title: 'Relaxation',
              description: 'Skill >4 units higher',
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideItem extends StatelessWidget {
  final Color color;
  final String title;
  final String description;

  const _GuideItem({
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================ FlowChartPainter (نسخه کامل با Grid و Labels) ================
class FlowChartPainter extends CustomPainter {
  final List<Activity> activities;
  final double animationValue;

  FlowChartPainter({required this.activities, required this.animationValue});

  String _getMentalState(double skill, double challenge) {
    final diff = challenge - skill;
    if (diff.abs() <= 2) return 'Flow';
    if (diff > 4) return 'Anxiety';
    if (diff < -4) return 'Boredom';
    if (diff > 0) return 'Arousal';
    return 'Relaxation';
  }

  Color _getStateColor(String state, double intensity) {
    switch (state) {
      case 'Flow':
        return Color.lerp(
          Colors.blue.shade300,
          Colors.blue.shade700,
          intensity,
        )!;
      case 'Anxiety':
        return Color.lerp(Colors.red.shade300, Colors.red.shade700, intensity)!;
      case 'Boredom':
        return Color.lerp(
          Colors.grey.shade300,
          Colors.grey.shade600,
          intensity,
        )!;
      case 'Arousal':
        return Color.lerp(
          Colors.orange.shade300,
          Colors.orange.shade700,
          intensity,
        )!;
      case 'Relaxation':
        return Color.lerp(
          Colors.green.shade300,
          Colors.green.shade700,
          intensity,
        )!;
      default:
        return Colors.blue;
    }
  }

  double _getShakeIntensity(String state, double intensity) {
    if (state == 'Anxiety') return 8 * intensity;
    if (state == 'Arousal') return 4 * intensity;
    return 1;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // پس‌زمینه موربِ ناحیه Flow
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [Colors.blue.withOpacity(0.05), Colors.green.withOpacity(0.12)],
      ).createShader(rect);

    canvas.drawRect(rect, gradientPaint);

    // ========== رسم Grid خطوط ==========
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 0.8;

    // خطوط عمودی (محور Skill)
    for (int i = 1; i < 10; i++) {
      final x = size.width * (i / 10);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // خطوط افقی (محور Challenge)
    for (int i = 1; i < 10; i++) {
      final y = size.height * (i / 10);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // ========== رسم محورهای اصلی X,Y ==========
    final axisPaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 2.0;

    // محور افقی (پایین)
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      axisPaint,
    );

    // محور عمودی (چپ)
    canvas.drawLine(Offset(0, size.height), Offset(0, 0), axisPaint);

    // ========== برچسب‌های محورها ==========
    final textStyle = TextStyle(
      color: Colors.grey.shade800,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    // برچسب محور افقی (Skill)
    final skillLabel = TextPainter(
      text: TextSpan(text: 'Skill →', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    skillLabel.paint(canvas, Offset(size.width - 50, size.height + 8));

    // برچسب محور عمودی (Challenge) - چرخش 90 درجه
    canvas.save();
    canvas.translate(0, size.height / 2);
    canvas.rotate(-math.pi / 2);
    final challengeLabel = TextPainter(
      text: TextSpan(text: '← Challenge', style: textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    challengeLabel.paint(canvas, const Offset(0, -20));
    canvas.restore();

    // ========== رسم نقاط فعالیت‌ها با اسم ==========
    for (var activity in activities) {
      final x = size.width * (activity.skillLevel / 10);
      final y = size.height * (1 - activity.challengeLevel / 10);

      final state = _getMentalState(
        activity.skillLevel,
        activity.challengeLevel,
      );

      final diff = (activity.challengeLevel - activity.skillLevel).abs();
      final intensity = (diff / 10).clamp(0.0, 1.0);

      final color = _getStateColor(state, intensity);

      final shake =
          _getShakeIntensity(state, intensity) *
          math.sin(animationValue * 2 * math.pi);

      final dx = shake;
      final dy = shake / 2;

      final pulse = 1 + (0.05 * math.sin(animationValue * 2 * math.pi));

      // رسم دایره
      final bubblePaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x + dx, y + dy), 14 * pulse, bubblePaint);

      // رسم حاشیه سفید دور دایره
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(Offset(x + dx, y + dy), 14 * pulse, borderPaint);

      // ========== نمایش اسم Activity ==========
      final nameStyle = TextStyle(
        color: Colors.grey.shade900,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        backgroundColor: Colors.white.withOpacity(0.85),
      );

      final namePainter = TextPainter(
        text: TextSpan(text: activity.name, style: nameStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      // موقعیت اسم زیر دایره
      final nameX = x + dx - (namePainter.width / 2);
      final nameY = y + dy + 20;

      namePainter.paint(canvas, Offset(nameX, nameY));
    }
  }

  @override
  bool shouldRepaint(covariant FlowChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.activities != activities;
  }
}
