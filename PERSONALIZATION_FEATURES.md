# Advanced Personalization Features

This document describes the Advanced Personalization system implemented in Flow Finder, which provides AI-powered recommendations, custom practices, and comprehensive user customization options.

## 📚 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Models](#models)
- [Services](#services)
- [Providers](#providers)
- [Screens](#screens)
- [Integration](#integration)
- [Usage Examples](#usage-examples)

## Overview

The Advanced Personalization system enables users to customize their mindfulness experience through:
- **AI-Powered Recommendations**: Intelligent practice suggestions based on mood, time, and history
- **Custom Breathing Patterns**: Create personalized breathing exercises
- **Theme Customization**: 8 beautiful theme options
- **Voice Selection**: 7 narrator voice options
- **Mood Tracking**: Track your emotional state over time
- **Adaptive Settings**: Automatically adjust difficulty based on performance

## Features

### 1. AI-Powered Recommendations 🤖

The recommendation engine analyzes multiple factors to suggest the best practices:

- **Mood-Based**: Recommendations tailored to your current emotional state (stressed, anxious, calm, energetic, tired, happy, sad, neutral)
- **Time-Based**: Suggestions appropriate for morning, afternoon, evening, or night
- **History-Based**: Learns from your past preferences and favorite practices
- **Streak-Based**: Encourages consistency with streak-aware recommendations
- **Adaptive Duration**: Adjusts practice length based on your average session duration

**Confidence Scoring**: Each recommendation includes a confidence score (0-100%) indicating how well it matches your profile.

### 2. Custom Practice Builder 🛠️

Create your own breathing patterns and practice routines:

#### Breathing Patterns
- **Customizable Phases**: Set duration for inhale, hold (after inhale), exhale, hold (after exhale)
- **Cycle Count**: Define how many repetitions
- **Default Patterns**: Includes Box Breathing, 4-7-8 Technique, Coherent Breathing, Energizing Breath, and Calming Breath
- **Persistence**: All custom patterns are saved locally with Hive

#### Practice Routines
- **Multi-Step**: Combine different practice types (breathing, meditation, body scan, PMR)
- **Flexible Duration**: Set individual durations for each step
- **Pattern Integration**: Link breathing patterns to routine steps

### 3. Theme System 🎨

8 Beautiful themes to personalize your experience:

| Theme | Colors | Emoji | Description |
|-------|--------|-------|-------------|
| **Ocean** | Blue gradient | 🌊 | Calming ocean vibes |
| **Forest** | Green gradient | 🌲 | Natural forest atmosphere |
| **Space** | Purple/indigo | ⭐ | Cosmic and peaceful |
| **Sunset** | Orange/pink | 🌅 | Warm and comforting |
| **Mountain** | Gray/blue | ⛰️ | Grounded and stable |
| **Desert** | Gold/orange | 🏜️ | Warm minimalism |
| **Aurora** | Green/purple | 🌌 | Ethereal and magical |
| **Zen** | Soft grays | 🧘 | Minimalist and focused |

Each theme includes:
- Primary and secondary colors
- Gradient colors for backgrounds
- Surface colors
- Automatic Material Design 3 theme generation

### 4. Voice Narrator System 🎙️

7 Voice options for guided practices:

| Voice | Gender | Language | Accent | Premium | Description |
|-------|--------|----------|--------|---------|-------------|
| **Sarah** | Female | English | US | No | Warm and calming |
| **Michael** | Male | English | US | No | Deep and soothing |
| **Emma** | Female | English | UK | No | Gentle and peaceful |
| **James** | Male | English | UK | No | Calm and reassuring |
| **Alex** | Neutral | English | Neutral | No | Balanced and clear |
| **Sofia** | Female | Spanish | Spain | Yes | Melodic and soothing |
| **Yuki** | Female | Japanese | Japan | Yes | Soft and tranquil |

Each voice includes:
- Adjustable pitch (0.5 - 2.0)
- Adjustable speed (0.5 - 2.0)
- Sample audio URL support
- Volume controls

### 5. Mood Tracking 📊

Track your emotional state over time:

- **8 Mood Types**: Stressed, Anxious, Calm, Energetic, Tired, Happy, Sad, Neutral
- **Intensity Levels**: Rate from 1-5
- **Notes**: Add optional notes to mood entries
- **History View**: See your mood patterns over the last 30 days
- **Integration**: Mood data feeds into the recommendation engine

### 6. User Preferences ⚙️

Comprehensive settings system:

- **Audio Settings**:
  - Voice volume (0-100%)
  - Background music volume (0-100%)
  - Sound effects (on/off)
  
- **Interaction Settings**:
  - Haptic feedback (on/off)
  - Adaptive difficulty (on/off)
  
- **Practice Settings**:
  - Default practice duration
  - Favorite practices list
  - Preferred theme
  - Preferred voice

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     Main App                             │
│              (PersonalizationProvider)                   │
└───────────────────┬─────────────────────────────────────┘
                    │
        ┌───────────┴──────────┬──────────────┐
        │                      │              │
┌───────▼──────┐    ┌─────────▼──────┐  ┌───▼────────┐
│ Recommendation│    │ Personalization│  │   Theme    │
│    Service    │    │    Service     │  │  Manager   │
└───────┬───────┘    └────────┬───────┘  └────────────┘
        │                     │
        │            ┌────────▼────────┐
        │            │   Hive Storage  │
        │            │  ┌──────────┐   │
        └────────────┼─►│user_prefs│   │
                     │  ├──────────┤   │
                     │  │  moods   │   │
                     │  ├──────────┤   │
                     │  │ patterns │   │
                     │  ├──────────┤   │
                     │  │ routines │   │
                     │  └──────────┘   │
                     └─────────────────┘
```

## Models

### 1. `recommendation_model.dart`

#### MoodType
```dart
enum MoodType {
  stressed, anxious, calm, energetic,
  tired, happy, sad, neutral
}
```

#### UserMood
```dart
class UserMood {
  final MoodType mood;
  final int intensity; // 1-5
  final DateTime timestamp;
  final String? note;
}
```

#### PracticeRecommendation
```dart
class PracticeRecommendation {
  final String id;
  final String title;
  final String description;
  final PracticeType type;
  final int durationMinutes;
  final double confidenceScore; // 0.0 - 1.0
  final List<String> reasons;
  final String? breathingPatternId;
  final String? customRoutineId;
}
```

#### UserPreferences
```dart
class UserPreferences {
  final String userId;
  final String? preferredVoiceId;
  final AppThemeType? preferredTheme;
  final double voiceVolume;
  final double backgroundMusicVolume;
  final bool soundEffectsEnabled;
  final bool hapticFeedbackEnabled;
  final bool adaptiveDifficultyEnabled;
  final int defaultPracticeDuration;
  final List<String> favoritePractices;
  final DateTime lastUpdated;
}
```

### 2. `custom_practice_model.dart`

#### CustomBreathingPattern
```dart
class CustomBreathingPattern {
  final String id;
  final String name;
  final String description;
  final int inhaleSeconds;
  final int holdInSeconds;
  final int exhaleSeconds;
  final int holdOutSeconds;
  final int cycles;
  final bool isDefault;
  final DateTime createdAt;
}
```

#### CustomPracticeRoutine
```dart
class CustomPracticeRoutine {
  final String id;
  final String name;
  final String description;
  final List<PracticeStep> steps;
  final int totalDurationMinutes;
  final PracticeType primaryType;
  final DateTime createdAt;
}
```

### 3. `theme_model.dart`

#### AppThemeData
```dart
class AppThemeData {
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final List<Color> gradientColors;
  final Color surfaceColor;
  final String emoji;
  
  ThemeData toThemeData(); // Converts to Material ThemeData
}
```

### 4. `voice_model.dart`

#### VoiceOption
```dart
class VoiceOption {
  final String id;
  final String name;
  final String description;
  final VoiceGender gender;
  final VoiceLanguage language;
  final String accent;
  final double pitch;
  final double speed;
  final bool isPremium;
}
```

## Services

### 1. PersonalizationService

Manages persistence of personalization data using Hive:

```dart
class PersonalizationService {
  Future<void> init();
  
  // Preferences
  Future<void> savePreferences(UserPreferences preferences);
  Future<UserPreferences?> loadPreferences();
  
  // Mood tracking
  Future<void> saveMood(UserMood mood);
  Future<List<UserMood>> getMoodHistory({int days = 30});
  
  // Custom patterns
  Future<void> saveCustomPattern(CustomBreathingPattern pattern);
  Future<List<CustomBreathingPattern>> getCustomPatterns();
  Future<void> deleteCustomPattern(String patternId);
  
  // Custom routines
  Future<void> saveCustomRoutine(CustomPracticeRoutine routine);
  Future<List<CustomPracticeRoutine>> getCustomRoutines();
  Future<void> deleteCustomRoutine(String routineId);
  
  // Voices
  List<VoiceOption> getAvailableVoices();
  VoiceOption? getVoiceById(String voiceId);
  
  // Adaptive settings
  Map<String, dynamic> calculateAdaptiveSettings({
    required int completedSessions,
    required int averageDuration,
    required double completionRate,
  });
}
```

**Hive Boxes Used:**
- `user_preferences`: UserPreferences data
- `mood_history`: Mood tracking data
- `custom_breathing_patterns`: Custom breathing patterns
- `custom_routines`: Custom practice routines

### 2. RecommendationService

AI-powered recommendation engine:

```dart
class RecommendationService {
  Future<List<PracticeRecommendation>> getRecommendations({
    MoodType? currentMood,
    TimeOfDay? timeOfDay,
    List<String> practiceHistory,
    int averageSessionDuration,
    int currentStreak,
    List<String> favoritePractices,
  });
}
```

**Recommendation Algorithms:**

1. **Mood-Based Recommendations**:
   - Stressed → PMR, Box Breathing
   - Anxious → 4-7-8 Breathing, Mindfulness
   - Calm → Meditation, Body Scan
   - Energetic → Energizing Breath, Quick meditation
   - Tired → Calming Breath, Gentle body scan

2. **Time-Based Recommendations**:
   - Morning → Energizing practices
   - Afternoon → Focus practices
   - Evening → Relaxation practices
   - Night → Sleep preparation

3. **History-Based**: Prioritizes previously completed practices

4. **Streak-Based**: Encourages consistency

5. **Adaptive Duration**: Matches your typical session length

## Providers

### PersonalizationProvider

Main state management for personalization features:

```dart
class PersonalizationProvider extends ChangeNotifier {
  // State
  UserPreferences? preferences;
  List<CustomBreathingPattern> customPatterns;
  List<CustomPracticeRoutine> customRoutines;
  List<UserMood> moodHistory;
  List<PracticeRecommendation> recommendations;
  
  // Getters
  AppThemeData get currentTheme;
  ThemeData get themeData;
  VoiceOption? get selectedVoice;
  MoodType? get latestMood;
  
  // Methods
  Future<void> init();
  Future<void> updatePreferences(UserPreferences);
  Future<void> updateTheme(AppThemeType);
  Future<void> updateVoice(String voiceId);
  Future<void> saveMood(UserMood);
  Future<void> saveCustomPattern(CustomBreathingPattern);
  Future<void> loadRecommendations();
}
```

## Screens

### 1. PersonalizationHomeScreen
Main hub for all personalization features:
- Current mood card
- Recommendations preview
- Theme selector access
- Voice selector access
- Custom practices access
- Settings toggles

### 2. ThemeSelectorScreen
Grid view of all 8 themes with live previews and gradient displays.

### 3. VoiceSelectorScreen
List of all voice options with:
- Gender and language info
- Accent display
- Premium badges
- Preview button
- Selection state

### 4. MoodTrackerScreen
- Mood selector grid (8 mood types)
- Mood history list
- Notes display

### 5. RecommendationsScreen
- AI-generated practice suggestions
- Confidence scores
- Ranking badges (top 3)
- Reason explanations
- Quick start actions

### 6. CustomPracticeBuilderScreen
Tabbed interface:
- **Breathing Patterns Tab**: Create/manage breathing patterns
- **Routines Tab**: Create/manage practice routines

## Integration

### Adding PersonalizationProvider to Your App

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => PersonalizationProvider()..init(),
        ),
        // ... other providers
      ],
      child: Consumer<PersonalizationProvider>(
        builder: (context, personalizationProvider, child) {
          return MaterialApp(
            theme: personalizationProvider.themeData, // Apply theme
            home: const HomeScreen(),
          );
        },
      ),
    ),
  );
}
```

### Accessing Personalization in Widgets

```dart
// Get current theme
final theme = context.read<PersonalizationProvider>().currentTheme;

// Get recommendations
final recommendations = context.watch<PersonalizationProvider>().recommendations;

// Update mood
await context.read<PersonalizationProvider>().saveMood(
  UserMood(mood: MoodType.calm, intensity: 4, timestamp: DateTime.now()),
);

// Change theme
await context.read<PersonalizationProvider>().updateTheme(AppThemeType.ocean);
```

## Usage Examples

### Example 1: Tracking Mood and Getting Recommendations

```dart
// Save current mood
final provider = context.read<PersonalizationProvider>();
await provider.saveMood(
  UserMood(
    mood: MoodType.stressed,
    intensity: 4,
    timestamp: DateTime.now(),
    note: 'Work deadline approaching',
  ),
);

// Load recommendations (automatically considers latest mood)
await provider.loadRecommendations();

// Display recommendations
final recommendations = provider.recommendations;
for (var rec in recommendations.take(3)) {
  print('${rec.title}: ${rec.confidenceScore * 100}% match');
  print('Reason: ${rec.reasons.first}');
}
```

### Example 2: Creating a Custom Breathing Pattern

```dart
final pattern = CustomBreathingPattern(
  id: const Uuid().v4(),
  name: 'My Relaxation Breath',
  description: 'Custom pattern for deep relaxation',
  inhaleSeconds: 5,
  holdInSeconds: 2,
  exhaleSeconds: 7,
  holdOutSeconds: 2,
  cycles: 8,
  createdAt: DateTime.now(),
);

await context.read<PersonalizationProvider>().saveCustomPattern(pattern);
```

### Example 3: Applying Theme Throughout App

```dart
// In main.dart
Consumer<PersonalizationProvider>(
  builder: (context, provider, child) {
    return MaterialApp(
      theme: provider.themeData,
      // ... rest of MaterialApp config
    );
  },
)

// Theme automatically updates everywhere when user changes it
```

## Benefits

1. **Personalized Experience**: Users can tailor every aspect of the app to their preferences
2. **Intelligent Recommendations**: AI learns from user behavior and suggests optimal practices
3. **Visual Customization**: 8 beautiful themes keep the experience fresh
4. **Audio Options**: Multiple voices and volume controls for perfect audio experience
5. **Progress Tracking**: Mood tracking helps users understand their patterns
6. **Flexibility**: Custom patterns and routines allow unlimited creativity
7. **Persistence**: All settings saved locally with Hive for instant loading

## Future Enhancements

- [ ] More sophisticated AI recommendation algorithms
- [ ] Social sharing of custom patterns
- [ ] Pattern marketplace
- [ ] Advanced statistics and insights
- [ ] Theme customization (create your own themes)
- [ ] Voice recording (record your own guidance)
- [ ] Smart notifications based on mood patterns
- [ ] Integration with wearables for biometric-based recommendations

---

**For more information, see:**
- [Main README](README.md)
- [Social Features Documentation](SOCIAL_FEATURES.md)
- [API Documentation](docs/api.md)
