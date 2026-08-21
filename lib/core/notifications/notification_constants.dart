import 'package:flutter/material.dart';

/// Centralized constants for local notification channels, IDs, and payload types.
///
/// Keeps notification configuration consistent and prevents magic strings across the app.
class NotificationConstants {
  NotificationConstants._();

  // ── Channels ──────────────────────────────────────────────
  /// General reminders and alerts channel ID.
  static const String remindersChannelId = 'odomex_reminders';

  /// Human-readable channel name shown in Android system notification settings.
  static const String remindersChannelName = 'Odomex Notifications';

  /// Channel description shown in Android system notification settings.
  static const String remindersChannelDescription =
      'Vehicle reminders and updates from Odomex';

  // ── Notification IDs ──────────────────────────────────────
  /// Predefined notification ID for the test notification.
  static const int testNotificationId = 1000;

  /// Dedicated notification ID for the daily activity reminder.
  static const int dailyActivityNotificationId = 1100;

  /// Reserved base ID range for future scheduled reminders:
  /// Service reminders: 2000+
  /// Oil change reminders: 3000+
  /// Insurance expiry reminders: 4000+
  /// PUC expiry reminders: 5000+
  static const int serviceReminderIdBase = 2000;
  static const int oilChangeReminderIdBase = 3000;
  static const int insuranceReminderIdBase = 4000;
  static const int pucReminderIdBase = 5000;

  // ── Daily Activity Defaults & Content ─────────────────────
  static const int defaultDailyActivityHour = 20;
  static const int defaultDailyActivityMinute = 0;
  static const TimeOfDay defaultDailyActivityTime =
      TimeOfDay(hour: defaultDailyActivityHour, minute: defaultDailyActivityMinute);

  static const String dailyActivityTitle = 'Odomex';
  static const String dailyActivityBody =
      "Don't forget to record today's vehicle activity.";

  // ── Icons & Drawables ─────────────────────────────────────
  /// Monochrome notification icon defined in android/app/src/main/res/drawable/ic_notification.xml.
  static const String androidNotificationIcon = '@drawable/ic_notification';

  // ── Payloads ──────────────────────────────────────────────
  static const String payloadKeyType = 'type';
  static const String payloadKeyVehicleId = 'vehicle_id';
  static const String payloadKeyAction = 'action';

  static const String payloadTypeTest = 'test_notification';
  static const String payloadTypeDailyActivity = 'daily_activity';
}
