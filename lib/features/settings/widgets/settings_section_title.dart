import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';

/// Clean section title for settings groups.
class SettingsSectionTitle extends StatelessWidget {
  const SettingsSectionTitle({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.paddingXs,
        bottom: AppSizes.spacingSm,
      ),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
