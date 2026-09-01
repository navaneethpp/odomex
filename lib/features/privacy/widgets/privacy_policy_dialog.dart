import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/privacy/widgets/privacy_policy_content.dart';

/// In-app modal dialog displaying the Odomex Privacy Policy & Data Usage.
class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({super.key});

  /// Displays the [PrivacyPolicyDialog] modal.
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const PrivacyPolicyDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);

    // Responsive constrained dialog size (up to 82% of screen height, max 560 width)
    final maxHeight = mediaQuery.size.height * 0.82;
    const maxWidth = 560.0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      elevation: AppSizes.elevationLg,
      backgroundColor: colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingLg,
        vertical: AppSizes.paddingXl,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Dialog Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.paddingXl,
                AppSizes.paddingLg,
                AppSizes.paddingSm,
                AppSizes.paddingSm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shield_outlined,
                      size: AppSizes.iconSm,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingMd),
                  Expanded(
                    child: Text(
                      'Privacy & Data Usage',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            Divider(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),

            // ── Scrollable Body ──
            const Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSizes.paddingXl),
                child: PrivacyPolicyContent(
                  showHeader: false,
                ),
              ),
            ),

            Divider(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),

            // ── Dialog Action Footer ──
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingXl,
                vertical: AppSizes.paddingMd,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton.tonal(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingXl,
                        vertical: AppSizes.paddingMd,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
