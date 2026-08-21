import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:odomex/core/notifications/notification_service.dart';
import 'package:odomex/core/theme/app_theme.dart';
import 'package:odomex/core/theme/app_theme_mode.dart';
import 'package:odomex/data/local/data_sources/vehicle_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_record_local_data_source.dart';
import 'package:odomex/data/local/hive_boxes.dart';
import 'package:odomex/data/local/hive_registrar.dart';
import 'package:odomex/data/sample_vehicle_records.dart';
import 'package:odomex/data/vehicles.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/providers/theme_provider.dart';
import 'package:odomex/routes/app_routes.dart';

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

  // 6. Initialize notification service safely without blocking app startup on error
  try {
    await NotificationService.instance.initialize();
  } catch (e, st) {
    debugPrint('Failed to initialize NotificationService: $e\n$st');
  }

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

      // Routing via AppStartupScreen at '/'
      initialRoute: AppRoutes.root,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
