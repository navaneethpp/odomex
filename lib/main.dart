import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:odomex/core/theme/app_theme.dart';
import 'package:odomex/core/theme/app_theme_mode.dart';
import 'package:odomex/data/local/data_sources/vehicle_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_record_local_data_source.dart';
import 'package:odomex/data/local/hive_boxes.dart';
import 'package:odomex/data/local/hive_registrar.dart';
import 'package:odomex/data/sample_vehicle_records.dart';
import 'package:odomex/data/vehicles.dart';
import 'package:odomex/features/settings/screens/settings_screen.dart';
import 'package:odomex/features/vehicle_dashboard/screens/vehicle_dashboard_screen.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_records/screens/vehicle_records_screen.dart';
import 'package:odomex/features/vehicle_settings/screens/global_vehicle_settings_screen.dart';
import 'package:odomex/features/vehicle_settings/screens/vehicle_settings_screen.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/providers/theme_provider.dart';
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
  final recordBox = await Hive.openBox<VehicleRecord>(HiveBoxes.vehicleRecords);
  final settingsBox = await Hive.openBox<dynamic>(HiveBoxes.appSettings);
  await Hive.openBox<dynamic>(HiveBoxes.vehicleSettings);
  await Hive.openBox<dynamic>(HiveBoxes.vehiclePreferences);

  // 4. Seed initial mock vehicles once if first launch
  final vehicleDataSource = HiveVehicleLocalDataSource(
    vehicleBox: vehicleBox,
    settingsBox: settingsBox,
  );
  await vehicleDataSource.seedInitialVehicles(Vehicles.vehicles);

  // 5. Seed initial mock historical records once if first launch
  final recordDataSource = HiveVehicleRecordLocalDataSource(
    recordBox: recordBox,
    settingsBox: settingsBox,
  );
  await recordDataSource.seedInitialRecords(SampleVehicleRecords.records);

  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode.flutterThemeMode,

      // Routing
      initialRoute: AppRoutes.home,

      routes: {
        AppRoutes.home: (context) => const HomeScreen(),

        // Primary individual vehicle screen (Daily dashboard)
        AppRoutes.vehicleDashboard: (context) {
          final vehicleId =
              ModalRoute.of(context)!.settings.arguments as String;
          return VehicleDashboardScreen(vehicleId: vehicleId);
        },

        // Vehicle-specific maintenance and reminder settings
        AppRoutes.vehicleSettings: (context) {
          final vehicleId =
              ModalRoute.of(context)!.settings.arguments as String;
          return VehicleSettingsScreen(vehicleId: vehicleId);
        },

        // Global vehicle defaults
        AppRoutes.globalVehicleSettings: (context) =>
            const GlobalVehicleSettingsScreen(),

        // Deep vehicle specifications & compliance
        AppRoutes.vehicleDetails: (context) {
          final vehicleId =
              ModalRoute.of(context)!.settings.arguments as String;
          return VehicleDetailsScreen(vehicleId: vehicleId);
        },

        // Full vehicle records history
        AppRoutes.vehicleRecords: (context) {
          final vehicleId =
              ModalRoute.of(context)!.settings.arguments as String;
          return VehicleRecordsScreen(vehicleId: vehicleId);
        },

        AppRoutes.addVehicle: (context) => const AddVehicleScreen(),
        AppRoutes.settings: (context) => const SettingsScreen(),
      },
    );
  }
}
