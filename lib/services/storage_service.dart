import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/session_state.dart';
import '../models/session_history.dart';

class StorageService {
  static const String _keySettings = 'app_settings';
  static const String _keySessionState = 'session_state';
  static const String _keyHistory = 'session_history';
  static const String _keyOnboardingComplete = 'onboarding_complete';

  // Save settings
  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySettings, jsonEncode(settings.toJson()));
  }

  // Load settings
  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keySettings);
    if (jsonString == null) {
      return AppSettings(); // Return default settings
    }
    return AppSettings.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  // Save session state
  Future<void> saveSessionState(SessionState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySessionState, jsonEncode(state.toJson()));
  }

  // Load session state
  Future<SessionState> loadSessionState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keySessionState);
    if (jsonString == null) {
      return SessionState(); // Return default state
    }
    return SessionState.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>);
  }

  // Save history
  Future<void> saveHistory(List<SessionHistory> history) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = history.map((h) => h.toJson()).toList();
    await prefs.setString(_keyHistory, jsonEncode(jsonList));
  }

  // Load history
  Future<List<SessionHistory>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyHistory);
    if (jsonString == null) {
      return [];
    }
    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => SessionHistory.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // Onboarding status
  Future<void> setOnboardingComplete(bool complete) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingComplete, complete);
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  // Clear all data
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
