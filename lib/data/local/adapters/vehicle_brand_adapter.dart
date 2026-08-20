import 'package:hive_ce/hive.dart';
import 'package:odomex/models/vehicle.dart';

/// Hive TypeAdapter for [VehicleBrand] enum.
class VehicleBrandAdapter extends TypeAdapter<VehicleBrand> {
  @override
  final int typeId = 1;

  @override
  VehicleBrand read(BinaryReader reader) {
    final index = reader.readByte();
    if (index >= 0 && index < VehicleBrand.values.length) {
      return VehicleBrand.values[index];
    }
    return VehicleBrand.honda; // fallback
  }

  @override
  void write(BinaryWriter writer, VehicleBrand obj) {
    writer.writeByte(obj.index);
  }
}
