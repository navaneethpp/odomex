import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:odomex/core/theme/app_sizes.dart';
import 'package:odomex/features/settings/widgets/settings_section_title.dart';
import 'package:odomex/features/vehicle_settings/models/global_vehicle_settings.dart';
import 'package:odomex/features/vehicle_settings/models/vehicle_settings.dart';
import 'package:odomex/features/vehicle_settings/providers/vehicle_settings_provider.dart';
import 'package:odomex/models/vehicle.dart';
import 'package:odomex/providers/vehicle_provider.dart';
import 'package:odomex/widgets/screen_container.dart';

/// Screen for configuring vehicle-specific maintenance intervals and reminder rules,
/// allowing custom overrides or falling back to global vehicle defaults.
class VehicleSettingsScreen extends ConsumerStatefulWidget {
  const VehicleSettingsScreen({
    super.key,
    required this.vehicleId,
  });

  final String vehicleId;

  @override
  ConsumerState<VehicleSettingsScreen> createState() =>
      _VehicleSettingsScreenState();
}

class _VehicleSettingsScreenState extends ConsumerState<VehicleSettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Override mode flags (true = custom override, false = use global default)
  bool _customServiceInterval = false;
  bool _customServiceReminder = false;
  bool _customOilChangeInterval = false;
  bool _customOilChangeReminder = false;
  bool _customMaintWarnKm = false;
  bool _customPuc = false;
  bool _customInsurance = false;

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
      final override = ref.read(vehicleSettingsProvider(widget.vehicleId));
      final global = ref.read(globalVehicleSettingsProvider);

      _customServiceInterval = override.serviceIntervalKm != null;
      _customServiceReminder = override.serviceReminderEnabled != null;
      _customOilChangeInterval = override.oilChangeIntervalKm != null;
      _customOilChangeReminder = override.oilChangeReminderEnabled != null;
      _customMaintWarnKm = override.maintenanceReminderThresholdKm != null;
      _customPuc = override.pucReminderEnabled != null ||
          override.pucReminderDays != null;
      _customInsurance = override.insuranceReminderEnabled != null ||
          override.insuranceReminderDays != null;

      _serviceIntervalController = TextEditingController(
        text: (override.serviceIntervalKm ?? global.serviceIntervalKm).toString(),
      );
      _oilChangeIntervalController = TextEditingController(
        text: (override.oilChangeIntervalKm ?? global.oilChangeIntervalKm)
            .toString(),
      );
      _maintWarnKmController = TextEditingController(
        text: (override.maintenanceReminderThresholdKm ??
                global.maintenanceReminderThresholdKm)
            .toString(),
      );
      _pucWarnDaysController = TextEditingController(
        text: (override.pucReminderDays ?? global.pucReminderDays).toString(),
      );
      _insWarnDaysController = TextEditingController(
        text: (override.insuranceReminderDays ?? global.insuranceReminderDays)
            .toString(),
      );

      _serviceReminderEnabled =
          override.serviceReminderEnabled ?? global.serviceReminderEnabled;
      _oilChangeReminderEnabled = override.oilChangeReminderEnabled ??
          global.oilChangeReminderEnabled;
      _pucReminderEnabled =
          override.pucReminderEnabled ?? global.pucReminderEnabled;
      _insReminderEnabled =
          override.insuranceReminderEnabled ?? global.insuranceReminderEnabled;

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

  void _resetAllToGlobal(GlobalVehicleSettings global) {
    setState(() {
      _customServiceInterval = false;
      _customServiceReminder = false;
      _customOilChangeInterval = false;
      _customOilChangeReminder = false;
      _customMaintWarnKm = false;
      _customPuc = false;
      _customInsurance = false;

      _serviceIntervalController.text = global.serviceIntervalKm.toString();
      _oilChangeIntervalController.text = global.oilChangeIntervalKm.toString();
      _maintWarnKmController.text =
          global.maintenanceReminderThresholdKm.toString();
      _pucWarnDaysController.text = global.pucReminderDays.toString();
      _insWarnDaysController.text = global.insuranceReminderDays.toString();

      _serviceReminderEnabled = global.serviceReminderEnabled;
      _oilChangeReminderEnabled = global.oilChangeReminderEnabled;
      _pucReminderEnabled = global.pucReminderEnabled;
      _insReminderEnabled = global.insuranceReminderEnabled;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reset to global defaults. Press Save to apply.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _hasUnsavedChanges(VehicleSettings currentSettings) {
    final currentCustomService = currentSettings.serviceIntervalKm != null;
    final currentCustomOil = currentSettings.oilChangeIntervalKm != null;
    final currentCustomMaint =
        currentSettings.maintenanceReminderThresholdKm != null;

    if (_customServiceInterval != currentCustomService ||
        _customOilChangeInterval != currentCustomOil ||
        _customMaintWarnKm != currentCustomMaint) {
      return true;
    }

    if (_customServiceInterval &&
        int.tryParse(_serviceIntervalController.text) !=
            currentSettings.serviceIntervalKm) {
      return true;
    }
    if (_customOilChangeInterval &&
        int.tryParse(_oilChangeIntervalController.text) !=
            currentSettings.oilChangeIntervalKm) {
      return true;
    }

    return false;
  }

  Future<bool> _onWillPop(VehicleSettings currentSettings) async {
    if (!_hasUnsavedChanges(currentSettings)) return true;

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content:
            const Text('Your vehicle settings changes haven\'t been saved.'),
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

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final updated = VehicleSettings(
      vehicleId: widget.vehicleId,
      serviceIntervalKm: _customServiceInterval
          ? int.tryParse(_serviceIntervalController.text.trim())
          : null,
      oilChangeIntervalKm: _customOilChangeInterval
          ? int.tryParse(_oilChangeIntervalController.text.trim())
          : null,
      serviceReminderEnabled:
          _customServiceReminder ? _serviceReminderEnabled : null,
      oilChangeReminderEnabled:
          _customOilChangeReminder ? _oilChangeReminderEnabled : null,
      maintenanceReminderThresholdKm: _customMaintWarnKm
          ? int.tryParse(_maintWarnKmController.text.trim())
          : null,
      pucReminderEnabled: _customPuc ? _pucReminderEnabled : null,
      pucReminderDays: _customPuc
          ? int.tryParse(_pucWarnDaysController.text.trim())
          : null,
      insuranceReminderEnabled:
          _customInsurance ? _insReminderEnabled : null,
      insuranceReminderDays: _customInsurance
          ? int.tryParse(_insWarnDaysController.text.trim())
          : null,
    );

    try {
      await ref
          .read(vehicleSettingsProvider(widget.vehicleId).notifier)
          .updateSettings(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle settings saved'),
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
            content: Text('Unable to save vehicle settings. Please try again.'),
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

    final vehicle = ref.watch(vehicleByIdProvider(widget.vehicleId));
    final overrideSettings =
        ref.watch(vehicleSettingsProvider(widget.vehicleId));
    final globalSettings = ref.watch(globalVehicleSettingsProvider);

    if (vehicle == null) {
      return const ScreenContainer(
        title: 'Vehicle Settings',
        child: Center(child: Text('Vehicle not found')),
      );
    }

    return PopScope(
      canPop: !_hasUnsavedChanges(overrideSettings),
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop(overrideSettings);
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: ScreenContainer(
        title: 'Vehicle Settings',
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: () => _resetAllToGlobal(globalSettings),
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Reset all to global defaults',
          ),
        ],
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: AppSizes.paddingXxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── 1. Vehicle Identity Header ───────────────────
                _VehicleIdentityCard(vehicle: vehicle),

                const SizedBox(height: AppSizes.spacingLg),

                // ── 2. Maintenance Intervals & Rules ──────────────
                const SettingsSectionTitle(title: 'MAINTENANCE'),
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
                        // Service Interval Header & Override Toggle
                        _OverrideHeader(
                          title: 'Service Interval',
                          isCustom: _customServiceInterval,
                          defaultLabel:
                              'Global default: ${globalSettings.serviceIntervalKm} km',
                          onToggle: (custom) {
                            setState(() {
                              _customServiceInterval = custom;
                              if (!custom) {
                                _serviceIntervalController.text =
                                    globalSettings.serviceIntervalKm.toString();
                              }
                            });
                          },
                        ),
                        if (_customServiceInterval) ...[
                          const SizedBox(height: AppSizes.spacingSm),
                          TextFormField(
                            controller: _serviceIntervalController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: 'Custom Service Interval',
                              prefixIcon: const Icon(Icons.build_outlined),
                              suffixText: 'km',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMd),
                              ),
                            ),
                            validator: (val) {
                              if (!_customServiceInterval) return null;
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
                        ],

                        const SizedBox(height: AppSizes.spacingSm),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Service Reminders'),
                          subtitle: Text(_customServiceReminder
                              ? 'Custom setting'
                              : 'Using global default (${globalSettings.serviceReminderEnabled ? "ON" : "OFF"})'),
                          value: _serviceReminderEnabled,
                          onChanged: (val) {
                            setState(() {
                              _customServiceReminder = true;
                              _serviceReminderEnabled = val;
                            });
                          },
                        ),

                        const Divider(height: AppSizes.spacingLg),

                        // Oil Change Interval Header & Override Toggle
                        _OverrideHeader(
                          title: 'Oil Change Interval',
                          isCustom: _customOilChangeInterval,
                          defaultLabel:
                              'Global default: ${globalSettings.oilChangeIntervalKm} km',
                          onToggle: (custom) {
                            setState(() {
                              _customOilChangeInterval = custom;
                              if (!custom) {
                                _oilChangeIntervalController.text =
                                    globalSettings.oilChangeIntervalKm
                                        .toString();
                              }
                            });
                          },
                        ),
                        if (_customOilChangeInterval) ...[
                          const SizedBox(height: AppSizes.spacingSm),
                          TextFormField(
                            controller: _oilChangeIntervalController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: 'Custom Oil Change Interval',
                              prefixIcon: const Icon(Icons.oil_barrel_outlined),
                              suffixText: 'km',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMd),
                              ),
                            ),
                            validator: (val) {
                              if (!_customOilChangeInterval) return null;
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
                        ],

                        const SizedBox(height: AppSizes.spacingSm),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Oil Change Reminders'),
                          subtitle: Text(_customOilChangeReminder
                              ? 'Custom setting'
                              : 'Using global default (${globalSettings.oilChangeReminderEnabled ? "ON" : "OFF"})'),
                          value: _oilChangeReminderEnabled,
                          onChanged: (val) {
                            setState(() {
                              _customOilChangeReminder = true;
                              _oilChangeReminderEnabled = val;
                            });
                          },
                        ),

                        const Divider(height: AppSizes.spacingLg),

                        // Maintenance Warning Threshold
                        _OverrideHeader(
                          title: 'Warning Threshold',
                          isCustom: _customMaintWarnKm,
                          defaultLabel:
                              'Global default: ${globalSettings.maintenanceReminderThresholdKm} km',
                          onToggle: (custom) {
                            setState(() {
                              _customMaintWarnKm = custom;
                              if (!custom) {
                                _maintWarnKmController.text = globalSettings
                                    .maintenanceReminderThresholdKm
                                    .toString();
                              }
                            });
                          },
                        ),
                        if (_customMaintWarnKm) ...[
                          const SizedBox(height: AppSizes.spacingSm),
                          TextFormField(
                            controller: _maintWarnKmController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: 'Custom Warning Threshold',
                              prefixIcon: const Icon(
                                  Icons.notifications_active_outlined),
                              suffixText: 'km',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMd),
                              ),
                            ),
                            validator: (val) {
                              if (!_customMaintWarnKm) return null;
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
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.spacingLg),

                // ── 3. Documents & Compliance ─────────────────────
                const SettingsSectionTitle(title: 'DOCUMENTS & COMPLIANCE'),
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
                        // PUC Reminders
                        _OverrideHeader(
                          title: 'PUC Reminders',
                          isCustom: _customPuc,
                          defaultLabel:
                              'Global default: ${globalSettings.pucReminderDays} days',
                          onToggle: (custom) {
                            setState(() {
                              _customPuc = custom;
                              if (!custom) {
                                _pucWarnDaysController.text =
                                    globalSettings.pucReminderDays.toString();
                                _pucReminderEnabled =
                                    globalSettings.pucReminderEnabled;
                              }
                            });
                          },
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Enable PUC Alerts'),
                          value: _pucReminderEnabled,
                          onChanged: (val) =>
                              setState(() {
                            _customPuc = true;
                            _pucReminderEnabled = val;
                          }),
                        ),
                        if (_customPuc && _pucReminderEnabled) ...[
                          const SizedBox(height: AppSizes.spacingSm),
                          TextFormField(
                            controller: _pucWarnDaysController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: 'Custom PUC Warning Threshold',
                              prefixIcon: const Icon(Icons.eco_outlined),
                              suffixText: 'days',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMd),
                              ),
                            ),
                            validator: (val) {
                              if (!_customPuc) return null;
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

                        const Divider(height: AppSizes.spacingLg),

                        // Insurance Reminders
                        _OverrideHeader(
                          title: 'Insurance Reminders',
                          isCustom: _customInsurance,
                          defaultLabel:
                              'Global default: ${globalSettings.insuranceReminderDays} days',
                          onToggle: (custom) {
                            setState(() {
                              _customInsurance = custom;
                              if (!custom) {
                                _insWarnDaysController.text = globalSettings
                                    .insuranceReminderDays
                                    .toString();
                                _insReminderEnabled =
                                    globalSettings.insuranceReminderEnabled;
                              }
                            });
                          },
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Enable Insurance Alerts'),
                          value: _insReminderEnabled,
                          onChanged: (val) =>
                              setState(() {
                            _customInsurance = true;
                            _insReminderEnabled = val;
                          }),
                        ),
                        if (_customInsurance && _insReminderEnabled) ...[
                          const SizedBox(height: AppSizes.spacingSm),
                          TextFormField(
                            controller: _insWarnDaysController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: 'Custom Insurance Warning Threshold',
                              prefixIcon:
                                  const Icon(Icons.verified_user_outlined),
                              suffixText: 'days',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusMd),
                              ),
                            ),
                            validator: (val) {
                              if (!_customInsurance) return null;
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
                    onPressed: _isSaving ? null : _saveSettings,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(
                      _isSaving ? 'Saving...' : 'Save Changes',
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

class _OverrideHeader extends StatelessWidget {
  const _OverrideHeader({
    required this.title,
    required this.isCustom,
    required this.defaultLabel,
    required this.onToggle,
  });

  final String title;
  final bool isCustom;
  final String defaultLabel;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isCustom ? 'Custom override active' : defaultLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isCustom
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isCustom ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () => onToggle(!isCustom),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingSm),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            isCustom ? 'Use Default' : 'Customize',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _VehicleIdentityCard extends StatelessWidget {
  const _VehicleIdentityCard({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: AppSizes.borderWidth,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingSm),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.two_wheeler_rounded,
              color: colorScheme.onPrimaryContainer,
              size: AppSizes.iconMd,
            ),
          ),
          const SizedBox(width: AppSizes.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle.brand.displayName} ${vehicle.model}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  vehicle.registrationNumber,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
