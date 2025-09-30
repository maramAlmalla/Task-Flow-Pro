import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Service responsible for handling local notifications
class NotificationsService {
  static final NotificationsService _instance = NotificationsService._internal();
  factory NotificationsService() => _instance;
  NotificationsService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notifications service
  Future<void> init() async {
    if (kIsWeb) {
      print('Notifications are not supported on web platform');
      return;
    }

    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Set local timezone
      final timeZoneName = await _getTimeZoneName();
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      // Android initialization settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Combined initialization settings
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize the plugin
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create notification channel for Android
      if (!kIsWeb && Platform.isAndroid) {
        await _createNotificationChannel();
      }

      _isInitialized = true;
      print('Notifications service initialized successfully');
    } catch (e) {
      print('Error initializing notifications service: $e');
    }
  }

  Future<String> _getTimeZoneName() async {
    // Simplified: always returns UTC; replace with proper detection if needed
    return 'UTC';
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'todo_reminders',
      'Todo Reminders',
      description: 'Notifications for task reminders and due dates',
      importance: Importance.high,
      playSound: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      print('Notification tapped with payload: $payload');
      // هنا يمكن التعامل مع التنقل داخل التطبيق حسب payload
    }
  }

  /// Schedule a notification at a specific date & time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (kIsWeb || !_isInitialized) {
      print('Skipping notification scheduling (Web platform or not initialized)');
      return;
    }

    try {
      final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(scheduledDate, tz.local);

      if (scheduledTZDate.isBefore(tz.TZDateTime.now(tz.local))) {
        print('Cannot schedule notification in the past');
        return;
      }

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'todo_reminders',
        'Todo Reminders',
        channelDescription: 'Notifications for task reminders and due dates',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // إلزامي بالإصدار الجديد
        payload: payload,
      );

      print('Notification scheduled successfully for $scheduledTZDate');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  /// Show an immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb || !_isInitialized) return;

    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'todo_reminders',
        'Todo Reminders',
        channelDescription: 'Notifications for task reminders and due dates',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      print('Immediate notification shown successfully');
    } catch (e) {
      print('Error showing immediate notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    if (kIsWeb || !_isInitialized) return;

    try {
      await _notificationsPlugin.cancel(id);
      print('Notification $id cancelled successfully');
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    if (kIsWeb || !_isInitialized) return;

    try {
      await _notificationsPlugin.cancelAll();
      print('All notifications cancelled successfully');
    } catch (e) {
      print('Error cancelling all notifications: $e');
    }
  }

  /// Request notification permissions (iOS only)
  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    try {
      final result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      return result ?? false;
    } catch (e) {
      print('Error requesting notification permissions: $e');
      return false;
    }
  }
}
