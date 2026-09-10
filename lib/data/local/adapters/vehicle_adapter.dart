import 'package:hive_ce/hive.dart';
import 'package:odomex/models/vehicle.dart';

/// Hive TypeAdapter for [Vehicle] model.
///
/// Encapsulates serialization of all vehicle specifications, document
/// details, maintenance records, access timestamps, and engine capacity units.
///
/// Uses indexed field mapping for forward and backward schema compatibility.
class VehicleAdapter extends TypeAdapter<Vehicle> {
  @override
  final int typeId = 0;

  @override
  Vehicle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    VehicleType? vehicleType;
    if (fields[24] != null) {
      if (fields[24] is VehicleType) {
        vehicleType = fields[24] as VehicleType;
      } else if (fields[24] is String) {
        vehicleType = VehicleType.fromStorageKey(fields[24] as String);
      } else if (fields[24] is int &&
          fields[24] >= 0 &&
          fields[24] < VehicleType.values.length) {
        vehicleType = VehicleType.values[fields[24] as int];
      }
    }

    return Vehicle(
      id: fields[0] as String?,
      brand: fields[1] as VehicleBrand? ?? VehicleBrand.honda,
      model: fields[2] as String? ?? '',
      manufacturingYear: fields[3] as int? ?? DateTime.now().year,
      odometerReading: (fields[4] as num?)?.toDouble() ?? 0.0,
      registrationNumber: fields[5] as String? ?? '',
      color: fields[6] as String? ?? '',
      fuelType: fields[7] as String? ?? 'Petrol',
      engineCapacity: (fields[8] as num?)?.toDouble(),
      purchaseDate: fields[9] as DateTime? ?? DateTime.now(),
      lastServiceDate: fields[10] as DateTime?,
      nextServiceOdometer: (fields[11] as num?)?.toDouble(),
      insuranceProvider: fields[12] as String?,
      insurancePolicyNumber: fields[13] as String?,
      insuranceStartDate: fields[14] as DateTime?,
      insuranceEndDate: fields[15] as DateTime?,
      pucCertificateNumber: fields[16] as String?,
      pucStartDate: fields[17] as DateTime?,
      pucEndDate: fields[18] as DateTime?,
      oilChangeInterval: (fields[19] as num?)?.toDouble(),
      lastOilChangeOdometer: (fields[20] as num?)?.toDouble(),
      lastOilChangeDate: fields[21] as DateTime?,
      lastAccessedAt: fields[22] as DateTime?,
      engineCapacityUnit: fields[23] != null
          ? (fields[23] is EngineCapacityUnit
              ? fields[23] as EngineCapacityUnit
              : (fields[23] == 'litres'
                  ? EngineCapacityUnit.litres
                  : EngineCapacityUnit.cc))
          : (fields[8] != null ? EngineCapacityUnit.cc : null),
      vehicleType: vehicleType,
      customBrand: fields[25] as String?,
      powertrainType: fields[26] as PowertrainType?,
      isDemo: fields[27] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, Vehicle obj) {
    writer
      ..writeByte(28) // Total fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.brand)
      ..writeByte(2)
      ..write(obj.model)
      ..writeByte(3)
      ..write(obj.manufacturingYear)
      ..writeByte(4)
      ..write(obj.odometerReading)
      ..writeByte(5)
      ..write(obj.registrationNumber)
      ..writeByte(6)
      ..write(obj.color)
      ..writeByte(7)
      ..write(obj.fuelType)
      ..writeByte(8)
      ..write(obj.engineCapacity)
      ..writeByte(9)
      ..write(obj.purchaseDate)
      ..writeByte(10)
      ..write(obj.lastServiceDate)
      ..writeByte(11)
      ..write(obj.nextServiceOdometer)
      ..writeByte(12)
      ..write(obj.insuranceProvider)
      ..writeByte(13)
      ..write(obj.insurancePolicyNumber)
      ..writeByte(14)
      ..write(obj.insuranceStartDate)
      ..writeByte(15)
      ..write(obj.insuranceEndDate)
      ..writeByte(16)
      ..write(obj.pucCertificateNumber)
      ..writeByte(17)
      ..write(obj.pucStartDate)
      ..writeByte(18)
      ..write(obj.pucEndDate)
      ..writeByte(19)
      ..write(obj.oilChangeInterval)
      ..writeByte(20)
      ..write(obj.lastOilChangeOdometer)
      ..writeByte(21)
      ..write(obj.lastOilChangeDate)
      ..writeByte(22)
      ..write(obj.lastAccessedAt)
      ..writeByte(23)
      ..write(obj.engineCapacityUnit?.name)
      ..writeByte(24)
      ..write(obj.vehicleType.storageKey)
      ..writeByte(25)
      ..write(obj.customBrand)
      ..writeByte(26)
      ..write(obj.powertrainType)
      ..writeByte(27)
      ..write(obj.isDemo);
  }
}
