/// Reusable validation functions for vehicle record forms.
///
/// All functions follow Flutter's FormField validator contract:
///   - Return `null` when the value is valid.
///   - Return a user-friendly error string when the value is invalid.
///
/// Keep business rules here rather than duplicating them across form widgets.
library;

// ─────────────────────────────────────────────
// ODOMETER
// ─────────────────────────────────────────────

/// Validates an odometer reading string.
///
/// [currentOdometer] is the vehicle's latest known odometer. When provided,
/// a soft warning is produced if the new reading is lower, but it is NOT
/// treated as an error (corrections should be allowed).
String? validateOdometer(
  String? value, {
  double? currentOdometer,
}) {
  if (value == null || value.trim().isEmpty) {
    return 'Enter the odometer reading.';
  }
  final parsed = double.tryParse(value.trim());
  if (parsed == null) return 'Enter a valid number.';
  if (parsed < 0) return 'Odometer cannot be negative.';
  return null;
}

// ─────────────────────────────────────────────
// FUEL
// ─────────────────────────────────────────────

/// Validates a fuel quantity string (in litres).
String? validateFuelQuantity(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Enter the fuel quantity.';
  }
  final parsed = double.tryParse(value.trim());
  if (parsed == null) return 'Enter a valid number.';
  if (parsed <= 0) return 'Quantity must be greater than 0.';
  return null;
}

// ─────────────────────────────────────────────
// COST
// ─────────────────────────────────────────────

/// Validates a monetary cost string (in INR).
///
/// When [required] is false, an empty value is allowed (the field is optional).
String? validateCost(String? value, {bool required = true}) {
  if (value == null || value.trim().isEmpty) {
    return required ? 'Enter the cost.' : null;
  }
  final parsed = double.tryParse(value.trim());
  if (parsed == null) return 'Enter a valid amount.';
  if (parsed < 0) return 'Cost cannot be negative.';
  return null;
}

// ─────────────────────────────────────────────
// DATE
// ─────────────────────────────────────────────

/// Validates that a record date has been selected and is not in the future.
String? validateRecordDate(DateTime? value) {
  if (value == null) return 'Select the date.';
  if (value.isAfter(DateTime.now())) return 'Date cannot be in the future.';
  return null;
}

// ─────────────────────────────────────────────
// OIL CHANGE
// ─────────────────────────────────────────────

/// Validates an oil quantity string (in litres).
///
/// When [required] is false, an empty value is allowed.
String? validateOilQuantity(String? value, {bool required = false}) {
  if (value == null || value.trim().isEmpty) {
    return required ? 'Enter the oil quantity.' : null;
  }
  final parsed = double.tryParse(value.trim());
  if (parsed == null) return 'Enter a valid number.';
  if (parsed <= 0) return 'Quantity must be greater than 0.';
  return null;
}

// ─────────────────────────────────────────────
// GENERAL TEXT
// ─────────────────────────────────────────────

/// Validates that a required text field is non-empty.
String? validateRequired(String? value, String fieldName) {
  if (value == null || value.trim().isEmpty) {
    return 'Enter $fieldName.';
  }
  return null;
}
