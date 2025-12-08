import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(initSettings);
    _initialized = true;
  }

  // Show foreground service notification
  Future<void> showMonitoringNotification() async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'monitoring_channel',
      'Session Monitoring',
      channelDescription: 'Monitors your social media usage',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      1,
      'SessionLock Active',
      'Monitoring your social media usage',
      notificationDetails,
    );
  }

  // Update notification with session time
  Future<void> updateMonitoringNotification(String sessionTime) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'monitoring_channel',
      'Session Monitoring',
      channelDescription: 'Monitors your social media usage',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      1,
      'SessionLock Active',
      'Session time: $sessionTime',
      notificationDetails,
    );
  }

  // Cancel monitoring notification
  Future<void> cancelMonitoringNotification() async {
    await _notifications.cancel(1);
  }

  // Show blocking notification
  Future<void> showBlockingNotification(String remainingTime) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'blocking_channel',
      'Session Blocking',
      channelDescription: 'Notifies when apps are blocked',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      2,
      'Break Time',
      'Take a break for $remainingTime',
      notificationDetails,
    );
  }
}
