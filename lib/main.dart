import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_theme.dart';
import 'package:odomex/routes/app_routes.dart';
import 'package:odomex/screens/AddVehicleScreen/add_vehicle_screen.dart';
import 'package:odomex/screens/HomeScreen/home_screen.dart';
import 'package:odomex/screens/VehicleDetailsScreen/vehicle_details.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
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

        // Vehicle Details receives a vehicleId (String) — not a Vehicle object.
        // The screen looks up the current vehicle from Riverpod so it always
        // reflects up-to-date state.
        AppRoutes.vehicleDetails: (context) {
          final vehicleId =
              ModalRoute.of(context)!.settings.arguments as String;
          return VehicleDetailsScreen(vehicleId: vehicleId);
        },

        AppRoutes.addVehicle: (context) => const AddVehicleScreen(),
      },
    );
  }
}
