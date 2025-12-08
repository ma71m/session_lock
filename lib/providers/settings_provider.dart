import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

class SettingsProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  AppSettings _settings = AppSettings();

  AppSettings get settings => _settings;

  // Initialize and load settings
  Future<void> initialize() async {
    _settings = await _storage.loadSettings();
    notifyListeners();
  }

  // Update session duration
  Future<void> setSessionDuration(int minutes) async {
    _settings = _settings.copyWith(sessionDuration: minutes);
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  // Update break duration
  Future<void> setBreakDuration(int minutes) async {
    _settings = _settings.copyWith(breakDuration: minutes);
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  // Update tracked apps
  Future<void> setTrackedApps(List<String> apps) async {
    _settings = _settings.copyWith(trackedApps: apps);
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  // Add tracked app
  Future<void> addTrackedApp(String packageName) async {
    final apps = List<String>.from(_settings.trackedApps);
    if (!apps.contains(packageName)) {
      apps.add(packageName);
      await setTrackedApps(apps);
    }
  }

  // Remove tracked app
  Future<void> removeTrackedApp(String packageName) async {
    final apps = List<String>.from(_settings.trackedApps);
    apps.remove(packageName);
    await setTrackedApps(apps);
  }

  // Toggle strict mode
  Future<void> toggleStrictMode() async {
    _settings = _settings.copyWith(strictMode: !_settings.strictMode);
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  // Toggle emergency bypass
  Future<void> toggleEmergencyBypass() async {
    _settings = _settings.copyWith(
      allowEmergencyBypass: !_settings.allowEmergencyBypass,
    );
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  // Set monitoring status
  Future<void> setMonitoring(bool isMonitoring) async {
    _settings = _settings.copyWith(isMonitoring: isMonitoring);
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  // Apply preset (sessionMin/breakMin)
  Future<void> applyPreset(int sessionMin, int breakMin) async {
    _settings = _settings.copyWith(
      sessionDuration: sessionMin,
      breakDuration: breakMin,
    );
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  // Check if app is tracked
  bool isAppTracked(String packageName) {
    return _settings.trackedApps.contains(packageName);
  }
}
