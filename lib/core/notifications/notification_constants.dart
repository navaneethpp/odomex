import 'package:flutter/material.dart';

/// Centralized constants for local notification channels, IDs, and payload types.
///
/// Keeps notification configuration consistent and prevents magic strings across the app.
class NotificationConstants {
  NotificationConstants._();

  // ── Channels ──────────────────────────────────────────────
  /// General reminders and alerts channel ID.
  static const String remindersChannelId = 'odomex_reminders_v2';
  
  /// Legacy channel ID for migration/cleanup.
  static const String legacyRemindersChannelId = 'odomex_reminders';

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

  /// Base notification ID for PUC expiry reminders (one ID per vehicle: base + vehicleHash).
  static const int pucReminderIdBase = 100000;

  /// Base notification ID for insurance expiry reminders.
  static const int insuranceReminderIdBase = 200000;

  /// Base notification ID for service due reminders.
  static const int serviceReminderIdBase = 300000;

  /// Base notification ID for oil change due reminders.
  static const int oilChangeReminderIdBase = 400000;

  // ── Legacy Notification ID Bases (for migration cleanup) ───
  /// @deprecated Old base IDs used before the hash-space expansion.
  /// Retained solely to cancel orphaned notifications from the old scheme.
  static const int legacyPucReminderIdBase = 2000;
  static const int legacyInsuranceReminderIdBase = 3000;
  static const int legacyServiceReminderIdBase = 4000;
  static const int legacyOilChangeReminderIdBase = 5000;

  // ── Daily Activity Defaults & Content ─────────────────────
  static const int defaultDailyActivityHour = 20;
  static const int defaultDailyActivityMinute = 0;
  static const TimeOfDay defaultDailyActivityTime =
      TimeOfDay(hour: defaultDailyActivityHour, minute: defaultDailyActivityMinute);

  static const String dailyActivityTitle = 'Odomex';
  static const String dailyActivityBody =
      "Don't forget to record today's vehicle activity.";

  // ── PUC Reminder Content ───────────────────────────────────
  static const String pucReminderTitle = 'PUC Expiry Reminder';

  /// Returns a PUC reminder body for a named vehicle.
  static String pucReminderBody(String vehicleName, int daysLeft) {
    if (daysLeft <= 0) {
      return '$vehicleName PUC certificate has expired. Renew it to stay road-legal.';
    }
    return '$vehicleName PUC certificate expires in $daysLeft day${daysLeft == 1 ? "" : "s"}. Time to renew.';
  }

  // ── Insurance Reminder Content ─────────────────────────────
  static const String insuranceReminderTitle = 'Insurance Expiry Reminder';

  /// Returns an insurance reminder body for a named vehicle.
  static String insuranceReminderBody(String vehicleName, int daysLeft) {
    if (daysLeft <= 0) {
      return '$vehicleName insurance has expired. Renew to stay protected.';
    }
    return '$vehicleName insurance expires in $daysLeft day${daysLeft == 1 ? "" : "s"}. Consider renewing soon.';
  }

  // ── Service Due Reminder Content ───────────────────────────
  static const String serviceReminderTitle = 'Service Due';

  /// Returns a service due reminder body for a named vehicle.
  static String serviceReminderBody(String vehicleName) {
    return '$vehicleName is approaching its next scheduled service. Book a service appointment.';
  }

  // ── Oil Change Reminder Content ────────────────────────────
  static const String oilChangeReminderTitle = 'Oil Change Due';

  /// Returns an oil change reminder body for a named vehicle.
  static String oilChangeReminderBody(String vehicleName) {
    return '$vehicleName is due for an oil change. Keep the engine running smoothly.';
  }

  // ── Icons & Drawables ─────────────────────────────────────
  /// Name of the Android drawable resource used for the status bar icon.
  /// Must be just the name, without '@drawable/' or extensions.
  static const String androidNotificationIcon = 'ic_notification';

  /// Fallback icon if the main one is unavailable (e.g. legacy devices).
  static const String androidNotificationIconFallback = 'mipmap/ic_launcher';

  // ── Payloads ──────────────────────────────────────────────
  static const String payloadKeyType = 'type';
  static const String payloadKeyVehicleId = 'vehicle_id';
  static const String payloadKeyAction = 'action';

  static const String payloadTypeTest = 'test_notification';
  static const String payloadTypeDailyActivity = 'daily_activity';
  static const String payloadTypePucReminder = 'puc_reminder';
  static const String payloadTypeInsuranceReminder = 'insurance_reminder';
  static const String payloadTypeServiceReminder = 'service_reminder';
  static const String payloadTypeOilChangeReminder = 'oil_change_reminder';

  // ── Notification ID Helpers ────────────────────────────────

  /// Computes a deterministic, collision-resistant notification ID for a vehicle and reminder type.
  ///
  /// Uses an FNV-1a inspired hash with 100,000 buckets per category.
  /// Range: [base, base + 99999]. Much lower collision probability than
  /// the previous 1,000-bucket scheme.
  static int vehicleNotificationId(int base, String vehicleId) {
    // FNV-1a inspired mixing for better distribution across the ID space.
    int hash = 0x811c9dc5; // FNV offset basis
    for (int i = 0; i < vehicleId.length; i++) {
      hash ^= vehicleId.codeUnitAt(i);
      hash = (hash * 0x01000193) & 0x7FFFFFFF; // FNV prime, masked to 31 bits
    }
    return base + (hash % 100000);
  }

  /// Computes a notification ID using the **legacy** hash algorithm.
  ///
  /// Used only for cancelling orphaned notifications from the old ID scheme.
  static int legacyVehicleNotificationId(int base, String vehicleId) {
    final hash = vehicleId.hashCode.abs() % 1000;
    return base + hash;
  }
}
