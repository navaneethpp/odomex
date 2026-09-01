import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:odomex/core/notifications/notification_service.dart';
import 'package:odomex/core/theme/app_theme.dart';
import 'package:odomex/core/theme/app_theme_mode.dart';
import 'package:odomex/data/local/data_sources/app_settings_local_data_source.dart';
import 'package:odomex/data/local/hive_boxes.dart';
import 'package:odomex/data/local/hive_registrar.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_settings/models/effective_vehicle_settings.dart';
import 'package:odomex/features/vehicle_settings/providers/vehicle_settings_provider.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/providers/notification_settings_provider.dart';
import 'package:odomex/providers/theme_provider.dart';
import 'package:odomex/providers/vehicle_provider.dart';
import 'package:odomex/routes/app_routes.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 1. Initialize Hive
  await Hive.initFlutter();

  // 2. Register all TypeAdapters
  registerHiveAdapters();

  // 3. Open persistent boxes
  await Hive.openBox<Vehicle>(HiveBoxes.vehicles);
  await Hive.openBox<VehicleRecord>(HiveBoxes.vehicleRecords);
  final settingsBox = await Hive.openBox<dynamic>(HiveBoxes.appSettings);
  await Hive.openBox<dynamic>(HiveBoxes.vehicleSettings);
  await Hive.openBox<dynamic>(HiveBoxes.vehiclePreferences);

  // 4. Initialize notification service safely without blocking app startup on error
  try {
    await NotificationService.instance.initialize();
    final appSettingsDataSource = HiveAppSettingsLocalDataSource(settingsBox: settingsBox);
    final notificationSettings = appSettingsDataSource.getNotificationSettings();
    await NotificationService.instance.syncDailyActivitySchedule(
      masterEnabled: notificationSettings.enabled,
      dailyActivityEnabled: notificationSettings.dailyActivity,
      hour: notificationSettings.dailyActivityReminderHour,
      minute: notificationSettings.dailyActivityReminderMinute,
    );
  } catch (e, st) {
    debugPrint('Failed to initialize NotificationService: $e\n$st');
  }

  // 5. Remove native splash once initialization is ready
  FlutterNativeSplash.remove();

  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshNotifications();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('[Notifications] App resumed: Re-checking actual OS notification permissions...');
      _refreshNotifications();
    }
  }

  /// Refreshes permissions and re-syncs all notification schedules,
  /// including vehicle-specific PUC, insurance, service and oil change reminders.
  void _refreshNotifications() {
    // 1. Refresh OS permission state
    ref.read(notificationPermissionProvider.notifier).refresh();

    // 2. Push current vehicle + effective settings context into the notifier,
    //    then refresh schedules. This approach avoids a circular provider dependency
    //    (notificationSettingsProvider → vehicleProvider → vehicleRecordProvider → ...).
    final vehicles = ref.read(vehicleProvider);
    final effectiveSettings = _buildEffectiveSettingsMap(vehicles);

    ref.read(notificationSettingsProvider.notifier)
      ..setVehicleContext(
        vehicles: vehicles,
        effectiveSettings: effectiveSettings,
      )
      ..refreshPermissionAndSchedules();
  }

  /// Builds a map of vehicleId → EffectiveVehicleSettings for all vehicles.
  Map<String, EffectiveVehicleSettings> _buildEffectiveSettingsMap(
    List<Vehicle> vehicles,
  ) {
    final result = <String, EffectiveVehicleSettings>{};
    for (final vehicle in vehicles) {
      result[vehicle.id] = ref.read(effectiveVehicleSettingsProvider(vehicle.id));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(appThemeModeProvider);

    // Watch vehicle list changes and keep notification vehicle context in sync.
    // This ensures reminder schedules are updated whenever vehicles are added,
    // edited, or deleted while the app is running.
    ref.listen(vehicleProvider, (previous, next) {
      if (previous != next) {
        final effectiveSettings = _buildEffectiveSettingsMap(next);
        ref.read(notificationSettingsProvider.notifier).setVehicleContext(
          vehicles: next,
          effectiveSettings: effectiveSettings,
        );
      }
    });

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
