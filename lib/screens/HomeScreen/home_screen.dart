import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/providers/vehicle_provider.dart';
import 'package:odomex/routes/app_routes.dart';
import 'package:odomex/screens/HomeScreen/widgets/vehicle_card.dart';
import 'package:odomex/widgets/screen_container.dart';

/// Home screen — displays all vehicles from the [vehicleProvider].
///
/// Automatically rebuilds when the vehicle list changes (e.g. after a vehicle
/// is added via [AddVehicleScreen]). No manual setState() or list refresh
/// needed.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _viewVehicle(BuildContext context, WidgetRef ref, Vehicle vehicle) {
    // Record the access BEFORE navigating so the list is already sorted
    // correctly when the user returns via the back button.
    ref.read(vehicleProvider.notifier).markVehicleAsAccessed(vehicle.id);

    Navigator.pushNamed(
      context,
      AppRoutes.vehicleDetails,
      // Pass only the ID — VehicleDetailsScreen fetches up-to-date state
      // from Riverpod rather than working from a potentially stale object.
      arguments: vehicle.id,
    );
  }

  void _addVehicle(BuildContext context) {
    // No need to await a return value: Riverpod automatically notifies
    // HomeScreen when a new vehicle is added in AddVehicleScreen.
    Navigator.pushNamed(context, AppRoutes.addVehicle);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehicleProvider);

    return ScreenContainer(
      title: 'Available Vehicles',
      showBackButton: false,

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

                return VehicleCard(
                  vehicle: vehicle,

                  onView: () => _viewVehicle(context, ref, vehicle),

                  onAdd: () {
                    // Opens Add Record sheet via Vehicle Details.
                    _viewVehicle(context, ref, vehicle);
                  },
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
