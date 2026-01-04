// lib/screens/social/live_sessions_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../providers/live_session_provider.dart';
import '../../models/live_session_model.dart';

class LiveSessionsScreen extends StatelessWidget {
  const LiveSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LiveSessionProvider>(
      builder: (context, sessionProvider, _) {
        if (sessionProvider.isLoading && sessionProvider.allSessions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => sessionProvider.refresh(),
          child: CustomScrollView(
            slivers: [
              // Live sessions
              if (sessionProvider.liveSessions.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, color: Colors.red, size: 12),
                        const SizedBox(width: 8),
                        Text(
                          'LIVE NOW',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final session = sessionProvider.liveSessions[index];
                    return _SessionCard(
                      session: session,
                      isLive: true,
                      onJoin: () =>
                          _joinSession(context, sessionProvider, session),
                    );
                  }, childCount: sessionProvider.liveSessions.length),
                ),
              ],

              // Upcoming sessions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Upcoming Sessions',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),

              if (sessionProvider.upcomingSessions.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No upcoming sessions',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final session = sessionProvider.upcomingSessions[index];
                    return _SessionCard(
                      session: session,
                      onJoin: () =>
                          _joinSession(context, sessionProvider, session),
                    );
                  }, childCount: sessionProvider.upcomingSessions.length),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _joinSession(
    BuildContext context,
    LiveSessionProvider provider,
    LiveSession session,
  ) async {
    final success = await provider.joinSession(session.id);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Joined: ${session.title}'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () {
              // Navigate to session screen (to be implemented)
            },
          ),
        ),
      );
    }
  }
}

class _SessionCard extends StatelessWidget {
  final LiveSession session;
  final bool isLive;
  final VoidCallback onJoin;

  const _SessionCard({
    required this.session,
    this.isLive = false,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isLive ? 8 : 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          if (session.thumbnailUrl != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: session.thumbnailUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (isLive)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Colors.white, size: 8),
                          SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type and status
                Row(
                  children: [
                    Chip(
                      label: Text(session.sessionTypeLabel),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    if (session.isStartingSoon) ...[
                      const SizedBox(width: 8),
                      const Chip(
                        label: Text('Starting Soon'),
                        backgroundColor: Colors.orange,
                        labelStyle: TextStyle(color: Colors.white),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  session.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                Text(
                  session.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Host info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: session.host?.avatarUrl != null
                          ? CachedNetworkImageProvider(session.host!.avatarUrl!)
                          : null,
                      child:
                          session.host?.avatarUrl == null &&
                              session.host != null
                          ? Text(
                              session.host!.displayName[0],
                              style: const TextStyle(fontSize: 12),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hosted by ${session.host?.displayName ?? 'Unknown'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Session details
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      isLive
                          ? 'Started ${_formatTime(session.scheduledStart)}'
                          : DateFormat(
                              'MMM d, h:mm a',
                            ).format(session.scheduledStart),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${session.durationMinutes} min',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Participants
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${session.currentParticipants} / ${session.maxParticipants} joined',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    if (!session.canJoin)
                      const Chip(
                        label: Text('Full', style: TextStyle(fontSize: 10)),
                        backgroundColor: Colors.red,
                        labelStyle: TextStyle(color: Colors.white),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Join button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLive
                  ? Colors.red.withOpacity(0.1)
                  : Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: ElevatedButton.icon(
              icon: Icon(isLive ? Icons.play_arrow : Icons.schedule),
              label: Text(isLive ? 'Join Now' : 'Join Session'),
              onPressed: session.canJoin ? onJoin : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLive ? Colors.red : null,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(time);
  }
}
