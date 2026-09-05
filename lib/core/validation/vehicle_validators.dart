/// Reusable field-level and cross-field validators for the Add Vehicle form.
///
/// All functions are pure (no widget or state dependencies) so they can be
/// unit-tested independently of the UI.
///
/// Each function returns null when the value is valid, or a short,
/// user-friendly error string when invalid.

library;

import 'package:odomex/models/vehicle.dart';

// ─────────────────────────────────────────────
// APPLICATION CONSTANTS
// ─────────────────────────────────────────────

/// The earliest year a vehicle could plausibly have been manufactured.
/// 1886 is the year of the Benz Patent-Motorwagen, the first true automobile.
const int kMinManufacturingYear = 1886;

/// Maximum plausible engine displacement for a consumer road vehicle (cc).
/// Electric vehicles are exempt from this limit.
const int kMaxEngineCapacityCC = 10000;

/// Maximum plausible engine displacement for a consumer road vehicle (litres).
/// Electric vehicles are exempt from this limit.
const double kMaxEngineCapacityLitres = 12.0;

const int kModelMinLength = 2;
const int kModelMaxLength = 50;
const int kColorMinLength = 2;
const int kColorMaxLength = 30;
const int kInsuranceProviderMinLength = 2;
const int kInsuranceProviderMaxLength = 100;
const int kPolicyNumberMinLength = 4;
const int kPolicyNumberMaxLength = 50;
const int kPucCertMinLength = 3;
const int kPucCertMaxLength = 50;

// ─────────────────────────────────────────────
// REGISTRATION NUMBER HELPERS
// ─────────────────────────────────────────────

/// Indian vehicle registration number pattern (after stripping separators).
///
/// Matches:
///   [A-Z]{2}      state code      (e.g. KL, MH, DL)
///   \d{1,2}       district code   (e.g. 10, 07, 5)
///   [A-Z]{0,3}    series code     (e.g. AB, X, or none)
///   \d{1,4}       number          (e.g. 1234, 1)
final RegExp _standardRegRegex = RegExp(r'^([A-Z]{2})(\d{1,2})([A-Z]{0,3})(\d{1,4})$');

/// BH series registration number pattern.
/// Matches: 21BH1234AA
final RegExp _bhRegRegex = RegExp(r'^(\d{2})(BH)(\d{4})([A-Z]{1,2})$');

/// Legitimate Indian State and UT vehicle registration prefixes.
const Set<String> _validStateCodes = {
  'AN', 'AP', 'AR', 'AS', 'BR', 'CG', 'CH', 'DD', 'DH', 'DL', 'DN', 
  'GA', 'GJ', 'HR', 'HP', 'JH', 'JK', 'KA', 'KL', 'LA', 'LD', 'MH', 
  'ML', 'MN', 'MP', 'MZ', 'NL', 'OD', 'PB', 'PY', 'RJ', 'SK', 'TN', 
  'TR', 'TS', 'TG', 'UK', 'UP', 'WB'
};

/// Strips separators from a registration number string (spaces and hyphens)
/// and uppercases it, ready for regex matching.
String _stripRegistration(String raw) =>
    raw.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();

/// Normalises an Indian registration number to the canonical spaced format.
/// Example: KL 5 6556 -> KL 05 6556
///
/// Assumes [raw] has already been validated via [validateRegistrationNumber].
String normaliseRegistrationNumber(String raw) {
  final s = _stripRegistration(raw);
  
  if (s.length < 4) return s.toUpperCase();

  final standardMatch = _standardRegRegex.firstMatch(s);
  if (standardMatch != null) {
    final state = standardMatch.group(1)!;
    final district = standardMatch.group(2)!.padLeft(2, '0');
    final series = standardMatch.group(3)!;
    final number = standardMatch.group(4)!.padLeft(4, '0');
    
    if (series.isEmpty) {
      return '$state $district $number';
    } else {
      return '$state $district $series $number';
    }
  }

  final bhMatch = _bhRegRegex.firstMatch(s);
  if (bhMatch != null) {
    return '${bhMatch.group(1)} BH ${bhMatch.group(3)} ${bhMatch.group(4)}';
  }

  return s;
}

// ─────────────────────────────────────────────
// FIELD VALIDATORS
// ─────────────────────────────────────────────

/// Brand selection (dropdown).
String? validateBrand(Object? value) {
  if (value == null) return 'Please select a brand.';
  return null;
}

/// Vehicle model name.
String? validateModel(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Model is required.';
  if (v.length < kModelMinLength) {
    return 'Model must be at least $kModelMinLength characters.';
  }
  if (v.length > kModelMaxLength) {
    return 'Model cannot exceed $kModelMaxLength characters.';
  }
  return null;
}

/// Manufacturing year string.
/// Pass [currentYear] as [DateTime.now().year] — kept as a parameter so this
/// function remains a pure function without side effects.
String? validateManufacturingYear(String? value, {required int currentYear}) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Manufacturing year is required.';
  if (v.length != 4 || int.tryParse(v) == null) {
    return 'Enter a valid 4-digit year.';
  }
  final year = int.parse(v);
  if (year < kMinManufacturingYear) {
    return 'Year cannot be earlier than $kMinManufacturingYear.';
  }
  if (year > currentYear) {
    return 'Manufacturing year cannot be in the future.';
  }
  return null;
}

/// Indian vehicle registration number.
/// Accepts KL 10 AB 1234, KL10AB1234, KL-10-AB-1234, KL 56 6556, etc.
String? validateRegistrationNumber(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Registration number is required.';
  
  final s = _stripRegistration(v);
  
  // Layer 2 & 3: Structural Validation
  final standardMatch = _standardRegRegex.firstMatch(s);
  if (standardMatch != null) {
    // Validate state code
    final state = standardMatch.group(1)!;
    if (!_validStateCodes.contains(state)) {
      return 'Enter a valid Indian vehicle registration number, such as KL 56 6556.';
    }
    return null;
  }
  
  final bhMatch = _bhRegRegex.firstMatch(s);
  if (bhMatch != null) {
    return null;
  }
  
  return 'Enter a valid Indian vehicle registration number, such as KL 56 6556.';
}

/// Vehicle color.
String? validateColor(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Color is required.';
  if (v.length < kColorMinLength) {
    return 'Color must be at least $kColorMinLength characters.';
  }
  if (v.length > kColorMaxLength) {
    return 'Color cannot exceed $kColorMaxLength characters.';
  }
  return null;
}

/// Fuel type dropdown selection.
String? validateFuelType(String? value) {
  if (value == null || value.isEmpty) return 'Please select a fuel type.';
  return null;
}

/// Custom fuel type text — required only when "Other" is selected.
String? validateCustomFuelType(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Please specify the fuel type.';
  if (v.length < 2) return 'Fuel type must be at least 2 characters.';
  if (v.length > 30) return 'Fuel type cannot exceed 30 characters.';
  return null;
}

/// Engine capacity validator for CC and Litres.
/// Pass [isElectric] = true to skip validation for electric vehicles.
String? validateEngineCapacity(
  String? value, {
  required bool isElectric,
  EngineCapacityUnit unit = EngineCapacityUnit.cc,
}) {
  if (isElectric) return null;
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Engine capacity is required.';

  switch (unit) {
    case EngineCapacityUnit.cc:
      final cc = int.tryParse(v);
      if (cc == null) return 'Please enter a valid engine capacity in CC.';
      if (cc <= 0) return 'Engine capacity must be greater than 0.';
      if (cc > kMaxEngineCapacityCC) {
        return 'Enter a realistic engine capacity (max $kMaxEngineCapacityCC cc).';
      }
      return null;

    case EngineCapacityUnit.litres:
      final litres = double.tryParse(v);
      if (litres == null) {
        return 'Please enter a valid engine capacity in litres.';
      }
      if (litres <= 0) return 'Engine capacity must be greater than 0.';
      if (litres > kMaxEngineCapacityLitres) {
        return 'Enter a realistic engine capacity (max ${kMaxEngineCapacityLitres.toStringAsFixed(0)} L).';
      }
      if (v.contains('.') && v.split('.')[1].length > 2) {
        return 'Engine capacity in litres can have at most 2 decimal places.';
      }
      return null;
  }
}

/// Current odometer reading.
String? validateOdometer(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Current odometer is required.';
  final reading = double.tryParse(v);
  if (reading == null) return 'Enter a valid odometer reading.';
  if (reading < 0) return 'Odometer reading cannot be negative.';
  return null;
}

/// Purchase date — required, not in the future, not before manufacturing year.
String? validatePurchaseDate(
  DateTime? date, {
  required int manufacturingYear,
}) {
  if (date == null) return 'Purchase date is required.';
  final today = DateTime.now();
  final dateOnly = DateTime(date.year, date.month, date.day);
  final todayOnly = DateTime(today.year, today.month, today.day);
  if (dateOnly.isAfter(todayOnly)) {
    return 'Purchase date cannot be in the future.';
  }
  if (manufacturingYear > 0 && date.year < manufacturingYear) {
    return 'Purchase date cannot be before the manufacturing year.';
  }
  return null;
}

// ─────────────────────────────────────────────
// SHARED DATE VALIDATORS
// ─────────────────────────────────────────────

/// Checks that a date is not in the future.
/// Uses the device's local calendar date.
String? validateNotFutureDate(DateTime? date, String fieldName) {
  if (date == null) return null;
  final now = DateTime.now();
  final todayOnly = DateTime(now.year, now.month, now.day);
  final dateOnly = DateTime(date.year, date.month, date.day);
  
  if (dateOnly.isAfter(todayOnly)) {
    return '$fieldName cannot be in the future.';
  }
  return null;
}


/// Validates a date that must not be before a reference purchase date.
String? validateDependentDate(DateTime? date, DateTime? purchaseDate, String fieldName) {
  if (date == null) return null;
  final notFutureError = validateNotFutureDate(date, fieldName);
  if (notFutureError != null) return notFutureError;
  
  if (purchaseDate != null) {
    final pDate = DateTime(purchaseDate.year, purchaseDate.month, purchaseDate.day);
    final dDate = DateTime(date.year, date.month, date.day);
    if (dDate.isBefore(pDate)) {
      return '$fieldName cannot be before the vehicle purchase date.';
    }
  }
  return null;
}

// ─────────────────────────────────────────────
// INSURANCE VALIDATORS
// ─────────────────────────────────────────────

/// Insurance provider name.
String? validateInsuranceProvider(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return null;
  if (v.length < kInsuranceProviderMinLength) {
    return 'Provider name must be at least $kInsuranceProviderMinLength characters.';
  }
  if (v.length > kInsuranceProviderMaxLength) {
    return 'Provider name cannot exceed $kInsuranceProviderMaxLength characters.';
  }
  return null;
}

/// Insurance policy number.
String? validatePolicyNumber(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return null;
  if (v.length < kPolicyNumberMinLength) {
    return 'Policy number must be at least $kPolicyNumberMinLength characters.';
  }
  if (v.length > kPolicyNumberMaxLength) {
    return 'Policy number cannot exceed $kPolicyNumberMaxLength characters.';
  }
  return null;
}

/// Cross-field: insurance end date must be strictly after start date.
String? validateInsuranceDates(DateTime? startDate, DateTime? endDate) {
  if (startDate == null || endDate == null) return null;
  if (!endDate.isAfter(startDate)) {
    return 'Insurance end date must be after the start date.';
  }
  return null;
}

// ─────────────────────────────────────────────
// PUC VALIDATORS
// ─────────────────────────────────────────────

/// PUC certificate number.
String? validatePucCertificate(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return null;
  if (v.length < kPucCertMinLength) {
    return 'Certificate number must be at least $kPucCertMinLength characters.';
  }
  if (v.length > kPucCertMaxLength) {
    return 'Certificate number cannot exceed $kPucCertMaxLength characters.';
  }
  return null;
}

/// Cross-field: PUC end date must be strictly after start date.
String? validatePucDates(DateTime? startDate, DateTime? endDate) {
  if (startDate == null || endDate == null) return null;
  if (!endDate.isAfter(startDate)) {
    return 'PUC end date must be after the start date.';
  }
  return null;
}

// ─────────────────────────────────────────────
// OIL CHANGE VALIDATORS
// ─────────────────────────────────────────────

/// Oil change interval in kilometres.
String? validateOilChangeInterval(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Oil change interval is required.';
  final km = double.tryParse(v);
  if (km == null) return 'Enter a valid interval in km.';
  if (km <= 0) return 'Interval must be greater than 0.';
  return null;
}

/// Last oil change odometer reading.
/// Cross-field: must not exceed [currentOdometer].
String? validateOilChangeOdometer(
  String? value, {
  required double? currentOdometer,
}) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Last oil change odometer is required.';
  final km = double.tryParse(v);
  if (km == null) return 'Enter a valid odometer reading.';
  if (km < 0) return 'Odometer reading cannot be negative.';
  if (currentOdometer != null && km > currentOdometer) {
    return 'Last oil change odometer cannot exceed the current odometer.';
  }
  return null;
}

/// Last oil change date — required, must not be in the future.
String? validateLastOilChangeDate(DateTime? date) {
  if (date == null) return 'Last oil change date is required.';
  final today = DateTime.now();
  final dateOnly = DateTime(date.year, date.month, date.day);
  final todayOnly = DateTime(today.year, today.month, today.day);
  if (dateOnly.isAfter(todayOnly)) {
    return 'Last oil change date cannot be in the future.';
  }
  return null;
}
