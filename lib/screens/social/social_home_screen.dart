// lib/screens/social/social_home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/social_provider.dart';
import '../../providers/challenge_provider.dart';
import '../../providers/live_session_provider.dart';
import 'friends_screen.dart';
import 'challenges_screen.dart';
import 'leaderboard_screen.dart';
import 'live_sessions_screen.dart';

class SocialHomeScreen extends StatefulWidget {
  const SocialHomeScreen({super.key});

  @override
  State<SocialHomeScreen> createState() => _SocialHomeScreenState();
}

class _SocialHomeScreenState extends State<SocialHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SocialProvider>().init();
      context.read<ChallengeProvider>().init();
      context.read<LiveSessionProvider>().init();
    });
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
        title: const Text('Community'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(
              icon: Consumer<SocialProvider>(
                builder: (context, social, _) {
                  final count = social.pendingRequestCount;
                  return Badge(
                    isLabelVisible: count > 0,
                    label: Text('$count'),
                    child: const Icon(Icons.people),
                  );
                },
              ),
              text: 'Friends',
            ),
            Tab(
              icon: Consumer<ChallengeProvider>(
                builder: (context, challenge, _) {
                  final count = challenge.activeChallenges.length;
                  return Badge(
                    isLabelVisible: count > 0,
                    label: Text('$count'),
                    child: const Icon(Icons.emoji_events),
                  );
                },
              ),
              text: 'Challenges',
            ),
            const Tab(icon: Icon(Icons.leaderboard), text: 'Leaderboard'),
            Tab(
              icon: Consumer<LiveSessionProvider>(
                builder: (context, sessions, _) {
                  final liveCount = sessions.liveSessions.length;
                  return Badge(
                    isLabelVisible: liveCount > 0,
                    label: Text('$liveCount'),
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.live_tv),
                  );
                },
              ),
              text: 'Live',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FriendsScreen(),
          ChallengesScreen(),
          LeaderboardScreen(),
          LiveSessionsScreen(),
        ],
      ),
    );
  }
}
