// lib/screens/social/leaderboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/challenge_provider.dart';
import '../../models/leaderboard_model.dart';
import '../../services/share_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChallengeProvider>(
      builder: (context, challengeProvider, _) {
        final leaderboard = challengeProvider.leaderboard;

        return RefreshIndicator(
          onRefresh: () => challengeProvider.loadLeaderboard(),
          child: Column(
            children: [
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Period filters
                    ...LeaderboardPeriod.values.map((period) {
                      final isSelected =
                          challengeProvider.selectedPeriod == period;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(_periodLabel(period)),
                          selected: isSelected,
                          onSelected: (_) {
                            challengeProvider.loadLeaderboard(period: period);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Leaderboard list
              if (challengeProvider.isLoading && leaderboard == null)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (leaderboard == null)
                const Expanded(
                  child: Center(child: Text('No leaderboard data available')),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: leaderboard.entries.length,
                    itemBuilder: (context, index) {
                      final entry = leaderboard.entries[index];
                      final isCurrentUser = entry.isCurrentUser;
                      final isTopThree = index < 3;

                      return Card(
                        color: isCurrentUser
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : null,
                        elevation: isTopThree ? 4 : 1,
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 40,
                                child: Center(
                                  child: Text(
                                    entry.rankDisplay,
                                    style: TextStyle(
                                      fontSize: isTopThree ? 24 : 16,
                                      fontWeight: isTopThree
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              CircleAvatar(
                                radius: isTopThree ? 24 : 20,
                                backgroundImage: entry.user.avatarUrl != null
                                    ? CachedNetworkImageProvider(
                                        entry.user.avatarUrl!,
                                      )
                                    : null,
                                child: entry.user.avatarUrl == null
                                    ? Text(entry.user.displayName[0])
                                    : null,
                              ),
                            ],
                          ),
                          title: Text(
                            entry.user.displayName,
                            style: TextStyle(
                              fontWeight: isCurrentUser || isTopThree
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text('@${entry.user.username}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${entry.score}',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                              Text(
                                'points',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Share button for current user's rank
              if (leaderboard?.currentUserEntry != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('Share My Rank'),
                    onPressed: () {
                      final entry = leaderboard!.currentUserEntry!;
                      ShareService().shareLeaderboardRank(
                        rank: entry.rank,
                        score: entry.score,
                        period: _periodLabel(leaderboard.period),
                        context: context,
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _periodLabel(LeaderboardPeriod period) {
    switch (period) {
      case LeaderboardPeriod.daily:
        return 'Daily';
      case LeaderboardPeriod.weekly:
        return 'Weekly';
      case LeaderboardPeriod.monthly:
        return 'Monthly';
      case LeaderboardPeriod.allTime:
        return 'All Time';
    }
  }
}
