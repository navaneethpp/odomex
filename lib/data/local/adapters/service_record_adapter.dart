import 'package:hive_ce/hive.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';

/// Hive TypeAdapter for [ServiceRecord].
class ServiceRecordAdapter extends TypeAdapter<ServiceRecord> {
  @override
  final int typeId = 5;

  @override
  ServiceRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return ServiceRecord(
      id: fields[0] as String? ?? '',
      vehicleId: fields[1] as String? ?? '',
      date: fields[2] as DateTime? ?? DateTime.now(),
      serviceType: fields[3] as ServiceType? ?? ServiceType.generalService,
      description: fields[4] as String? ?? '',
      odometerReading: (fields[5] as num?)?.toDouble(),
      cost: (fields[6] as num?)?.toDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, ServiceRecord obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.vehicleId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.serviceType)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.odometerReading)
      ..writeByte(6)
      ..write(obj.cost);
  }
}
