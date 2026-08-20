import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/settings/widgets/settings_section_title.dart';
import 'package:odomex/features/vehicle_settings/models/global_vehicle_settings.dart';
import 'package:odomex/features/vehicle_settings/providers/vehicle_settings_provider.dart';
import 'package:odomex/widgets/screen_container.dart';

/// Screen for configuring application-wide default vehicle maintenance intervals and rules.
class GlobalVehicleSettingsScreen extends ConsumerStatefulWidget {
  const GlobalVehicleSettingsScreen({super.key});

  @override
  ConsumerState<GlobalVehicleSettingsScreen> createState() =>
      _GlobalVehicleSettingsScreenState();
}

class _GlobalVehicleSettingsScreenState
    extends ConsumerState<GlobalVehicleSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _serviceIntervalController;
  late TextEditingController _oilChangeIntervalController;
  late TextEditingController _maintWarnKmController;
  late TextEditingController _pucWarnDaysController;
  late TextEditingController _insWarnDaysController;

  late bool _serviceReminderEnabled;
  late bool _oilChangeReminderEnabled;
  late bool _pucReminderEnabled;
  late bool _insReminderEnabled;

  bool _isInitialized = false;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final global = ref.read(globalVehicleSettingsProvider);
      _serviceIntervalController =
          TextEditingController(text: global.serviceIntervalKm.toString());
      _oilChangeIntervalController =
          TextEditingController(text: global.oilChangeIntervalKm.toString());
      _maintWarnKmController = TextEditingController(
          text: global.maintenanceReminderThresholdKm.toString());
      _pucWarnDaysController =
          TextEditingController(text: global.pucReminderDays.toString());
      _insWarnDaysController =
          TextEditingController(text: global.insuranceReminderDays.toString());

      _serviceReminderEnabled = global.serviceReminderEnabled;
      _oilChangeReminderEnabled = global.oilChangeReminderEnabled;
      _pucReminderEnabled = global.pucReminderEnabled;
      _insReminderEnabled = global.insuranceReminderEnabled;

      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _serviceIntervalController.dispose();
    _oilChangeIntervalController.dispose();
    _maintWarnKmController.dispose();
    _pucWarnDaysController.dispose();
    _insWarnDaysController.dispose();
    super.dispose();
  }

  bool _hasUnsavedChanges(GlobalVehicleSettings current) {
    final serviceInterval = int.tryParse(_serviceIntervalController.text) ??
        current.serviceIntervalKm;
    final oilInterval = int.tryParse(_oilChangeIntervalController.text) ??
        current.oilChangeIntervalKm;
    final maintWarn = int.tryParse(_maintWarnKmController.text) ??
        current.maintenanceReminderThresholdKm;
    final pucDays = int.tryParse(_pucWarnDaysController.text) ??
        current.pucReminderDays;
    final insDays = int.tryParse(_insWarnDaysController.text) ??
        current.insuranceReminderDays;

    return serviceInterval != current.serviceIntervalKm ||
        oilInterval != current.oilChangeIntervalKm ||
        maintWarn != current.maintenanceReminderThresholdKm ||
        pucDays != current.pucReminderDays ||
        insDays != current.insuranceReminderDays ||
        _serviceReminderEnabled != current.serviceReminderEnabled ||
        _oilChangeReminderEnabled != current.oilChangeReminderEnabled ||
        _pucReminderEnabled != current.pucReminderEnabled ||
        _insReminderEnabled != current.insuranceReminderEnabled;
  }

  Future<bool> _onWillPop(GlobalVehicleSettings current) async {
    if (!_hasUnsavedChanges(current)) return true;

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
            'Your global vehicle default changes haven\'t been saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return shouldDiscard ?? false;
  }

  Future<void> _saveGlobalSettings(GlobalVehicleSettings current) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final updated = current.copyWith(
      serviceIntervalKm: int.parse(_serviceIntervalController.text.trim()),
      oilChangeIntervalKm: int.parse(_oilChangeIntervalController.text.trim()),
      maintenanceReminderThresholdKm:
          int.parse(_maintWarnKmController.text.trim()),
      pucReminderDays: int.parse(_pucWarnDaysController.text.trim()),
      insuranceReminderDays: int.parse(_insWarnDaysController.text.trim()),
      serviceReminderEnabled: _serviceReminderEnabled,
      oilChangeReminderEnabled: _oilChangeReminderEnabled,
      pucReminderEnabled: _pucReminderEnabled,
      insuranceReminderEnabled: _insReminderEnabled,
    );

    try {
      await ref
          .read(globalVehicleSettingsProvider.notifier)
          .updateGlobalSettings(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle defaults saved'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to save vehicle defaults. Please try again.'),
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
    final global = ref.watch(globalVehicleSettingsProvider);

    return PopScope(
      canPop: !_hasUnsavedChanges(global),
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop(global);
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: ScreenContainer(
        title: 'Vehicle Defaults',
        showBackButton: true,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: AppSizes.paddingXxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. Explanatory Scope Banner ──────────────────
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingLg),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                      width: AppSizes.borderWidth,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingSm),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          color: colorScheme.primary,
                          size: AppSizes.iconMd,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Default Vehicle Settings',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'These default maintenance and reminder rules apply to all vehicles unless customized for an individual vehicle.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.spacingLg),

                // ── 2. Maintenance Defaults ──────────────────────
                const SettingsSectionTitle(title: 'MAINTENANCE DEFAULTS'),
                Card(
                  elevation: AppSizes.elevationSm,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    side: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                      width: AppSizes.borderWidth,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service Interval
                        TextFormField(
                          controller: _serviceIntervalController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: 'Default Service Interval',
                            prefixIcon: const Icon(Icons.build_outlined),
                            suffixText: 'km',
                            helperText: 'Default distance between services',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusMd),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter a service interval';
                            }
                            final num = int.tryParse(val.trim());
                            if (num == null || num <= 0) {
                              return 'Must be greater than 0';
                            }
                            if (num > 100000) {
                              return 'Must be 100,000 km or less';
                            }
                            return null;
                          },
                        ),

                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Default Service Reminders'),
                          subtitle: const Text('Enable service alerts by default'),
                          value: _serviceReminderEnabled,
                          onChanged: (val) =>
                              setState(() => _serviceReminderEnabled = val),
                        ),

                        const Divider(height: AppSizes.spacingLg),

                        // Oil Change Interval
                        TextFormField(
                          controller: _oilChangeIntervalController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: 'Default Oil Change Interval',
                            prefixIcon: const Icon(Icons.oil_barrel_outlined),
                            suffixText: 'km',
                            helperText: 'Default distance between oil changes',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusMd),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter an oil change interval';
                            }
                            final num = int.tryParse(val.trim());
                            if (num == null || num <= 0) {
                              return 'Must be greater than 0';
                            }
                            if (num > 100000) {
                              return 'Must be 100,000 km or less';
                            }
                            return null;
                          },
                        ),

                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Default Oil Change Reminders'),
                          subtitle: const Text('Enable oil change alerts by default'),
                          value: _oilChangeReminderEnabled,
                          onChanged: (val) =>
                              setState(() => _oilChangeReminderEnabled = val),
                        ),

                        const Divider(height: AppSizes.spacingLg),

                        // Warning Threshold
                        TextFormField(
                          controller: _maintWarnKmController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: 'Default Warning Threshold',
                            prefixIcon: const Icon(Icons.notifications_active_outlined),
                            suffixText: 'km',
                            helperText: 'Warn before due distance',
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusMd),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter a warning threshold';
                            }
                            final num = int.tryParse(val.trim());
                            if (num == null || num <= 0) {
                              return 'Must be greater than 0';
                            }
                            if (num > 10000) {
                              return 'Must be 10,000 km or less';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.spacingLg),

                // ── 3. Documents & Compliance Defaults ────────────
                const SettingsSectionTitle(
                    title: 'DOCUMENTS & COMPLIANCE DEFAULTS'),
                Card(
                  elevation: AppSizes.elevationSm,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    side: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                      width: AppSizes.borderWidth,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingLg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // PUC
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Default PUC Reminders'),
                          subtitle: const Text(
                              'Alert before pollution cert expires by default'),
                          value: _pucReminderEnabled,
                          onChanged: (val) =>
                              setState(() => _pucReminderEnabled = val),
                        ),

                        if (_pucReminderEnabled) ...[
                          const SizedBox(height: AppSizes.spacingSm),
                          TextFormField(
                            controller: _pucWarnDaysController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: 'Default PUC Warning Threshold',
                              prefixIcon: const Icon(Icons.eco_outlined),
                              suffixText: 'days',
                              helperText: 'Days before expiry to alert',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMd),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter warning days';
                              }
                              final num = int.tryParse(val.trim());
                              if (num == null || num < 0) {
                                return 'Must be 0 or greater';
                              }
                              if (num > 365) {
                                return 'Must be 365 days or less';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSizes.spacingMd),
                        ],

                        const Divider(height: AppSizes.spacingLg),

                        // Insurance
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Default Insurance Reminders'),
                          subtitle: const Text(
                              'Alert before insurance policy expires by default'),
                          value: _insReminderEnabled,
                          onChanged: (val) =>
                              setState(() => _insReminderEnabled = val),
                        ),

                        if (_insReminderEnabled) ...[
                          const SizedBox(height: AppSizes.spacingSm),
                          TextFormField(
                            controller: _insWarnDaysController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: 'Default Insurance Warning Threshold',
                              prefixIcon:
                                  const Icon(Icons.verified_user_outlined),
                              suffixText: 'days',
                              helperText: 'Days before expiry to alert',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMd),
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter warning days';
                              }
                              final num = int.tryParse(val.trim());
                              if (num == null || num < 0) {
                                return 'Must be 0 or greater';
                              }
                              if (num > 365) {
                                return 'Must be 365 days or less';
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.spacingXl),

                // ── 4. Save Button ────────────────────────────────
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed:
                        _isSaving ? null : () => _saveGlobalSettings(global),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(
                      _isSaving ? 'Saving...' : 'Save Defaults',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
