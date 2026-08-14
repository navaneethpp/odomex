import 'package:flutter/material.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/widgets/screen_container.dart';

class VehicleDetailsScreen extends StatelessWidget {
  const VehicleDetailsScreen({
    super.key,
    required this.vehicle,
  });

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return ScreenContainer(
      title: "Vehicle Details",
      showBackButton: true,
      child: Center(child: Text(vehicle.model)),
    );
  }
}

/// TODO:
/// 1. Completing the UI.
