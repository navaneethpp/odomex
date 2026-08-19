import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A form field that presents a read-only text input. Tapping it opens a
/// [showDatePicker] dialog. The selected date is displayed using [dateFormat]
/// (defaults to 'd MMMM yyyy', e.g. '19 August 2026').
///
/// Use [firstDate] and [lastDate] to restrict the selectable range.
/// Pass [initialDate] to pre-select a date when the picker opens.
class DatePickerField extends StatelessWidget {
  final String labelText;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final String? Function(DateTime?)? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final String? hintText;

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
  });

  static final DateFormat _defaultFormat = DateFormat('d MMMM yyyy');

  Future<void> _openPicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? selectedDate ?? now,
      firstDate: firstDate ?? DateTime(1980),
      lastDate: lastDate ?? DateTime(now.year + 10),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayText =
        selectedDate != null ? _defaultFormat.format(selectedDate!) : null;

    return FormField<DateTime>(
      initialValue: selectedDate,
      validator: validator != null ? (_) => validator!(selectedDate) : null,
      builder: (state) {
        return InkWell(
          onTap: () => _openPicker(context),
          borderRadius: BorderRadius.circular(10),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: labelText,
              hintText: hintText ?? 'Select date',
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
