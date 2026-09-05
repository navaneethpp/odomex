import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/models/powertrain_type.dart';

void main() {
  group('PowertrainType Oil Change Applicability Tests', () {
    test('isOilChangeApplicable should be true for Petrol', () {
      expect(PowertrainType.petrol.isOilChangeApplicable, isTrue);
    });

    test('isOilChangeApplicable should be true for Diesel', () {
      expect(PowertrainType.diesel.isOilChangeApplicable, isTrue);
    });

    test('isOilChangeApplicable should be true for CNG + Petrol', () {
      expect(PowertrainType.cngPetrol.isOilChangeApplicable, isTrue);
    });

    test('isOilChangeApplicable should be true for Hybrid', () {
      expect(PowertrainType.hybrid.isOilChangeApplicable, isTrue);
    });

    test('isOilChangeApplicable should be true for Plug-in Hybrid', () {
      expect(PowertrainType.plugInHybrid.isOilChangeApplicable, isTrue);
    });

    test('isOilChangeApplicable should be false for Electric Vehicle (EV)', () {
      expect(PowertrainType.ev.isOilChangeApplicable, isFalse);
    });
  });
}
