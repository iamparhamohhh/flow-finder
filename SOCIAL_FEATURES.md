# Social & Community Features Documentation

## 🎉 Overview

The Social & Community Features bring a complete social networking experience to Flow Finder, allowing users to connect, compete, and grow together in their mindfulness journey.

## ✨ Features Implemented

### 1. **Friend System** 👥
- **Search Users**: Find other users by username or display name
- **Friend Requests**: Send and receive friend requests
- **Friends List**: View all your friends with online status
- **Remove Friends**: Manage your connections
- **Invite Friends**: Share the app via social media/messaging

**Location**: `lib/screens/social/friends_screen.dart`

### 2. **Community Challenges** 🏆
- **Active Challenges**: View and join ongoing challenges
- **Challenge Types**: Daily, Weekly, Monthly, and Special challenges
- **Difficulty Levels**: Easy, Medium, Hard, Expert
- **Progress Tracking**: Real-time progress updates
- **Rewards System**: Earn points for completing challenges
- **Share Completions**: Share your achievements on social media

**Location**: `lib/screens/social/challenges_screen.dart`

### 3. **Leaderboard** 📊
- **Multiple Periods**: Daily, Weekly, Monthly, All-Time
- **Category Filtering**: Total Points, Streak, Sessions, Minutes
- **Top Rankings**: Special highlighting for top 3 users
- **Current User Highlight**: Easy to find your rank
- **Share Rank**: Share your leaderboard position

**Location**: `lib/screens/social/leaderboard_screen.dart`

### 4. **Live Practice Sessions** 🎥
- **Live Sessions**: Join real-time group meditation/breathing sessions
- **Upcoming Schedule**: See all scheduled sessions
- **Session Types**: Breathing, Meditation, Body Scan, PMR, Yoga, Discussion
- **Session Details**: Host info, duration, participant count
- **Live Indicators**: Visual badges for live sessions
- **Join/Leave**: Seamlessly join and leave sessions

**Location**: `lib/screens/social/live_sessions_screen.dart`

### 5. **Share Progress** 📤
Multiple sharing options via social media:
- **Share Achievements**: Share completed goals
- **Share Streak**: Show off your consistency
- **Share Challenge Completion**: Celebrate victories
- **Share Leaderboard Rank**: Display your ranking
- **Share Session Stats**: Post practice session details
- **Weekly Summary**: Share weekly progress reports
- **Invite Friends**: Invite others to join the app

**Location**: `lib/services/share_service.dart`

## 📁 Project Structure

```
lib/
├── models/
│   ├── user_model.dart              # User profile and stats
│   ├── friend_model.dart            # Friendship and requests
│   ├── challenge_model.dart         # Community challenges
│   ├── leaderboard_model.dart       # Leaderboard entries
│   └── live_session_model.dart      # Live practice sessions
├── providers/
│   ├── social_provider.dart         # Friends management
│   ├── challenge_provider.dart      # Challenges & leaderboard
│   └── live_session_provider.dart   # Live sessions
├── services/
│   ├── social_service.dart          # API service (mock data)
│   └── share_service.dart           # Social sharing
├── screens/
│   └── social/
│       ├── social_home_screen.dart  # Main tabbed interface
│       ├── friends_screen.dart      # Friends management
│       ├── challenges_screen.dart   # Challenges list
│       ├── leaderboard_screen.dart  # Rankings
│       └── live_sessions_screen.dart # Live sessions
└── widgets/
    └── share_achievement_button.dart # Reusable share widgets
```

## 🚀 Getting Started

### Dependencies Added

```yaml
dependencies:
  share_plus: ^10.1.3      # Social sharing
  http: ^1.2.2             # API calls
  cached_network_image: ^3.4.1  # Image caching
  intl: ^0.19.0            # Date formatting
  uuid: ^4.5.1             # Unique IDs
```

### Installation

1. Dependencies are already added to `pubspec.yaml`
2. Run: `flutter pub get` ✅ (Already done)
3. The social tab is integrated into the home screen

### Usage

The social features are accessible via the **Community tab** in the bottom navigation bar.

## 💻 Code Examples

### Using Share Service

```dart
import 'package:flow_finder/services/share_service.dart';

// Share achievement
ShareService().shareAchievement(
  achievementTitle: 'Mindfulness Master',
  achievementDescription: 'Completed 30 days of meditation!',
  context: context,
);

// Share streak
ShareService().shareStreak(
  streakDays: 21,
  totalSessions: 63,
  totalMinutes: 945,
  context: context,
);

// Share challenge completion
ShareService().shareChallengeCompletion(
  challengeTitle: 'Weekly Meditation Master',
  rewardPoints: 300,
  participantCount: 156,
  context: context,
);
```

### Accessing Social Provider

```dart
import 'package:provider/provider.dart';
import 'package:flow_finder/providers/social_provider.dart';

// In your widget
final socialProvider = context.watch<SocialProvider>();

// Get friends count
final friendCount = socialProvider.friendCount;

// Get current user
final currentUser = socialProvider.currentUser;

// Send friend request
await socialProvider.sendFriendRequest(userId);

// Accept friend request
await socialProvider.acceptFriendRequest(requestId);
```

### Accessing Challenge Provider

```dart
import 'package:flow_finder/providers/challenge_provider.dart';

final challengeProvider = context.watch<ChallengeProvider>();

// Get active challenges
final challenges = challengeProvider.activeChallenges;

// Join a challenge
await challengeProvider.joinChallenge(challengeId);

// Update progress
await challengeProvider.updateChallengeProgress(
  challengeId: 'challenge_1',
  incrementBy: 1,
);
```

### Accessing Live Session Provider

```dart
import 'package:flow_finder/providers/live_session_provider.dart';

final sessionProvider = context.watch<LiveSessionProvider>();

// Get live sessions
final liveSessions = sessionProvider.liveSessions;

// Get upcoming sessions
final upcoming = sessionProvider.upcomingSessions;

// Join a session
await sessionProvider.joinSession(sessionId);

// Leave current session
await sessionProvider.leaveSession();
```

## 🎨 UI Components

### Friend Request Card
Shows pending friend requests with accept/reject buttons

### Challenge Card
Displays challenge details with progress bar and completion status

### Leaderboard Entry
Shows user rank, avatar, stats with special highlighting for top 3

### Live Session Card
Rich session display with thumbnail, live badges, and join buttons

## 🔧 Customization

### Modifying Mock Data

The current implementation uses mock data in `lib/services/social_service.dart`. To connect to a real backend:

1. Replace mock methods with actual HTTP calls
2. Update endpoints in `SocialService`
3. Handle authentication tokens
4. Implement error handling

Example:
```dart
Future<List<Friendship>> getFriends() async {
  final response = await http.get(
    Uri.parse('https://your-api.com/api/friends'),
    headers: {'Authorization': 'Bearer $token'},
  );
  
  if (response.statusCode == 200) {
    final List data = json.decode(response.body);
    return data.map((json) => Friendship.fromJson(json)).toList();
  }
  throw Exception('Failed to load friends');
}
```

### Styling

All UI components use Material Design 3 and can be customized via:
- Theme colors in `main.dart`
- Individual widget styles in screen files
- Custom color schemes

## 🧪 Testing

### Manual Testing Checklist

- [ ] Friends: Search, add, accept, remove
- [ ] Challenges: View, join, progress updates
- [ ] Leaderboard: Period filters, category switches
- [ ] Live Sessions: View upcoming, join live
- [ ] Share: All share functions work
- [ ] Refresh: Pull-to-refresh on all screens
- [ ] Navigation: Tabs switch correctly

## 📱 Integration with Existing Features

### Update Challenge Progress After Activity

```dart
// In your practice completion handler
final challengeProvider = context.read<ChallengeProvider>();

await challengeProvider.updateChallengeProgress(
  challengeId: 'daily_breathing',
  incrementBy: 1,
);
```

### Share Achievement After Quest Completion

```dart
// After completing a quest
ShareService().shareAchievement(
  achievementTitle: quest.title,
  achievementDescription: quest.description,
  context: context,
);
```

## 🌟 Future Enhancements

Potential additions:
1. **Real-time Chat**: Message friends directly
2. **Groups**: Create practice groups
3. **Notifications**: Push notifications for friend requests, challenges
4. **Profile Customization**: Avatar upload, bio editing
5. **Activity Feed**: See friends' recent activities
6. **Video Sessions**: Actual video streaming for live sessions
7. **Voice Chat**: Audio communication during sessions
8. **Achievements System**: Unlock badges and rewards
9. **Practice History**: Share detailed statistics
10. **Analytics Dashboard**: Advanced insights

## 🐛 Troubleshooting

### Common Issues

**Issue**: Share not working on iOS
- **Solution**: Add required permissions in `ios/Runner/Info.plist`

**Issue**: Images not loading
- **Solution**: Check internet connection and image URLs

**Issue**: Providers not initialized
- **Solution**: Ensure providers are initialized in `main.dart`

## 📄 License

Part of the Flow Finder app - see main README for license information.

---

**Need Help?** Check the inline documentation in each file or create an issue in the repository.
