import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/core/theme/app_theme_mode.dart';
import 'package:odomex/data/local/data_sources/app_settings_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_local_data_source.dart';
import 'package:odomex/data/local/data_sources/vehicle_preferences_local_data_source.dart';
import 'package:odomex/features/onboarding/screens/onboarding_screen.dart';
import 'package:odomex/features/settings/models/notification_settings.dart';
import 'package:odomex/features/settings/models/vehicle_sort_option.dart';
import 'package:odomex/features/vehicle_preferences/models/vehicle_preferences.dart';
import 'package:odomex/features/vehicle_settings/models/global_vehicle_settings.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/providers/theme_provider.dart';
import 'package:odomex/providers/vehicle_preferences_provider.dart';
import 'package:odomex/providers/vehicle_provider.dart';
import 'package:odomex/routes/app_routes.dart';
import 'package:odomex/screens/AddVehicleScreen/add_vehicle_screen.dart';
import 'package:odomex/screens/AddVehicleScreen/widgets/date_picker_field.dart';
import 'package:odomex/screens/AddVehicleScreen/widgets/searchable_brand_picker.dart';
import 'package:odomex/screens/HomeScreen/home_screen.dart';
import 'package:odomex/screens/HomeScreen/widgets/vehicle_card.dart';

class FakeAppSettingsLocalDataSource implements AppSettingsLocalDataSource {
  bool _onboardingCompleted = false;

  @override
  bool isOnboardingCompleted() => _onboardingCompleted;

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    _onboardingCompleted = completed;
  }

  @override
  AppThemeMode getThemeMode() => AppThemeMode.system;

  @override
  Future<void> saveThemeMode(AppThemeMode mode) async {}

  @override
  GlobalVehicleSettings getGlobalVehicleSettings() =>
      const GlobalVehicleSettings();

  @override
  Future<void> saveGlobalVehicleSettings(GlobalVehicleSettings settings) async {}

  @override
  VehicleSortOption getVehicleSortOption() => VehicleSortOption.lastAccessed;

  @override
  Future<void> saveVehicleSortOption(VehicleSortOption option) async {}

  @override
  bool getNotificationsEnabled() => false;

  @override
  Future<void> saveNotificationsEnabled(bool enabled) async {}

  @override
  NotificationSettings getNotificationSettings() =>
      const NotificationSettings();

  @override
  Future<void> saveNotificationSettings(NotificationSettings settings) async {}
}

class FakeVehicleLocalDataSource implements VehicleLocalDataSource {
  final Map<String, Vehicle> _vehicles = {};

  @override
  List<Vehicle> getVehicles() => _vehicles.values.toList();

  @override
  Vehicle? getVehicle(String vehicleId) => _vehicles[vehicleId];

  @override
  Future<void> addVehicle(Vehicle vehicle) async {
    _vehicles[vehicle.id] = vehicle;
  }

  @override
  Future<void> updateVehicle(Vehicle vehicle) async {
    _vehicles[vehicle.id] = vehicle;
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {
    _vehicles.remove(vehicleId);
  }

  @override
  Future<void> seedInitialVehicles(List<Vehicle> initialVehicles) async {}
}

class FakeVehiclePreferencesLocalDataSource
    implements VehiclePreferencesLocalDataSource {
  final Map<String, VehiclePreferences> _prefs = {};

  @override
  VehiclePreferences? getPreference(String vehicleId) => _prefs[vehicleId];

  @override
  Map<String, VehiclePreferences> getAllPreferences() => Map.of(_prefs);

  @override
  Future<void> savePreference(VehiclePreferences preference) async {
    _prefs[preference.vehicleId] = preference;
  }

  @override
  Future<void> deletePreference(String vehicleId) async {
    _prefs.remove(vehicleId);
  }
}

void main() {
  group('First-Time User Flow & Black Screen Prevention Tests', () {
    testWidgets(
        'Fresh install -> Onboarding -> Get Started -> Add Vehicle -> Save -> Home Screen with new vehicle',
        (tester) async {
      final fakeSettings = FakeAppSettingsLocalDataSource();
      final fakeVehicleDataSource = FakeVehicleLocalDataSource();
      final fakePrefsDataSource = FakeVehiclePreferencesLocalDataSource();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsLocalDataSourceProvider
                .overrideWithValue(fakeSettings),
            vehicleLocalDataSourceProvider
                .overrideWithValue(fakeVehicleDataSource),
            vehiclePreferencesLocalDataSourceProvider
                .overrideWithValue(fakePrefsDataSource),
          ],
          child: const MaterialApp(
            initialRoute: AppRoutes.root,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Initial screen is Onboarding
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Meet your vehicle.'), findsOneWidget);

      // 2. Advance through onboarding story to page 5
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('Get Started'), findsOneWidget);

      // 3. Tap Get Started -> Replaces route with AddVehicleScreen
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.byType(AddVehicleScreen), findsOneWidget);

      // 4. Fill required vehicle fields
      // Brand picker
      await tester.tap(find.byType(SearchableBrandPicker));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Honda').last);
      await tester.pumpAndSettle();

      // Model
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Model *'), 'Activa 6G');

      // Manufacturing Year
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Manufacturing Year *'), '2022');

      // Registration Number
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Registration Number *'),
          'KL 10 AB 1234');

      // Color
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Color *'), 'Matte Blue');

      // Fuel Type
      await tester.ensureVisible(
          find.byType(DropdownButtonFormField<String>));
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Petrol').last);
      await tester.pumpAndSettle();

      // Engine Capacity
      await tester.ensureVisible(
          find.widgetWithText(TextFormField, 'Engine Capacity *'));
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Engine Capacity *'), '110');

      // Purchase Date
      await tester.ensureVisible(find.byType(DatePickerField).first);
      await tester.tap(find.byType(DatePickerField).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Odometer
      await tester.ensureVisible(
          find.widgetWithText(TextFormField, 'Current Odometer *'));
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Current Odometer *'), '12000');

      // 5. Tap Save Vehicle
      await tester.ensureVisible(find.text('Save Vehicle'));
      await tester.tap(find.text('Save Vehicle'));
      await tester.pumpAndSettle();

      // 6. Must be on HomeScreen without black screen!
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Available Vehicles'), findsOneWidget);
      expect(find.byType(VehicleCard), findsOneWidget);
      expect(find.text('Activa 6G'), findsOneWidget);
      expect(fakeSettings.isOnboardingCompleted(), isTrue);
    });

    testWidgets(
        'Add vehicle opened from HomeScreen pops cleanly back to HomeScreen on Save',
        (tester) async {
      final fakeSettings = FakeAppSettingsLocalDataSource();
      fakeSettings._onboardingCompleted = true;
      final fakeVehicleDataSource = FakeVehicleLocalDataSource();
      final fakePrefsDataSource = FakeVehiclePreferencesLocalDataSource();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appSettingsLocalDataSourceProvider
                .overrideWithValue(fakeSettings),
            vehicleLocalDataSourceProvider
                .overrideWithValue(fakeVehicleDataSource),
            vehiclePreferencesLocalDataSourceProvider
                .overrideWithValue(fakePrefsDataSource),
          ],
          child: const MaterialApp(
            initialRoute: AppRoutes.root,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);

      // Open Add Vehicle from FloatingActionButton
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AddVehicleScreen), findsOneWidget);

      // Fill required fields
      await tester.tap(find.byType(SearchableBrandPicker));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('brand_search_field')), 'KTM');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'KTM'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Model *'), 'Duke 390');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Manufacturing Year *'), '2023');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Registration Number *'),
          'KL 07 CD 5678');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Color *'), 'Orange');

      await tester.ensureVisible(
          find.byType(DropdownButtonFormField<String>));
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Petrol').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(
          find.widgetWithText(TextFormField, 'Engine Capacity *'));
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Engine Capacity *'), '373');

      await tester.ensureVisible(find.byType(DatePickerField).first);
      await tester.tap(find.byType(DatePickerField).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(
          find.widgetWithText(TextFormField, 'Current Odometer *'));
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Current Odometer *'), '5000');

      // Tap Save Vehicle
      await tester.ensureVisible(find.text('Save Vehicle'));
      await tester.tap(find.text('Save Vehicle'));
      await tester.pumpAndSettle();

      // Returns cleanly to HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Duke 390'), findsOneWidget);
    });
  });
}
