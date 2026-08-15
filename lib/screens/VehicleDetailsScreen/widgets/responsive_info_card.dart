import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';

class ResponsiveInfoCard extends StatelessWidget {
  final String subtitleValue;
  final String titleValue;
  final IconData? icon;
  final Color? backgroundColor;
  final bool centerAlign; // NEW

  const ResponsiveInfoCard({
    super.key,
    required this.subtitleValue,
    required this.titleValue,
    this.icon,
    this.backgroundColor,
    this.centerAlign =
        false, // NEW — defaults to current left-aligned look
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final crossAxisAlignment = centerAlign
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final textAlign = centerAlign
        ? TextAlign.center
        : TextAlign.start;

    return SizedBox(
      width: double.infinity,
      child: Card(
        color: backgroundColor ?? colorScheme.surface,
        elevation: AppSizes.elevationMd,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLg),
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: AppSizes.iconMd,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: AppSizes.spacingSm),
              ],

              Text(
                subtitleValue,
                textAlign: textAlign,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AppSizes.spacingXs),

              Text(
                titleValue,
                textAlign: textAlign,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
