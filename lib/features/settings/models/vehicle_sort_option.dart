/// Available sorting options for the vehicle list on the Home Screen.
enum VehicleSortOption {
  lastAccessed,
  alphabetical,
}

extension VehicleSortOptionExtension on VehicleSortOption {
  String get title {
    switch (this) {
      case VehicleSortOption.lastAccessed:
        return 'Last Accessed';
      case VehicleSortOption.alphabetical:
        return 'Alphabetical';
    }
  }

  String get subtitle {
    switch (this) {
      case VehicleSortOption.lastAccessed:
        return 'Show recently used vehicles first';
      case VehicleSortOption.alphabetical:
        return 'Sort vehicles by their model name';
    }
  }

  String get storageKey {
    switch (this) {
      case VehicleSortOption.lastAccessed:
        return 'last_accessed';
      case VehicleSortOption.alphabetical:
        return 'alphabetical';
    }
  }

  static VehicleSortOption fromStorageKey(String? key) {
    if (key == null) return VehicleSortOption.lastAccessed;
    switch (key) {
      case 'alphabetical':
        return VehicleSortOption.alphabetical;
      case 'last_accessed':
      default:
        return VehicleSortOption.lastAccessed;
    }
  }
}
