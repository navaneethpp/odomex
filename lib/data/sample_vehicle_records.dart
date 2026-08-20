import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';

/// Realistic sample historical activity records for mock vehicles.
///
/// Spans the last 60-90 days with logically increasing odometer progressions,
/// realistic fuel refills, oil changes, and maintenance services.
class SampleVehicleRecords {
  SampleVehicleRecords._();

  static List<VehicleRecord> get records {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      // ═══════════════════════════════════════════════════════════════════════
      // VEHICLE 001: Honda Activa 5G (Current Odo: 25,450 km)
      // ═══════════════════════════════════════════════════════════════════════
      OdometerRecord(
        id: 'rec_activa_001',
        vehicleId: 'vehicle_001',
        date: today.subtract(const Duration(days: 60)),
        createdAt: today.subtract(const Duration(days: 60)),
        odometer: 24100,
        notes: 'Monthly odometer check',
      ),
      OdometerRecord(
        id: 'rec_activa_002',
        vehicleId: 'vehicle_001',
        date: today.subtract(const Duration(days: 52)),
        createdAt: today.subtract(const Duration(days: 52)),
        odometer: 24240,
      ),
      FuelRecord(
        id: 'rec_activa_003',
        vehicleId: 'vehicle_001',
        date: today.subtract(const Duration(days: 45)),
        createdAt: today.subtract(const Duration(days: 45)),
        quantity: 4.8,
        cost: 510,
        odometerReading: 24380,
        station: 'IOCL Kochi',
        notes: 'Full tank refill',
      ),
      OdometerRecord(
        id: 'rec_activa_004',
        vehicleId: 'vehicle_001',
        date: today.subtract(const Duration(days: 38)),
        createdAt: today.subtract(const Duration(days: 38)),
        odometer: 24520,
      ),
      OilChangeRecord(
        id: 'rec_activa_005',
        vehicleId: 'vehicle_001',
        date: today.subtract(const Duration(days: 30)),
        createdAt: today.subtract(const Duration(days: 30)),
        odometerReading: 24700,
        oilType: '10W-30 MB',
        quantity: 0.8,
        cost: 450,
        notes: 'Engine oil replacement at service center',
      ),
      FuelRecord(
        id: 'rec_activa_006',
        vehicleId: 'vehicle_001',
        date: today.subtract(const Duration(days: 25)),
        createdAt: today.subtract(const Duration(days: 25)),
        quantity: 5.0,
        cost: 535,
        odometerReading: 24860,
        station: 'BPCL Edappally',
      ),
      ServiceRecord(
        id: 'rec_activa_007',
        vehicleId: 'vehicle_001',
        date: today.subtract(const Duration(days: 18)),
        createdAt: today.subtract(const Duration(days: 18)),
        serviceType: ServiceType.generalService,
        description: 'Periodic maintenance & brake tightening',
        odometerReading: 25020,
        cost: 1150,
      ),
      FuelRecord(
        id: 'rec_activa_008',
        vehicleId: 'vehicle_001',
        date: today.subtract(const Duration(days: 10)),
        createdAt: today.subtract(const Duration(days: 10)),
        quantity: 5.2,
        cost: 550,
        odometerReading: 25210,
        station: 'HPCL Kakkanad',
      ),
      OdometerRecord(
        id: 'rec_activa_009',
        vehicleId: 'vehicle_001',
        date: today.subtract(const Duration(days: 5)),
        createdAt: today.subtract(const Duration(days: 5)),
        odometer: 25330,
      ),
      OdometerRecord(
        id: 'rec_activa_010',
        vehicleId: 'vehicle_001',
        date: today.subtract(const Duration(days: 3)),
        createdAt: today.subtract(const Duration(days: 3)),
        odometer: 25380,
      ),
      OdometerRecord(
        id: 'rec_activa_011',
        vehicleId: 'vehicle_001',
        date: today.subtract(const Duration(days: 1)),
        createdAt: today.subtract(const Duration(days: 1)),
        odometer: 25415,
      ),
      OdometerRecord(
        id: 'rec_activa_012',
        vehicleId: 'vehicle_001',
        date: today,
        createdAt: today,
        odometer: 25450,
        notes: 'Trip to office & back',
      ),

      // ═══════════════════════════════════════════════════════════════════════
      // VEHICLE 002: Hero Splendor Plus (Current Odo: 12,300 km)
      // ═══════════════════════════════════════════════════════════════════════
      OdometerRecord(
        id: 'rec_splendor_001',
        vehicleId: 'vehicle_002',
        date: today.subtract(const Duration(days: 45)),
        createdAt: today.subtract(const Duration(days: 45)),
        odometer: 11500,
      ),
      FuelRecord(
        id: 'rec_splendor_002',
        vehicleId: 'vehicle_002',
        date: today.subtract(const Duration(days: 30)),
        createdAt: today.subtract(const Duration(days: 30)),
        quantity: 8.5,
        cost: 900,
        odometerReading: 11800,
        station: 'HPCL MG Road',
      ),
      ServiceRecord(
        id: 'rec_splendor_003',
        vehicleId: 'vehicle_002',
        date: today.subtract(const Duration(days: 15)),
        createdAt: today.subtract(const Duration(days: 15)),
        serviceType: ServiceType.oilService,
        description: 'Oil change and chain lubrication',
        odometerReading: 12100,
        cost: 650,
      ),
      OdometerRecord(
        id: 'rec_splendor_004',
        vehicleId: 'vehicle_002',
        date: today.subtract(const Duration(days: 2)),
        createdAt: today.subtract(const Duration(days: 2)),
        odometer: 12280,
      ),
      OdometerRecord(
        id: 'rec_splendor_005',
        vehicleId: 'vehicle_002',
        date: today,
        createdAt: today,
        odometer: 12300,
      ),

      // ═══════════════════════════════════════════════════════════════════════
      // VEHICLE 004: KTM Duke 200 (Current Odo: 18,750 km)
      // ═══════════════════════════════════════════════════════════════════════
      OdometerRecord(
        id: 'rec_duke_001',
        vehicleId: 'vehicle_004',
        date: today.subtract(const Duration(days: 30)),
        createdAt: today.subtract(const Duration(days: 30)),
        odometer: 17800,
      ),
      FuelRecord(
        id: 'rec_duke_002',
        vehicleId: 'vehicle_004',
        date: today.subtract(const Duration(days: 20)),
        createdAt: today.subtract(const Duration(days: 20)),
        quantity: 10.0,
        cost: 1080,
        odometerReading: 18150,
        station: 'Shell Vytilla',
      ),
      OilChangeRecord(
        id: 'rec_duke_003',
        vehicleId: 'vehicle_004',
        date: today.subtract(const Duration(days: 12)),
        createdAt: today.subtract(const Duration(days: 12)),
        odometerReading: 18400,
        oilType: '15W-50 Fully Synthetic',
        quantity: 1.5,
        cost: 1250,
        notes: 'Motul 7100 4T',
      ),
      OdometerRecord(
        id: 'rec_duke_004',
        vehicleId: 'vehicle_004',
        date: today.subtract(const Duration(days: 2)),
        createdAt: today.subtract(const Duration(days: 2)),
        odometer: 18690,
      ),
      OdometerRecord(
        id: 'rec_duke_005',
        vehicleId: 'vehicle_004',
        date: today,
        createdAt: today,
        odometer: 18750,
      ),
    ];
  }
}
