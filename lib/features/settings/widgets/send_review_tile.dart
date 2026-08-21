import 'package:flutter/material.dart';
import 'package:odomex/core/services/feedback_service.dart';
import 'package:odomex/core/theme/app_sizes.dart';

/// Settings tile providing a direct action to send feedback/reviews via email.
class SendReviewTile extends StatelessWidget {
  const SendReviewTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: AppSizes.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderWidth,
        ),
      ),
      child: InkWell(
        onTap: () => FeedbackService.sendFeedback(context: context),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: Semantics(
          label: 'Send a Review. Share your feedback about Odomex.',
          button: true,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingLg),
            child: Row(
              children: [
                // Icon badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Icon(
                    Icons.rate_review_outlined,
                    color: colorScheme.primary,
                    size: AppSizes.iconMd,
                  ),
                ),

                const SizedBox(width: AppSizes.spacingMd),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Send a Review',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Share your feedback about Odomex',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_outward_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: AppSizes.iconLg,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
