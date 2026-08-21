import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:odomex/core/notifications/notification_constants.dart';

/// Callback signature for handling tapped notifications with payload.
typedef NotificationTapCallback = void Function(String? payload);

/// A centralized, reusable service for managing local notifications.
///
/// Encapsulates package-specific configuration, permission requests,
/// channel initialization, and notification dispatching.
class NotificationService {
  NotificationService._({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static final NotificationService instance = NotificationService._();

  @visibleForTesting
  static NotificationService withCustomPlugin(
    FlutterLocalNotificationsPlugin plugin,
  ) {
    return NotificationService._(plugin: plugin);
  }

  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

  /// Optional listener for notification tap events.
  NotificationTapCallback? onNotificationTapped;

  /// Whether the notification plugin has been successfully initialized.
  bool get isInitialized => _isInitialized;

  /// Initializes the local notification plugin and configures the default Android channel.
  ///
  /// Safe to call during app startup; permissions are not requested here.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const androidSettings = AndroidInitializationSettings(
        NotificationConstants.androidNotificationIcon,
      );

      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      // Setup default Android notification channel
      await _createNotificationChannel();

      _isInitialized = true;
    } catch (e, st) {
      debugPrint('NotificationService: Failed to initialize ($e)\n$st');
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('NotificationService: Notification tapped (payload: ${response.payload})');
    onNotificationTapped?.call(response.payload);
  }

  /// Creates the primary Android notification channel.
  Future<void> _createNotificationChannel() async {
    try {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        const channel = AndroidNotificationChannel(
          NotificationConstants.remindersChannelId,
          NotificationConstants.remindersChannelName,
          description: NotificationConstants.remindersChannelDescription,
          importance: Importance.high,
          showBadge: true,
        );

        await androidPlugin.createNotificationChannel(channel);
      }
    } catch (e) {
      debugPrint('NotificationService: Failed to create notification channel: $e');
    }
  }

  /// Requests runtime notification permission from the operating system (Android 13+ and iOS).
  ///
  /// Returns `true` if permission is granted, `false` otherwise.
  Future<bool> requestPermission() async {
    try {
      // 1. Android runtime permission (API 33+)
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }

      // 2. iOS permission
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      // 3. macOS permission
      final macPlugin = _plugin.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>();
      if (macPlugin != null) {
        final granted = await macPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }

      return true;
    } catch (e, st) {
      debugPrint('NotificationService: Error requesting permission ($e)\n$st');
      return false;
    }
  }

  /// Checks whether notifications are enabled at the platform/OS level.
  Future<bool> areNotificationsEnabled() async {
    try {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final enabled = await androidPlugin.areNotificationsEnabled();
        return enabled ?? false;
      }

      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (iosPlugin != null) {
        final settings = await iosPlugin.checkPermissions();
        return settings?.isEnabled ?? false;
      }

      return true;
    } catch (e) {
      debugPrint('NotificationService: Error checking permission status: $e');
      return false;
    }
  }

  /// Shows an immediate local notification.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = NotificationConstants.remindersChannelId,
    String channelName = NotificationConstants.remindersChannelName,
    String channelDescription = NotificationConstants.remindersChannelDescription,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: importance,
        priority: priority,
        icon: NotificationConstants.androidNotificationIcon,
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
    } catch (e, st) {
      debugPrint('NotificationService: Failed to show notification ($e)\n$st');
    }
  }

  /// Displays the predefined Odomex Test Notification.
  Future<void> showTestNotification() async {
    await showNotification(
      id: NotificationConstants.testNotificationId,
      title: 'Odomex Test Notification',
      body: 'Notifications are working correctly.',
      payload: NotificationConstants.payloadTypeTest,
    );
  }

  /// Cancels a specific notification by [id].
  Future<void> cancel(int id) async {
    try {
      await _plugin.cancel(id: id);
    } catch (e) {
      debugPrint('NotificationService: Failed to cancel notification $id: $e');
    }
  }

  /// Cancels all pending and displayed notifications.
  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('NotificationService: Failed to cancel all notifications: $e');
    }
  }
}
