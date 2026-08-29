import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/vehicle_records/providers/vehicle_record_provider.dart';
import 'package:odomex/features/vehicle_records/utils/vehicle_record_validators.dart';

/// A smart odometer text input field with a "Use Latest" shortcut button.
///
/// Features:
/// - Retrieves the latest saved odometer reading from Odomex local data for the current vehicle.
/// - Populates the text controller and keeps the input 100% user-editable.
/// - Provides subtle floating SnackBar feedback (`✓ Latest reading added` or `No previous odometer reading available.`).
/// - Strictly validates according to Odomex business rules without bypassing validation on save.
class SmartOdometerInputField extends ConsumerWidget {
  const SmartOdometerInputField({
    super.key,
    required this.controller,
    required this.vehicleId,
    this.currentOdometer,
    this.labelText = 'Odometer Reading *',
    this.hintText,
    this.required = true,
    this.autofocus = false,
    this.validator,
    this.onChanged,
  });

  /// The text editing controller for the odometer input.
  final TextEditingController controller;

  /// The unique identifier of the selected vehicle.
  final String vehicleId;

  /// The current known odometer reading baseline for the vehicle.
  final double? currentOdometer;

  /// Label displayed above or inside the field.
  final String labelText;

  /// Optional hint text. If null, a default hint based on [currentOdometer] is computed.
  final String? hintText;

  /// Whether this field is required.
  final bool required;

  /// Whether the input field should auto-focus.
  final bool autofocus;

  /// Custom validator. Defaults to [validateRecordOdometer].
  final FormFieldValidator<String>? validator;

  /// Callback when the input text changes.
  final ValueChanged<String>? onChanged;

  void _applyLatestOdometer(
    BuildContext context,
    WidgetRef ref,
  ) {
    final latest = ref.read(
      latestOdometerReadingProvider(vehicleId),
    );

    if (latest != null && latest > 0) {
      final formatted = latest % 1 == 0
          ? latest.toInt().toString()
          : latest.toString();

      controller.text = formatted;
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
      onChanged?.call(formatted);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Latest reading added'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No previous odometer reading available.',
          ),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final computedHint =
        hintText ??
        (currentOdometer != null
            ? 'Current: ${currentOdometer!.toStringAsFixed(0)} km'
            : 'e.g. 25000');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header Row: Label & "Use Latest" Action Button ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                labelText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Semantics(
              label: 'Use latest saved odometer reading',
              button: true,
              child: TextButton.icon(
                onPressed: () =>
                    _applyLatestOdometer(context, ref),
                icon: const Icon(
                  Icons.history_rounded,
                  size: 16,
                ),
                label: const Text(
                  'Use Latest',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSizes.spacingXs),

        // ── Odometer Input Field ──
        TextFormField(
          controller: controller,
          autofocus: autofocus,
          keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'^\d*\.?\d*'),
            ),
          ],
          decoration: InputDecoration(
            hintText: computedHint,
            suffixText: 'km',
          ),
          onChanged: onChanged,
          validator:
              validator ??
              (v) => validateRecordOdometer(
                v,
                currentVehicleOdometer: currentOdometer,
                required: required,
              ),
        ),
      ],
    );
  }
}
