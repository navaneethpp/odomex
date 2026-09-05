import 'package:hive_ce/hive.dart';
import 'package:odomex/models/energy_source.dart';

class EnergySourceAdapter extends TypeAdapter<EnergySource> {
  @override
  final int typeId = 9;

  @override
  EnergySource read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return EnergySource.petrol;
      case 1:
        return EnergySource.diesel;
      case 2:
        return EnergySource.cng;
      case 3:
        return EnergySource.electricity;
      default:
        return EnergySource.petrol;
    }
  }

  @override
  void write(BinaryWriter writer, EnergySource obj) {
    switch (obj) {
      case EnergySource.petrol:
        writer.writeByte(0);
        break;
      case EnergySource.diesel:
        writer.writeByte(1);
        break;
      case EnergySource.cng:
        writer.writeByte(2);
        break;
      case EnergySource.electricity:
        writer.writeByte(3);
        break;
    }
  }
}
