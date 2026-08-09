import 'package:flutter/material.dart';
import 'package:odomex/data/vehicles.dart';
import 'package:odomex/routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _viewVehicle(dynamic context) {
    Navigator.pushNamed(context, AppRoutes.vehicleDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: Vehicles.vehicles.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 8,
            ),
            child: Card(
              elevation: 4,
              child: InkWell(
                onTap: () => _viewVehicle(context),
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            Vehicles.vehicles[index].model,
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge,
                          ),
                          Text(
                            Vehicles
                                .vehicles[index]
                                .odometerReading
                                .toString(),
                            style: Theme.of(
                              context,
                            ).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.add),
                    ),
                    IconButton(
                      onPressed: () =>
                          _viewVehicle(context),
                      icon: Icon(Icons.remove_red_eye),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
