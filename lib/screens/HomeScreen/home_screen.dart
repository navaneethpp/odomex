import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/repositories/vehicles_repository.dart';
import 'package:odomex/routes/app_routes.dart';
import 'package:odomex/screens/HomeScreen/widgets/vehicle_card.dart';
import 'package:odomex/widgets/screen_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Vehicle> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  void _loadVehicles() {
    setState(() {
      _vehicles = VehiclesRepository.instance.getVehicles();
    });
  }

  void _viewVehicle(BuildContext context, Vehicle vehicle) {
    Navigator.pushNamed(
      context,
      AppRoutes.vehicleDetails,
      arguments: vehicle,
    );
  }

  /// Navigate to Add Vehicle screen and refresh the list when it returns.
  Future<void> _addVehicle(BuildContext context) async {
    final added = await Navigator.pushNamed(context, AppRoutes.addVehicle);
    if (added == true) {
      _loadVehicles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      title: 'Available Vehicles',
      showBackButton: false,

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addVehicle(context);
        },
        child: const Icon(Icons.add),
      ),

      child: _vehicles.isEmpty
          ? _buildEmptyState(context)
          : ListView.separated(
              itemCount: _vehicles.length,

              separatorBuilder: (context, index) {
                return const SizedBox(height: AppSizes.spacingMd);
              },

              itemBuilder: (context, index) {
                final vehicle = _vehicles[index];

                return VehicleCard(
                  vehicle: vehicle,

                  onView: () {
                    _viewVehicle(context, vehicle);
                  },

                  onAdd: () {
                    // TODO: Add vehicle data action (odometer, fuel, service)
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
