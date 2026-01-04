// lib/screens/personalization/personalization_home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/personalization_provider.dart';
import '../../models/theme_model.dart';
import '../../models/voice_model.dart';
import '../../models/recommendation_model.dart';
import 'theme_selector_screen.dart';
import 'voice_selector_screen.dart';
import 'custom_practice_builder_screen.dart';
import 'mood_tracker_screen.dart';
import 'recommendations_screen.dart';
import '../notifications/notification_settings_screen.dart';

class PersonalizationHomeScreen extends StatelessWidget {
  const PersonalizationHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personalization'), elevation: 0),
      body: Consumer<PersonalizationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final preferences = provider.preferences;
          final currentTheme = provider.currentTheme;
          final selectedVoice = provider.selectedVoice;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Current Mood Card
              _buildMoodCard(context, provider),
              const SizedBox(height: 16),

              // Recommendations Card
              _buildRecommendationsCard(context, provider),
              const SizedBox(height: 24),

              // Appearance Section
              _buildSectionHeader('Appearance'),
              const SizedBox(height: 12),
              _buildThemeCard(context, currentTheme),
              const SizedBox(height: 24),

              // Audio Section
              _buildSectionHeader('Audio'),
              const SizedBox(height: 12),
              _buildVoiceCard(context, selectedVoice),
              const SizedBox(height: 12),
              _buildVolumeCard(context, preferences),
              const SizedBox(height: 24),

              // Custom Practices Section
              _buildSectionHeader('Custom Practices'),
              const SizedBox(height: 12),
              _buildCustomPracticesCard(context, provider),
              const SizedBox(height: 24),

              // Notifications Section
              _buildSectionHeader('Notifications'),
              const SizedBox(height: 12),
              _buildNotificationsCard(context),
              const SizedBox(height: 24),

              // Settings Section
              _buildSectionHeader('Settings'),
              const SizedBox(height: 12),
              _buildSettingsCard(context, preferences, provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMoodCard(
    BuildContext context,
    PersonalizationProvider provider,
  ) {
    final latestMood = provider.latestMood;

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MoodTrackerScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getMoodIcon(latestMood),
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How are you feeling?',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      latestMood != null
                          ? 'Current: ${_getMoodName(latestMood)}'
                          : 'Track your mood',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationsCard(
    BuildContext context,
    PersonalizationProvider provider,
  ) {
    final recommendations = provider.recommendations;

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RecommendationsScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recommended for You',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right),
                ],
              ),
              if (recommendations.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  recommendations.first.title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  recommendations.first.reasons.isNotEmpty
                      ? recommendations.first.reasons.first
                      : recommendations.first.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context, AppThemeData currentTheme) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ThemeSelectorScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: currentTheme.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    currentTheme.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentTheme.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceCard(BuildContext context, VoiceOption? selectedVoice) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VoiceSelectorScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.record_voice_over,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Narrator Voice',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      selectedVoice?.displayName ?? 'Select a voice',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVolumeCard(BuildContext context, preferences) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Volume', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Consumer<PersonalizationProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    _buildVolumeSlider(
                      context,
                      'Voice',
                      Icons.mic,
                      preferences?.voiceVolume ?? 0.8,
                      (value) => provider.updateVolumes(voice: value),
                    ),
                    const SizedBox(height: 8),
                    _buildVolumeSlider(
                      context,
                      'Background Music',
                      Icons.music_note,
                      preferences?.backgroundMusicVolume ?? 0.5,
                      (value) => provider.updateVolumes(background: value),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeSlider(
    BuildContext context,
    String label,
    IconData icon,
    double value,
    Function(double) onChanged,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Expanded(
          child: Slider(value: value, onChanged: onChanged, min: 0, max: 1),
        ),
        Text(
          '${(value * 100).toInt()}%',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildCustomPracticesCard(
    BuildContext context,
    PersonalizationProvider provider,
  ) {
    final patternsCount = provider.customPatterns.length;
    final routinesCount = provider.customRoutines.length;

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CustomPracticeBuilderScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add_circle_outline,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Custom Practices',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$patternsCount patterns • $routinesCount routines',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsCard(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationSettingsScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.notifications_active,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Smart Notifications',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AI reminders & practice schedules',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context,
    preferences,
    PersonalizationProvider provider,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preferences', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Sound Effects'),
              subtitle: const Text('Enable practice sound effects'),
              value: preferences?.soundEffectsEnabled ?? true,
              onChanged: provider.toggleSoundEffects,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Haptic Feedback'),
              subtitle: const Text('Vibrate during transitions'),
              value: preferences?.hapticFeedbackEnabled ?? true,
              onChanged: provider.toggleHapticFeedback,
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Adaptive Difficulty'),
              subtitle: const Text('Automatically adjust based on performance'),
              value: preferences?.adaptiveDifficultyEnabled ?? true,
              onChanged: provider.toggleAdaptiveDifficulty,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Builder(
      builder: (context) => Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  IconData _getMoodIcon(MoodType? mood) {
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
      default:
        return Icons.mood;
    }
  }

  String _getMoodName(MoodType mood) {
    return mood.toString().split('.').last.capitalize();
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
