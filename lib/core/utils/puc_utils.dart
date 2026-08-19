/// PUC (Pollution Under Control) validity calculation utilities.
///
/// IMPORTANT — APPLICATION BUSINESS RULE:
/// The PUC validity durations below are based on Indian emission norms as of 2024.
/// These rules MAY NEED TO BE UPDATED if government regulations change.
///
/// Current rule:
///   - Vehicles manufactured before [_bs6CutoffYear] (BS4 and older norms):
///     PUC validity = 6 months.
///   - Vehicles manufactured in [_bs6CutoffYear] or later (BS6 norms, mandated from
///     April 2020 in India): PUC validity = 1 year.
///
/// Reference: Central Motor Vehicles Rules, 1989 (Rule 115).
library;

/// The manufacturing year from which BS6 emission norms apply.
/// BS6 vehicles are subject to stricter norms and receive a longer PUC validity.
const int _bs6CutoffYear = 2020;

/// Calculates the PUC certificate expiry date based on the start date and the
/// vehicle's manufacturing year.
///
/// [startDate] — the date the PUC test was conducted.
/// [manufacturingYear] — the vehicle's manufacturing year (used to determine
/// the applicable emission norm and thus the validity period).
///
/// Returns a [DateTime] representing the calculated expiry date.
/// The user may still manually override this value in the form.
DateTime calculatePucExpiry({
  required DateTime startDate,
  required int manufacturingYear,
}) {
  // BS4 and older: 6-month validity.
  if (manufacturingYear < _bs6CutoffYear) {
    return DateTime(
      startDate.year,
      startDate.month + 6,
      startDate.day,
    );
  }

  // BS6 and newer: 1-year validity.
  return DateTime(
    startDate.year + 1,
    startDate.month,
    startDate.day,
  );
}

/// Returns a human-readable description of the PUC validity period for a
/// given [manufacturingYear]. Useful for displaying hints in the UI.
String pucValidityDescription(int manufacturingYear) {
  if (manufacturingYear < _bs6CutoffYear) {
    return '6 months (BS4/older)';
  }
  return '1 year (BS6/newer)';
}
