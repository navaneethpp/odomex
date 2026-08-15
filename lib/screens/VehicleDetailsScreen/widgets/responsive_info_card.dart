import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';

class ResponsiveInfoCard extends StatelessWidget {
  final String subtitleValue;
  final String titleValue;
  final IconData? icon;
  final Color? backgroundColor;

  const ResponsiveInfoCard({
    super.key,
    required this.subtitleValue,
    required this.titleValue,
    this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: Card(
        color: backgroundColor ?? colorScheme.surface,
        elevation: AppSizes.elevationMd,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
