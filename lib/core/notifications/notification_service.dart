import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:odomex/core/notifications/notification_constants.dart';
import 'package:odomex/features/settings/models/notification_permission_state.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Callback signature for handling tapped notifications with payload.
typedef NotificationTapCallback = void Function(String? payload);

/// A centralized, reusable service for managing local notifications and scheduling.
///
/// Encapsulates package-specific configuration, permission requests,
/// channel initialization, and timezone-aware notification dispatching/scheduling.
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
  String _localTimeZoneName = 'UTC';

  /// Optional listener for notification tap events.
  NotificationTapCallback? onNotificationTapped;

  /// Whether the notification plugin has been successfully initialized.
  bool get isInitialized => _isInitialized;

  /// The active local timezone name.
  String get localTimeZoneName => _localTimeZoneName;

  /// Initializes the local notification plugin, device timezone, and default Android channel.
  ///
  /// Safe to call during app startup; permissions are not requested here.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Configure device local timezone
      await _configureLocalTimeZone();

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

      // 2. Setup default Android notification channel
      await _createNotificationChannel();

      _isInitialized = true;
      debugPrint('[Notifications] Initialized: YES (Timezone: $_localTimeZoneName)');
    } catch (e, st) {
      debugPrint('[Notifications] Failed to initialize: $e\n$st');
    }
  }

  /// Configures timezone data and sets the device local location.
  Future<void> _configureLocalTimeZone() async {
    try {
      tz.initializeTimeZones();
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = timezoneInfo.identifier;
      _localTimeZoneName = timeZoneName;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('[Notifications] FlutterTimezone error ($e). Using fallback.');
      try {
        _localTimeZoneName = DateTime.now().timeZoneName;
      } catch (_) {}
    }
  }

  void _onNotificationResponse(NotificationResponse response) {
    debugPrint(
        '[Notifications] Notification tapped (payload: ${response.payload})');
    onNotificationTapped?.call(response.payload);
  }

  /// Creates the primary Android notification channel.
  Future<void> _createNotificationChannel() async {
    try {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // Clean up legacy channel to avoid duplicates and ensure the new icon/importance applies.
        await androidPlugin.deleteNotificationChannel(
            channelId: NotificationConstants.legacyRemindersChannelId);

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
      debugPrint(
          '[Notifications] Failed to create notification channel: $e');
    }
  }

  /// Requests runtime notification permission from the operating system (Android 13+ and iOS).
  ///
  /// Requests notification permission ONLY without triggering exact alarm system intent.
  /// Returns `true` if permission is granted, `false` otherwise.
  Future<bool> requestPermission() async {
    try {
      // 1. Android runtime permission (API 33+)
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final notifGranted = await androidPlugin.requestNotificationsPermission();
        final isGranted = notifGranted ?? false;
        debugPrint('[Notifications] OS permission request result: ${isGranted ? "GRANTED" : "DENIED"}');
        return isGranted;
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
      debugPrint('[Notifications] Error requesting permission ($e)\n$st');
      return false;
    }
  }

  /// Checks the current OS-level notification permission and exact alarm capability.
  ///
  /// On Android 12+ (API 31+), `SCHEDULE_EXACT_ALARM` requires explicit user approval
  /// from Settings → Special App Access → Alarms & Reminders. This method queries
  /// the real OS state rather than assuming it is granted.
  Future<NotificationPermissionState> checkPermissions() async {
    final notificationGranted = await areNotificationsEnabled();
    final exactAlarmGranted = await _canScheduleExactAlarms();
    return NotificationPermissionState(
      notificationGranted: notificationGranted,
      exactAlarmGranted: exactAlarmGranted,
    );
  }

  /// Checks whether exact alarms can be scheduled on this device.
  ///
  /// Returns `true` on Android versions below API 31, on iOS/macOS, and when the
  /// `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` permission has been explicitly granted.
  Future<bool> _canScheduleExactAlarms() async {
    try {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final canSchedule = await androidPlugin.canScheduleExactNotifications();
        return canSchedule ?? true;
      }
      // iOS/macOS/desktop — exact alarms not applicable; return true.
      return true;
    } catch (e) {
      debugPrint('[Notifications] Could not check exact alarm capability: $e. Assuming granted.');
      return true;
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
      debugPrint('[Notifications] Error checking permission status: $e');
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
    String channelDescription =
        NotificationConstants.remindersChannelDescription,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    if (!_isInitialized) await initialize();

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
      debugPrint('[Notifications] Immediate notification shown: id=$id, title="$title"');
    } catch (e, st) {
      debugPrint('[Notifications] Failed to show notification ($e)\n$st');
    }
  }

  /// Schedules a one-time notification at a specific [scheduledDate].
  ///
  /// Prefers exact alarms (`exactAllowWhileIdle`). If the OS denies exact alarm
  /// scheduling (Android 12+ permission not granted), automatically falls back to
  /// an inexact alarm (`inexactAllowWhileIdle`), which fires approximately on time.
  Future<void> scheduleNotificationAt({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
    String channelId = NotificationConstants.remindersChannelId,
    String channelName = NotificationConstants.remindersChannelName,
    String channelDescription =
        NotificationConstants.remindersChannelDescription,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    if (!_isInitialized) await initialize();

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

      await _scheduleWithFallback(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        details: details,
        payload: payload,
      );

      debugPrint('[Notifications] Scheduled notification at specific time:');
      debugPrint('[Notifications] Notification ID: $id');
      debugPrint('[Notifications] Next scheduled time: $scheduledDate');
      debugPrint('[Notifications] Scheduling result: SUCCESS');
    } catch (e, st) {
      debugPrint('[Notifications] Failed to schedule notification ($e)\n$st');
    }
  }

  /// Schedules a daily recurring notification at the specified local [hour] and [minute].
  ///
  /// Prefers exact alarms; automatically falls back to inexact if not available.
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
    String channelId = NotificationConstants.remindersChannelId,
    String channelName = NotificationConstants.remindersChannelName,
    String channelDescription =
        NotificationConstants.remindersChannelDescription,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    if (!_isInitialized) await initialize();

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

      final scheduledDate = _nextInstanceOfTime(hour, minute);

      await _scheduleWithFallback(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        details: details,
        payload: payload,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('[Notifications] Daily Activity notification scheduled:');
      debugPrint('[Notifications] Configured time: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}');
      debugPrint('[Notifications] Current time: ${tz.TZDateTime.now(tz.local)}');
      debugPrint('[Notifications] Next scheduled time: $scheduledDate');
      debugPrint('[Notifications] Notification ID: $id');
      debugPrint('[Notifications] Scheduling result: SUCCESS');
    } catch (e, st) {
      debugPrint(
          '[Notifications] Failed to schedule daily notification ($e)\n$st');
    }
  }

  /// Internal helper: schedules with exact alarm first; falls back to inexact on PlatformException.
  Future<void> _scheduleWithFallback({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails details,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: matchDateTimeComponents,
        payload: payload,
      );
      debugPrint('[Notifications] Scheduled with EXACT alarm mode (id=$id)');
    } on PlatformException catch (e) {
      // Android 12+ throws PlatformException when SCHEDULE_EXACT_ALARM is not granted.
      // Fall back to inexact which fires approximately at the right time (±15 min).
      debugPrint('[Notifications] Exact alarm denied (${e.message}). Falling back to inexact alarm for id=$id');
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: matchDateTimeComponents,
        payload: payload,
      );
      debugPrint('[Notifications] Scheduled with INEXACT alarm mode (id=$id)');
    }
  }

  /// Calculates the next occurrence of [hour] and [minute] in the device's local timezone.
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now) || scheduledDate.isAtSameMomentAs(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Synchronizes the daily activity reminder schedule based on preferences and OS permission.
  ///
  /// Automatically cancels any previous schedule before recreating to prevent duplicates.
  Future<void> syncDailyActivitySchedule({
    required bool masterEnabled,
    required bool dailyActivityEnabled,
    required int hour,
    required int minute,
  }) async {
    if (!_isInitialized) await initialize();

    // Guard against corrupt/invalid values
    final safeHour = (hour >= 0 && hour <= 23) ? hour : 20;
    final safeMinute = (minute >= 0 && minute <= 59) ? minute : 0;

    debugPrint('[Notifications] syncDailyActivitySchedule: masterEnabled=$masterEnabled, dailyActivityEnabled=$dailyActivityEnabled, time=${safeHour.toString().padLeft(2, '0')}:${safeMinute.toString().padLeft(2, '0')}');

    if (masterEnabled && dailyActivityEnabled) {
      final hasPermission = await areNotificationsEnabled();
      debugPrint('[Notifications] OS permission status: ${hasPermission ? "GRANTED" : "DENIED"}');
      if (hasPermission) {
        debugPrint('[Notifications] Cancelling previous Daily Activity notification before rescheduling');
        await cancel(NotificationConstants.dailyActivityNotificationId);
        await scheduleDailyNotification(
          id: NotificationConstants.dailyActivityNotificationId,
          title: NotificationConstants.dailyActivityTitle,
          body: NotificationConstants.dailyActivityBody,
          hour: safeHour,
          minute: safeMinute,
          payload: NotificationConstants.payloadTypeDailyActivity,
        );
        return;
      }
    }

    debugPrint('[Notifications] Daily Activity disabled or permission denied. Cancelling schedule.');
    await cancel(NotificationConstants.dailyActivityNotificationId);
  }

  /// Development helper to schedule a test reminder [minutesFromNow] in the future.
  ///
  /// Uses the real OS scheduling mechanism without waiting for the daily clock time.
  Future<bool> scheduleDevTestReminder({int minutesFromNow = 2}) async {
    if (!_isInitialized) await initialize();

    final hasPermission = await areNotificationsEnabled();
    if (!hasPermission) {
      debugPrint('[Notifications] Dev test reminder failed: OS permission denied');
      return false;
    }

    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = now.add(Duration(minutes: minutesFromNow));

    debugPrint('[Notifications] Scheduling DEV test reminder for $scheduledDate');

    await cancel(NotificationConstants.dailyActivityNotificationId);
    await scheduleNotificationAt(
      id: NotificationConstants.dailyActivityNotificationId,
      title: NotificationConstants.dailyActivityTitle,
      body: NotificationConstants.dailyActivityBody,
      scheduledDate: scheduledDate,
      payload: NotificationConstants.payloadTypeDailyActivity,
    );

    return true;
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
    if (!_isInitialized) return;

    try {
      await _plugin.cancel(id: id);
      debugPrint('[Notifications] Cancelled notification: id=$id');
    } catch (e) {
      debugPrint('[Notifications] Failed to cancel notification $id: $e');
    }
  }

  /// Cancels all pending and displayed notifications.
  Future<void> cancelAll() async {
    if (!_isInitialized) return;

    try {
      await _plugin.cancelAll();
      debugPrint('[Notifications] Cancelled all notifications');
    } catch (e) {
      debugPrint('[Notifications] Failed to cancel all notifications: $e');
    }
  }
}
