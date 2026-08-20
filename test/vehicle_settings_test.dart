import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:odomex/data/local/data_sources/vehicle_settings_local_data_source.dart';
import 'package:odomex/data/local/hive_boxes.dart';
import 'package:odomex/features/vehicle_dashboard/utils/vehicle_reminder_calculator.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';
import 'package:odomex/features/vehicle_settings/models/global_vehicle_settings.dart';
import 'package:odomex/features/vehicle_settings/models/vehicle_settings.dart';
import 'package:odomex/features/vehicle_settings/screens/global_vehicle_settings_screen.dart';
import 'package:odomex/features/vehicle_settings/screens/vehicle_settings_screen.dart';
import 'package:odomex/features/vehicle_settings/utils/vehicle_settings_resolver.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/providers/vehicle_provider.dart';
import 'package:odomex/repositories/vehicle_settings_repository.dart';

void main() {
  final testVehicle = Vehicle(
    id: 'v1',
    brand: VehicleBrand.honda,
    model: 'Activa 5G',
    manufacturingYear: 2020,
    odometerReading: 25000,
    registrationNumber: 'KL 10 AB 1234',
    color: 'Black',
    fuelType: 'Petrol',
    purchaseDate: DateTime(2020, 1, 1),
    insuranceProvider: 'HDFC ERGO',
    insuranceStartDate: DateTime(2020, 1, 1),
    insuranceEndDate: DateTime.now().add(const Duration(days: 45)),
    pucCertificateNumber: 'PUC123',
    pucStartDate: DateTime(2020, 1, 1),
    pucEndDate: DateTime.now().add(const Duration(days: 45)),
  );

  group('GlobalVehicleSettings & VehicleSettings Models Tests', () {
    late Directory tempDir;
    late Box<dynamic> settingsBox;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('hive_veh_settings_test_');
      Hive.init(tempDir.path);
      settingsBox = await Hive.openBox<dynamic>(HiveBoxes.vehicleSettings);
    });

    tearDown(() async {
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('GlobalVehicleSettings has sensible defaults', () {
      const global = GlobalVehicleSettings();

      expect(global.serviceIntervalKm, 3000);
      expect(global.oilChangeIntervalKm, 3000);
      expect(global.serviceReminderEnabled, true);
      expect(global.oilChangeReminderEnabled, true);
      expect(global.maintenanceReminderThresholdKm, 500);
      expect(global.pucReminderEnabled, true);
      expect(global.pucReminderDays, 30);
      expect(global.insuranceReminderEnabled, true);
      expect(global.insuranceReminderDays, 30);
    });

    test('persists and isolates vehicle settings overrides per vehicle ID', () async {
      final dataSource =
          HiveVehicleSettingsLocalDataSource(settingsBox: settingsBox);
      final repository =
          VehicleSettingsRepository(localDataSource: dataSource);

      final settingsA = VehicleSettings(
        vehicleId: 'v1',
        serviceIntervalKm: 4000,
        oilChangeIntervalKm: 2500,
      );
      final settingsB = VehicleSettings(
        vehicleId: 'v2',
        serviceIntervalKm: 6000,
      );

      await repository.saveSettings(settingsA);
      await repository.saveSettings(settingsB);

      final loadedA = dataSource.getSettings('v1');
      final loadedB = dataSource.getSettings('v2');

      expect(loadedA?.serviceIntervalKm, 4000);
      expect(loadedA?.oilChangeIntervalKm, 2500);
      expect(loadedB?.serviceIntervalKm, 6000);
      expect(loadedB?.oilChangeIntervalKm, null); // uses global default
    });
  });

  group('VehicleSettingsResolver Inheritance Tests', () {
    test('inherits global defaults when no override exists', () {
      const global = GlobalVehicleSettings(
        serviceIntervalKm: 3000,
        oilChangeIntervalKm: 3000,
      );

      final effective = VehicleSettingsResolver.resolve(
        global: global,
        vehicleOverride: null,
        vehicleId: 'v1',
      );

      expect(effective.serviceIntervalKm, 3000);
      expect(effective.oilChangeIntervalKm, 3000);
      expect(effective.isUsingGlobalServiceInterval, true);
      expect(effective.isUsingAllDefaults, true);
    });

    test('applies custom override and preserves other global defaults', () {
      const global = GlobalVehicleSettings(
        serviceIntervalKm: 3000,
        oilChangeIntervalKm: 3000,
      );

      final override = VehicleSettings(
        vehicleId: 'v1',
        serviceIntervalKm: 5000, // Custom override
      );

      final effective = VehicleSettingsResolver.resolve(
        global: global,
        vehicleOverride: override,
        vehicleId: 'v1',
      );

      expect(effective.serviceIntervalKm, 5000);
      expect(effective.oilChangeIntervalKm, 3000);
      expect(effective.isUsingGlobalServiceInterval, false);
      expect(effective.isUsingGlobalOilChangeInterval, true);
      expect(effective.isUsingAllDefaults, false);
    });

    test('changing global setting propagates to inheriting vehicles but preserves overrides', () {
      var global = const GlobalVehicleSettings(serviceIntervalKm: 3000);

      final vehicleAOverride = VehicleSettings(vehicleId: 'vA'); // inherits
      final vehicleBOverride = VehicleSettings(
        vehicleId: 'vB',
        serviceIntervalKm: 5000, // custom override
      );

      var effectiveA = VehicleSettingsResolver.resolve(
        global: global,
        vehicleOverride: vehicleAOverride,
        vehicleId: 'vA',
      );
      var effectiveB = VehicleSettingsResolver.resolve(
        global: global,
        vehicleOverride: vehicleBOverride,
        vehicleId: 'vB',
      );

      expect(effectiveA.serviceIntervalKm, 3000);
      expect(effectiveB.serviceIntervalKm, 5000);

      // Global change 3,000 -> 4,000 km
      global = global.copyWith(serviceIntervalKm: 4000);

      effectiveA = VehicleSettingsResolver.resolve(
        global: global,
        vehicleOverride: vehicleAOverride,
        vehicleId: 'vA',
      );
      effectiveB = VehicleSettingsResolver.resolve(
        global: global,
        vehicleOverride: vehicleBOverride,
        vehicleId: 'vB',
      );

      expect(effectiveA.serviceIntervalKm, 4000); // dynamically updated
      expect(effectiveB.serviceIntervalKm, 5000); // preserved custom override
    });
  });

  group('VehicleReminderCalculator with EffectiveVehicleSettings Tests', () {
    test('recalculates next service odometer and respects disabled switch', () {
      final records = [
        ServiceRecord(
          id: 's1',
          vehicleId: 'v1',
          date: DateTime.now().subtract(const Duration(days: 10)),
          serviceType: ServiceType.generalService,
          description: 'Routine maintenance',
          odometerReading: 24000,
          cost: 800,
        ),
      ];

      final effective = VehicleSettingsResolver.resolve(
        global: const GlobalVehicleSettings(
          serviceIntervalKm: 5000,
          maintenanceReminderThresholdKm: 500,
        ),
        vehicleOverride: null,
        vehicleId: 'v1',
      );

      final reminders = VehicleReminderCalculator.calculateReminders(
        testVehicle,
        settings: effective,
        records: records,
      );

      final serviceReminder =
          reminders.firstWhere((r) => r.type == ReminderType.service);
      expect(serviceReminder.dueText, 'Due at 29000 km');
      expect(serviceReminder.remainingText, '4000 km remaining');
      expect(serviceReminder.urgency, ReminderUrgency.upcoming);

      // Disable service reminder
      final disabledEffective = VehicleSettingsResolver.resolve(
        global: const GlobalVehicleSettings(serviceReminderEnabled: false),
        vehicleOverride: null,
        vehicleId: 'v1',
      );
      final disabledReminders = VehicleReminderCalculator.calculateReminders(
        testVehicle,
        settings: disabledEffective,
        records: records,
      );

      expect(
        disabledReminders.any((r) => r.type == ReminderType.service),
        false,
      );
    });
  });

  group('GlobalVehicleSettingsScreen & VehicleSettingsScreen Widget Tests', () {
    testWidgets('GlobalVehicleSettingsScreen renders explanatory banner and fields',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GlobalVehicleSettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Vehicle Defaults'), findsOneWidget);
      expect(find.text('Default Vehicle Settings'), findsOneWidget);
      expect(find.text('MAINTENANCE DEFAULTS'), findsOneWidget);
      expect(find.text('Default Service Interval'), findsOneWidget);
      expect(find.text('Default Oil Change Interval'), findsOneWidget);
      expect(find.text('DOCUMENTS & COMPLIANCE DEFAULTS'), findsOneWidget);
      expect(find.text('Save Defaults'), findsOneWidget);
    });

    testWidgets('VehicleSettingsScreen renders vehicle identity and customize options',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehicleByIdProvider('v1').overrideWithValue(testVehicle),
          ],
          child: const MaterialApp(
            home: VehicleSettingsScreen(vehicleId: 'v1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Vehicle Settings'), findsOneWidget);
      expect(find.text('Honda Activa 5G'), findsOneWidget);
      expect(find.text('KL 10 AB 1234'), findsOneWidget);
      expect(find.text('MAINTENANCE'), findsOneWidget);
      expect(find.text('Service Interval'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    });
  });
}
