import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/providers/insurance_provider_provider.dart';

/// Modal bottom sheet allowing the user to search and select an Insurance Provider.
class InsuranceProviderSelectorSheet extends ConsumerStatefulWidget {
  const InsuranceProviderSelectorSheet({
    super.key,
    this.selectedProvider,
  });

  final String? selectedProvider;

  static Future<String?> show(
      BuildContext context, String? selectedProvider) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (context) => InsuranceProviderSelectorSheet(
        selectedProvider: selectedProvider,
      ),
    );
  }

  @override
  ConsumerState<InsuranceProviderSelectorSheet> createState() =>
      _InsuranceProviderSelectorSheetState();
}

class _InsuranceProviderSelectorSheetState
    extends ConsumerState<InsuranceProviderSelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addCustomProvider(String providerName) async {
    await ref
        .read(customInsuranceProviderProvider.notifier)
        .addCustomProvider(providerName);
    if (mounted) {
      Navigator.pop(context, providerName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allProviders = ref.watch(allInsuranceProvidersProvider);
    final customProviders = ref.watch(customInsuranceProviderProvider);

    final filteredProviders = _searchQuery.isEmpty
        ? allProviders
        : allProviders
            .where((p) => p.toLowerCase().contains(_searchQuery))
            .toList();

    // Check if there is an exact match for the custom provider we are searching for
    final hasExactMatch = allProviders.any(
        (p) => p.toLowerCase() == _searchQuery);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.paddingLg,
          horizontal: AppSizes.paddingMd,
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppSizes.radiusRound),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingMd),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
              child: Text(
                'Select Insurance Provider',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingMd),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search insurance provider',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    borderSide: BorderSide.none,
                  ),
                ),
                textInputAction: TextInputAction.search,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSm),

            // Results List
            Expanded(
              child: filteredProviders.isEmpty
                  ? _buildEmptyState(context, colorScheme)
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredProviders.length +
                          ((_searchQuery.isNotEmpty && !hasExactMatch) ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == filteredProviders.length) {
                          // Add new provider button at the bottom of search results
                          return _buildAddProviderTile(theme, colorScheme);
                        }

                        final provider = filteredProviders[index];
                        final isSelected = provider == widget.selectedProvider;
                        final isCustom = customProviders.contains(provider);

                        return _buildProviderTile(
                            context, theme, colorScheme, provider, isSelected, isCustom);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderTile(
      BuildContext context,
      ThemeData theme,
      ColorScheme colorScheme,
      String provider,
      bool isSelected,
      bool isCustom) {
    return InkWell(
      onTap: () {
        Navigator.pop(context, provider);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingLg,
          vertical: AppSizes.paddingMd,
        ),
        color: isSelected ? colorScheme.primary.withValues(alpha: 0.08) : null,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                    ),
                  ),
                  if (isCustom) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Custom Provider',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                color: colorScheme.primary,
                size: AppSizes.iconMd,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddProviderTile(ThemeData theme, ColorScheme colorScheme) {
    final newProviderName = _searchController.text.trim();
    return InkWell(
      onTap: () => _addCustomProvider(newProviderName),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingLg,
          vertical: AppSizes.paddingMd,
        ),
        child: Row(
          children: [
            Icon(Icons.add_circle_outline, color: colorScheme.primary),
            const SizedBox(width: AppSizes.spacingMd),
            Expanded(
              child: Text(
                'Add "$newProviderName"',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    final newProviderName = _searchController.text.trim();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSizes.spacingMd),
            Text(
              'No insurance provider found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: AppSizes.spacingSm),
            Text(
              'Can\'t find your provider? Add it below.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingLg),
            if (newProviderName.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => _addCustomProvider(newProviderName),
                icon: const Icon(Icons.add),
                label: Text('Add "$newProviderName"'),
              ),
          ],
        ),
      ),
    );
  }
}
