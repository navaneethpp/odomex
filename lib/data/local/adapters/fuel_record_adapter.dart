import 'package:hive_ce/hive.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';

/// Hive TypeAdapter for [FuelRecord].
class FuelRecordAdapter extends TypeAdapter<FuelRecord> {
  @override
  final int typeId = 4;

  @override
  FuelRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return FuelRecord(
      id: fields[0] as String? ?? '',
      vehicleId: fields[1] as String? ?? '',
      date: fields[2] as DateTime? ?? DateTime.now(),
      quantity: (fields[3] as num?)?.toDouble() ?? 0.0,
      cost: (fields[4] as num?)?.toDouble() ?? 0.0,
      odometerReading: (fields[5] as num?)?.toDouble(),
      station: fields[6] as String?,
      notes: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FuelRecord obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.vehicleId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.cost)
      ..writeByte(5)
      ..write(obj.odometerReading)
      ..writeByte(6)
      ..write(obj.station)
      ..writeByte(7)
      ..write(obj.notes);
  }
}
