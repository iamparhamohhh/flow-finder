// lib/screens/social/challenges_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/challenge_provider.dart';
import '../../models/challenge_model.dart';
import '../../services/share_service.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengeProvider>(
      builder: (context, challengeProvider, _) {
        if (challengeProvider.isLoading &&
            challengeProvider.challenges.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => challengeProvider.loadChallenges(),
          child: CustomScrollView(
            slivers: [
              // Stats card
              SliverToBoxAdapter(
                child: Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          icon: Icons.check_circle,
                          value:
                              '${challengeProvider.totalChallengesCompleted}',
                          label: 'Completed',
                        ),
                        _StatItem(
                          icon: Icons.emoji_events,
                          value:
                              '${challengeProvider.totalPointsFromChallenges}',
                          label: 'Points Earned',
                        ),
                        _StatItem(
                          icon: Icons.trending_up,
                          value: '${challengeProvider.activeChallenges.length}',
                          label: 'Active',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Challenges header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(
                    'Active Challenges',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),

              // Challenges list
              if (challengeProvider.activeChallenges.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No active challenges',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final challenge = challengeProvider.activeChallenges[index];
                    return _ChallengeCard(challenge: challenge);
                  }, childCount: challengeProvider.activeChallenges.length),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final CommunityChallenge challenge;

  const _ChallengeCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    final progress =
        challenge.userProgress?.getProgress(challenge.targetValue) ?? 0.0;
    final currentValue = challenge.userProgress?.currentValue ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (challenge.badgeIcon != null)
                      Text(
                        challenge.badgeIcon!,
                        style: const TextStyle(fontSize: 32),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            challenge.difficultyLabel,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    if (challenge.isCompleted)
                      const Chip(
                        label: Text('Completed'),
                        backgroundColor: Colors.green,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  challenge.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress: $currentValue / ${challenge.targetValue} ${challenge.targetUnit}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${challenge.participantCount} participants',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimeRemaining(challenge.timeRemaining),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (challenge.isCompleted)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        '+${challenge.rewardPoints} points earned!',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      ShareService().shareChallengeCompletion(
                        challengeTitle: challenge.title,
                        rewardPoints: challenge.rewardPoints,
                        participantCount: challenge.participantCount,
                        context: context,
                      );
                    },
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Reward: ${challenge.rewardPoints} points',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatTimeRemaining(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h left';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m left';
    } else {
      return '${duration.inMinutes}m left';
    }
  }
}
