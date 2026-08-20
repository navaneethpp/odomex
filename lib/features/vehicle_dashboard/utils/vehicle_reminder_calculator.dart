import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:odomex/core/theme/app_colors.dart';
import 'package:odomex/core/utils/vehicle_status.dart';
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
enum ReminderType {
  insurance,
  puc,
  oilChange,
  service,
}

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

  static final DateFormat _dateFormat = DateFormat('d MMMM yyyy');

  /// Calculates all reminders for [vehicle] and returns them sorted by urgency.
  static List<VehicleReminder> calculateReminders(Vehicle vehicle) {
    final reminders = <VehicleReminder>[];

    // ── 1. Insurance ──
    if (vehicle.hasInsurance && vehicle.insuranceEndDate != null) {
      final days = daysUntilExpiry(vehicle.insuranceEndDate!);
      final ReminderUrgency urgency;
      final String remainingText;

      if (days < 0) {
        urgency = ReminderUrgency.overdue;
        remainingText = '${-days} days overdue';
      } else if (days == 0) {
        urgency = ReminderUrgency.dueToday;
        remainingText = 'Expires today';
      } else if (days <= kDocumentWarnDays) {
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
          subtitle: vehicle.insurancePolicyNumber != null &&
                  vehicle.insurancePolicyNumber!.isNotEmpty
              ? 'Policy #${vehicle.insurancePolicyNumber}'
              : (vehicle.insuranceProvider ?? 'Insurance'),
          dueText: 'Expires ${_dateFormat.format(vehicle.insuranceEndDate!)}',
          remainingText: remainingText,
          urgency: urgency,
          icon: Icons.verified_user_rounded,
        ),
      );
    }

    // ── 2. PUC (Pollution Certificate) ──
    if (vehicle.hasPuc && vehicle.pucEndDate != null) {
      final days = daysUntilExpiry(vehicle.pucEndDate!);
      final ReminderUrgency urgency;
      final String remainingText;

      if (days < 0) {
        urgency = ReminderUrgency.overdue;
        remainingText = '${-days} days overdue';
      } else if (days == 0) {
        urgency = ReminderUrgency.dueToday;
        remainingText = 'Expires today';
      } else if (days <= kDocumentWarnDays) {
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
          subtitle: vehicle.pucCertificateNumber != null &&
                  vehicle.pucCertificateNumber!.isNotEmpty
              ? 'Cert #${vehicle.pucCertificateNumber}'
              : 'Emission Test',
          dueText: 'Expires ${_dateFormat.format(vehicle.pucEndDate!)}',
          remainingText: remainingText,
          urgency: urgency,
          icon: Icons.eco_rounded,
        ),
      );
    }

    // ── 3. Oil Change ──
    if (vehicle.nextOilChangeOdometer != null) {
      final nextOdo = vehicle.nextOilChangeOdometer!;
      final diff = nextOdo - vehicle.odometerReading;
      final ReminderUrgency urgency;
      final String remainingText;

      if (diff < 0) {
        urgency = ReminderUrgency.overdue;
        remainingText = '${(-diff).toStringAsFixed(0)} km overdue';
      } else if (diff == 0) {
        urgency = ReminderUrgency.dueToday;
        remainingText = 'Due now';
      } else if (diff <= kMaintenanceWarnKm) {
        urgency = ReminderUrgency.dueSoon;
        remainingText = '${diff.toStringAsFixed(0)} km remaining';
      } else {
        urgency = ReminderUrgency.upcoming;
        remainingText = '${diff.toStringAsFixed(0)} km remaining';
      }

      reminders.add(
        VehicleReminder(
          type: ReminderType.oilChange,
          title: 'Oil Change',
          subtitle: vehicle.oilChangeInterval != null
              ? 'Every ${vehicle.oilChangeInterval!.toStringAsFixed(0)} km'
              : 'Scheduled Oil Change',
          dueText: 'Due at ${nextOdo.toStringAsFixed(0)} km',
          remainingText: remainingText,
          urgency: urgency,
          icon: Icons.oil_barrel_rounded,
        ),
      );
    }

    // ── 4. Service ──
    if (vehicle.nextServiceOdometer != null) {
      final nextOdo = vehicle.nextServiceOdometer!;
      final diff = nextOdo - vehicle.odometerReading;
      final ReminderUrgency urgency;
      final String remainingText;

      if (diff < 0) {
        urgency = ReminderUrgency.overdue;
        remainingText = '${(-diff).toStringAsFixed(0)} km overdue';
      } else if (diff == 0) {
        urgency = ReminderUrgency.dueToday;
        remainingText = 'Due now';
      } else if (diff <= kMaintenanceWarnKm) {
        urgency = ReminderUrgency.dueSoon;
        remainingText = '${diff.toStringAsFixed(0)} km remaining';
      } else {
        urgency = ReminderUrgency.upcoming;
        remainingText = '${diff.toStringAsFixed(0)} km remaining';
      }

      reminders.add(
        VehicleReminder(
          type: ReminderType.service,
          title: 'Scheduled Service',
          subtitle: 'General Maintenance',
          dueText: 'Due at ${nextOdo.toStringAsFixed(0)} km',
          remainingText: remainingText,
          urgency: urgency,
          icon: Icons.build_rounded,
        ),
      );
    }

    // Sort by urgency: Overdue (0) -> Due Today (1) -> Due Soon (2) -> Upcoming (3)
    reminders.sort((a, b) => a.urgency.sortWeight.compareTo(b.urgency.sortWeight));

    return reminders;
  }
}
