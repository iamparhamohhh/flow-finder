// lib/screens/social/friends_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/social_provider.dart';
import '../../services/share_service.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialProvider>(
      builder: (context, socialProvider, _) {
        return RefreshIndicator(
          onRefresh: () async {
            await socialProvider.loadFriends();
            await socialProvider.loadPendingRequests();
          },
          child: CustomScrollView(
            slivers: [
              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search users...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _isSearching
                                ? IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      _searchController.clear();
                                      socialProvider.clearSearch();
                                      setState(() => _isSearching = false);
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() => _isSearching = value.isNotEmpty);
                            if (value.length >= 2) {
                              socialProvider.searchUsers(value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.person_add),
                        onPressed: () =>
                            ShareService().inviteFriends(context: context),
                        tooltip: 'Invite Friends',
                      ),
                    ],
                  ),
                ),
              ),

              // Search results
              if (_isSearching && socialProvider.searchResults.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Search Results',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              if (_isSearching)
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final user = socialProvider.searchResults[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.avatarUrl != null
                            ? CachedNetworkImageProvider(user.avatarUrl!)
                            : null,
                        child: user.avatarUrl == null
                            ? Text(user.displayName[0])
                            : null,
                      ),
                      title: Text(user.displayName),
                      subtitle: Text('@${user.username}'),
                      trailing: ElevatedButton.icon(
                        icon: const Icon(Icons.person_add, size: 16),
                        label: const Text('Add'),
                        onPressed: () async {
                          final success = await socialProvider
                              .sendFriendRequest(user.id);
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Friend request sent!'),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  }, childCount: socialProvider.searchResults.length),
                ),

              // Pending requests
              if (!_isSearching && socialProvider.pendingRequests.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Friend Requests (${socialProvider.pendingRequests.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              if (!_isSearching && socialProvider.pendingRequests.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final request = socialProvider.pendingRequests[index];
                    final fromUser = request.fromUser!;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: fromUser.avatarUrl != null
                              ? CachedNetworkImageProvider(fromUser.avatarUrl!)
                              : null,
                          child: fromUser.avatarUrl == null
                              ? Text(fromUser.displayName[0])
                              : null,
                        ),
                        title: Text(fromUser.displayName),
                        subtitle: Text('@${fromUser.username}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                              onPressed: () async {
                                await socialProvider.acceptFriendRequest(
                                  request.id,
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${fromUser.displayName} is now your friend!',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => socialProvider
                                  .rejectFriendRequest(request.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: socialProvider.pendingRequests.length),
                ),

              // Friends list header
              if (!_isSearching)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'My Friends (${socialProvider.friendCount})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),

              // Friends list
              if (!_isSearching && socialProvider.friends.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No friends yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Search and add friends to get started!',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),

              if (!_isSearching)
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final friendship = socialProvider.friends[index];
                    final friend = friendship.friend!;

                    return ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundImage: friend.avatarUrl != null
                                ? CachedNetworkImageProvider(friend.avatarUrl!)
                                : null,
                            child: friend.avatarUrl == null
                                ? Text(friend.displayName[0])
                                : null,
                          ),
                          if (friend.isOnline)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(friend.displayName),
                      subtitle: Text(
                        friend.isOnline
                            ? 'Online'
                            : 'Last active: ${_formatLastActive(friend.lastActive)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${friend.totalPoints} pts',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'view',
                                child: Row(
                                  children: [
                                    Icon(Icons.person),
                                    SizedBox(width: 8),
                                    Text('View Profile'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'remove',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person_remove,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Remove Friend',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) async {
                              if (value == 'remove') {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Remove Friend'),
                                    content: Text(
                                      'Remove ${friend.displayName} from your friends?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text(
                                          'Remove',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await socialProvider.removeFriend(
                                    friendship.id,
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }, childCount: socialProvider.friends.length),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatLastActive(DateTime lastActive) {
    final diff = DateTime.now().difference(lastActive);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
