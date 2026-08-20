import 'package:hive_ce/hive.dart';
import 'package:odomex/data/local/adapters/fuel_record_adapter.dart';
import 'package:odomex/data/local/adapters/odometer_record_adapter.dart';
import 'package:odomex/data/local/adapters/oil_change_record_adapter.dart';
import 'package:odomex/data/local/adapters/service_record_adapter.dart';
import 'package:odomex/data/local/adapters/service_type_adapter.dart';
import 'package:odomex/data/local/adapters/vehicle_adapter.dart';
import 'package:odomex/data/local/adapters/vehicle_brand_adapter.dart';

/// Registers all Hive TypeAdapters with [Hive].
///
/// Must be called before opening any Hive boxes in `main()`.
void registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(VehicleAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(VehicleBrandAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(ServiceTypeAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(OdometerRecordAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(FuelRecordAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(ServiceRecordAdapter());
  }
  if (!Hive.isAdapterRegistered(6)) {
    Hive.registerAdapter(OilChangeRecordAdapter());
  }
}
