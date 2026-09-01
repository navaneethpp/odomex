import 'package:flutter/foundation.dart';
import 'package:odomex/core/notifications/notification_constants.dart';
import 'package:odomex/core/notifications/notification_service.dart';
import 'package:odomex/features/settings/models/notification_settings.dart';
import 'package:odomex/features/vehicle_settings/models/effective_vehicle_settings.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:timezone/timezone.dart' as tz;

/// Schedules and cancels vehicle-specific expiry and maintenance reminders.
///
/// Handles four reminder types:
/// - **PUC**: Fires N days before `vehicle.pucEndDate`.
/// - **Insurance**: Fires N days before `vehicle.insuranceEndDate`.
/// - **Service**: Fires as an immediate notification when the vehicle is within
///   the service threshold (i.e. `currentOdometer >= nextServiceOdometer - thresholdKm`).
/// - **Oil Change**: Same odometer-threshold logic for oil change intervals.
///
/// All scheduling decisions respect:
/// 1. The global master switch (`NotificationSettings.enabled`).
/// 2. Per-category switches (`NotificationSettings.pucReminder`, etc.).
/// 3. Per-vehicle effective settings (custom day/km thresholds from `EffectiveVehicleSettings`).
class VehicleReminderScheduler {
  VehicleReminderScheduler({NotificationService? service})
      : _service = service ?? NotificationService.instance;

  final NotificationService _service;

  // ─────────────────────────────────────────────
  // PUBLIC API
  // ─────────────────────────────────────────────

  /// Synchronizes all vehicle-specific reminder schedules.
  ///
  /// Cancels existing schedules first to prevent duplicate notifications,
  /// then re-evaluates each vehicle's state and schedules as appropriate.
  Future<void> syncAllVehicleReminders({
    required List<Vehicle> vehicles,
    required NotificationSettings notificationSettings,
    required Map<String, EffectiveVehicleSettings> effectiveSettings,
  }) async {
    debugPrint('[VehicleReminders] Syncing reminders for ${vehicles.length} vehicle(s). masterEnabled=${notificationSettings.enabled}');

    for (final vehicle in vehicles) {
      final settings = effectiveSettings[vehicle.id];
      await _syncForVehicle(
        vehicle: vehicle,
        notificationSettings: notificationSettings,
        effectiveSettings: settings,
      );
    }
  }

  /// Cancels all vehicle-specific reminder notifications for the given vehicles.
  Future<void> cancelAllVehicleReminders(List<Vehicle> vehicles) async {
    for (final vehicle in vehicles) {
      await _cancelAllForVehicle(vehicle.id);
    }
  }

  /// Cancels all reminders for a single vehicle (used when vehicle is deleted).
  Future<void> cancelRemindersForVehicle(String vehicleId) async {
    await _cancelAllForVehicle(vehicleId);
  }

  // ─────────────────────────────────────────────
  // PRIVATE: PER-VEHICLE LOGIC
  // ─────────────────────────────────────────────

  Future<void> _syncForVehicle({
    required Vehicle vehicle,
    required NotificationSettings notificationSettings,
    required EffectiveVehicleSettings? effectiveSettings,
  }) async {
    final masterEnabled = notificationSettings.enabled;

    // Cancel all existing reminders first; re-schedule those that qualify.
    await _cancelAllForVehicle(vehicle.id);

    if (!masterEnabled) {
      debugPrint('[VehicleReminders] Master disabled → skipping ${vehicle.id}');
      return;
    }

    // Check OS notification permission once per vehicle batch (cached in service)
    final hasPermission = await _service.areNotificationsEnabled();
    if (!hasPermission) {
      debugPrint('[VehicleReminders] OS permission denied → skipping ${vehicle.id}');
      return;
    }

    final vehicleName = '${vehicle.brandDisplayName} ${vehicle.model}';

    // 1. PUC Reminder
    if (notificationSettings.pucReminder &&
        (effectiveSettings?.pucReminderEnabled ?? true)) {
      await _schedulePucReminder(
        vehicle: vehicle,
        vehicleName: vehicleName,
        daysBeforeExpiry: effectiveSettings?.pucReminderDays ?? 30,
      );
    }

    // 2. Insurance Reminder
    if (notificationSettings.insuranceReminder &&
        (effectiveSettings?.insuranceReminderEnabled ?? true)) {
      await _scheduleInsuranceReminder(
        vehicle: vehicle,
        vehicleName: vehicleName,
        daysBeforeExpiry: effectiveSettings?.insuranceReminderDays ?? 30,
      );
    }

    // 3. Service Reminder (odometer-based → immediate notification if overdue)
    if (notificationSettings.serviceReminder &&
        (effectiveSettings?.serviceReminderEnabled ?? true)) {
      await _scheduleServiceReminder(
        vehicle: vehicle,
        vehicleName: vehicleName,
        thresholdKm: effectiveSettings?.maintenanceReminderThresholdKm ?? 500,
      );
    }

    // 4. Oil Change Reminder (odometer-based → immediate notification if overdue)
    if (notificationSettings.oilChangeReminder &&
        (effectiveSettings?.oilChangeReminderEnabled ?? true)) {
      await _scheduleOilChangeReminder(
        vehicle: vehicle,
        vehicleName: vehicleName,
        thresholdKm: effectiveSettings?.maintenanceReminderThresholdKm ?? 500,
      );
    }
  }

  // ─────────────────────────────────────────────
  // PUC REMINDER
  // ─────────────────────────────────────────────

  Future<void> _schedulePucReminder({
    required Vehicle vehicle,
    required String vehicleName,
    required int daysBeforeExpiry,
  }) async {
    final pucEndDate = vehicle.pucEndDate;
    if (pucEndDate == null) {
      debugPrint('[VehicleReminders] PUC: No end date for $vehicleName → skipping');
      return;
    }

    final reminderDate = _reminderDateFor(pucEndDate, daysBeforeExpiry);
    final notificationId = NotificationConstants.vehicleNotificationId(
      NotificationConstants.pucReminderIdBase,
      vehicle.id,
    );

    if (reminderDate == null) {
      debugPrint('[VehicleReminders] PUC: Reminder date already past for $vehicleName → skipping');
      return;
    }

    final daysLeft = pucEndDate.difference(DateTime.now()).inDays;
    debugPrint('[VehicleReminders] PUC: Scheduling for $vehicleName at $reminderDate (daysLeft=$daysLeft)');

    await _service.scheduleNotificationAt(
      id: notificationId,
      title: NotificationConstants.pucReminderTitle,
      body: NotificationConstants.pucReminderBody(vehicleName, daysLeft),
      scheduledDate: tz.TZDateTime.from(reminderDate, tz.local),
      payload: NotificationConstants.payloadTypePucReminder,
    );
  }

  // ─────────────────────────────────────────────
  // INSURANCE REMINDER
  // ─────────────────────────────────────────────

  Future<void> _scheduleInsuranceReminder({
    required Vehicle vehicle,
    required String vehicleName,
    required int daysBeforeExpiry,
  }) async {
    final insuranceEndDate = vehicle.insuranceEndDate;
    if (insuranceEndDate == null) {
      debugPrint('[VehicleReminders] Insurance: No end date for $vehicleName → skipping');
      return;
    }

    final reminderDate = _reminderDateFor(insuranceEndDate, daysBeforeExpiry);
    final notificationId = NotificationConstants.vehicleNotificationId(
      NotificationConstants.insuranceReminderIdBase,
      vehicle.id,
    );

    if (reminderDate == null) {
      debugPrint('[VehicleReminders] Insurance: Reminder date already past for $vehicleName → skipping');
      return;
    }

    final daysLeft = insuranceEndDate.difference(DateTime.now()).inDays;
    debugPrint('[VehicleReminders] Insurance: Scheduling for $vehicleName at $reminderDate (daysLeft=$daysLeft)');

    await _service.scheduleNotificationAt(
      id: notificationId,
      title: NotificationConstants.insuranceReminderTitle,
      body: NotificationConstants.insuranceReminderBody(vehicleName, daysLeft),
      scheduledDate: tz.TZDateTime.from(reminderDate, tz.local),
      payload: NotificationConstants.payloadTypeInsuranceReminder,
    );
  }

  // ─────────────────────────────────────────────
  // SERVICE REMINDER (ODOMETER-BASED)
  // ─────────────────────────────────────────────

  Future<void> _scheduleServiceReminder({
    required Vehicle vehicle,
    required String vehicleName,
    required int thresholdKm,
  }) async {
    final nextServiceOdometer = vehicle.nextServiceOdometer;
    if (nextServiceOdometer == null) {
      debugPrint('[VehicleReminders] Service: No next service odometer for $vehicleName → skipping');
      return;
    }

    final currentOdometer = vehicle.odometerReading;
    final kmUntilDue = nextServiceOdometer - currentOdometer;

    if (kmUntilDue > thresholdKm) {
      debugPrint('[VehicleReminders] Service: $vehicleName is ${kmUntilDue.toStringAsFixed(0)} km from due → not yet in threshold');
      return;
    }

    // Vehicle is within threshold or overdue — fire an immediate notification.
    final notificationId = NotificationConstants.vehicleNotificationId(
      NotificationConstants.serviceReminderIdBase,
      vehicle.id,
    );

    debugPrint('[VehicleReminders] Service: $vehicleName is within ${thresholdKm}km threshold (${kmUntilDue.toStringAsFixed(0)} km left) → notifying now');

    await _service.showNotification(
      id: notificationId,
      title: NotificationConstants.serviceReminderTitle,
      body: NotificationConstants.serviceReminderBody(vehicleName),
      payload: NotificationConstants.payloadTypeServiceReminder,
    );
  }

  // ─────────────────────────────────────────────
  // OIL CHANGE REMINDER (ODOMETER-BASED)
  // ─────────────────────────────────────────────

  Future<void> _scheduleOilChangeReminder({
    required Vehicle vehicle,
    required String vehicleName,
    required int thresholdKm,
  }) async {
    final nextOilChangeOdometer = vehicle.nextOilChangeOdometer;
    if (nextOilChangeOdometer == null) {
      debugPrint('[VehicleReminders] OilChange: No next oil change odometer for $vehicleName → skipping');
      return;
    }

    final currentOdometer = vehicle.odometerReading;
    final kmUntilDue = nextOilChangeOdometer - currentOdometer;

    if (kmUntilDue > thresholdKm) {
      debugPrint('[VehicleReminders] OilChange: $vehicleName is ${kmUntilDue.toStringAsFixed(0)} km from due → not yet in threshold');
      return;
    }

    final notificationId = NotificationConstants.vehicleNotificationId(
      NotificationConstants.oilChangeReminderIdBase,
      vehicle.id,
    );

    debugPrint('[VehicleReminders] OilChange: $vehicleName is within ${thresholdKm}km threshold (${kmUntilDue.toStringAsFixed(0)} km left) → notifying now');

    await _service.showNotification(
      id: notificationId,
      title: NotificationConstants.oilChangeReminderTitle,
      body: NotificationConstants.oilChangeReminderBody(vehicleName),
      payload: NotificationConstants.payloadTypeOilChangeReminder,
    );
  }

  // ─────────────────────────────────────────────
  // CANCEL HELPERS
  // ─────────────────────────────────────────────

  Future<void> _cancelAllForVehicle(String vehicleId) async {
    final pucId = NotificationConstants.vehicleNotificationId(
      NotificationConstants.pucReminderIdBase, vehicleId);
    final insId = NotificationConstants.vehicleNotificationId(
      NotificationConstants.insuranceReminderIdBase, vehicleId);
    final svcId = NotificationConstants.vehicleNotificationId(
      NotificationConstants.serviceReminderIdBase, vehicleId);
    final oilId = NotificationConstants.vehicleNotificationId(
      NotificationConstants.oilChangeReminderIdBase, vehicleId);

    await Future.wait([
      _service.cancel(pucId),
      _service.cancel(insId),
      _service.cancel(svcId),
      _service.cancel(oilId),
    ]);
  }

  // ─────────────────────────────────────────────
  // DATE HELPERS
  // ─────────────────────────────────────────────

  /// Computes the reminder trigger date as [expiryDate] minus [daysBeforeExpiry].
  ///
  /// Returns `null` if the computed reminder date is already in the past
  /// (meaning the reminder window has passed — no point scheduling it now).
  DateTime? _reminderDateFor(DateTime expiryDate, int daysBeforeExpiry) {
    final reminderDate = expiryDate.subtract(Duration(days: daysBeforeExpiry));
    // Set reminder to fire at 9:00 AM local time on the reminder day.
    final reminderAtTime = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      9,
      0,
    );
    final now = DateTime.now();
    if (reminderAtTime.isBefore(now)) return null;
    return reminderAtTime;
  }
}
