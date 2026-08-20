import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/core/utils/vehicle_status.dart';
import 'package:odomex/features/vehicle_records/widgets/add_vehicle_record_sheet.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/providers/vehicle_provider.dart';
import 'package:odomex/screens/VehicleDetailsScreen/widgets/alerts_card.dart';
import 'package:odomex/screens/VehicleDetailsScreen/widgets/compliance_card.dart';
import 'package:odomex/screens/VehicleDetailsScreen/widgets/info_list_card.dart';
import 'package:odomex/screens/VehicleDetailsScreen/widgets/maintenance_card.dart';
import 'package:odomex/screens/VehicleDetailsScreen/widgets/odometer_hero_card.dart';
import 'package:odomex/screens/VehicleDetailsScreen/widgets/section_title.dart';
import 'package:odomex/screens/VehicleDetailsScreen/widgets/status_overview_grid.dart';
import 'package:odomex/screens/VehicleDetailsScreen/widgets/vehicle_header_card.dart';
import 'package:odomex/widgets/screen_container.dart';

/// Vehicle Details dashboard — loads vehicle state from Riverpod by ID.
///
/// Accepts [vehicleId] rather than a [Vehicle] object so that it always
/// reflects the most up-to-date state: if the vehicle is updated elsewhere
/// in the app, this screen automatically rebuilds.
///
/// Information hierarchy:
///   1. Vehicle Header      — which vehicle am I looking at?
///   2. Odometer Hero       — current status (most important number)
///   3. Status Overview     — 2×2 health grid at a glance
///   4. Alerts              — anything requiring immediate attention
///   5. Maintenance         — oil change + service details
///   6. Documents           — insurance + PUC with expiry status
///   7. Vehicle Info        — static specifications
///   8. Engine Info         — fuel / displacement
class VehicleDetailsScreen extends ConsumerWidget {
  const VehicleDetailsScreen({
    super.key,
    required this.vehicleId,
  });

  final String vehicleId;

  // ─────────────────────────────────────────────
  // DATE / NUMBER HELPERS
  // ─────────────────────────────────────────────

  static final DateFormat _dateFormat = DateFormat('d MMMM yyyy');
  static final NumberFormat _numFmt = NumberFormat.decimalPattern('en_IN');

  String _fmtDate(DateTime? date) {
    if (date == null) return '—';
    return _dateFormat.format(date);
  }

  // ─────────────────────────────────────────────
  // ALERT CONSTRUCTION
  // ─────────────────────────────────────────────

  List<VehicleAlert> _buildAlerts(Vehicle vehicle) {
    final alerts = <VehicleAlert>[];

    // Oil change
    final oilStatus = calculateOilChangeStatus(vehicle);
    final next = vehicle.nextOilChangeOdometer;
    if (oilStatus == MaintenanceStatus.due) {
      alerts.add(const VehicleAlert(
        icon: Icons.oil_barrel_outlined,
        title: 'Oil change is overdue',
        subtitle: 'Current reading has passed the service interval.',
        severity: AlertSeverity.critical,
      ));
    } else if (oilStatus == MaintenanceStatus.dueSoon && next != null) {
      final remaining = next - vehicle.odometerReading;
      alerts.add(VehicleAlert(
        icon: Icons.oil_barrel_outlined,
        title: 'Oil change due soon',
        subtitle: '${_numFmt.format(remaining)} km remaining.',
      ));
    }

    // Service
    final svcStatus = calculateServiceStatus(vehicle);
    final nextSvc = vehicle.nextServiceOdometer;
    if (svcStatus == MaintenanceStatus.due) {
      alerts.add(const VehicleAlert(
        icon: Icons.build_circle_outlined,
        title: 'Service is overdue',
        subtitle: 'Current reading has passed the service milestone.',
        severity: AlertSeverity.critical,
      ));
    } else if (svcStatus == MaintenanceStatus.dueSoon && nextSvc != null) {
      final remaining = nextSvc - vehicle.odometerReading;
      alerts.add(VehicleAlert(
        icon: Icons.build_circle_outlined,
        title: 'Service due soon',
        subtitle: '${_numFmt.format(remaining)} km remaining.',
      ));
    }

    // Insurance
    if (vehicle.hasInsurance) {
      final insStatus = calculateDocumentStatus(vehicle.insuranceEndDate);
      if (insStatus == DocumentStatus.expired) {
        alerts.add(VehicleAlert(
          icon: Icons.shield_outlined,
          title: 'Insurance has expired',
          subtitle: _fmtDate(vehicle.insuranceEndDate),
          severity: AlertSeverity.critical,
        ));
      } else if (insStatus == DocumentStatus.expiringSoon &&
          vehicle.insuranceEndDate != null) {
        final days = daysUntilExpiry(vehicle.insuranceEndDate!);
        alerts.add(VehicleAlert(
          icon: Icons.shield_outlined,
          title: 'Insurance expires in $days ${days == 1 ? 'day' : 'days'}',
          subtitle: _fmtDate(vehicle.insuranceEndDate),
        ));
      }
    }

    // PUC
    if (vehicle.hasPuc) {
      final pucStatus = calculateDocumentStatus(vehicle.pucEndDate);
      if (pucStatus == DocumentStatus.expired) {
        alerts.add(VehicleAlert(
          icon: Icons.verified_outlined,
          title: 'PUC has expired',
          subtitle: _fmtDate(vehicle.pucEndDate),
          severity: AlertSeverity.critical,
        ));
      } else if (pucStatus == DocumentStatus.expiringSoon &&
          vehicle.pucEndDate != null) {
        final days = daysUntilExpiry(vehicle.pucEndDate!);
        alerts.add(VehicleAlert(
          icon: Icons.verified_outlined,
          title: 'PUC expires in $days ${days == 1 ? 'day' : 'days'}',
          subtitle: _fmtDate(vehicle.pucEndDate),
        ));
      }
    }

    return alerts;
  }

  // ─────────────────────────────────────────────
  // STATUS SUBTITLE HELPERS
  // ─────────────────────────────────────────────

  String _oilChangeSubtitle(Vehicle vehicle) {
    final next = vehicle.nextOilChangeOdometer;
    if (next == null) return 'Unknown';
    final remaining = next - vehicle.odometerReading;
    if (remaining <= 0) return 'Due now';
    return '${_numFmt.format(remaining)} km left';
  }

  String _serviceSubtitle(Vehicle vehicle) {
    final next = vehicle.nextServiceOdometer;
    if (next == null) return 'Unknown';
    final remaining = next - vehicle.odometerReading;
    if (remaining <= 0) return 'Due now';
    return '${_numFmt.format(remaining)} km left';
  }

  String _insuranceSubtitle(Vehicle vehicle) {
    final status = vehicle.hasInsurance
        ? calculateDocumentStatus(vehicle.insuranceEndDate)
        : DocumentStatus.notAvailable;
    if (status == DocumentStatus.notAvailable) return 'Not added';
    if (status == DocumentStatus.expiringSoon &&
        vehicle.insuranceEndDate != null) {
      final days = daysUntilExpiry(vehicle.insuranceEndDate!);
      return 'Exp. in $days d';
    }
    return documentStatusLabel(status);
  }

  String _pucSubtitle(Vehicle vehicle) {
    final status = vehicle.hasPuc
        ? calculateDocumentStatus(vehicle.pucEndDate)
        : DocumentStatus.notAvailable;
    if (status == DocumentStatus.notAvailable) return 'Not added';
    if (status == DocumentStatus.expiringSoon && vehicle.pucEndDate != null) {
      final days = daysUntilExpiry(vehicle.pucEndDate!);
      return 'Exp. in $days d';
    }
    return documentStatusLabel(status);
  }

  // ─────────────────────────────────────────────
  void _addRecord(BuildContext context) {
    showAddVehicleRecordSheet(
      context: context,
      vehicleId: vehicleId,
    );
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicle = ref.watch(vehicleByIdProvider(vehicleId));

    // Guard: vehicle may have been removed while this screen was open.
    if (vehicle == null) {
      return ScreenContainer(
        title: 'Vehicle',
        showBackButton: true,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.no_crash_outlined,
                size: AppSizes.iconXl * 2,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSizes.spacingLg),
              Text(
                'Vehicle not found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    final alerts = _buildAlerts(vehicle);
    final oilStatus = calculateOilChangeStatus(vehicle);
    final svcStatus = calculateServiceStatus(vehicle);
    final insStatus = vehicle.hasInsurance
        ? calculateDocumentStatus(vehicle.insuranceEndDate)
        : DocumentStatus.notAvailable;
    final pucStatus = vehicle.hasPuc
        ? calculateDocumentStatus(vehicle.pucEndDate)
        : DocumentStatus.notAvailable;

    return ScreenContainer(
      title: vehicle.model,
      showBackButton: true,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addRecord(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Record'),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 1. Vehicle Header ──────────────────────
            VehicleHeaderCard(vehicle: vehicle),

            const SizedBox(height: AppSizes.spacingLg),

            // ── 2. Odometer Hero ───────────────────────
            OdometerHeroCard(odometerReading: vehicle.odometerReading),

            const SizedBox(height: AppSizes.spacingLg),

            // ── 3. Status Overview ─────────────────────
            const SectionTitle(title: 'Vehicle Status'),

            StatusOverviewGrid(
              oilChangeStatus: oilStatus,
              oilChangeSubtitle: _oilChangeSubtitle(vehicle),
              serviceStatus: svcStatus,
              serviceSubtitle: _serviceSubtitle(vehicle),
              insuranceStatus: insStatus,
              insuranceSubtitle: _insuranceSubtitle(vehicle),
              pucStatus: pucStatus,
              pucSubtitle: _pucSubtitle(vehicle),
            ),

            const SizedBox(height: AppSizes.spacingLg),

            // ── 4. Alerts ──────────────────────────────
            AlertsCard(alerts: alerts),

            const SizedBox(height: AppSizes.spacingLg),

            // ── 5. Maintenance ─────────────────────────
            const SectionTitle(title: 'Maintenance'),
            MaintenanceCard(vehicle: vehicle),

            const SizedBox(height: AppSizes.spacingLg),

            // ── 6. Documents & Compliance ──────────────
            const SectionTitle(title: 'Documents & Compliance'),
            ComplianceCard(vehicle: vehicle),

            const SizedBox(height: AppSizes.spacingLg),

            // ── 7. Vehicle Information ─────────────────
            const SectionTitle(title: 'Vehicle Information'),
            InfoListCard(
              rows: [
                InfoRow(label: 'Brand', value: vehicle.brand.displayName),
                InfoRow(
                    label: 'Year',
                    value: vehicle.manufacturingYear.toString()),
                InfoRow(
                    label: 'Registration',
                    value: vehicle.registrationNumber,
                    fullWidth: true),
                InfoRow(label: 'Color', value: vehicle.color),
                InfoRow(
                    label: 'Purchase Date',
                    value: _fmtDate(vehicle.purchaseDate)),
              ],
            ),

            const SizedBox(height: AppSizes.spacingLg),

            // ── 8. Engine Information ──────────────────
            const SectionTitle(title: 'Engine Information'),
            InfoListCard(
              rows: [
                InfoRow(label: 'Fuel Type', value: vehicle.fuelType),
                InfoRow(
                  label: 'Engine',
                  value: vehicle.engineCapacity != null
                      ? '${vehicle.engineCapacity} cc'
                      : 'Electric',
                ),
              ],
            ),

            const SizedBox(height: AppSizes.spacingXl),
          ],
        ),
      ),
    );
  }
}
