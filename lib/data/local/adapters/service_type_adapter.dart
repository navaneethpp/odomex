import 'package:hive_ce/hive.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';

/// Hive TypeAdapter for [ServiceType] enum.
class ServiceTypeAdapter extends TypeAdapter<ServiceType> {
  @override
  final int typeId = 2;

  @override
  ServiceType read(BinaryReader reader) {
    final index = reader.readByte();
    if (index >= 0 && index < ServiceType.values.length) {
      return ServiceType.values[index];
    }
    return ServiceType.generalService;
  }

  @override
  void write(BinaryWriter writer, ServiceType obj) {
    writer.writeByte(obj.index);
  }
}
