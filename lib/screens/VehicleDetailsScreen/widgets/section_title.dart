import 'package:flutter/material.dart';
import 'package:odomex/core/theme/app_sizes.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const SectionTitle({
    super.key,
    required this.title,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding:
          padding ??
          const EdgeInsets.symmetric(
            vertical: AppSizes.spacingSm,
          ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------
// USAGE EXAMPLE
// ---------------------------------------------------------------
//
// Plain:
//   const SectionTitle(title: 'Vehicle Info')
//
// With a trailing action:
//   SectionTitle(
//     title: 'Recent Trips',
//     trailing: TextButton(
//       onPressed: () {},
//       child: const Text('See all'),
//     ),
//   )
