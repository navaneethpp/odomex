import 'package:flutter_test/flutter_test.dart';
import 'package:odomex/core/validation/vehicle_validators.dart';

void main() {
  group('Vehicle Validators - Registration Number', () {
    group('validateRegistrationNumber', () {
      test('accepts legitimate Indian registration formats', () {
        final validInputs = [
          'KL 56 6556',
          'KL566556',
          'kl 56 6556',
          'KL-56-6556',
          'KL 01 AB 1234',
          'MH 12 CD 1234',
          'TN 38 BB 4567',
          'KA 05 MN 1234',
          'DL 01 AB 1234',
          'DL 1 A 1', // 1-digit district, 1-letter series, 1-digit number
          'KA 5 MN 1234', // 1-digit district
          '21 BH 1234 AA', // BH series
        ];

        for (final input in validInputs) {
          expect(validateRegistrationNumber(input), isNull,
              reason: 'Should accept $input');
        }
      });

      test('rejects clearly invalid formats', () {
        final invalidInputs = [
          'K',
          'KL',
          '123456',
          'ABCDEFG',
          '12 KL 3456',
          '@# KL 56 6556',
          'XX 56 6556', // Invalid state code
          'KL 56 ABC 12345', // Number too long
        ];

        for (final input in invalidInputs) {
          expect(validateRegistrationNumber(input), isNotNull,
              reason: 'Should reject $input');
        }
      });

      test('rejects empty input with required message', () {
        expect(validateRegistrationNumber(''),
            equals('Registration number is required.'));
        expect(validateRegistrationNumber('   '),
            equals('Registration number is required.'));
      });
    });

    group('normaliseRegistrationNumber', () {
      test('normalizes standard format with series', () {
        expect(normaliseRegistrationNumber('kl01ab1234'),
            equals('KL 01 AB 1234'));
        expect(normaliseRegistrationNumber('KL-01-AB-1234'),
            equals('KL 01 AB 1234'));
        expect(normaliseRegistrationNumber('KL 1 AB 1234'),
            equals('KL 01 AB 1234')); // Pads district
      });

      test('normalizes format without series', () {
        expect(normaliseRegistrationNumber('KL 56 6556'),
            equals('KL 56 6556'));
        expect(normaliseRegistrationNumber('kl566556'), equals('KL 56 6556'));
        expect(normaliseRegistrationNumber('KL-56-6556'),
            equals('KL 56 6556'));
        expect(normaliseRegistrationNumber('KL  56  6556'),
            equals('KL 56 6556'));
      });

      test('normalizes BH series', () {
        expect(normaliseRegistrationNumber('21BH1234AA'),
            equals('21 BH 1234 AA'));
        expect(normaliseRegistrationNumber('21-bh-1234-aa'),
            equals('21 BH 1234 AA'));
      });

      test('falls back gracefully on invalid length strings', () {
        expect(normaliseRegistrationNumber('K'), equals('K'));
        expect(normaliseRegistrationNumber('123'), equals('123'));
      });
    });
  });
}
