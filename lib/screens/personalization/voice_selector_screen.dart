// lib/screens/personalization/voice_selector_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/personalization_provider.dart';
import '../../models/voice_model.dart';

class VoiceSelectorScreen extends StatelessWidget {
  const VoiceSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Narrator Voice')),
      body: Consumer<PersonalizationProvider>(
        builder: (context, provider, child) {
          final voices = provider.availableVoices;
          final selectedVoiceId = provider.selectedVoice?.id;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: voices.length,
            itemBuilder: (context, index) {
              final voice = voices[index];
              final isSelected = selectedVoiceId == voice.id;

              return _buildVoiceCard(
                context,
                voice,
                isSelected,
                () => provider.updateVoice(voice.id),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildVoiceCard(
    BuildContext context,
    VoiceOption voice,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Voice icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getGenderIcon(voice.gender),
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Voice details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          voice.displayName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (voice.isPremium) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 12,
                                  color: Colors.amber.shade800,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'PRO',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_getLanguageName(voice.language)} • ${_getGenderName(voice.gender)} • ${voice.accent}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      voice.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Preview button and selection indicator
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.play_circle_outline),
                    onPressed: () {
                      // TODO: Implement voice preview
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Preview: "${voice.displayName}"'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    tooltip: 'Preview voice',
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getGenderIcon(VoiceGender gender) {
    switch (gender) {
      case VoiceGender.male:
        return Icons.man;
      case VoiceGender.female:
        return Icons.woman;
      case VoiceGender.neutral:
        return Icons.person;
    }
  }

  String _getGenderName(VoiceGender gender) {
    switch (gender) {
      case VoiceGender.male:
        return 'Male';
      case VoiceGender.female:
        return 'Female';
      case VoiceGender.neutral:
        return 'Neutral';
    }
  }

  String _getLanguageName(VoiceLanguage language) {
    switch (language) {
      case VoiceLanguage.english:
        return 'English';
      case VoiceLanguage.spanish:
        return 'Spanish';
      case VoiceLanguage.french:
        return 'French';
      case VoiceLanguage.german:
        return 'German';
      case VoiceLanguage.japanese:
        return 'Japanese';
      case VoiceLanguage.chinese:
        return 'Chinese';
    }
  }
}
