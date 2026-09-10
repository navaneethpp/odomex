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
///
/// Demo vehicles (`Vehicle.isDemo == true`) are always excluded from scheduling.
class VehicleReminderScheduler {
  VehicleReminderScheduler({NotificationService? service})
      : _service = service ?? NotificationService.instance;

  final NotificationService _service;

  /// Tracks which odometer-based notification IDs have already been shown
  /// during the current sync cycle, to prevent duplicate immediate
  /// notifications on repeated app launches/resumes.
  final Set<int> _shownOdometerNotificationIds = {};

  // ─────────────────────────────────────────────
  // PUBLIC API
  // ─────────────────────────────────────────────

  /// Synchronizes all vehicle-specific reminder schedules.
  ///
  /// Cancels existing schedules first to prevent duplicate notifications,
  /// then re-evaluates each vehicle's state and schedules as appropriate.
  ///
  /// Demo vehicles are automatically filtered out and never scheduled.
  Future<void> syncAllVehicleReminders({
    required List<Vehicle> vehicles,
    required NotificationSettings notificationSettings,
    required Map<String, EffectiveVehicleSettings> effectiveSettings,
  }) async {
    // Filter out demo vehicles — they must never create real OS alarms.
    final realVehicles = vehicles.where((v) => !v.isDemo).toList();

    debugPrint('[VehicleReminders] Syncing reminders for ${realVehicles.length} real vehicle(s) '
        '(${vehicles.length - realVehicles.length} demo skipped). '
        'masterEnabled=${notificationSettings.enabled}');

    // Clear the dedup tracker at the start of each full sync cycle.
    _shownOdometerNotificationIds.clear();

    for (final vehicle in realVehicles) {
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
    if (!vehicle.isPucApplicable) return;

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
      debugPrint('[VehicleReminders] PUC: No valid future reminder date for $vehicleName → skipping');
      return;
    }

    final daysLeft = pucEndDate.difference(DateTime.now()).inDays;
    final scheduledTz = tz.TZDateTime.from(reminderDate, tz.local);

    debugPrint('[VehicleReminders] Scheduling reminder');
    debugPrint('[VehicleReminders]   id: $notificationId');
    debugPrint('[VehicleReminders]   type: puc_reminder');
    debugPrint('[VehicleReminders]   vehicleId: ${vehicle.id}');
    debugPrint('[VehicleReminders]   vehicleName: $vehicleName');
    debugPrint('[VehicleReminders]   expiryDate: $pucEndDate');
    debugPrint('[VehicleReminders]   daysLeft: $daysLeft');
    debugPrint('[VehicleReminders]   daysBeforeExpiry: $daysBeforeExpiry');
    debugPrint('[VehicleReminders]   scheduledFor: $scheduledTz');

    await _service.scheduleNotificationAt(
      id: notificationId,
      title: NotificationConstants.pucReminderTitle,
      body: NotificationConstants.pucReminderBody(vehicleName, daysLeft),
      scheduledDate: scheduledTz,
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
      debugPrint('[VehicleReminders] Insurance: No valid future reminder date for $vehicleName → skipping');
      return;
    }

    final daysLeft = insuranceEndDate.difference(DateTime.now()).inDays;
    final scheduledTz = tz.TZDateTime.from(reminderDate, tz.local);

    debugPrint('[VehicleReminders] Scheduling reminder');
    debugPrint('[VehicleReminders]   id: $notificationId');
    debugPrint('[VehicleReminders]   type: insurance_reminder');
    debugPrint('[VehicleReminders]   vehicleId: ${vehicle.id}');
    debugPrint('[VehicleReminders]   vehicleName: $vehicleName');
    debugPrint('[VehicleReminders]   expiryDate: $insuranceEndDate');
    debugPrint('[VehicleReminders]   daysLeft: $daysLeft');
    debugPrint('[VehicleReminders]   daysBeforeExpiry: $daysBeforeExpiry');
    debugPrint('[VehicleReminders]   scheduledFor: $scheduledTz');

    await _service.scheduleNotificationAt(
      id: notificationId,
      title: NotificationConstants.insuranceReminderTitle,
      body: NotificationConstants.insuranceReminderBody(vehicleName, daysLeft),
      scheduledDate: scheduledTz,
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

    // Dedup guard: only show once per sync cycle to prevent repeated notifications
    // on every app launch/resume once the threshold is crossed.
    if (_shownOdometerNotificationIds.contains(notificationId)) {
      debugPrint('[VehicleReminders] Service: $vehicleName already notified this cycle → skipping duplicate');
      return;
    }

    debugPrint('[VehicleReminders] Service: $vehicleName is within ${thresholdKm}km threshold (${kmUntilDue.toStringAsFixed(0)} km left) → notifying now');

    await _service.showNotification(
      id: notificationId,
      title: NotificationConstants.serviceReminderTitle,
      body: NotificationConstants.serviceReminderBody(vehicleName),
      payload: NotificationConstants.payloadTypeServiceReminder,
    );

    _shownOdometerNotificationIds.add(notificationId);
  }

  // ─────────────────────────────────────────────
  // OIL CHANGE REMINDER (ODOMETER-BASED)
  // ─────────────────────────────────────────────

  Future<void> _scheduleOilChangeReminder({
    required Vehicle vehicle,
    required String vehicleName,
    required int thresholdKm,
  }) async {
    if (!vehicle.isOilChangeApplicable) return;

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

    // Dedup guard: only show once per sync cycle.
    if (_shownOdometerNotificationIds.contains(notificationId)) {
      debugPrint('[VehicleReminders] OilChange: $vehicleName already notified this cycle → skipping duplicate');
      return;
    }

    debugPrint('[VehicleReminders] OilChange: $vehicleName is within ${thresholdKm}km threshold (${kmUntilDue.toStringAsFixed(0)} km left) → notifying now');

    await _service.showNotification(
      id: notificationId,
      title: NotificationConstants.oilChangeReminderTitle,
      body: NotificationConstants.oilChangeReminderBody(vehicleName),
      payload: NotificationConstants.payloadTypeOilChangeReminder,
    );

    _shownOdometerNotificationIds.add(notificationId);
  }

  // ─────────────────────────────────────────────
  // CANCEL HELPERS
  // ─────────────────────────────────────────────

  Future<void> _cancelAllForVehicle(String vehicleId) async {
    // Cancel current-scheme IDs
    final pucId = NotificationConstants.vehicleNotificationId(
      NotificationConstants.pucReminderIdBase, vehicleId);
    final insId = NotificationConstants.vehicleNotificationId(
      NotificationConstants.insuranceReminderIdBase, vehicleId);
    final svcId = NotificationConstants.vehicleNotificationId(
      NotificationConstants.serviceReminderIdBase, vehicleId);
    final oilId = NotificationConstants.vehicleNotificationId(
      NotificationConstants.oilChangeReminderIdBase, vehicleId);

    // Also cancel legacy-scheme IDs to clean up orphaned notifications
    // from the old narrow-range hash (base 2000–5000, % 1000).
    final legacyPucId = NotificationConstants.legacyVehicleNotificationId(
      NotificationConstants.legacyPucReminderIdBase, vehicleId);
    final legacyInsId = NotificationConstants.legacyVehicleNotificationId(
      NotificationConstants.legacyInsuranceReminderIdBase, vehicleId);
    final legacySvcId = NotificationConstants.legacyVehicleNotificationId(
      NotificationConstants.legacyServiceReminderIdBase, vehicleId);
    final legacyOilId = NotificationConstants.legacyVehicleNotificationId(
      NotificationConstants.legacyOilChangeReminderIdBase, vehicleId);

    await Future.wait([
      _service.cancel(pucId),
      _service.cancel(insId),
      _service.cancel(svcId),
      _service.cancel(oilId),
      _service.cancel(legacyPucId),
      _service.cancel(legacyInsId),
      _service.cancel(legacySvcId),
      _service.cancel(legacyOilId),
    ]);
  }

  // ─────────────────────────────────────────────
  // DATE HELPERS
  // ─────────────────────────────────────────────

  /// Computes the reminder trigger date for a date-based expiry.
  ///
  /// **Logic:**
  /// 1. If the expiry date itself has already completely passed → return `null`.
  /// 2. If `expiryDate - daysBeforeExpiry` is still in the future → return that date at 09:00.
  /// 3. If the N-day mark has passed but the expiry is still future → schedule
  ///    for **tomorrow at 09:00** as an "urgent catch-up" reminder.
  /// 4. If the expiry is today → schedule for **today at 09:00** if that hasn't passed yet.
  /// 5. Otherwise → return `null` (no valid future time available).
  DateTime? _reminderDateFor(DateTime expiryDate, int daysBeforeExpiry) {
    final now = DateTime.now();

    // Normalize expiry to midnight (date-only field — prevent UTC offset shifting the day).
    final expiryDay = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final todayDay = DateTime(now.year, now.month, now.day);

    // 1. Expiry is completely in the past (before today).
    if (expiryDay.isBefore(todayDay)) {
      debugPrint('[VehicleReminders] _reminderDateFor: expiry $expiryDay is before today $todayDay → null');
      return null;
    }

    // 2. Calculate the ideal N-day-before reminder date.
    final idealReminderDay = expiryDay.subtract(Duration(days: daysBeforeExpiry));
    final idealReminderAt9 = DateTime(
      idealReminderDay.year,
      idealReminderDay.month,
      idealReminderDay.day,
      9,
      0,
    );

    // If the ideal date is still in the future, use it.
    if (idealReminderAt9.isAfter(now)) {
      return idealReminderAt9;
    }

    // 3. Ideal date already passed, but expiry is still future.
    //    Schedule for tomorrow at 09:00 as an urgent catch-up.
    final tomorrowAt9 = DateTime(now.year, now.month, now.day + 1, 9, 0);
    if (tomorrowAt9.isBefore(expiryDay) || _isSameDay(tomorrowAt9, expiryDay)) {
      debugPrint('[VehicleReminders] _reminderDateFor: ideal date past, '
          'scheduling urgent catch-up for tomorrow 09:00');
      return tomorrowAt9;
    }

    // 4. Expiry is today — schedule for today at 09:00 if it hasn't passed.
    if (_isSameDay(expiryDay, todayDay)) {
      final todayAt9 = DateTime(now.year, now.month, now.day, 9, 0);
      if (todayAt9.isAfter(now)) {
        debugPrint('[VehicleReminders] _reminderDateFor: expiry is today, '
            'scheduling for today 09:00');
        return todayAt9;
      }
    }

    // 5. No valid future time available.
    debugPrint('[VehicleReminders] _reminderDateFor: no valid future time for expiry $expiryDay');
    return null;
  }

  /// Returns `true` if two [DateTime] values fall on the same calendar day.
  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
