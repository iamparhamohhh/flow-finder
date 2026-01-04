// lib/screens/personalization/mood_tracker_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/personalization_provider.dart';
import '../../models/recommendation_model.dart';

class MoodTrackerScreen extends StatelessWidget {
  const MoodTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood Tracker')),
      body: Consumer<PersonalizationProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Current mood selector
              _buildMoodSelector(context, provider),
              const Divider(height: 32),
              // Mood history
              Expanded(child: _buildMoodHistory(context, provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMoodSelector(
    BuildContext context,
    PersonalizationProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling right now?',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: MoodType.values.length,
            itemBuilder: (context, index) {
              final mood = MoodType.values[index];
              final isSelected = provider.latestMood == mood;

              return _buildMoodButton(context, mood, isSelected, () async {
                final userMood = UserMood(
                  mood: mood,
                  timestamp: DateTime.now(),
                  intensity: 5, // Default intensity
                );
                await provider.saveMood(userMood);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Mood saved: ${_getMoodName(mood)}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMoodButton(
    BuildContext context,
    MoodType mood,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getMoodIcon(mood),
              size: 32,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              _getMoodName(mood),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodHistory(
    BuildContext context,
    PersonalizationProvider provider,
  ) {
    final moodHistory = provider.moodHistory;

    if (moodHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No mood history yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your mood to see patterns',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: moodHistory.length,
      itemBuilder: (context, index) {
        final userMood = moodHistory[index];
        return _buildMoodHistoryItem(context, userMood);
      },
    );
  }

  Widget _buildMoodHistoryItem(BuildContext context, UserMood userMood) {
    final dateFormat = DateFormat('MMM d, y');
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            _getMoodIcon(userMood.mood),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(_getMoodName(userMood.mood)),
        subtitle: Text(
          '${dateFormat.format(userMood.timestamp)} at ${timeFormat.format(userMood.timestamp)}',
        ),
        trailing: userMood.note != null
            ? IconButton(
                icon: const Icon(Icons.note),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Notes'),
                      content: Text(userMood.note!),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }

  IconData _getMoodIcon(MoodType mood) {
    switch (mood) {
      case MoodType.anxious:
        return Icons.psychology;
      case MoodType.stressed:
        return Icons.warning_amber;
      case MoodType.calm:
        return Icons.spa;
      case MoodType.energetic:
        return Icons.bolt;
      case MoodType.tired:
        return Icons.bedtime;
      case MoodType.neutral:
        return Icons.center_focus_strong;
      case MoodType.sad:
        return Icons.sentiment_dissatisfied;
      case MoodType.happy:
        return Icons.sentiment_satisfied_alt;
    }
  }

  String _getMoodName(MoodType mood) {
    return mood.toString().split('.').last[0].toUpperCase() +
        mood.toString().split('.').last.substring(1);
  }
}
