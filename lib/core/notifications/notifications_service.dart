import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Service responsible for handling local notifications
/// This service is guarded for web platform and provides notification scheduling
/// for task reminders and due dates
class NotificationsService {
  static final NotificationsService _instance = NotificationsService._internal();
  factory NotificationsService() => _instance;
  NotificationsService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notifications service
  /// Sets up notification channels and timezone data
  /// Skipped on web platform as notifications are not supported
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
      const DarwinInitializationSettings iosSettings = 
          DarwinInitializationSettings(
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

  /// Get the device timezone name
  /// Returns UTC as fallback if unable to determine
  Future<String> _getTimeZoneName() async {
    try {
      // For production, you might want to use a more robust timezone detection
      return 'UTC'; // Simplified for this example
    } catch (e) {
      return 'UTC';
    }
  }

  /// Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'todo_reminders',
      'Todo Reminders',
      description: 'Notifications for task reminders and due dates',
      importance: Importance.high,
      playSound: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Handle notification tap events
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      print('Notification tapped with payload: $payload');
      // Handle navigation to specific task or page based on payload
      // This would typically involve navigation service or global navigator
    }
  }

  /// Schedule a notification for a specific date and time
  /// [id] - Unique notification ID
  /// [title] - Notification title
  /// [body] - Notification body text
  /// [scheduledDate] - When to show the notification
  /// [payload] - Optional data to pass when notification is tapped
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
      final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );

      // Check if the scheduled date is in the future
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
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
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
    if (kIsWeb || !_isInitialized) {
      print('Skipping immediate notification (Web platform or not initialized)');
      return;
    }

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

  /// Cancel a scheduled notification
  Future<void> cancelNotification(int id) async {
    if (kIsWeb || !_isInitialized) {
      return;
    }

    try {
      await _notificationsPlugin.cancel(id);
      print('Notification $id cancelled successfully');
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications() async {
    if (kIsWeb || !_isInitialized) {
      return;
    }

    try {
      await _notificationsPlugin.cancelAll();
      print('All notifications cancelled successfully');
    } catch (e) {
      print('Error cancelling all notifications: $e');
    }
  }

  /// Request notification permissions (iOS)
  Future<bool> requestPermissions() async {
    if (kIsWeb) {
      return false;
    }

    try {
      final result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
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