import 'package:flutter/material.dart';
import 'package:odomex/models/vehicle.dart';

class VehicleDetailsScreen extends StatelessWidget {
  const VehicleDetailsScreen({
    super.key,
    required this.vehicle,
  });

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vehicle Details")),
      body: Center(child: Text(vehicle.model)),
    );
  }
}
