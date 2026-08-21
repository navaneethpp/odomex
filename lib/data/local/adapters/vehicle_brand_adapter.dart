import 'package:hive_ce/hive.dart';
import 'package:odomex/models/vehicle.dart';

/// Hive TypeAdapter for [VehicleBrand] enum.
class VehicleBrandAdapter extends TypeAdapter<VehicleBrand> {
  @override
  final int typeId = 1;

  @override
  VehicleBrand read(BinaryReader reader) {
    final raw = reader.read();
    if (raw is int) {
      if (raw >= 0 && raw < VehicleBrand.values.length) {
        return VehicleBrand.values[raw];
      }
    } else if (raw is String) {
      for (final b in VehicleBrand.values) {
        if (b.name == raw || b.id == raw) {
          return b;
        }
      }
    }
    return VehicleBrand.honda; // fallback
  }

  @override
  void write(BinaryWriter writer, VehicleBrand obj) {
    writer.write(obj.index);
  }
}
