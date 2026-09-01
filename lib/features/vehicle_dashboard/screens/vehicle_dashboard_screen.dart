import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_durations.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_dashboard/providers/vehicle_dashboard_provider.dart';
import 'package:odomex/features/vehicle_dashboard/widgets/dashboard_header.dart';
import 'package:odomex/features/vehicle_dashboard/widgets/odometer_summary_card.dart';
import 'package:odomex/features/vehicle_dashboard/widgets/recent_records_section.dart';
import 'package:odomex/features/vehicle_dashboard/widgets/reminder_section.dart';
import 'package:odomex/features/vehicle_dashboard/widgets/usage_overview_section.dart';
import 'package:odomex/features/vehicle_dashboard/widgets/vehicle_details_button.dart';
import 'package:odomex/features/vehicle_records/widgets/add_vehicle_record_sheet.dart';
import 'package:odomex/routes/app_routes.dart';
import 'package:odomex/widgets/animated_number_text.dart';
import 'package:odomex/widgets/screen_container.dart';

/// Primary dashboard screen for an individual vehicle.
///
/// Gives the user a quick understanding of period usage, daily travel,
/// daily expenses, upcoming reminders, and recent activity with synchronized
/// numerical counter animations.
class VehicleDashboardScreen extends ConsumerStatefulWidget {
  const VehicleDashboardScreen({
    super.key,
    required this.vehicleId,
  });

  final String vehicleId;

  @override
  ConsumerState<VehicleDashboardScreen> createState() =>
      _VehicleDashboardScreenState();
}

class _VehicleDashboardScreenState extends ConsumerState<VehicleDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _counterController;
  late Animation<double> _counterAnimation;

  @override
  void initState() {
    super.initState();
    _counterController = AnimationController(
      vsync: this,
      duration: AppDurations.counterAnimation,
    );
    _counterAnimation = CurvedAnimation(
      parent: _counterController,
      curve: AppDurations.counterCurve,
    );
    _counterController.forward();
  }

  @override
  void didUpdateWidget(covariant VehicleDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.vehicleId != oldWidget.vehicleId) {
      _counterController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _counterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardData =
        ref.watch(vehicleDashboardProvider(widget.vehicleId));
    final selectedRange =
        ref.watch(dashboardRangeProvider(widget.vehicleId));

    if (dashboardData == null) {
      return ScreenContainer(
        title: 'Vehicle Dashboard',
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

    final vehicle = dashboardData.vehicle;

    return SynchronizedCounterScope(
      animation: _counterAnimation,
      child: ScreenContainer(
        title: vehicle.model,
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.vehicleSettings,
                arguments: widget.vehicleId,
              );
            },
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Vehicle Settings',
          ),
        ],
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showAddVehicleRecordSheet(
              context: context,
              vehicleId: widget.vehicleId,
            );
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Record'),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── 1. Top Identity Header ───────────────────
              DashboardHeader(vehicle: vehicle),

              const SizedBox(height: AppSizes.spacingLg),

              // ── 2. Current Odometer Highlight ────────────
              OdometerSummaryCard(
                vehicle: vehicle,
                odometerReading: dashboardData.effectiveOdometerReading,
              ),

              const SizedBox(height: AppSizes.spacingLg),

              // ── 3. Period Usage & Cost Overview ──────────
              UsageOverviewSection(
                periodSummary: dashboardData.periodSummary,
                selectedRange: selectedRange,
                onRangeSelected: (range) {
                  ref
                      .read(dashboardRangeProvider(widget.vehicleId).notifier)
                      .state = range;
                },
              ),

              const SizedBox(height: AppSizes.spacingLg),

              // ── 4. Upcoming Reminders & Maintenance ──────
              ReminderSection(reminders: dashboardData.reminders),

              const SizedBox(height: AppSizes.spacingLg),

              // ── 5. Recent Activity (Last 10 Records) ─────
              RecentRecordsSection(
                vehicleId: widget.vehicleId,
                records: dashboardData.recentRecords,
                totalRecordsCount: dashboardData.totalRecordsCount,
              ),

              const SizedBox(height: AppSizes.spacingLg),

              // ── 6. Full Specifications & Details Action ──
              VehicleDetailsButton(vehicleId: widget.vehicleId),
            ],
          ),
        ),
      ),
    );
  }
}
