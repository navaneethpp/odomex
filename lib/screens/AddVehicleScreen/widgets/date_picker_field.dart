import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A form field that presents a read-only text input. Tapping it opens a
/// [showDatePicker] dialog. The selected date is displayed using [dateFormat]
/// (defaults to 'd MMMM yyyy', e.g. '19 August 2026').
///
/// Use [firstDate] and [lastDate] to restrict the selectable range in the
/// picker calendar. Pass [initialDate] to override where the calendar opens.
///
/// [validator] receives the current [selectedDate] and should return null for
/// valid values or a user-friendly error string for invalid values.
class DatePickerField extends StatefulWidget {
  final String labelText;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String? Function(DateTime?)? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final String? hintText;
  final bool disableFutureDates;
  final bool enabled;
  final VoidCallback? onDisabledTap;

  const DatePickerField({
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
    this.enabled = true,
    this.onDisabledTap,
  });

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  static final DateFormat _defaultFormat = DateFormat('d MMMM yyyy');

  // Holds a reference to the FormField state so we can call validate()
  // externally when selectedDate changes via the parent.
  FormFieldState<DateTime>? _fieldState;

  @override
  void didUpdateWidget(DatePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the parent updates selectedDate (e.g. from a cross-field calculation),
    // re-trigger validation so error text refreshes automatically.
    if (oldWidget.selectedDate != widget.selectedDate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fieldState?.didChange(widget.selectedDate);
      });
    }
  }

  Future<void> _openPicker(BuildContext context) async {
    final now = DateTime.now();
    DateTime effectiveLastDate = widget.lastDate ?? DateTime(now.year + 10);

    if (widget.disableFutureDates) {
      effectiveLastDate = now;
      final initial = widget.initialDate ?? widget.selectedDate;
      if (initial != null && initial.isAfter(effectiveLastDate)) {
        effectiveLastDate = initial;
      }
    }


    DateTime fallbackInitial = now;
    if (widget.firstDate != null && fallbackInitial.isBefore(widget.firstDate!)) {
      fallbackInitial = widget.firstDate!;
    }
    
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.initialDate ?? widget.selectedDate ?? fallbackInitial,
      firstDate: widget.firstDate ?? DateTime(1980),
      lastDate: effectiveLastDate,
    );

    if (picked != null) {
      widget.onDateSelected(picked);
      _fieldState?.didChange(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayText = widget.selectedDate != null
        ? _defaultFormat.format(widget.selectedDate!)
        : null;

    return FormField<DateTime>(
      initialValue: widget.selectedDate,
      validator: widget.validator != null
          ? (_) => widget.validator!(widget.selectedDate)
          : null,
      builder: (state) {
        _fieldState = state;
        return InkWell(
          onTap: () {
            if (!widget.enabled) {
              widget.onDisabledTap?.call();
              return;
            }
            _openPicker(context);
          },
          borderRadius: BorderRadius.circular(10),
          child: Opacity(
            opacity: widget.enabled ? 1.0 : 0.6,
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
          ),
        );
      },
    );
  }
}
