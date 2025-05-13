# Kottab - كتاب | Quran Memorization App

<div align="center">

![Kottab Logo](https://github.com/username/kottab/blob/assets/kottab_logo.png)

**رفيقك في حفظ القرآن**  
_Your companion for Quran memorization_

[![Flutter Version](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)](https://flutter.dev)

</div>

## 📱 About Kottab

Kottab (كتاب) is a modern, user-friendly Quran memorization app designed to help Muslims systematically memorize the Quran. The app follows the "Spaced Repetition with a Rolling Review Window" method, breaking the Quran into manageable verse sets and scheduling reviews at strategic intervals to optimize retention.

### ✨ Key Features

- **Smart Memorization Tracking**: Track progress through personalized memorization plans
- **Spaced Repetition**: Intelligent review scheduling based on scientific memory principles
- **Visual Progress**: Beautiful visualizations of your memorization journey
- **Daily Streaks**: Track your consistency and build a daily habit
- **Material Design 3**: Modern, clean UI following Material You principles
- **Full RTL Support**: Optimized for Arabic language
- **Performance Optimized**: Efficient resource usage and smooth animations
- **Accessibility Focus**: Support for text scaling and color contrast
- **Offline First**: Use all core features without internet connection

## 📸 Screenshots

<div align="center">
<table>
  <tr>
    <td><img src="https://github.com/username/kottab/blob/assets/screenshot_home.png" width="200"></td>
    <td><img src="https://github.com/username/kottab/blob/assets/screenshot_surahs.png" width="200"></td>
    <td><img src="https://github.com/username/kottab/blob/assets/screenshot_stats.png" width="200"></td>
  </tr>
  <tr>
    <td align="center">Home Screen</td>
    <td align="center">Surahs Screen</td>
    <td align="center">Statistics Screen</td>
  </tr>
  <tr>
    <td><img src="https://github.com/username/kottab/blob/assets/screenshot_schedule.png" width="200"></td>
    <td><img src="https://github.com/username/kottab/blob/assets/screenshot_session.png" width="200"></td>
    <td><img src="https://github.com/username/kottab/blob/assets/screenshot_settings.png" width="200"></td>
  </tr>
  <tr>
    <td align="center">Schedule Screen</td>
    <td align="center">Session Management</td>
    <td align="center">Settings Screen</td>
  </tr>
</table>
</div>

## 🚀 Getting Started

### Prerequisites

- Flutter (>=3.0.0)
- Dart (>=2.18.0)
- Android Studio / VS Code
- Git

### Installation

```bash
# Clone this repository
git clone https://github.com/username/kottab.git

# Navigate to the project
cd kottab

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 🛠️ Technology Stack

- **Flutter**: UI framework
- **Provider**: State management
- **Shared Preferences**: Local storage
- **Material Design 3**: UI design language

## 🏗️ Project Structure

```
lib/
│
├── config/             # App configuration
│   ├── app_theme.dart  # Theme definition
│   ├── app_colors.dart # Color palette
│   └── launch/         # App initialization
│
├── data/               # Data providers and repositories
│
├── models/             # Data models
│
├── providers/          # State management
│
├── screens/            # App screens
│   ├── home_screen.dart
│   ├── surahs_screen.dart
│   ├── stats_screen.dart
│   └── ...
│
├── services/           # Business logic
│
├── utils/              # Utility functions
│   ├── accessibility/  # Accessibility helpers
│   └── performance/    # Performance optimizations
│
└── widgets/            # Reusable UI components
    ├── home/           # Home screen widgets
    ├── surahs/         # Surah screen widgets
    └── ...
```

## 🎯 Core Features in Detail

### Memorization System

- **Verse Sets**: The Quran is divided into manageable sets of verses
- **Smart Scheduling**: Review intervals are calculated based on performance
- **Progress Tracking**: Visual indicators of memorization progress
- **Quality Rating**: Rate your memorization quality to adjust review schedules

### User Experience

- **Onboarding Flow**: Guided introduction for first-time users
- **Daily Goals**: Set and track daily memorization targets
- **Achievement System**: Rewards for consistent memorization habits
- **Search Functionality**: Find surahs and verses quickly

### Technical Features

- **Performance Monitoring**: Built-in system to maintain app responsiveness
- **Accessibility Tools**: Support for various user needs
- **Error Handling**: Robust error recovery mechanisms
- **RTL Optimization**: Perfect right-to-left text rendering for Arabic

## ⚙️ Configuration

The app supports various configuration options:

- **Theme**: Light and dark mode support
- **Notifications**: Configurable reminders for daily practice
- **Verse Set Size**: Adjustable memorization chunk size
- **Review Intervals**: Customizable spacing for the spaced repetition algorithm

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run a specific test
flutter test test/widget_test.dart
```

## 📋 Roadmap

- [ ] Cloud synchronization for multi-device support
- [ ] Community features for group memorization
- [ ] Audio recitation integration
- [ ] AI-powered memorization recommendations
- [ ] Advanced analytics and insights
- [ ] Multiple Quran translations support

See [NEXT_STEPS.md](NEXT_STEPS.md) for a detailed roadmap of planned features and improvements.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please make sure to update tests as appropriate.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Contact

Your Name - [email@example.com](mailto:email@example.com)

Project Link: [https://github.com/username/kottab](https://github.com/username/kottab)

## 🙏 Acknowledgments

- [The Noble Quran](https://quran.com/)
- [Spaced Repetition Research](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4492928/)
- [Flutter Team](https://flutter.dev/team)
- All contributors and testers who made this app possible