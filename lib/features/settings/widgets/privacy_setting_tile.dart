import 'package:flutter/material.dart';
import 'package:odomex/core/constants/app_constants.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:url_launcher/url_launcher.dart';

/// Settings tile for opening the official Privacy Policy webpage.
class PrivacySettingTile extends StatelessWidget {
  const PrivacySettingTile({super.key});

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final uri = Uri.parse(AppConstants.privacyPolicyUrl);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the Privacy Policy link.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the Privacy Policy link.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

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
          Icons.arrow_outward_rounded,
          size: AppSizes.iconSm,
          color: colorScheme.onSurfaceVariant,
        ),
        onTap: () => _openPrivacyPolicy(context),
      ),
    );
  }
}
