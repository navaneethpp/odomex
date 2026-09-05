import 'package:hive_ce/hive.dart';
import 'package:odomex/models/powertrain_type.dart';

class PowertrainTypeAdapter extends TypeAdapter<PowertrainType> {
  @override
  final int typeId = 8;

  @override
  PowertrainType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PowertrainType.petrol;
      case 1:
        return PowertrainType.diesel;
      case 2:
        return PowertrainType.cngPetrol;
      case 3:
        return PowertrainType.hybrid;
      case 4:
        return PowertrainType.plugInHybrid;
      case 5:
        return PowertrainType.ev;
      default:
        return PowertrainType.petrol;
    }
  }

  @override
  void write(BinaryWriter writer, PowertrainType obj) {
    switch (obj) {
      case PowertrainType.petrol:
        writer.writeByte(0);
        break;
      case PowertrainType.diesel:
        writer.writeByte(1);
        break;
      case PowertrainType.cngPetrol:
        writer.writeByte(2);
        break;
      case PowertrainType.hybrid:
        writer.writeByte(3);
        break;
      case PowertrainType.plugInHybrid:
        writer.writeByte(4);
        break;
      case PowertrainType.ev:
        writer.writeByte(5);
        break;
    }
  }
}
