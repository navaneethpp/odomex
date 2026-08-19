import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_theme.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/routes/app_routes.dart';
import 'package:odomex/screens/AddVehicleScreen/add_vehicle_screen.dart';
import 'package:odomex/screens/HomeScreen/home_screen.dart';
import 'package:odomex/screens/VehicleDetailsScreen/vehicle_details.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Routing
      initialRoute: AppRoutes.home,

      routes: {
        AppRoutes.home: (context) => const HomeScreen(),

        AppRoutes.vehicleDetails: (context) {
          final vehicle =
              ModalRoute.of(context)!.settings.arguments as Vehicle;
          return VehicleDetailsScreen(vehicle: vehicle);
        },

        AppRoutes.addVehicle: (context) => const AddVehicleScreen(),
      },
    );
  }
}
