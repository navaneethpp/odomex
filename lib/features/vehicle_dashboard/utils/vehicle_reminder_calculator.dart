import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:odomex/core/theme/app_colors.dart';
import 'package:odomex/core/utils/vehicle_status.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_settings/models/effective_vehicle_settings.dart';
import 'package:odomex/models/vehicle.dart';

/// Urgency level for sorting reminders.
enum ReminderUrgency {
  overdue,
  dueToday,
  dueSoon,
  upcoming,
}

extension ReminderUrgencyExtension on ReminderUrgency {
  int get sortWeight {
    switch (this) {
      case ReminderUrgency.overdue:
        return 0;
      case ReminderUrgency.dueToday:
        return 1;
      case ReminderUrgency.dueSoon:
        return 2;
      case ReminderUrgency.upcoming:
        return 3;
    }
  }

  String get label {
    switch (this) {
      case ReminderUrgency.overdue:
        return 'Overdue';
      case ReminderUrgency.dueToday:
        return 'Due Today';
      case ReminderUrgency.dueSoon:
        return 'Due Soon';
      case ReminderUrgency.upcoming:
        return 'Upcoming';
    }
  }

  Color color(ColorScheme colorScheme) {
    switch (this) {
      case ReminderUrgency.overdue:
        return AppColors.error;
      case ReminderUrgency.dueToday:
        return AppColors.warning;
      case ReminderUrgency.dueSoon:
        return AppColors.warning;
      case ReminderUrgency.upcoming:
        return AppColors.success;
    }
  }
}

/// Reminder type category.
enum ReminderType { insurance, puc, oilChange, service }

/// Immutable representation of an action item/reminder for the dashboard.
class VehicleReminder {
  const VehicleReminder({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.dueText,
    required this.remainingText,
    required this.urgency,
    required this.icon,
  });

  final ReminderType type;
  final String title;
  final String subtitle;
  final String dueText;
  final String remainingText;
  final ReminderUrgency urgency;
  final IconData icon;
}

/// Computes and prioritizes all upcoming maintenance & compliance reminders.
class VehicleReminderCalculator {
  VehicleReminderCalculator._();

  static final DateFormat _dateFormat = DateFormat(
    'd MMMM yyyy',
  );

  /// Calculates all reminders for [vehicle] and returns them sorted by urgency.
  ///
  /// Dynamically respects [settings] (effective merged settings) and derives maintenance targets from [records].
  static List<VehicleReminder> calculateReminders(
    Vehicle vehicle, {
    EffectiveVehicleSettings? settings,
    List<VehicleRecord>? records,
  }) {
    final reminders = <VehicleReminder>[];

    // ── 1. Insurance ──
    final insuranceEnabled =
        settings?.insuranceReminderEnabled ?? true;
    final insuranceWarnDays =
        settings?.insuranceReminderDays ??
        kDocumentWarnDays;

    if (insuranceEnabled &&
        vehicle.hasInsurance &&
        vehicle.insuranceEndDate != null) {
      final days = daysUntilExpiry(
        vehicle.insuranceEndDate!,
      );
      final ReminderUrgency urgency;
      final String remainingText;

      if (days < 0) {
        urgency = ReminderUrgency.overdue;
        remainingText = '${-days} days overdue';
      } else if (days == 0) {
        urgency = ReminderUrgency.dueToday;
        remainingText = 'Expires today';
      } else if (days <= insuranceWarnDays) {
        urgency = ReminderUrgency.dueSoon;
        remainingText = '$days days remaining';
      } else {
        urgency = ReminderUrgency.upcoming;
        remainingText = '$days days remaining';
      }

      reminders.add(
        VehicleReminder(
          type: ReminderType.insurance,
          title: 'Insurance Policy',
          subtitle:
              vehicle.insurancePolicyNumber != null &&
                  vehicle.insurancePolicyNumber!.isNotEmpty
              ? 'Policy #${vehicle.insurancePolicyNumber}'
              : (vehicle.insuranceProvider ?? 'Insurance'),
          dueText:
              'Expires ${_dateFormat.format(vehicle.insuranceEndDate!)}',
          remainingText: remainingText,
          urgency: urgency,
          icon: Icons.verified_user_rounded,
        ),
      );
    }

    // ── 2. PUC (Pollution Certificate) ──
    final pucEnabled = settings?.pucReminderEnabled ?? true;
    final pucWarnDays =
        settings?.pucReminderDays ?? kDocumentWarnDays;

    if (pucEnabled &&
        vehicle.hasPuc &&
        vehicle.isPucApplicable &&
        vehicle.pucEndDate != null) {
      final days = daysUntilExpiry(vehicle.pucEndDate!);
      final ReminderUrgency urgency;
      final String remainingText;

      if (days < 0) {
        urgency = ReminderUrgency.overdue;
        remainingText = '${-days} days overdue';
      } else if (days == 0) {
        urgency = ReminderUrgency.dueToday;
        remainingText = 'Expires today';
      } else if (days <= pucWarnDays) {
        urgency = ReminderUrgency.dueSoon;
        remainingText = '$days days remaining';
      } else {
        urgency = ReminderUrgency.upcoming;
        remainingText = '$days days remaining';
      }

      reminders.add(
        VehicleReminder(
          type: ReminderType.puc,
          title: 'PUC Certificate',
          subtitle:
              vehicle.pucCertificateNumber != null &&
                  vehicle.pucCertificateNumber!.isNotEmpty
              ? 'Cert #${vehicle.pucCertificateNumber}'
              : 'Emission Test',
          dueText:
              'Expires ${_dateFormat.format(vehicle.pucEndDate!)}',
          remainingText: remainingText,
          urgency: urgency,
          icon: Icons.eco_rounded,
        ),
      );
    }

    final warnThresholdKm =
        settings?.maintenanceReminderThresholdKm ??
        kMaintenanceWarnKm;

    // ── 3. Oil Change ──
    final oilChangeEnabled =
        settings?.oilChangeReminderEnabled ?? true;
    if (oilChangeEnabled && vehicle.isOilChangeApplicable) {
      final interval =
          settings?.oilChangeIntervalKm ??
          vehicle.oilChangeInterval?.toInt() ??
          3000;

      // Look for latest historical OilChangeRecord with an odometer reading
      double? nextOdo;
      if (records != null && records.isNotEmpty) {
        final oilRecords = records
            .whereType<OilChangeRecord>()
            .toList();
        if (oilRecords.isNotEmpty) {
          oilRecords.sort(
            (a, b) => b.date.compareTo(a.date),
          );
          final lastOilOdo =
              oilRecords.first.odometerReading;
          nextOdo = lastOilOdo + interval;
        }
      }

      nextOdo ??=
          vehicle.nextOilChangeOdometer ??
          (vehicle.odometerReading + interval);

      final diff = nextOdo - vehicle.odometerReading;
      final ReminderUrgency urgency;
      final String remainingText;

      if (diff < 0) {
        urgency = ReminderUrgency.overdue;
        remainingText =
            '${(-diff).toStringAsFixed(0)} km overdue';
      } else if (diff == 0) {
        urgency = ReminderUrgency.dueToday;
        remainingText = 'Due now';
      } else if (diff <= warnThresholdKm) {
        urgency = ReminderUrgency.dueSoon;
        remainingText =
            '${diff.toStringAsFixed(0)} km remaining';
      } else {
        urgency = ReminderUrgency.upcoming;
        remainingText =
            '${diff.toStringAsFixed(0)} km remaining';
      }

      reminders.add(
        VehicleReminder(
          type: ReminderType.oilChange,
          title: 'Oil Change',
          subtitle:
              'Every ${interval.toStringAsFixed(0)} km',
          dueText:
              'Due at ${nextOdo.toStringAsFixed(0)} km',
          remainingText: remainingText,
          urgency: urgency,
          icon: Icons.oil_barrel_rounded,
        ),
      );
    }

    // ── 4. Scheduled Service ──
    final serviceEnabled =
        settings?.serviceReminderEnabled ?? true;
    if (serviceEnabled) {
      final interval = settings?.serviceIntervalKm ?? 3000;

      // Look for latest historical ServiceRecord with an odometer reading
      double? nextOdo;
      if (records != null && records.isNotEmpty) {
        final serviceRecords = records
            .whereType<ServiceRecord>()
            .where((r) => r.odometerReading != null)
            .toList();
        if (serviceRecords.isNotEmpty) {
          serviceRecords.sort(
            (a, b) => b.date.compareTo(a.date),
          );
          final lastServiceOdo =
              serviceRecords.first.odometerReading!;
          nextOdo = lastServiceOdo + interval;
        }
      }

      nextOdo ??=
          vehicle.nextServiceOdometer ??
          (vehicle.odometerReading + interval);

      final diff = nextOdo - vehicle.odometerReading;
      final ReminderUrgency urgency;
      final String remainingText;

      if (diff < 0) {
        urgency = ReminderUrgency.overdue;
        remainingText =
            '${(-diff).toStringAsFixed(0)} km overdue';
      } else if (diff == 0) {
        urgency = ReminderUrgency.dueToday;
        remainingText = 'Due now';
      } else if (diff <= warnThresholdKm) {
        urgency = ReminderUrgency.dueSoon;
        remainingText =
            '${diff.toStringAsFixed(0)} km remaining';
      } else {
        urgency = ReminderUrgency.upcoming;
        remainingText =
            '${diff.toStringAsFixed(0)} km remaining';
      }

      reminders.add(
        VehicleReminder(
          type: ReminderType.service,
          title: 'Scheduled Service',
          subtitle:
              'Every ${interval.toStringAsFixed(0)} km',
          dueText:
              'Due at ${nextOdo.toStringAsFixed(0)} km',
          remainingText: remainingText,
          urgency: urgency,
          icon: Icons.build_rounded,
        ),
      );
    }

    // Sort by urgency: Overdue (0) -> Due Today (1) -> Due Soon (2) -> Upcoming (3)
    reminders.sort(
      (a, b) => a.urgency.sortWeight.compareTo(
        b.urgency.sortWeight,
      ),
    );

    return reminders;
  }
}
