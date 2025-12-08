# SessionLock

SessionLock is a Flutter application designed to help users manage their screen time and limit usage of distracting apps. It provides monitoring capabilities and session enforcement to promote digital well-being.

## Features

- **App Monitoring**: Tracks usage of specified applications.
- **Session Locking**: rigorous session enforcement that blocks access to distracting apps during focus periods.
- **Usage Statistics**: Visualizes app usage data.
- **Permissions Management**: Handles necessary Android permissions (Usage Stats, Overflow, etc.) for robust functionality.
- **Dark/Light Mode**: Full support for system themes.

## Getting Started

### Prerequisites

- Flutter SDK (Latest Stable)
- Android SDK (API 34 support recommended)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/session_lock.git
   ```
2. Navigate to the project directory:
   ```bash
   cd session_lock
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Building for Release

To build the APK for Android:

```bash
flutter build apk --release
```

The output will be located at `build/app/outputs/flutter-apk/app-release.apk`.

## permissions

This app requires several sensitive permissions to function correctly:
- **Usage Access**: To monitor time spent in apps.
- **Display Over Apps**: To show the lock screen over other apps.
- **Notifications**: To show the persistent monitoring service status.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
