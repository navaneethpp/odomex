import 'package:odomex/features/settings/models/vehicle_sort_option.dart';
import 'package:odomex/features/vehicle_preferences/models/vehicle_preferences.dart';
import 'package:odomex/models/vehicle.dart';

/// Pure sorting utility for vehicle lists.
class VehicleListSorter {
  const VehicleListSorter();

  /// Returns a sorted copy of [vehicles] respecting [preferences] (pinned priority)
  /// and the active [sortOption].
  static List<Vehicle> sort({
    required List<Vehicle> vehicles,
    required VehicleSortOption sortOption,
    required Map<String, VehiclePreferences> preferences,
  }) {
    final copy = List<Vehicle>.of(vehicles);
    copy.sort((a, b) {
      final aPinned = preferences[a.id]?.isPinned ?? false;
      final bPinned = preferences[b.id]?.isPinned ?? false;

      // Priority 1: Pinned vehicles always appear first
      if (aPinned != bPinned) {
        return aPinned ? -1 : 1;
      }

      // Priority 2: Apply selected sorting method
      switch (sortOption) {
        case VehicleSortOption.lastAccessed:
          final aTime = a.lastAccessedAt;
          final bTime = b.lastAccessedAt;

          if (aTime != null && bTime != null) {
            final cmp = bTime.compareTo(aTime);
            if (cmp != 0) return cmp;
          } else if (aTime != null && bTime == null) {
            return -1; // Accessed before never-accessed
          } else if (aTime == null && bTime != null) {
            return 1;
          }

          // Secondary sort for tie-breakers or unaccessed vehicles: alphabetical by model
          final modelCmp =
              a.model.toLowerCase().compareTo(b.model.toLowerCase());
          if (modelCmp != 0) return modelCmp;

          return a.id.compareTo(b.id);

        case VehicleSortOption.alphabetical:
          final modelCmp =
              a.model.toLowerCase().compareTo(b.model.toLowerCase());
          if (modelCmp != 0) return modelCmp;

          return a.id.compareTo(b.id);
      }
    });

    return copy;
  }
}
