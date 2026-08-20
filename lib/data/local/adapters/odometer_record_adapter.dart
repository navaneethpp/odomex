import 'package:hive_ce/hive.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';

/// Hive TypeAdapter for [OdometerRecord].
class OdometerRecordAdapter extends TypeAdapter<OdometerRecord> {
  @override
  final int typeId = 3;

  @override
  OdometerRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return OdometerRecord(
      id: fields[0] as String? ?? '',
      vehicleId: fields[1] as String? ?? '',
      date: fields[2] as DateTime? ?? DateTime.now(),
      odometer: (fields[3] as num?)?.toDouble() ?? 0.0,
      notes: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OdometerRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.vehicleId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.odometer)
      ..writeByte(4)
      ..write(obj.notes);
  }
}
