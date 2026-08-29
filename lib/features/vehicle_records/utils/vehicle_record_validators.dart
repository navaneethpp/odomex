/// Reusable validation functions for vehicle record forms.
///
/// All functions follow Flutter's FormField validator contract:
///   - Return `null` when the value is valid.
///   - Return a user-friendly error string when the value is invalid.
///
/// Business rules are strictly encapsulated here so that UI components only
/// configure and display errors.
library;

// ─────────────────────────────────────────────
// GENERIC VALIDATORS
// ─────────────────────────────────────────────

/// Validates that a required string is non-empty after trimming.
String? validateRequired(String? value, String fieldName) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName is required.';
  }
  return null;
}

/// Validates that a numeric string is strictly positive (> 0).
String? validatePositiveNumber(String? value, String fieldName) {
  if (value == null || value.trim().isEmpty) {
    return '$fieldName is required.';
  }
  final parsed = double.tryParse(value.trim());
  if (parsed == null) return 'Enter a valid $fieldName.';
  if (parsed <= 0) return '$fieldName must be greater than 0.';
  return null;
}

/// Validates that a numeric string is non-negative (>= 0).
String? validateNonNegativeNumber(
  String? value,
  String fieldName, {
  bool required = true,
}) {
  if (value == null || value.trim().isEmpty) {
    return required ? '$fieldName is required.' : null;
  }
  final parsed = double.tryParse(value.trim());
  if (parsed == null) return 'Enter a valid $fieldName.';
  if (parsed < 0) return '$fieldName cannot be negative.';
  return null;
}

/// Validates minimum string length (when value is present).
String? validateMinLength(String? value, int minLength, String fieldName) {
  if (value == null || value.trim().isEmpty) return null;
  if (value.trim().length < minLength) {
    return '$fieldName must be at least $minLength characters.';
  }
  return null;
}

/// Validates maximum string length.
String? validateMaxLength(String? value, int maxLength, String fieldName) {
  if (value == null || value.trim().isEmpty) return null;
  if (value.trim().length > maxLength) {
    return '$fieldName cannot exceed $maxLength characters.';
  }
  return null;
}

// ─────────────────────────────────────────────
// ODOMETER VALIDATION
// ─────────────────────────────────────────────

/// Validates an odometer reading string with cross-vehicle checks.
///
/// Rules:
///   - Required by default.
///   - Must be a valid numeric double.
///   - Must be >= 0.
///   - If [currentVehicleOdometer] is supplied and [allowLower] is false,
///     rejects readings lower than the current vehicle reading.
String? validateRecordOdometer(
  String? value, {
  double? currentVehicleOdometer,
  bool required = true,
  bool allowLower = false,
  String fieldName = 'Odometer reading',
}) {
  if (value == null || value.trim().isEmpty) {
    return required ? '$fieldName is required.' : null;
  }
  final parsed = double.tryParse(value.trim());
  if (parsed == null) return 'Enter a valid ${fieldName.toLowerCase()}.';
  if (parsed < 0) return '$fieldName cannot be negative.';

  if (currentVehicleOdometer != null && !allowLower) {
    if (parsed < currentVehicleOdometer) {
      return '$fieldName cannot be lower than the current vehicle reading.';
    }
  }

  return null;
}

/// Alias for general odometer field validation.
String? validateOdometer(
  String? value, {
  double? currentOdometer,
  bool allowLower = false,
  String fieldName = 'Odometer reading',
}) {
  return validateRecordOdometer(
    value,
    currentVehicleOdometer: currentOdometer,
    allowLower: allowLower,
    fieldName: fieldName,
  );
}

// ─────────────────────────────────────────────
// DATE VALIDATION
// ─────────────────────────────────────────────

/// Validates that a record date has been selected and is not in the future.
String? validateRecordDate(
  DateTime? value, {
  String fieldName = 'Record date',
}) {
  if (value == null) return '$fieldName is required.';
  // Truncate to day level to allow picking "today" regardless of time-of-day
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day, 23, 59, 59);
  if (value.isAfter(today)) return '$fieldName cannot be in the future.';
  return null;
}

// ─────────────────────────────────────────────
// FUEL VALIDATORS
// ─────────────────────────────────────────────

/// Validates fuel quantity in litres (> 0).
String? validateFuelQuantity(String? value) {
  return validatePositiveNumber(value, 'Fuel quantity');
}

/// Validates fuel price per unit/litre in INR (> 0).
String? validateFuelPrice(String? value, {bool required = true}) {
  if (value == null || value.trim().isEmpty) {
    return required ? 'Price per litre is required.' : null;
  }
  return validatePositiveNumber(value, 'Price per litre');
}

/// Validates fuel cost in INR (>= 0).
String? validateFuelCost(String? value) {
  return validateNonNegativeNumber(value, 'Fuel cost', required: true);
}

// ─────────────────────────────────────────────
// SERVICE VALIDATORS
// ─────────────────────────────────────────────

/// Validates service cost in INR (>= 0, required by default).
String? validateServiceCost(String? value, {bool required = true}) {
  return validateNonNegativeNumber(value, 'Service cost', required: required);
}

/// Validates service description (required, min 5 chars, max 1000 chars).
String? validateServiceDescription(String? value, {bool required = true}) {
  if (value == null || value.trim().isEmpty) {
    return required ? 'Please provide service details.' : null;
  }
  if (value.trim().length < 5) {
    return 'Service details must be at least 5 characters.';
  }
  if (value.trim().length > 1000) {
    return 'Service details cannot exceed 1000 characters.';
  }
  return null;
}

// ─────────────────────────────────────────────
// OIL CHANGE VALIDATORS
// ─────────────────────────────────────────────

/// Validates oil quantity in litres (> 0, required).
String? validateOilQuantity(String? value, {bool required = true}) {
  if (value == null || value.trim().isEmpty) {
    return required ? 'Oil quantity is required.' : null;
  }
  return validatePositiveNumber(value, 'Oil quantity');
}

/// Validates oil change cost in INR (>= 0, required).
String? validateOilCost(String? value, {bool required = true}) {
  return validateNonNegativeNumber(value, 'Oil cost', required: required);
}

/// Validates general notes (optional, max 500 chars).
String? validateNotes(String? value) {
  return validateMaxLength(value, 500, 'Notes');
}
