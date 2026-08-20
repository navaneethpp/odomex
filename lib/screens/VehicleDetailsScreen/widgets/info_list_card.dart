import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';

/// A single label-value info row used inside [InfoListCard].
class InfoRow {
  final String label;
  final String value;
  final bool fullWidth;

  const InfoRow({
    required this.label,
    required this.value,
    this.fullWidth = false,
  });
}

/// A card that renders a list of [InfoRow] items in a clean,
/// compact list layout. Adjacent pairs of rows that are not fullWidth
/// are displayed side-by-side.
class InfoListCard extends StatelessWidget {
  final List<InfoRow> rows;

  const InfoListCard({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final widgets = <Widget>[];
    int i = 0;

    while (i < rows.length) {
      final row = rows[i];

      if (row.fullWidth || i + 1 >= rows.length) {
        // Full-width or last odd item
        widgets.add(_InfoCell(
          label: row.label,
          value: row.value,
          colorScheme: colorScheme,
          theme: theme,
        ));
        i++;
      } else {
        // Two side-by-side
        final nextRow = rows[i + 1];
        if (nextRow.fullWidth) {
          widgets.add(_InfoCell(
            label: row.label,
            value: row.value,
            colorScheme: colorScheme,
            theme: theme,
          ));
          i++;
        } else {
          widgets.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _InfoCell(
                      label: row.label,
                      value: row.value,
                      colorScheme: colorScheme,
                      theme: theme,
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    color: colorScheme.outlineVariant,
                  ),
                  Expanded(
                    child: _InfoCell(
                      label: nextRow.label,
                      value: nextRow.value,
                      colorScheme: colorScheme,
                      theme: theme,
                    ),
                  ),
                ],
              ),
            ),
          );
          i += 2;
        }
      }

      if (i < rows.length) {
        widgets.add(Divider(
          height: 1,
          color: colorScheme.outlineVariant,
        ));
      }
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: Column(
            children: widgets,
          ),
        ),
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _InfoCell({
    required this.label,
    required this.value,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingLg,
        vertical: AppSizes.paddingMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSizes.spacingXs),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
