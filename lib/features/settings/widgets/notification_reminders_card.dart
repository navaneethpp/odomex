import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/settings/models/notification_settings.dart';
import 'package:odomex/features/settings/widgets/notification_preference_tile.dart';
import 'package:odomex/providers/notification_settings_provider.dart';

/// Card container presenting all individual vehicle reminder preference rows.
class NotificationRemindersCard extends ConsumerWidget {
  const NotificationRemindersCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = ref.watch(notificationSettingsProvider);
    final isMasterEnabled = settings.enabled;

    const categories = NotificationCategory.values;

    return Card(
      elevation: AppSizes.elevationSm,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderWidth,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < categories.length; i++) ...[
            NotificationPreferenceTile(
              title: categories[i].title,
              description: categories[i].description,
              icon: categories[i].icon,
              value: settings.isCategoryEnabled(categories[i]),
              isInteractive: isMasterEnabled,
              onChanged: (value) {
                ref
                    .read(notificationSettingsProvider.notifier)
                    .setCategoryEnabled(categories[i], value);
              },
            ),
            if (i < categories.length - 1)
              Divider(
                height: 1,
                thickness: AppSizes.borderWidth,
                indent: AppSizes.paddingLg,
                endIndent: AppSizes.paddingLg,
                color: colorScheme.outlineVariant.withValues(alpha: 0.25),
              ),
          ],
        ],
      ),
    );
  }
}
