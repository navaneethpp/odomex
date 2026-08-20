import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A shared form field that presents a read-only text input and opens a
/// system date picker on tap.
///
/// Generalised from the [DatePickerField] widget in AddVehicleScreen and
/// moved to the shared widgets layer so it can be used by any feature.
///
/// - [lastDate] defaults to today when [disableFutureDates] is true.
/// - [validator] receives the current [selectedDate] and should return null
///   for valid values or an error string for invalid values.
class AppDateField extends StatefulWidget {
  const AppDateField({
    super.key,
    required this.labelText,
    required this.selectedDate,
    required this.onDateSelected,
    this.validator,
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.hintText,
    this.disableFutureDates = false,
  });

  final String labelText;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String? Function(DateTime?)? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final String? hintText;

  /// When true, [lastDate] is automatically set to [DateTime.now()] so the
  /// user cannot select a future date.
  final bool disableFutureDates;

  @override
  State<AppDateField> createState() => _AppDateFieldState();
}

class _AppDateFieldState extends State<AppDateField> {
  static final DateFormat _fmt = DateFormat('d MMMM yyyy');

  FormFieldState<DateTime>? _fieldState;

  @override
  void didUpdateWidget(AppDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fieldState?.didChange(widget.selectedDate);
      });
    }
  }

  Future<void> _openPicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.initialDate ?? widget.selectedDate ?? now,
      firstDate: widget.firstDate ?? DateTime(1980),
      lastDate: widget.disableFutureDates
          ? now
          : widget.lastDate ?? DateTime(now.year + 10),
    );
    if (picked != null) {
      widget.onDateSelected(picked);
      _fieldState?.didChange(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayText =
        widget.selectedDate != null ? _fmt.format(widget.selectedDate!) : null;

    return FormField<DateTime>(
      initialValue: widget.selectedDate,
      validator: widget.validator != null
          ? (_) => widget.validator!(widget.selectedDate)
          : null,
      builder: (state) {
        _fieldState = state;
        return InkWell(
          onTap: () => _openPicker(context),
          borderRadius: BorderRadius.circular(10),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText ?? 'Select date',
              errorText: state.errorText,
              suffixIcon: const Icon(Icons.calendar_today_outlined),
            ),
            isEmpty: displayText == null,
            child: displayText != null
                ? Text(displayText)
                : const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
