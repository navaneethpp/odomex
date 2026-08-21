/// Represents the current OS-level permission state for notifications and alarm scheduling.
class NotificationPermissionState {
  final bool notificationGranted;
  final bool exactAlarmGranted;

  const NotificationPermissionState({
    this.notificationGranted = false,
    this.exactAlarmGranted = true,
  });

  /// Whether the app is authorized by the operating system to dispatch notifications.
  bool get isFullyOperational => notificationGranted;

  NotificationPermissionState copyWith({
    bool? notificationGranted,
    bool? exactAlarmGranted,
  }) {
    return NotificationPermissionState(
      notificationGranted: notificationGranted ?? this.notificationGranted,
      exactAlarmGranted: exactAlarmGranted ?? this.exactAlarmGranted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPermissionState &&
          runtimeType == other.runtimeType &&
          notificationGranted == other.notificationGranted &&
          exactAlarmGranted == other.exactAlarmGranted;

  @override
  int get hashCode => notificationGranted.hashCode ^ exactAlarmGranted.hashCode;

  @override
  String toString() =>
      'NotificationPermissionState(notificationGranted: $notificationGranted, exactAlarmGranted: $exactAlarmGranted)';
}
