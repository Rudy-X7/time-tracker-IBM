# Time Tracker

A comprehensive time tracking application built with Flutter that helps users track time spent on different projects and tasks.

![Flutter Version](https://img.shields.io/badge/flutter-^3.7.0-blue.svg)
![Dart Version](https://img.shields.io/badge/dart-^3.7.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

## Features

- 📝 Create and manage projects and tasks
- ⏱️ Track time entries with notes
- 📊 View time entries grouped by project or in a flat list
- 📅 Organize entries by date
- 📱 Cross-platform support (iOS, Android, macOS, Web, Windows, Linux)
- 💾 Local storage for offline access

## Getting Started

### Prerequisites

- Flutter SDK (^3.7.0)
- Dart SDK (^3.7.0)
- An IDE (VSCode, Android Studio, or IntelliJ)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/time_tracker.git
cd time_tracker
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Usage

### Adding Projects and Tasks

1. Tap the settings icon in the top-right corner
2. Create projects with custom names and colors
3. Add tasks associated with projects

### Recording Time Entries

1. Tap the + button on the home screen
2. Select a project and task
3. Enter the duration and date
4. Add optional notes
5. Save the entry

### Viewing and Managing Entries

- Toggle between list view and project-grouped view using the icon in the app bar
- Swipe left on an entry to delete it
- Tap on the settings icon to manage projects and tasks

## Tech Stack

- **Flutter**: UI framework
- **Provider**: State management
- **LocalStorage**: Data persistence
- **Intl**: Date formatting

## Dependencies

- `provider: ^6.1.4` - State management
- `localstorage: ^6.0.0` - Local data persistence
- `intl: ^0.20.2` - Internationalization and date formatting
- `collection: ^1.19.1` - Collection utilities (groupBy)

## Project Structure

```
lib/
├── models/
│   ├── project.dart
│   ├── task.dart
│   └── time_entry.dart
├── providers/
│   ├── project_provider.dart
│   ├── task_provider.dart
│   ├── time_entry_provider.dart
│   └── storage_helper.dart
├── screens/
│   ├── home_screen.dart
│   ├── add_time_entry_screen.dart
│   └── project_task_management_screen.dart
└── main.dart
```

## Roadmap

- [ ] Add data visualization with charts and graphs
- [ ] Implement cloud sync
- [ ] Add export functionality (CSV, PDF)
- [ ] Support for recurring tasks
- [ ] Timer functionality for real-time tracking

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- The open-source community for valuable packages
