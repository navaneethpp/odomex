import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/data/vehicle_catalog.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/screens/AddVehicleScreen/widgets/searchable_brand_picker.dart';

void main() {
  group('VehicleType Enum Tests', () {
    test('verifies all 7 vehicle types and display properties', () {
      expect(VehicleType.values.length, 7);

      expect(VehicleType.motorcycle.displayName, 'Motorcycle');
      expect(VehicleType.motorcycle.storageKey, 'motorcycle');
      expect(VehicleType.motorcycle.icon, Icons.two_wheeler_rounded);

      expect(VehicleType.scooter.displayName, 'Scooter');
      expect(VehicleType.scooter.storageKey, 'scooter');
      expect(VehicleType.scooter.icon, Icons.moped_rounded);

      expect(VehicleType.autoRickshaw.displayName, 'Auto Rickshaw');
      expect(VehicleType.autoRickshaw.storageKey, 'auto_rickshaw');
      expect(VehicleType.autoRickshaw.icon, Icons.electric_rickshaw_rounded);

      expect(VehicleType.car.displayName, 'Car');
      expect(VehicleType.car.storageKey, 'car');
      expect(VehicleType.car.icon, Icons.directions_car_rounded);

      expect(VehicleType.pickup.displayName, 'Pickup Truck');
      expect(VehicleType.pickup.storageKey, 'pickup');
      expect(VehicleType.pickup.icon, Icons.local_shipping_rounded);

      expect(VehicleType.van.displayName, 'Van');
      expect(VehicleType.van.storageKey, 'van');
      expect(VehicleType.van.icon, Icons.airport_shuttle_rounded);

      expect(VehicleType.bus.displayName, 'Bus');
      expect(VehicleType.bus.storageKey, 'bus');
      expect(VehicleType.bus.icon, Icons.directions_bus_rounded);
    });

    test('fromStorageKey maps correctly with fallback', () {
      expect(VehicleType.fromStorageKey('car'), VehicleType.car);
      expect(VehicleType.fromStorageKey('auto_rickshaw'), VehicleType.autoRickshaw);
      expect(VehicleType.fromStorageKey('bus'), VehicleType.bus);
      expect(VehicleType.fromStorageKey('unknown_key'), VehicleType.motorcycle);
      expect(
        VehicleType.fromStorageKey(null, defaultType: VehicleType.scooter),
        VehicleType.scooter,
      );
    });
  });

  group('VehicleCatalog Tests', () {
    test('provides categorized brand lists', () {
      final bikes = VehicleCatalog.getBrandsForType(VehicleType.motorcycle);
      expect(bikes.contains(VehicleBrand.royalEnfield), true);
      expect(bikes.contains(VehicleBrand.ktm), true);
      expect(bikes.contains(VehicleBrand.marutiSuzuki), false);

      final cars = VehicleCatalog.getBrandsForType(VehicleType.car);
      expect(cars.contains(VehicleBrand.marutiSuzuki), true);
      expect(cars.contains(VehicleBrand.hyundai), true);
      expect(cars.contains(VehicleBrand.tataMotors), true);
      expect(cars.contains(VehicleBrand.royalEnfield), false);

      final autos = VehicleCatalog.getBrandsForType(VehicleType.autoRickshaw);
      expect(autos.contains(VehicleBrand.bajaj), true);
      expect(autos.contains(VehicleBrand.piaggio), true);
      expect(autos.contains(VehicleBrand.atulAuto), true);

      final buses = VehicleCatalog.getBrandsForType(VehicleType.bus);
      expect(buses.contains(VehicleBrand.ashokLeyland), true);
      expect(buses.contains(VehicleBrand.tataMotors), true);
      expect(buses.contains(VehicleBrand.volvo), true);
    });

    test('brands can belong to multiple categories', () {
      expect(VehicleCatalog.isBrandSupported(VehicleType.motorcycle, VehicleBrand.honda), true);
      expect(VehicleCatalog.isBrandSupported(VehicleType.scooter, VehicleBrand.honda), true);
      expect(VehicleCatalog.isBrandSupported(VehicleType.car, VehicleBrand.honda), true);

      expect(VehicleCatalog.isBrandSupported(VehicleType.car, VehicleBrand.tataMotors), true);
      expect(VehicleCatalog.isBrandSupported(VehicleType.pickup, VehicleBrand.tataMotors), true);
      expect(VehicleCatalog.isBrandSupported(VehicleType.van, VehicleBrand.tataMotors), true);
      expect(VehicleCatalog.isBrandSupported(VehicleType.bus, VehicleBrand.tataMotors), true);
      expect(VehicleCatalog.isBrandSupported(VehicleType.motorcycle, VehicleBrand.tataMotors), false);
    });
  });

  group('Vehicle Model Inference & Brand Display Tests', () {
    test('infers scooter for Activa / Jupiter and motorcycle for other legacy records', () {
      final legacyActiva = Vehicle(
        brand: VehicleBrand.honda,
        model: 'Honda Activa 5G',
        manufacturingYear: 2019,
        odometerReading: 25000,
        registrationNumber: 'KL 10 AB 1234',
        color: 'White',
        fuelType: 'Petrol',
        purchaseDate: DateTime(2019, 1, 1),
      );
      expect(legacyActiva.vehicleType, VehicleType.scooter);

      final legacySplendor = Vehicle(
        brand: VehicleBrand.hero,
        model: 'Hero Splendor Plus',
        manufacturingYear: 2018,
        odometerReading: 30000,
        registrationNumber: 'KL 11 CD 5678',
        color: 'Black',
        fuelType: 'Petrol',
        purchaseDate: DateTime(2018, 1, 1),
      );
      expect(legacySplendor.vehicleType, VehicleType.motorcycle);

      final legacyCar = Vehicle(
        brand: VehicleBrand.marutiSuzuki,
        model: 'Maruti Suzuki Swift VXi',
        manufacturingYear: 2021,
        odometerReading: 15000,
        registrationNumber: 'KL 07 EF 1234',
        color: 'Red',
        fuelType: 'Petrol',
        purchaseDate: DateTime(2021, 1, 1),
      );
      expect(legacyCar.vehicleType, VehicleType.car);
    });

    test('brandDisplayName resolves standard and custom brands', () {
      final standard = Vehicle(
        vehicleType: VehicleType.car,
        brand: VehicleBrand.toyota,
        model: 'Innova Crysta',
        manufacturingYear: 2022,
        odometerReading: 40000,
        registrationNumber: 'KL 07 GH 1234',
        color: 'Silver',
        fuelType: 'Diesel',
        purchaseDate: DateTime(2022, 1, 1),
      );
      expect(standard.brandDisplayName, 'Toyota');

      final custom = Vehicle(
        vehicleType: VehicleType.car,
        brand: VehicleBrand.other,
        customBrand: 'Lucid Motors',
        model: 'Air Sapphire',
        manufacturingYear: 2024,
        odometerReading: 5000,
        registrationNumber: 'KL 01 AB 9999',
        color: 'Blue',
        fuelType: 'Electric',
        purchaseDate: DateTime(2024, 1, 1),
      );
      expect(custom.brandDisplayName, 'Lucid Motors');
    });
  });

  group('SearchableBrandPicker Widget Tests', () {
    testWidgets('renders selected brand and opens search sheet to filter brands', (tester) async {
      VehicleBrand? selectedBrand = VehicleBrand.honda;
      String? customBrand;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SearchableBrandPicker(
                  vehicleType: VehicleType.car,
                  selectedBrand: selectedBrand,
                  customBrandName: customBrand,
                  onBrandSelected: (brand, custom) {
                    setState(() {
                      selectedBrand = brand;
                      customBrand = custom;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Honda'), findsOneWidget);

      // Tap picker to open sheet
      await tester.tap(find.text('Honda'));
      await tester.pumpAndSettle();

      expect(find.text('Select Car Brand'), findsOneWidget);
      expect(find.byKey(const Key('brand_search_field')), findsOneWidget);

      // Search for 'Tata'
      await tester.enterText(find.byKey(const Key('brand_search_field')), 'Tata');
      await tester.pumpAndSettle();

      expect(find.text('Tata Motors'), findsOneWidget);
      expect(find.text('Maruti Suzuki'), findsNothing);

      // Tap Tata Motors -> Sheet closes and selection is updated
      await tester.tap(find.widgetWithText(ListTile, 'Tata Motors'));
      await tester.pumpAndSettle();

      expect(find.text('Tata Motors'), findsOneWidget);
    });

    testWidgets('searches and selects VinFast with case-insensitive query', (tester) async {
      VehicleBrand? selectedBrand;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SearchableBrandPicker(
                  vehicleType: VehicleType.car,
                  selectedBrand: selectedBrand,
                  onBrandSelected: (brand, custom) {
                    setState(() {
                      selectedBrand = brand;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open sheet
      await tester.tap(find.byType(SearchableBrandPicker));
      await tester.pumpAndSettle();

      // Search lowercase "vinfast"
      await tester.enterText(find.byKey(const Key('brand_search_field')), 'vinfast');
      await tester.pumpAndSettle();

      expect(find.text('VinFast'), findsOneWidget);

      // Tap VinFast
      await tester.tap(find.widgetWithText(ListTile, 'VinFast'));
      await tester.pumpAndSettle();

      expect(find.text('VinFast'), findsOneWidget);
      expect(selectedBrand, VehicleBrand.vinfast);
    });
  });

  group('VinFast Specific Catalog & Model Tests', () {
    test('VinFast is in Car catalog and not in other categories', () {
      expect(VehicleCatalog.isBrandSupported(VehicleType.car, VehicleBrand.vinfast), true);
      expect(VehicleCatalog.isBrandSupported(VehicleType.motorcycle, VehicleBrand.vinfast), false);
      expect(VehicleCatalog.isBrandSupported(VehicleType.scooter, VehicleBrand.vinfast), false);
      expect(VehicleCatalog.isBrandSupported(VehicleType.autoRickshaw, VehicleBrand.vinfast), false);
      expect(VehicleCatalog.isBrandSupported(VehicleType.pickup, VehicleBrand.vinfast), false);
      expect(VehicleCatalog.isBrandSupported(VehicleType.van, VehicleBrand.vinfast), false);
      expect(VehicleCatalog.isBrandSupported(VehicleType.bus, VehicleBrand.vinfast), false);
    });

    test('creates VinFast VF e34 vehicle model correctly', () {
      final vinfastCar = Vehicle(
        vehicleType: VehicleType.car,
        brand: VehicleBrand.vinfast,
        model: 'VF e34',
        manufacturingYear: 2024,
        odometerReading: 1200,
        registrationNumber: 'KL 01 VF 3434',
        color: 'Deep Ocean Blue',
        fuelType: 'Electric',
        purchaseDate: DateTime(2024, 3, 1),
      );

      expect(vinfastCar.brand, VehicleBrand.vinfast);
      expect(vinfastCar.brandDisplayName, 'VinFast');
      expect(vinfastCar.model, 'VF e34');
      expect(vinfastCar.vehicleType, VehicleType.car);
    });
  });
}
