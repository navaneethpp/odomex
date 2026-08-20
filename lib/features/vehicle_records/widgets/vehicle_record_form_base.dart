import 'package:flutter/material.dart';
import 'package:odomex/features/vehicle_records/models/vehicle_record.dart';

/// Abstract base class for all vehicle record form states.
///
/// Extending this class (instead of [State] directly) allows the
/// [AddVehicleRecordSheet] to hold a single typed [GlobalKey] that works
/// across all form widget variants:
///
/// ```dart
/// final GlobalKey<VehicleRecordFormState> _formKey = GlobalKey();
///
/// // Validate + build in one call:
/// final record = _formKey.currentState?.buildRecord();
/// ```
///
/// ### Contract
/// - [buildRecord] must call [Form.validate] on its internal form key before
///   building the record.
/// - Returns the typed [VehicleRecord] on success, or `null` if validation
///   fails.
/// - The returned record is fully constructed and ready to be persisted;
///   the caller does not need to know the record type.
abstract class VehicleRecordFormState<T extends StatefulWidget>
    extends State<T> {
  /// Validates this form and returns a fully-constructed [VehicleRecord] if
  /// all fields are valid, or `null` if validation fails.
  VehicleRecord? buildRecord();
}
