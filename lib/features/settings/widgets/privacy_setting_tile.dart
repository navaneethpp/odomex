import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/privacy/widgets/privacy_policy_dialog.dart';

/// Settings tile for viewing the in-app Privacy Policy & Data Usage dialog.
class PrivacySettingTile extends StatelessWidget {
  const PrivacySettingTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: AppSizes.elevationSm,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Icon(
            Icons.privacy_tip_outlined,
            color: colorScheme.primary,
            size: AppSizes.iconMd,
          ),
        ),
        title: Text(
          'Privacy Policy',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Read how Odomex handles your data',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          size: AppSizes.iconMd,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: () => PrivacyPolicyDialog.show(context),
      ),
    );
  }
}
