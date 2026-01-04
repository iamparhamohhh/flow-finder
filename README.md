<div align="center">

# 🌊 Flow Finder

**Your Personal Mindfulness & Wellness Companion**

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?style=for-the-badge&logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

*Discover your flow state through guided mindfulness practices, breathing exercises, and progressive wellness tracking.*

[Features](#-features) • [Screenshots](#-screenshots) • [Getting Started](#-getting-started) • [Architecture](#-architecture) • [Contributing](#-contributing)

</div>

---

## 📱 About

**Flow Finder** is a comprehensive mindfulness and wellness application built with Flutter. It combines modern UI/UX design with evidence-based wellness practices to help users achieve mental clarity, reduce stress, and track their journey toward better mental health.

### 🎯 Core Philosophy

- **Progressive Enhancement**: Unlock new practices as you progress
- **Gamified Wellness**: Daily quests and rewards keep you motivated
- **Data-Driven Insights**: Visual flow charts track your emotional journey
- **Audio-Guided Practices**: Immersive sound design for deep relaxation

---

## ✨ Features

### 🧘 Mindfulness Practices

- **Guided Breathing Exercises**
  - Box Breathing (4-4-4-4)
  - 4-7-8 Relaxation Technique
  - Customizable breathing patterns
  - Real-time visual guidance with animations
  - Ambient sounds for enhanced focus

- **Body Scan Meditation**
  - Progressive relaxation sequences
  - Step-by-step body awareness guidance
  - Audio cues and ambient soundscapes

- **Progressive Muscle Relaxation (PMR)**
  - Systematic tension-release exercises
  - Guided audio instructions
  - Visual progress tracking

### 📊 Progress Tracking

- **Flow Chart Visualization**
  - Interactive emotional state tracking
  - Historical data analysis
  - Pattern recognition over time
  - Beautiful, intuitive graphs

- **Activity Logging**
  - Persistent storage with Hive database
  - Comprehensive practice history
  - Achievement milestones

### 🎮 Gamification

- **Daily Quests System**
  - Rotating daily challenges
  - Reward points for completion
  - Unlockable content
  - Streak tracking

- **Achievement System**
  - Progressive unlocks
  - Motivation through rewards
  - Journey milestones

### 🎨 User Experience

- **Material Design 3**
  - Modern, clean interface
  - Smooth animations
  - Intuitive navigation
  - Dark mode ready

- **Responsive Design**
  - Optimized for phones and tablets
  - Cross-platform compatibility (iOS, Android, Web)

---

## 🖼️ Screenshots

*Coming soon - screenshots of the app in action*

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (>=3.9.2)
- **Dart SDK** (>=3.9.2)
- Android Studio / Xcode (for mobile development)
- A code editor (VS Code, Android Studio, or IntelliJ IDEA)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/flow_finder.git
   cd flow_finder
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate model files**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

#### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

---

## 🏗️ Architecture

### Project Structure

```
lib/
├── main.dart                    # App entry point
├── core/                        # Core functionality
│   ├── constants/              # App constants
│   ├── theme/                  # Theme configuration
│   └── utils/                  # Utility functions
├── models/                      # Data models
│   ├── activity_model.dart     # Activity tracking
│   └── quest_model.dart        # Quest system
├── providers/                   # State management (Provider pattern)
│   ├── activity_provider.dart
│   ├── breathing_provider.dart
│   ├── body_scan_provider.dart
│   ├── mindfulness_provider.dart
│   ├── pmr_provider.dart
│   ├── quest_provider.dart
│   └── theme_provider.dart
├── screens/                     # UI screens
│   ├── home_screen.dart
│   ├── flow_chart_screen.dart
│   ├── breathing_screen.dart
│   ├── practices/              # Practice screens
│   └── quests/                 # Quest-related screens
├── services/                    # Business logic services
│   ├── audio_service.dart      # Audio playback
│   └── hive_service.dart       # Local storage
└── widgets/                     # Reusable UI components
```

### Key Technologies

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform UI framework |
| **Provider** | State management solution |
| **Hive** | Fast, lightweight local database |
| **AudioPlayers** | Audio playback for guided sessions |
| **Material Design 3** | Modern UI components |

### Design Patterns

- **Provider Pattern**: For reactive state management
- **Repository Pattern**: Data layer abstraction
- **Service Pattern**: Business logic separation
- **Model-View-Provider (MVP)**: Clean architecture

---

## 🎵 Audio Assets

The app includes professionally selected audio assets:

- `ambient.mp3` - Calming background ambience
- `bell.mp3` - Meditation session markers

*Audio files are located in `assets/sounds/`*

---

## 🧪 Testing

Run the test suite:

```bash
flutter test
```

Run tests with coverage:

```bash
flutter test --coverage
```

---

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/AmazingFeature`)
3. **Commit your changes** (`git commit -m 'Add some AmazingFeature'`)
4. **Push to the branch** (`git push origin feature/AmazingFeature`)
5. **Open a Pull Request**

### Development Guidelines

- Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide
- Write meaningful commit messages
- Add tests for new features
- Update documentation as needed
- Ensure all tests pass before submitting PR

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- The mindfulness and meditation community for inspiration
- Contributors and testers who help improve Flow Finder

---

## 📧 Contact

Have questions or suggestions? Feel free to reach out!

- **Issues**: [GitHub Issues](https://github.com/yourusername/flow_finder/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/flow_finder/discussions)

---

<div align="center">

**Made with ❤️ and Flutter**

⭐ Star this repository if you find it helpful!

</div>
