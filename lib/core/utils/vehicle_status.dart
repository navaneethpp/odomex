import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_colors.dart';
import 'package:odomex/models/vehicle.dart';

// ─────────────────────────────────────────────
// STATUS ENUMS
// ─────────────────────────────────────────────

/// Status of a compliance document (insurance, PUC).
enum DocumentStatus {
  /// Document is valid and not expiring within the warning window.
  active,

  /// Document is expiring within [kDocumentWarnDays] days.
  expiringSoon,

  /// Document has expired.
  expired,

  /// No document information is available.
  notAvailable,
}

/// Status of a maintenance item (oil change, service).
enum MaintenanceStatus {
  /// Maintenance is not due for some time.
  good,

  /// Maintenance is due within [kMaintenanceWarnKm] km.
  dueSoon,

  /// Maintenance is due now or overdue.
  due,

  /// Not enough information to determine status.
  notAvailable,
}

// ─────────────────────────────────────────────
// THRESHOLDS — business rules
// ─────────────────────────────────────────────

/// Number of days before expiry at which a document is considered "expiring soon".
const int kDocumentWarnDays = 30;

/// Number of km before scheduled maintenance at which it is considered "due soon".
const double kMaintenanceWarnKm = 500;

// ─────────────────────────────────────────────
// DOCUMENT STATUS
// ─────────────────────────────────────────────

/// Calculates the [DocumentStatus] for a document that expires on [expiryDate].
/// Pass null when the document information is not available.
DocumentStatus calculateDocumentStatus(DateTime? expiryDate) {
  if (expiryDate == null) return DocumentStatus.notAvailable;

  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final expiryDate0 =
      DateTime(expiryDate.year, expiryDate.month, expiryDate.day);

  if (expiryDate0.isBefore(todayDate)) return DocumentStatus.expired;
  if (expiryDate0
      .isBefore(todayDate.add(const Duration(days: kDocumentWarnDays)))) {
    return DocumentStatus.expiringSoon;
  }
  return DocumentStatus.active;
}

/// Returns the number of days until [expiryDate].
/// Negative means already expired.
int daysUntilExpiry(DateTime expiryDate) {
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);
  final expiryDate0 =
      DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
  return expiryDate0.difference(todayDate).inDays;
}

// ─────────────────────────────────────────────
// MAINTENANCE STATUS
// ─────────────────────────────────────────────

/// Calculates the [MaintenanceStatus] for oil change.
/// Returns [MaintenanceStatus.notAvailable] when data is missing.
MaintenanceStatus calculateOilChangeStatus(Vehicle vehicle) {
  final next = vehicle.nextOilChangeOdometer;
  if (next == null) return MaintenanceStatus.notAvailable;

  final remaining = next - vehicle.odometerReading;
  if (remaining <= 0) return MaintenanceStatus.due;
  if (remaining <= kMaintenanceWarnKm) return MaintenanceStatus.dueSoon;
  return MaintenanceStatus.good;
}

/// Calculates the [MaintenanceStatus] for service, based on the next service
/// odometer reading and the current odometer.
MaintenanceStatus calculateServiceStatus(Vehicle vehicle) {
  final next = vehicle.nextServiceOdometer;
  if (next == null) return MaintenanceStatus.notAvailable;

  final remaining = next - vehicle.odometerReading;
  if (remaining <= 0) return MaintenanceStatus.due;
  if (remaining <= kMaintenanceWarnKm) return MaintenanceStatus.dueSoon;
  return MaintenanceStatus.good;
}

// ─────────────────────────────────────────────
// THEME-AWARE STATUS COLORS
// ─────────────────────────────────────────────

/// Returns a theme-aware color for the given [DocumentStatus].
/// Uses [AppColors] semantic colors only.
Color documentStatusColor(DocumentStatus status, ColorScheme colorScheme) {
  switch (status) {
    case DocumentStatus.active:
      return AppColors.success;
    case DocumentStatus.expiringSoon:
      return AppColors.warning;
    case DocumentStatus.expired:
      return AppColors.error;
    case DocumentStatus.notAvailable:
      return colorScheme.onSurfaceVariant;
  }
}

/// Returns a theme-aware color for the given [MaintenanceStatus].
Color maintenanceStatusColor(
    MaintenanceStatus status, ColorScheme colorScheme) {
  switch (status) {
    case MaintenanceStatus.good:
      return AppColors.success;
    case MaintenanceStatus.dueSoon:
      return AppColors.warning;
    case MaintenanceStatus.due:
      return AppColors.error;
    case MaintenanceStatus.notAvailable:
      return colorScheme.onSurfaceVariant;
  }
}

// ─────────────────────────────────────────────
// HUMAN-READABLE LABELS
// ─────────────────────────────────────────────

String documentStatusLabel(DocumentStatus status) {
  switch (status) {
    case DocumentStatus.active:
      return 'Active';
    case DocumentStatus.expiringSoon:
      return 'Expiring Soon';
    case DocumentStatus.expired:
      return 'Expired';
    case DocumentStatus.notAvailable:
      return 'Not Added';
  }
}

String maintenanceStatusLabel(MaintenanceStatus status) {
  switch (status) {
    case MaintenanceStatus.good:
      return 'Good';
    case MaintenanceStatus.dueSoon:
      return 'Due Soon';
    case MaintenanceStatus.due:
      return 'Due Now';
    case MaintenanceStatus.notAvailable:
      return 'Unknown';
  }
}
