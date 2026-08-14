import 'package:flutter/material.dart';

import 'package:odomex/data/vehicles.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/routes/app_routes.dart';
import 'package:odomex/screens/HomeScreen/widgets/vehicle_card.dart';
import 'package:odomex/widgets/screen_container.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _viewVehicle(BuildContext context, Vehicle vehicle) {
    Navigator.pushNamed(
      context,
      AppRoutes.vehicleDetails,
      arguments: vehicle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      title: 'Available Vehicles',
      showBackButton: false,
      child: ListView.separated(
        itemCount: Vehicles.vehicles.length,

        separatorBuilder: (context, index) {
          return const SizedBox(height: 12);
        },

        itemBuilder: (context, index) {
          final vehicle = Vehicles.vehicles[index];

          return VehicleCard(
            vehicle: vehicle,

            onView: () {
              _viewVehicle(context, vehicle);
            },

            onAdd: () {
              // TODO: Add vehicle action
            },
          );
        },
      ),
    );
  }
}
