import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:odomex/core/theme/app_theme.dart';
import 'package:odomex/data/local/data_sources/vehicle_local_data_source.dart';
import 'package:odomex/data/local/hive_boxes.dart';
import 'package:odomex/data/local/hive_registrar.dart';
import 'package:odomex/data/vehicles.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/routes/app_routes.dart';
import 'package:odomex/screens/AddVehicleScreen/add_vehicle_screen.dart';
import 'package:odomex/screens/HomeScreen/home_screen.dart';
import 'package:odomex/screens/VehicleDetailsScreen/vehicle_details.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Hive
  await Hive.initFlutter();

  // 2. Register all TypeAdapters
  registerHiveAdapters();

  // 3. Open persistent boxes
  final vehicleBox = await Hive.openBox<Vehicle>(HiveBoxes.vehicles);
  await Hive.openBox<VehicleRecord>(HiveBoxes.vehicleRecords);
  final settingsBox = await Hive.openBox<dynamic>(HiveBoxes.appSettings);

  // 4. Seed initial mock vehicles once if first launch
  final vehicleDataSource = HiveVehicleLocalDataSource(
    vehicleBox: vehicleBox,
    settingsBox: settingsBox,
  );
  await vehicleDataSource.seedInitialVehicles(Vehicles.vehicles);

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
