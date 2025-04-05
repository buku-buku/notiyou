enum NotificationEvent {
  missionSuccess('MISSION_SUCCESS'),
  missionFailed('MISSION_FAILED'),
  supporterAssigned('SUPPORTER_ASSIGNED'),
  supporterDismissed('SUPPORTER_DISMISSED'),
  missionAlarm('MISSION_ALARM');

  final String value;
  const NotificationEvent(this.value);

  @override
  String toString() => value;

  static NotificationEvent getNotificationEvent(String? type) {
    if (type == null) {
      return NotificationEvent.missionAlarm;
    }
    return NotificationEvent.values.firstWhere(
      (e) => e.value == type,
      orElse: () => NotificationEvent.missionAlarm,
    );
  }
}
