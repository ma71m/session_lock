# SessionLock

**SessionLock** is a Flutter app that helps users manage screen time and reduce distractions by monitoring app usage and enforcing focused sessions. It tracks foreground apps, shows usage statistics, and blocks access to chosen apps during locked sessions — helping users build healthier device habits.

---

## Table of contents

* [Features](#features)
* [How it works](#how-it-works)
* [Permissions required](#permissions-required)
* [Install & run (developer)](#install--run-developer)
* [Configuration & usage](#configuration--usage)
* [Architecture & recommended packages](#architecture--recommended-packages)
* [Testing tips](#testing-tips)
* [Troubleshooting](#troubleshooting)
* [Contributing](#contributing)
* [License & contact](#license--contact)

---

## Features

* **App monitoring** — tracks foreground app usage and session length.
* **Session locking** — rigorous enforcement that blocks selected apps during focus periods (fullscreen overlay / blocking UI).
* **Usage statistics** — visual charts and summaries of app time.
* **Permissions management** — guides the user to grant Android permissions (Usage Access, Draw over other apps / overlay, notifications).
* **Theme support** — follows system dark / light mode.
* **Extensible** — designed to let you add rules, schedules and rewards.

---

## How it works (high level)

1. The app uses Android **Usage Stats** to detect which app is currently in the foreground.
2. When the user starts a focus session, SessionLock compares the foreground app to the blocked list.
3. If a blocked app comes to the foreground during a session, the app displays a fullscreen overlay (or lock screen) to prevent interaction with that app until the session ends.
4. Usage data is recorded locally and shown in charts on the dashboard.

> Note: Android does not allow silent force-kill of other apps; blocking is implemented via overlay / UI control and notifications to guide the user back to the session.

---

## Permissions required (Android)

To work correctly the app needs a few special Android permissions. The README should explain why and how to enable them:

* `android.permission.PACKAGE_USAGE_STATS` (Usage Access)

  * Required to read which app is in the foreground and collect usage stats.
  * The user must enable it in **Settings → Usage Access** for SessionLock. You can open that settings screen programmatically.

* `SYSTEM_ALERT_WINDOW` (Draw over other apps / overlay)

  * Required to show a blocking overlay above other apps during an active session.

* Notification permission

  * To send session start/stop and reminder notifications.

**Example: open Usage Access settings (Flutter using `android_intent_plus`)**

```dart
import 'package:android_intent_plus/android_intent.dart';

// Open usage access settings
final intent = AndroidIntent(
  action: 'android.settings.USAGE_ACCESS_SETTINGS',
);
await intent.launch();
```

---

## Install & run (developer)

1. Clone the repo:

```bash
git clone https://github.com/<your-username>/sessionlock.git
cd sessionlock
```

2. Get packages:

```bash
flutter pub get
```

3. Run on device (an Android device/emulator is required for Usage Stats and overlay testing):

```bash
flutter run
```

4. Build release APK:

```bash
flutter build apk --release
```

---

## Configuration & usage

* **Add / remove monitored apps** — from the app settings screen, select which apps you want to monitor or block.
* **Start a session** — choose duration and optionally a whitelist; SessionLock will begin enforcing the lock.
* **View stats** — daily / weekly summaries and charts show time spent per app and session history.

Consider adding user preferences (shared preferences / local DB) to store:

* blocked apps list
* session rules and schedules
* accumulated rewards or streaks

---

## Architecture & recommended packages

A suggested modular architecture:

* `presentation` — Flutter UI (screens, widgets)
* `domain` — business logic (session rules, enforcement state)
* `data` — platform integration (usage stats, local DB)

Useful packages you may already use or want to adopt:

* `permission_handler` — runtime permission helpers
* `android_intent_plus` — to open Android settings screens
* `shared_preferences` or `hive` — local storage
* `provider` / `riverpod` — state management
* `flutter_local_notifications` — local notifications
* (Platform plugin) a plugin to read usage stats (e.g. `usage_stats`, `app_usage`, or a custom platform channel if needed)

> If you already have a platform implementation, document which plugin and native code files implement UsageStats and overlay handling.

---

## Testing tips

* Use a physical Android device when testing overlay and usage access — emulators can behave differently with special permissions.
* Turn on developer options and ensure the app is not battery-optimized to avoid the system killing background tasks during tests.
* Test with popular social apps (Facebook, Instagram, TikTok, WhatsApp) to confirm detection and overlay behavior.

---

## Troubleshooting

* **Usage stats not detected** — verify `Usage Access` is enabled for the app in Settings.
* **Overlay not showing** — check Draw-over-other-apps permission and that your overlay activity/service is running.
* **App closes unexpectedly** — check logs (`flutter logs` / `adb logcat`) for permission / exception traces.

---

## Contributing

Contributions, bug reports and feature ideas are welcome!

1. Fork the repo
2. Create a feature branch (`git checkout -b feat/my-feature`)
3. Commit changes and open a PR with a clear description and screenshots where relevant

Please add tests for new features and keep commits small and focused.

---

## License

Specify a license (e.g., MIT). Example:

```
MIT License
Copyright (c) 2025 <Your Name>
```

---

## Contact

If you want help integrating SessionLock into your project or need feature work: open an issue.

---

### Final notes

* Add screenshots/GIFs to this README to help users understand the lock UI and analytics view.
* In the repo, add a `docs/` folder for design notes and native Android code documentation (manifest entries, services, receivers).

---
