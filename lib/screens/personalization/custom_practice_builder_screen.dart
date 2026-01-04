// lib/screens/personalization/custom_practice_builder_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/personalization_provider.dart';
import '../../models/custom_practice_model.dart';

class CustomPracticeBuilderScreen extends StatefulWidget {
  const CustomPracticeBuilderScreen({super.key});

  @override
  State<CustomPracticeBuilderScreen> createState() =>
      _CustomPracticeBuilderScreenState();
}

class _CustomPracticeBuilderScreenState
    extends State<CustomPracticeBuilderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Custom Practices'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Breathing Patterns', icon: Icon(Icons.air)),
            Tab(text: 'Routines', icon: Icon(Icons.playlist_play)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_BreathingPatternsTab(), _RoutinesTab()],
      ),
    );
  }
}

class _BreathingPatternsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PersonalizationProvider>(
      builder: (context, provider, child) {
        final patterns = provider.customPatterns;

        return Column(
          children: [
            // Patterns list
            Expanded(
              child: patterns.isEmpty
                  ? _buildEmptyState(
                      context,
                      'No custom patterns yet',
                      'Create your own breathing patterns',
                      Icons.air,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: patterns.length,
                      itemBuilder: (context, index) {
                        final pattern = patterns[index];
                        return _buildPatternCard(context, pattern, provider);
                      },
                    ),
            ),
            // Add button
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => _showCreatePatternDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Create Pattern'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPatternCard(
    BuildContext context,
    CustomBreathingPattern pattern,
    PersonalizationProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(Icons.air, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(pattern.name),
        subtitle: Text(
          'In: ${pattern.inhaleSeconds}s • Hold: ${pattern.holdInSeconds}s • '
          'Out: ${pattern.exhaleSeconds}s • Hold: ${pattern.holdOutSeconds}s',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            _showDeleteDialog(context, pattern, provider);
          },
        ),
        onTap: () {
          // TODO: Preview pattern
        },
      ),
    );
  }

  void _showCreatePatternDialog(BuildContext context) {
    final nameController = TextEditingController();
    int inhale = 4;
    int holdIn = 0;
    int exhale = 4;
    int holdOut = 0;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Breathing Pattern'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Pattern Name',
                    hintText: 'My Custom Pattern',
                  ),
                ),
                const SizedBox(height: 16),
                _buildDurationSlider('Inhale', inhale, (v) {
                  setState(() => inhale = v);
                }),
                _buildDurationSlider('Hold After Inhale', holdIn, (v) {
                  setState(() => holdIn = v);
                }),
                _buildDurationSlider('Exhale', exhale, (v) {
                  setState(() => exhale = v);
                }),
                _buildDurationSlider('Hold After Exhale', holdOut, (v) {
                  setState(() => holdOut = v);
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty) {
                  return;
                }
                final pattern = CustomBreathingPattern(
                  id: const Uuid().v4(),
                  name: nameController.text,
                  description: 'Custom pattern',
                  inhaleSeconds: inhale,
                  holdInSeconds: holdIn,
                  exhaleSeconds: exhale,
                  holdOutSeconds: holdOut,
                  cycles: 10,
                  createdAt: DateTime.now(),
                );
                context.read<PersonalizationProvider>().saveCustomPattern(
                  pattern,
                );
                Navigator.pop(context);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSlider(
    String label,
    int value,
    Function(int) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('$label: ${value}s'),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 10,
          divisions: 10,
          onChanged: (v) => onChanged(v.toInt()),
        ),
      ],
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    CustomBreathingPattern pattern,
    PersonalizationProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pattern'),
        content: Text('Delete "${pattern.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteCustomPattern(pattern.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutinesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PersonalizationProvider>(
      builder: (context, provider, child) {
        final routines = provider.customRoutines;

        return Column(
          children: [
            Expanded(
              child: routines.isEmpty
                  ? _buildEmptyState(
                      context,
                      'No custom routines yet',
                      'Combine practices into routines',
                      Icons.playlist_play,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: routines.length,
                      itemBuilder: (context, index) {
                        final routine = routines[index];
                        return _buildRoutineCard(context, routine, provider);
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Routine builder coming soon!'),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Routine'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRoutineCard(
    BuildContext context,
    CustomPracticeRoutine routine,
    PersonalizationProvider provider,
  ) {
    final totalDuration = routine.steps.fold<int>(
      0,
      (sum, step) => sum + step.durationMinutes,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Icon(
            Icons.playlist_play,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        title: Text(routine.name),
        subtitle: Text('${routine.steps.length} steps • $totalDuration min'),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Routine'),
                content: Text('Delete "${routine.name}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      provider.deleteCustomRoutine(routine.id);
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          },
        ),
        children: routine.steps.map((step) {
          return ListTile(
            dense: true,
            leading: Text('${routine.steps.indexOf(step) + 1}'),
            title: Text(step.title),
            subtitle: step.breathingPatternId != null
                ? Text('Pattern: ${step.breathingPatternId}')
                : null,
            trailing: Text('${step.durationMinutes} min'),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
