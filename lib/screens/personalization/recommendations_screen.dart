// lib/screens/personalization/recommendations_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/personalization_provider.dart';
import '../../models/recommendation_model.dart';
import '../../models/custom_practice_model.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended for You'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PersonalizationProvider>().loadRecommendations();
            },
            tooltip: 'Refresh recommendations',
          ),
        ],
      ),
      body: Consumer<PersonalizationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final recommendations = provider.recommendations;

          if (recommendations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No recommendations yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Track your mood and complete practices to get personalized recommendations',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = recommendations[index];
              return _buildRecommendationCard(context, recommendation, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    PracticeRecommendation recommendation,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: index == 0 ? 4 : 2, // Highlight top recommendation
      child: InkWell(
        onTap: () {
          // TODO: Navigate to practice screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Start: ${recommendation.title}'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Rank badge
                  if (index < 3)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getRankColor(index, context),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  if (index < 3) const SizedBox(width: 12),
                  // Practice icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getPracticeIcon(recommendation.type),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Practice name and type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendation.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          recommendation.type.name,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Confidence indicator
                  _buildConfidenceBadge(
                    context,
                    recommendation.confidenceScore,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Duration and difficulty
              Row(
                children: [
                  _buildInfoChip(
                    context,
                    Icons.timer_outlined,
                    '${recommendation.durationMinutes} min',
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    context,
                    Icons.trending_up,
                    recommendation.confidenceLabel,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Reason
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        recommendation.reasons.isNotEmpty
                            ? recommendation.reasons.first
                            : recommendation.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge(BuildContext context, double confidence) {
    final percentage = (confidence * 100).toInt();
    final color = confidence > 0.8
        ? Colors.green
        : confidence > 0.6
        ? Colors.orange
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        '$percentage%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int index, BuildContext context) {
    switch (index) {
      case 0:
        return Colors.amber.shade700; // Gold
      case 1:
        return Colors.grey.shade400; // Silver
      case 2:
        return Colors.brown.shade400; // Bronze
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  IconData _getPracticeIcon(PracticeType practiceType) {
    switch (practiceType) {
      case PracticeType.breathing:
        return Icons.air;
      case PracticeType.meditation:
        return Icons.self_improvement;
      case PracticeType.bodyScan:
        return Icons.accessibility_new;
      case PracticeType.pmr:
        return Icons.fitness_center;
      case PracticeType.custom:
        return Icons.category;
    }
  }
}
