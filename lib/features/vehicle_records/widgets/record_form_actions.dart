import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';

/// Standardized action buttons for record creation forms.
///
/// Features:
///   - Double-submission prevention via [isSaving].
///   - Loading indicator when saving is in progress.
///   - Full width button adhering to [AppSizes].
class RecordFormActions extends StatelessWidget {
  const RecordFormActions({
    super.key,
    required this.onSave,
    this.isSaving = false,
    this.saveLabel = 'Save Record',
  });

  final VoidCallback onSave;
  final bool isSaving;
  final String saveLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: isSaving ? null : onSave,
        child: isSaving
            ? const SizedBox(
                height: AppSizes.iconMd,
                width: AppSizes.iconMd,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Text(saveLabel),
      ),
    );
  }
}
