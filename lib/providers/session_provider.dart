import 'dart:async';
import 'package:flutter/material.dart';
import '../models/session_state.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';
import '../services/platform_service.dart';
import '../services/notification_service.dart';

class SessionProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  final PlatformService _platform = PlatformService();
  final NotificationService _notification = NotificationService();

  SessionState _state = SessionState();
  AppSettings? _settings;
  Timer? _timer;
  StreamSubscription? _foregroundAppSubscription;

  SessionState get state => _state;
  bool get isMonitoring => _settings?.isMonitoring ?? false;

  // Initialize provider
  Future<void> initialize(AppSettings settings) async {
    _settings = settings;
    _state = await _storage.loadSessionState();
    notifyListeners();
  }

  // Start monitoring
  Future<void> startMonitoring(AppSettings settings) async {
    _settings = settings;

    // Start platform monitoring service
    final started =
        await _platform.startMonitoringService(settings.trackedApps);
    if (!started) {
      print('Failed to start monitoring service');
      return;
    }

    // Show notification
    await _notification.showMonitoringNotification();

    // Listen to foreground app changes
    _foregroundAppSubscription = _platform.foregroundAppStream.listen(
      _handleForegroundAppChange,
      onError: (error) => print('Foreground app stream error: $error'),
    );

    // Start internal timer
    _startTimer();
  }

  // Stop monitoring
  Future<void> stopMonitoring() async {
    await _platform.stopMonitoringService();
    await _notification.cancelMonitoringNotification();
    await _platform.hideBlockingScreen();

    _foregroundAppSubscription?.cancel();
    _timer?.cancel();

    _state = SessionState();
    await _storage.saveSessionState(_state);
    notifyListeners();
  }

  // Handle foreground app change from native
  void _handleForegroundAppChange(String packageName) {
    if (_settings == null) return;

    final isTrackedApp = _settings!.trackedApps.contains(packageName);

    if (isTrackedApp) {
      _onTrackedAppEnterForeground(packageName);
    } else {
      _onTrackedAppExitForeground();
    }
  }

  // Tracked app entered foreground
  void _onTrackedAppEnterForeground(String packageName) {
    if (_settings == null) return;

    // If blocked, show blocking screen immediately
    if (_state.isBlocked) {
      final remainingBreakTime =
          _settings!.breakDurationMs - _state.inactivityTime;
      _platform.showBlockingScreen(remainingBreakTime);
      return;
    }

    // If inactivity >= break duration, reset session
    if (_state.inactivityTime >= _settings!.breakDurationMs) {
      _state = _state.copyWith(
        sessionTime: 0,
        inactivityTime: 0,
        isBlocked: false,
      );
    }

    // Start/resume session
    _state = _state.copyWith(
      isSessionActive: true,
      currentApp: packageName,
      inactivityTime: 0,
    );

    _storage.saveSessionState(_state);
    notifyListeners();
  }

  // Tracked app exited foreground
  void _onTrackedAppExitForeground() {
    _state = _state.copyWith(
      isSessionActive: false,
      currentApp: null,
    );

    _storage.saveSessionState(_state);
    notifyListeners();
  }

  // Internal timer (updates every second)
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimers();
    });
  }

  // Update timers
  void _updateTimers() {
    if (_settings == null) return;

    if (_state.isSessionActive) {
      // Increment session time
      final newSessionTime = _state.sessionTime + 1000;
      _state = _state.copyWith(
        sessionTime: newSessionTime,
        inactivityTime: 0,
      );

      // Check if session limit exceeded
      if (newSessionTime >= _settings!.sessionDurationMs && !_state.isBlocked) {
        _state = _state.copyWith(isBlocked: true);
        _platform.showBlockingScreen(_settings!.breakDurationMs);
        _notification
            .showBlockingNotification(_settings!.breakDuration.toString());
      }

      // Update notification
      _notification.updateMonitoringNotification(_state.formattedSessionTime);
    } else {
      // Increment inactivity time
      final newInactivityTime = _state.inactivityTime + 1000;
      _state = _state.copyWith(inactivityTime: newInactivityTime);

      // Check if inactivity >= break duration
      if (newInactivityTime >= _settings!.breakDurationMs) {
        if (_state.isBlocked) {
          // Unblock and reset
          _state = _state.copyWith(
            sessionTime: 0,
            isBlocked: false,
          );
          _platform.hideBlockingScreen();
        }
      }
    }

    _storage.saveSessionState(_state);
    notifyListeners();
  }

  // Manual reset
  Future<void> resetSession() async {
    _state = SessionState();
    await _storage.saveSessionState(_state);
    await _platform.hideBlockingScreen();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _foregroundAppSubscription?.cancel();
    super.dispose();
  }
}
