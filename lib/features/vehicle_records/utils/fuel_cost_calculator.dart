import 'package:odomex/core/constants/app_constants.dart';

/// Reusable calculation and financial formatting utility for vehicle fuel operations.
class FuelCostCalculator {
  const FuelCostCalculator._();

  /// Calculates total fuel cost: `quantity (L) * pricePerUnit (₹/L)`.
  ///
  /// Returns `null` if either value is null, non-positive (<= 0), or non-finite.
  /// Automatically rounds to 2 decimal places to avoid floating-point representation anomalies
  /// (e.g. 5.5 * 105.50 = 580.25 rather than 580.2499999999999).
  static double? calculateTotalCost({
    required double? quantity,
    required double? pricePerUnit,
  }) {
    if (quantity == null || pricePerUnit == null) return null;
    if (quantity <= 0 || pricePerUnit <= 0) return null;
    if (!quantity.isFinite || !pricePerUnit.isFinite) return null;

    final total = quantity * pricePerUnit;
    return double.parse(total.toStringAsFixed(2));
  }

  /// Calculates unit price from total cost and quantity: `totalCost / quantity`.
  ///
  /// Returns `null` if either value is null, non-positive (<= 0), or non-finite.
  static double? calculatePricePerUnit({
    required double? totalCost,
    required double? quantity,
  }) {
    if (totalCost == null || quantity == null) return null;
    if (totalCost <= 0 || quantity <= 0) return null;
    if (!totalCost.isFinite || !quantity.isFinite) return null;

    final price = totalCost / quantity;
    return double.parse(price.toStringAsFixed(2));
  }

  /// Calculates quantity from total cost and unit price: `totalCost / pricePerUnit`.
  ///
  /// Returns `null` if either value is null, non-positive (<= 0), or non-finite.
  static double? calculateQuantity({
    required double? totalCost,
    required double? pricePerUnit,
  }) {
    if (totalCost == null || pricePerUnit == null) return null;
    if (totalCost <= 0 || pricePerUnit <= 0) return null;
    if (!totalCost.isFinite || !pricePerUnit.isFinite) return null;

    final qty = totalCost / pricePerUnit;
    // We don't want to enforce 2 decimal rounding on quantity unless we absolutely have to,
    // but the requirement says "Normally use 2 decimal places... For fuel quantity: Preserve sufficient decimal precision".
    // Flutter double has plenty. We'll round to 3 or 4 if it's too long, or just leave it for the UI formatter.
    // Let's truncate/round at a reasonable precision like 3 decimals to avoid drift.
    return double.parse(qty.toStringAsFixed(3));
  }

  /// Checks if the three values are mathematically consistent within a small tolerance.
  /// Tolerance handles rounding issues like 100 / 3 * 3 != 100.
  static bool areValuesConsistent({
    required double quantity,
    required double pricePerUnit,
    required double totalCost,
  }) {
    if (quantity <= 0 || pricePerUnit <= 0 || totalCost <= 0) return false;
    final expectedTotal = quantity * pricePerUnit;
    
    // We allow a tolerance of up to 0.05. e.g. floating point drift or manual rounding by user.
    return (expectedTotal - totalCost).abs() <= 0.05;
  }

  /// Formats a monetary fuel cost amount for display with the currency symbol.
  ///
  /// Examples:
  /// - `580.25` -> `'₹580.25'`
  /// - `500.0`  -> `'₹500.00'`
  /// - `null`   -> `'—'`
  static String formatCost(
    double? cost, {
    String symbol = AppConstants.currencySymbol,
  }) {
    if (cost == null || cost.isNaN || cost.isInfinite) return '—';
    return '$symbol${cost.toStringAsFixed(2)}';
  }
}
