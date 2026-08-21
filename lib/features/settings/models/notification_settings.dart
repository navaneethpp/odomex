import 'package:flutter/material.dart';
import 'package:odomex/core/notifications/notification_constants.dart';

/// Distinct categories of vehicle notifications and reminders supported in Odomex.
enum NotificationCategory {
  dailyActivity,
  pucReminder,
  insuranceReminder,
  serviceReminder,
  oilChangeReminder;

  /// User-facing display title for the notification category.
  String get title {
    switch (this) {
      case NotificationCategory.dailyActivity:
        return 'Daily Activity';
      case NotificationCategory.pucReminder:
        return 'PUC Reminder';
      case NotificationCategory.insuranceReminder:
        return 'Insurance Reminder';
      case NotificationCategory.serviceReminder:
        return 'Service Reminder';
      case NotificationCategory.oilChangeReminder:
        return 'Oil Change Reminder';
    }
  }

  /// User-facing short description explaining the reminder.
  String get description {
    switch (this) {
      case NotificationCategory.dailyActivity:
        return "Remind me to record my vehicle's daily activity.";
      case NotificationCategory.pucReminder:
        return 'Remind me before my PUC expires.';
      case NotificationCategory.insuranceReminder:
        return 'Remind me before my vehicle insurance expires.';
      case NotificationCategory.serviceReminder:
        return 'Remind me when vehicle service is due.';
      case NotificationCategory.oilChangeReminder:
        return 'Remind me when the next oil change is due.';
    }
  }

  /// Theme-adaptive icon representing the category.
  IconData get icon {
    switch (this) {
      case NotificationCategory.dailyActivity:
        return Icons.today_rounded;
      case NotificationCategory.pucReminder:
        return Icons.verified_outlined;
      case NotificationCategory.insuranceReminder:
        return Icons.shield_outlined;
      case NotificationCategory.serviceReminder:
        return Icons.build_outlined;
      case NotificationCategory.oilChangeReminder:
        return Icons.oil_barrel_outlined;
    }
  }

  /// Key used when serializing to/from persistent storage maps.
  String get storageKey {
    switch (this) {
      case NotificationCategory.dailyActivity:
        return 'daily_activity';
      case NotificationCategory.pucReminder:
        return 'puc_reminder';
      case NotificationCategory.insuranceReminder:
        return 'insurance_reminder';
      case NotificationCategory.serviceReminder:
        return 'service_reminder';
      case NotificationCategory.oilChangeReminder:
        return 'oil_change_reminder';
    }
  }
}

/// Immutable data model holding user preferences for global and category notifications.
@immutable
class NotificationSettings {
  const NotificationSettings({
    this.enabled = false,
    this.dailyActivity = true,
    this.dailyActivityReminderHour =
        NotificationConstants.defaultDailyActivityHour,
    this.dailyActivityReminderMinute =
        NotificationConstants.defaultDailyActivityMinute,
    this.pucReminder = true,
    this.insuranceReminder = true,
    this.serviceReminder = true,
    this.oilChangeReminder = true,
  });

  /// Master notification switch controlling whether any local notifications can be sent.
  final bool enabled;

  /// Whether daily activity recording reminders are enabled.
  final bool dailyActivity;

  /// Hour of the day (0-23) when the daily activity reminder should trigger.
  final int dailyActivityReminderHour;

  /// Minute of the hour (0-59) when the daily activity reminder should trigger.
  final int dailyActivityReminderMinute;

  /// Returns the daily activity reminder time as a Flutter [TimeOfDay].
  TimeOfDay get dailyActivityReminderTime => TimeOfDay(
        hour: dailyActivityReminderHour,
        minute: dailyActivityReminderMinute,
      );

  /// Whether PUC expiry reminders are enabled.
  final bool pucReminder;

  /// Whether insurance expiry reminders are enabled.
  final bool insuranceReminder;

  /// Whether vehicle service due reminders are enabled.
  final bool serviceReminder;

  /// Whether oil change due reminders are enabled.
  final bool oilChangeReminder;

  /// Checks if a specific [category] is enabled in this settings configuration.
  bool isCategoryEnabled(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.dailyActivity:
        return dailyActivity;
      case NotificationCategory.pucReminder:
        return pucReminder;
      case NotificationCategory.insuranceReminder:
        return insuranceReminder;
      case NotificationCategory.serviceReminder:
        return serviceReminder;
      case NotificationCategory.oilChangeReminder:
        return oilChangeReminder;
    }
  }

  /// Returns a new instance updating only the specified [category].
  NotificationSettings copyWithCategory(
    NotificationCategory category,
    bool isEnabled,
  ) {
    switch (category) {
      case NotificationCategory.dailyActivity:
        return copyWith(dailyActivity: isEnabled);
      case NotificationCategory.pucReminder:
        return copyWith(pucReminder: isEnabled);
      case NotificationCategory.insuranceReminder:
        return copyWith(insuranceReminder: isEnabled);
      case NotificationCategory.serviceReminder:
        return copyWith(serviceReminder: isEnabled);
      case NotificationCategory.oilChangeReminder:
        return copyWith(oilChangeReminder: isEnabled);
    }
  }

  NotificationSettings copyWith({
    bool? enabled,
    bool? dailyActivity,
    int? dailyActivityReminderHour,
    int? dailyActivityReminderMinute,
    bool? pucReminder,
    bool? insuranceReminder,
    bool? serviceReminder,
    bool? oilChangeReminder,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      dailyActivity: dailyActivity ?? this.dailyActivity,
      dailyActivityReminderHour:
          dailyActivityReminderHour ?? this.dailyActivityReminderHour,
      dailyActivityReminderMinute:
          dailyActivityReminderMinute ?? this.dailyActivityReminderMinute,
      pucReminder: pucReminder ?? this.pucReminder,
      insuranceReminder: insuranceReminder ?? this.insuranceReminder,
      serviceReminder: serviceReminder ?? this.serviceReminder,
      oilChangeReminder: oilChangeReminder ?? this.oilChangeReminder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      NotificationCategory.dailyActivity.storageKey: dailyActivity,
      'daily_activity_hour': dailyActivityReminderHour,
      'daily_activity_minute': dailyActivityReminderMinute,
      NotificationCategory.pucReminder.storageKey: pucReminder,
      NotificationCategory.insuranceReminder.storageKey: insuranceReminder,
      NotificationCategory.serviceReminder.storageKey: serviceReminder,
      NotificationCategory.oilChangeReminder.storageKey: oilChangeReminder,
    };
  }

  factory NotificationSettings.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) return const NotificationSettings();

    return NotificationSettings(
      enabled: map['enabled'] as bool? ?? false,
      dailyActivity:
          map[NotificationCategory.dailyActivity.storageKey] as bool? ?? true,
      dailyActivityReminderHour: map['daily_activity_hour'] as int? ??
          NotificationConstants.defaultDailyActivityHour,
      dailyActivityReminderMinute: map['daily_activity_minute'] as int? ??
          NotificationConstants.defaultDailyActivityMinute,
      pucReminder:
          map[NotificationCategory.pucReminder.storageKey] as bool? ?? true,
      insuranceReminder:
          map[NotificationCategory.insuranceReminder.storageKey] as bool? ??
              true,
      serviceReminder:
          map[NotificationCategory.serviceReminder.storageKey] as bool? ?? true,
      oilChangeReminder:
          map[NotificationCategory.oilChangeReminder.storageKey] as bool? ??
              true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettings &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          dailyActivity == other.dailyActivity &&
          dailyActivityReminderHour == other.dailyActivityReminderHour &&
          dailyActivityReminderMinute == other.dailyActivityReminderMinute &&
          pucReminder == other.pucReminder &&
          insuranceReminder == other.insuranceReminder &&
          serviceReminder == other.serviceReminder &&
          oilChangeReminder == other.oilChangeReminder;

  @override
  int get hashCode => Object.hash(
        enabled,
        dailyActivity,
        dailyActivityReminderHour,
        dailyActivityReminderMinute,
        pucReminder,
        insuranceReminder,
        serviceReminder,
        oilChangeReminder,
      );
}
