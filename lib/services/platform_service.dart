import 'dart:async';
import 'package:flutter/services.dart';
import '../models/app_info.dart';

class PlatformService {
  static const MethodChannel _channel =
      MethodChannel('com.example.session_lock/monitoring');
  static const EventChannel _eventChannel =
      EventChannel('com.example.session_lock/events');

  Stream<String>? _foregroundAppStream;

  // Check if UsageStats permission is granted
  Future<bool> hasUsageStatsPermission() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('checkUsageStatsPermission');
      return result ?? false;
    } catch (e) {
      print('Error checking usage stats permission: $e');
      return false;
    }
  }

  // Request UsageStats permission (opens settings)
  Future<void> requestUsageStatsPermission() async {
    try {
      await _channel.invokeMethod('requestUsageStatsPermission');
    } catch (e) {
      print('Error requesting usage stats permission: $e');
    }
  }

  // Check if overlay permission is granted
  Future<bool> hasOverlayPermission() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('checkOverlayPermission');
      return result ?? false;
    } catch (e) {
      print('Error checking overlay permission: $e');
      return false;
    }
  }

  // Request overlay permission (opens settings)
  Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (e) {
      print('Error requesting overlay permission: $e');
    }
  }

  // Get list of installed apps
  Future<List<AppInfo>> getInstalledApps() async {
    try {
      final result =
          await _channel.invokeMethod<List<dynamic>>('getInstalledApps');
      if (result == null) return [];

      return result.map((app) {
        final appMap = Map<String, dynamic>.from(app as Map);
        return AppInfo(
          packageName: appMap['packageName'] as String,
          appName: appMap['appName'] as String,
          iconBase64: appMap['iconBase64'] as String?,
        );
      }).toList();
    } catch (e) {
      print('Error getting installed apps: $e');
      return [];
    }
  }

  // Get current foreground app package name
  Future<String?> getCurrentForegroundApp() async {
    try {
      final result =
          await _channel.invokeMethod<String>('getCurrentForegroundApp');
      return result;
    } catch (e) {
      print('Error getting foreground app: $e');
      return null;
    }
  }

  // Start monitoring service
  Future<bool> startMonitoringService(List<String> trackedApps) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'startMonitoringService',
        {'trackedApps': trackedApps},
      );
      return result ?? false;
    } catch (e) {
      print('Error starting monitoring service: $e');
      return false;
    }
  }

  // Stop monitoring service
  Future<bool> stopMonitoringService() async {
    try {
      final result = await _channel.invokeMethod<bool>('stopMonitoringService');
      return result ?? false;
    } catch (e) {
      print('Error stopping monitoring service: $e');
      return false;
    }
  }

  // Show blocking screen
  Future<void> showBlockingScreen(int remainingTimeMs) async {
    try {
      await _channel.invokeMethod('showBlockingScreen', {
        'remainingTimeMs': remainingTimeMs,
      });
    } catch (e) {
      print('Error showing blocking screen: $e');
    }
  }

  // Hide blocking screen
  Future<void> hideBlockingScreen() async {
    try {
      await _channel.invokeMethod('hideBlockingScreen');
    } catch (e) {
      print('Error hiding blocking screen: $e');
    }
  }

  // Request ignore battery optimizations
  Future<void> requestIgnoreBatteryOptimizations() async {
    try {
      await _channel.invokeMethod('requestIgnoreBatteryOptimizations');
    } catch (e) {
      print('Error requesting battery optimization: $e');
    }
  }

  // Listen to foreground app changes
  Stream<String> get foregroundAppStream {
    _foregroundAppStream ??=
        _eventChannel.receiveBroadcastStream().map((event) => event as String);
    return _foregroundAppStream!;
  }

  // Check if monitoring service is running
  Future<bool> isMonitoringServiceRunning() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('isMonitoringServiceRunning');
      return result ?? false;
    } catch (e) {
      print('Error checking service status: $e');
      return false;
    }
  }
}
