import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_preferences/widgets/vehicle_action_sheet.dart';
import 'package:odomex/features/vehicle_records/widgets/add_vehicle_record_sheet.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/providers/vehicle_preferences_provider.dart';
import 'package:odomex/providers/vehicle_provider.dart';
import 'package:odomex/routes/app_routes.dart';
import 'package:odomex/screens/HomeScreen/widgets/vehicle_card.dart';
import 'package:odomex/widgets/screen_container.dart';

/// Home screen — displays all vehicles from the [vehicleProvider].
///
/// Automatically rebuilds when the vehicle list changes (e.g. after a vehicle
/// is added, pinned, or updated).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _viewVehicle(BuildContext context, WidgetRef ref, Vehicle vehicle) {
    // Record the access BEFORE navigating so the list is already sorted
    // correctly when the user returns via the back button.
    ref.read(vehicleProvider.notifier).markVehicleAsAccessed(vehicle.id);

    Navigator.pushNamed(
      context,
      AppRoutes.vehicleDashboard,
      // Pass only the ID — VehicleDashboardScreen fetches up-to-date state
      // from Riverpod rather than working from a potentially stale object.
      arguments: vehicle.id,
    );
  }

  void _addVehicle(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.addVehicle);
  }

  void _addRecord(BuildContext context, Vehicle vehicle) {
    showAddVehicleRecordSheet(
      context: context,
      vehicleId: vehicle.id,
    );
  }

  void _showVehicleActions(
    BuildContext context,
    WidgetRef ref,
    Vehicle vehicle,
    bool isPinned,
  ) {
    showVehicleActionSheet(
      context: context,
      vehicle: vehicle,
      isPinned: isPinned,
      onTogglePin: () async {
        final newPinned = await ref
            .read(vehiclePreferencesProvider.notifier)
            .togglePin(vehicle.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                newPinned ? 'Vehicle pinned' : 'Vehicle unpinned',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehicleProvider);
    final preferences = ref.watch(vehiclePreferencesProvider);

    return ScreenContainer(
      title: 'Available Vehicles',
      showBackButton: false,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.settings);
          },
          icon: const Icon(Icons.settings_outlined),
          tooltip: 'Settings',
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addVehicle(context),
        child: const Icon(Icons.add),
      ),
      child: vehicles.isEmpty
          ? _buildEmptyState(context)
          : ListView.separated(
              itemCount: vehicles.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSizes.spacingMd),
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                final isPinned = preferences[vehicle.id]?.isPinned ?? false;

                return VehicleCard(
                  vehicle: vehicle,
                  isPinned: isPinned,
                  onView: () => _viewVehicle(context, ref, vehicle),
                  onAdd: () => _addRecord(context, vehicle),
                  onLongPress: () =>
                      _showVehicleActions(context, ref, vehicle, isPinned),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: AppSizes.iconXl * 2,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSizes.spacingLg),
          Text(
            'No vehicles yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSm),
          Text(
            'Tap + to add your first vehicle',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
