import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/models/powertrain_type.dart';

void main() {
  group('PowertrainType PUC Applicability Tests', () {
    test('isPucApplicable should be true for Petrol', () {
      expect(PowertrainType.petrol.isPucApplicable, isTrue);
    });

    test('isPucApplicable should be true for Diesel', () {
      expect(PowertrainType.diesel.isPucApplicable, isTrue);
    });

    test('isPucApplicable should be true for CNG + Petrol', () {
      expect(PowertrainType.cngPetrol.isPucApplicable, isTrue);
    });

    test('isPucApplicable should be true for Hybrid', () {
      expect(PowertrainType.hybrid.isPucApplicable, isTrue);
    });

    test('isPucApplicable should be true for Plug-in Hybrid', () {
      expect(PowertrainType.plugInHybrid.isPucApplicable, isTrue);
    });

    test('isPucApplicable should be false for Electric Vehicle (EV)', () {
      expect(PowertrainType.ev.isPucApplicable, isFalse);
    });
  });
}
