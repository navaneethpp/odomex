/// Reusable field-level and cross-field validators for the Add Vehicle form.
///
/// All functions are pure (no widget or state dependencies) so they can be
/// unit-tested independently of the UI.
///
/// Each function returns null when the value is valid, or a short,
/// user-friendly error string when invalid.

library;

// ─────────────────────────────────────────────
// APPLICATION CONSTANTS
// ─────────────────────────────────────────────

/// The earliest year a vehicle could plausibly have been manufactured.
/// 1886 is the year of the Benz Patent-Motorwagen, the first true automobile.
const int kMinManufacturingYear = 1886;

/// Maximum plausible engine displacement for a consumer road vehicle (cc).
/// Electric vehicles are exempt from this limit.
const int kMaxEngineCapacityCC = 10000;

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
///   \d{2}         district code   (e.g. 10, 07)
///   [A-Z]{1,3}    series code     (e.g. AB, X)
///   \d{4}         number          (e.g. 1234)
final RegExp _regRegex = RegExp(r'^[A-Z]{2}\d{2}[A-Z]{1,3}\d{4}$');

/// Strips separators from a registration number string (spaces and hyphens)
/// and uppercases it, ready for regex matching.
String _stripRegistration(String raw) =>
    raw.replaceAll(RegExp(r'[\s\-]'), '').toUpperCase();

/// Normalises an Indian registration number to the canonical spaced format:
///   KL 10 AB 1234
///
/// Assumes [raw] has already been validated via [validateRegistrationNumber].
String normaliseRegistrationNumber(String raw) {
  final s = _stripRegistration(raw);
  if (s.length < 9) return s.toUpperCase();

  final state = s.substring(0, 2);
  final district = s.substring(2, 4);
  final rest = s.substring(4);

  // The last 4 characters are always the sequential number.
  final seriesEnd = rest.length - 4;
  if (seriesEnd <= 0) return s;

  final series = rest.substring(0, seriesEnd);
  final number = rest.substring(seriesEnd);
  return '$state $district $series $number';
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
/// Accepts KL 10 AB 1234, KL10AB1234, KL-10-AB-1234, etc.
String? validateRegistrationNumber(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Registration number is required.';
  if (!_regRegex.hasMatch(_stripRegistration(v))) {
    return 'Enter a valid vehicle registration number.';
  }
  return null;
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

/// Engine capacity in cc.
/// Pass [isElectric] = true to skip validation for electric vehicles.
String? validateEngineCapacity(String? value, {required bool isElectric}) {
  if (isElectric) return null;
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Engine capacity is required.';
  final cc = int.tryParse(v);
  if (cc == null) return 'Enter a valid engine capacity.';
  if (cc <= 0) return 'Engine capacity must be greater than 0.';
  if (cc > kMaxEngineCapacityCC) {
    return 'Enter a realistic engine capacity (max $kMaxEngineCapacityCC cc).';
  }
  return null;
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
  if (date.isAfter(DateTime(today.year, today.month, today.day))) {
    return 'Purchase date cannot be in the future.';
  }
  if (manufacturingYear > 0 && date.year < manufacturingYear) {
    return 'Purchase date cannot be before the manufacturing year.';
  }
  return null;
}

// ─────────────────────────────────────────────
// INSURANCE VALIDATORS
// ─────────────────────────────────────────────

/// Insurance provider name.
String? validateInsuranceProvider(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Insurance provider is required.';
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
  if (v.isEmpty) return 'Policy number is required.';
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
  if (v.isEmpty) return 'PUC certificate number is required.';
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
  if (date.isAfter(DateTime(today.year, today.month, today.day))) {
    return 'Last oil change date cannot be in the future.';
  }
  return null;
}
