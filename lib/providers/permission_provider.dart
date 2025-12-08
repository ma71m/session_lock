import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/platform_service.dart';

class PermissionProvider with ChangeNotifier {
  final PlatformService _platform = PlatformService();

  bool _hasUsageStats = false;
  bool _hasOverlay = false;
  bool _hasNotification = false;
  bool _hasBatteryOptimization = false;

  bool get hasUsageStats => _hasUsageStats;
  bool get hasOverlay => _hasOverlay;
  bool get hasNotification => _hasNotification;
  bool get hasBatteryOptimization => _hasBatteryOptimization;
  bool get allPermissionsGranted =>
      _hasUsageStats && _hasOverlay && _hasNotification;

  // Check all permissions
  Future<void> checkPermissions() async {
    _hasUsageStats = await _platform.hasUsageStatsPermission();
    _hasOverlay = await _platform.hasOverlayPermission();
    _hasNotification = await Permission.notification.isGranted;
    _hasBatteryOptimization =
        await Permission.ignoreBatteryOptimizations.isGranted;
    notifyListeners();
  }

  // Request usage stats permission
  Future<void> requestUsageStats() async {
    await _platform.requestUsageStatsPermission();
    // Wait a bit for user to grant permission
    await Future.delayed(const Duration(seconds: 1));
    await checkPermissions();
  }

  // Request overlay permission
  Future<void> requestOverlay() async {
    await _platform.requestOverlayPermission();
    await Future.delayed(const Duration(seconds: 1));
    await checkPermissions();
  }

  // Request notification permission
  Future<void> requestNotification() async {
    await Permission.notification.request();
    await checkPermissions();
  }

  // Request battery optimization exemption
  Future<void> requestBatteryOptimization() async {
    await _platform.requestIgnoreBatteryOptimizations();
    await Future.delayed(const Duration(seconds: 1));
    await checkPermissions();
  }
}
