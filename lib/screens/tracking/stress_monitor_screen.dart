import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/tracking_model.dart';
import '../../providers/tracking_provider.dart';

class StressMonitorScreen extends StatefulWidget {
  const StressMonitorScreen({super.key});

  @override
  State<StressMonitorScreen> createState() => _StressMonitorScreenState();
}

class _StressMonitorScreenState extends State<StressMonitorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrackingProvider>().loadRecentStressEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stress Monitor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Consumer<TrackingProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadRecentStressEntries(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final stressEntries = provider.recentStressEntries;

          if (stressEntries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.psychology, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No stress entries yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Monitor stress levels and identify patterns',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddStressDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Stress Entry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Statistics Card
              _buildStatisticsCard(provider),
              // Stress Entries List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.loadRecentStressEntries(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: stressEntries.length,
                    itemBuilder: (context, index) {
                      final entry = stressEntries[index];
                      return _buildStressEntryCard(context, entry, provider);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStressDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
      ),
    );
  }

  Widget _buildStatisticsCard(TrackingProvider provider) {
    final stats = provider.currentStatistics;
    final avgStress = stats?['averageStressLevel'] ?? 0.0;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: Icons.psychology,
              label: 'Avg Stress',
              value: avgStress.toStringAsFixed(1),
              color: _getStressColor(avgStress),
            ),
            _buildStatItem(
              icon: Icons.trending_down,
              label: 'Goal',
              value: '< 2.5',
              color: Colors.green,
            ),
            _buildStatItem(
              icon: Icons.calendar_today,
              label: 'Entries',
              value: provider.recentStressEntries.length.toString(),
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStressEntryCard(
    BuildContext context,
    StressEntry entry,
    TrackingProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showStressDetailsDialog(context, entry, provider),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM dd, yyyy').format(entry.timestamp),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('HH:mm').format(entry.timestamp),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Stress level indicator
              Row(
                children: [
                  Text(entry.level.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.level.label,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getStressColor(entry.level.value.toDouble()),
                        ),
                      ),
                      Text(
                        'Level ${entry.level.value}/5',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Stress level bar
                  _buildStressBar(entry.level),
                ],
              ),
              // Triggers
              if (entry.triggers.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Triggers:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: entry.triggers.map((trigger) {
                    return Chip(
                      label: Text(trigger),
                      labelStyle: const TextStyle(fontSize: 11),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Colors.red.withOpacity(0.1),
                    );
                  }).toList(),
                ),
              ],
              // Symptoms
              if (entry.symptoms.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.healing, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        entry.symptoms.join(', '),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              // Coping strategy
              if (entry.copingStrategy != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb,
                        size: 14,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          entry.copingStrategy!,
                          style: const TextStyle(fontSize: 12),
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

  Widget _buildStressBar(StressLevel level) {
    return Container(
      width: 80,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: level.value / 5,
        child: Container(
          decoration: BoxDecoration(
            color: _getStressColor(level.value.toDouble()),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Color _getStressColor(double level) {
    if (level <= 1.5) return Colors.green;
    if (level <= 2.5) return Colors.lightGreen;
    if (level <= 3.5) return Colors.orange;
    if (level <= 4.5) return Colors.deepOrange;
    return Colors.red;
  }

  void _showAddStressDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddStressEntrySheet(),
    );
  }

  void _showStressDetailsDialog(
    BuildContext context,
    StressEntry entry,
    TrackingProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) =>
          StressDetailsDialog(entry: entry, provider: provider),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stress Monitor'),
        content: const Text(
          'Track stress levels to identify triggers and find effective coping strategies.\n\n'
          '• Monitor stress levels 1-5\n'
          '• Identify triggers and symptoms\n'
          '• Record coping strategies\n'
          '• View trends over time',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

// ==================== ADD STRESS ENTRY SHEET ====================

class AddStressEntrySheet extends StatefulWidget {
  const AddStressEntrySheet({super.key});

  @override
  State<AddStressEntrySheet> createState() => _AddStressEntrySheetState();
}

class _AddStressEntrySheetState extends State<AddStressEntrySheet> {
  StressLevel _level = StressLevel.moderate;
  final List<String> _triggers = [];
  final List<String> _symptoms = [];
  final _notesController = TextEditingController();
  final _copingController = TextEditingController();
  final _triggerController = TextEditingController();
  final _symptomController = TextEditingController();

  final List<String> _commonTriggers = [
    'Work',
    'Finances',
    'Relationships',
    'Health',
    'Family',
    'Traffic',
    'Deadlines',
    'Conflict',
  ];

  final List<String> _commonSymptoms = [
    'Headache',
    'Tension',
    'Fatigue',
    'Irritability',
    'Anxiety',
    'Sleep issues',
    'Racing thoughts',
    'Muscle pain',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    _copingController.dispose();
    _triggerController.dispose();
    _symptomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Stress Entry',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text(
              'Current stress level',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            _buildStressLevelSelector(),
            const SizedBox(height: 24),
            const Text(
              'Triggers',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonTriggers.map((trigger) {
                final isSelected = _triggers.contains(trigger);
                return FilterChip(
                  label: Text(trigger),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _triggers.add(trigger);
                      } else {
                        _triggers.remove(trigger);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Symptoms',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonSymptoms.map((symptom) {
                final isSelected = _symptoms.contains(symptom);
                return FilterChip(
                  label: Text(symptom),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _symptoms.add(symptom);
                      } else {
                        _symptoms.remove(symptom);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _copingController,
              decoration: const InputDecoration(
                labelText: 'Coping strategy (optional)',
                hintText: 'What helped or might help?',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lightbulb_outline),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Any additional thoughts?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveStressEntry,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStressLevelSelector() {
    return Column(
      children: StressLevel.values.map((level) {
        final isSelected = _level == level;
        return RadioListTile<StressLevel>(
          value: level,
          groupValue: _level,
          onChanged: (value) => setState(() => _level = value!),
          title: Row(
            children: [
              Text(level.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(level.label),
            ],
          ),
          subtitle: Text('Level ${level.value}/5'),
          selected: isSelected,
        );
      }).toList(),
    );
  }

  Future<void> _saveStressEntry() async {
    final provider = context.read<TrackingProvider>();
    await provider.addStressEntry(
      level: _level,
      triggers: _triggers.isEmpty ? null : _triggers,
      symptoms: _symptoms.isEmpty ? null : _symptoms,
      copingStrategy: _copingController.text.isEmpty
          ? null
          : _copingController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Stress entry saved!')));
    }
  }
}

// ==================== STRESS DETAILS DIALOG ====================

class StressDetailsDialog extends StatelessWidget {
  final StressEntry entry;
  final TrackingProvider provider;

  const StressDetailsDialog({
    super.key,
    required this.entry,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(DateFormat('MMM dd, yyyy HH:mm').format(entry.timestamp)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(entry.level.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.level.label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Level ${entry.level.value}/5'),
                  ],
                ),
              ],
            ),
            if (entry.triggers.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Triggers:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: entry.triggers
                    .map((trigger) => Chip(label: Text(trigger)))
                    .toList(),
              ),
            ],
            if (entry.symptoms.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Symptoms:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: entry.symptoms
                    .map((symptom) => Chip(label: Text(symptom)))
                    .toList(),
              ),
            ],
            if (entry.copingStrategy != null) ...[
              const SizedBox(height: 16),
              const Text(
                'Coping Strategy:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(entry.copingStrategy!),
            ],
            if (entry.notes != null && entry.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(entry.notes!),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Entry'),
                content: const Text(
                  'Are you sure you want to delete this stress entry?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              await provider.deleteStressEntry(entry.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Stress entry deleted')),
                );
              }
            }
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Delete'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
