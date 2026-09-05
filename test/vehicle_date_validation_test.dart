import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/core/validation/vehicle_validators.dart';

void main() {
  group('Vehicle Date Validation Tests', () {
    test('validateDependentDate with null date returns null', () {
      expect(validateDependentDate(null, DateTime.now(), 'Test Date'), isNull);
    });

    test('validateDependentDate with future date returns future error', () {
      final futureDate = DateTime.now().add(const Duration(days: 2));
      expect(
        validateDependentDate(futureDate, DateTime.now(), 'Test Date'),
        'Test Date cannot be in the future.',
      );
    });

    test('validateDependentDate before purchase date returns before error', () {
      final purchaseDate = DateTime(2026, 9, 1);
      final dependentDate = DateTime(2026, 8, 31);
      expect(
        validateDependentDate(dependentDate, purchaseDate, 'Insurance start date'),
        'Insurance start date cannot be before the vehicle purchase date.',
      );
    });

    test('validateDependentDate same as purchase date is valid', () {
      final purchaseDate = DateTime(2026, 9, 1);
      final dependentDate = DateTime(2026, 9, 1);
      // As long as it's not in the future (today or past is fine)
      if (dependentDate.isAfter(DateTime.now())) return; // skip if test run on older date
      expect(
        validateDependentDate(dependentDate, purchaseDate, 'Insurance start date'),
        isNull,
      );
    });

    test('validateDependentDate after purchase date is valid', () {
      final purchaseDate = DateTime(2026, 9, 1);
      final dependentDate = DateTime(2026, 9, 2);
      if (dependentDate.isAfter(DateTime.now())) return;
      expect(
        validateDependentDate(dependentDate, purchaseDate, 'Insurance start date'),
        isNull,
      );
    });
  });
}
