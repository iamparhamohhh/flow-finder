import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/tracking_model.dart';
import '../../providers/tracking_provider.dart';

class MoodJournalScreen extends StatefulWidget {
  const MoodJournalScreen({super.key});

  @override
  State<MoodJournalScreen> createState() => _MoodJournalScreenState();
}

class _MoodJournalScreenState extends State<MoodJournalScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrackingProvider>().loadRecentMoodEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Journal'),
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
                    onPressed: () => provider.loadRecentMoodEntries(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final moodEntries = provider.recentMoodEntries;

          if (moodEntries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.mood, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No mood entries yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Track your mood before and after practices',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddMoodDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Mood Entry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Statistics Card
              _buildStatisticsCard(provider),
              // Mood Entries List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => provider.loadRecentMoodEntries(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: moodEntries.length,
                    itemBuilder: (context, index) {
                      final entry = moodEntries[index];
                      return _buildMoodEntryCard(context, entry, provider);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMoodDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
      ),
    );
  }

  Widget _buildStatisticsCard(TrackingProvider provider) {
    final stats = provider.currentStatistics;
    final avgMood = stats?['averageMoodRating'] ?? 0.0;
    final improvementRate = stats?['moodImprovementRate'] ?? 0.0;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: Icons.mood,
              label: 'Avg Mood',
              value: avgMood.toStringAsFixed(1),
              color: _getMoodColor(avgMood),
            ),
            _buildStatItem(
              icon: Icons.trending_up,
              label: 'Improvement',
              value: '${(improvementRate * 100).toStringAsFixed(0)}%',
              color: improvementRate > 0 ? Colors.green : Colors.grey,
            ),
            _buildStatItem(
              icon: Icons.calendar_today,
              label: 'Entries',
              value: provider.recentMoodEntries.length.toString(),
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

  Widget _buildMoodEntryCard(
    BuildContext context,
    MoodJournalEntry entry,
    TrackingProvider provider,
  ) {
    final improvement = entry.moodImprovement;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showMoodDetailsDialog(context, entry, provider),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and time
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
              // Mood comparison
              Row(
                children: [
                  Expanded(child: _buildMoodIndicator('Before', entry.preMood)),
                  const SizedBox(width: 12),
                  if (entry.postMood != null) ...[
                    Icon(
                      improvement > 0
                          ? Icons.arrow_forward
                          : Icons.arrow_right_alt,
                      color: improvement > 0 ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMoodIndicator('After', entry.postMood!),
                    ),
                  ] else
                    const Expanded(
                      child: Center(
                        child: Text(
                          'No post-practice mood',
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Improvement indicator
              if (improvement > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.trending_up,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+$improvement improvement',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Practice info
              if (entry.practiceName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.self_improvement, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      entry.practiceName!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
              // Tags
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: entry.tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      labelStyle: const TextStyle(fontSize: 11),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
              // Notes preview
              if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  entry.notes!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodIndicator(String label, MoodRating mood) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(mood.emoji, style: const TextStyle(fontSize: 32)),
        Text(
          mood.label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Color _getMoodColor(double avgMood) {
    if (avgMood >= 4.0) return Colors.green;
    if (avgMood >= 3.0) return Colors.lightGreen;
    if (avgMood >= 2.0) return Colors.orange;
    return Colors.red;
  }

  void _showAddMoodDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddMoodEntrySheet(),
    );
  }

  void _showMoodDetailsDialog(
    BuildContext context,
    MoodJournalEntry entry,
    TrackingProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => MoodDetailsDialog(entry: entry, provider: provider),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mood Journal'),
        content: const Text(
          'Track your mood before and after mindfulness practices to see how they improve your emotional well-being.\n\n'
          '• Rate your mood from 1-5\n'
          '• Add notes and tags\n'
          '• View improvement trends\n'
          '• Correlate with practices',
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

// ==================== ADD MOOD ENTRY SHEET ====================

class AddMoodEntrySheet extends StatefulWidget {
  const AddMoodEntrySheet({super.key});

  @override
  State<AddMoodEntrySheet> createState() => _AddMoodEntrySheetState();
}

class _AddMoodEntrySheetState extends State<AddMoodEntrySheet> {
  MoodRating? _preMood;
  MoodRating? _postMood;
  final _notesController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _tags = [];

  @override
  void dispose() {
    _notesController.dispose();
    _tagController.dispose();
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
              'Add Mood Entry',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text(
              'How are you feeling now?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            _buildMoodSelector(_preMood, (mood) {
              setState(() => _preMood = mood);
            }),
            const SizedBox(height: 24),
            const Text(
              'Post-practice mood (optional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            _buildMoodSelector(_postMood, (mood) {
              setState(() => _postMood = mood);
            }),
            const SizedBox(height: 24),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'How are you feeling? Any thoughts?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tagController,
              decoration: InputDecoration(
                labelText: 'Add tags (optional)',
                hintText: 'e.g., anxious, calm, energized',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTag,
                ),
              ),
              onSubmitted: (_) => _addTag(),
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    onDeleted: () {
                      setState(() => _tags.remove(tag));
                    },
                  );
                }).toList(),
              ),
            ],
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
                    onPressed: _preMood == null ? null : _saveMoodEntry,
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

  Widget _buildMoodSelector(
    MoodRating? selected,
    Function(MoodRating) onSelect,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: MoodRating.values.map((mood) {
        final isSelected = selected == mood;
        return InkWell(
          onTap: () => onSelect(mood),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
                width: isSelected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(mood.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 4),
                Text(
                  mood.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  Future<void> _saveMoodEntry() async {
    if (_preMood == null) return;

    final provider = context.read<TrackingProvider>();
    await provider.addMoodEntry(
      preMood: _preMood!,
      postMood: _postMood,
      tags: _tags.isEmpty ? null : _tags,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mood entry saved!')));
    }
  }
}

// ==================== MOOD DETAILS DIALOG ====================

class MoodDetailsDialog extends StatelessWidget {
  final MoodJournalEntry entry;
  final TrackingProvider provider;

  const MoodDetailsDialog({
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
            _buildDetailRow('Pre-practice mood:', entry.preMood.label),
            if (entry.postMood != null)
              _buildDetailRow('Post-practice mood:', entry.postMood!.label),
            if (entry.moodImprovement > 0)
              _buildDetailRow(
                'Improvement:',
                '+${entry.moodImprovement}',
                color: Colors.green,
              ),
            if (entry.practiceName != null)
              _buildDetailRow('Practice:', entry.practiceName!),
            if (entry.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Tags:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: entry.tags
                    .map((tag) => Chip(label: Text(tag)))
                    .toList(),
              ),
            ],
            if (entry.notes != null && entry.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
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
                  'Are you sure you want to delete this mood entry?',
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
              await provider.deleteMoodEntry(entry.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mood entry deleted')),
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

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}
