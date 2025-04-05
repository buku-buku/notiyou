import 'package:notiyou/routes/router.dart';
import 'package:notiyou/screens/challenger_config_page.dart';
import 'package:notiyou/screens/history_page.dart';
import 'package:notiyou/screens/home_page.dart';
import 'package:notiyou/services/notification/notification_event.dart';
import 'package:notiyou/services/notification/notification_handler_interface.dart';

class NotificationHandlerImpl implements NotificationHandler {
  @override
  void handleNotification(NotificationEvent event, Map<String, dynamic> data) {
    switch (event) {
      case NotificationEvent.missionSuccess:
        _handleMissionSuccessNotification(data);
        break;
      case NotificationEvent.missionFailed:
        _handleMissionFailedNotification(data);
        break;
      case NotificationEvent.supporterAssigned:
        _handleSupporterAssignedNotification(data);
        break;
      case NotificationEvent.supporterDismissed:
        _handleSupporterDismissedNotification(data);
        break;
      case NotificationEvent.missionAlarm:
        _handleMissionAlarmNotification(data);
        break;
      default:
        break;
    }
  }

  void _handleMissionSuccessNotification(Map<String, dynamic> data) {
    router.push(HistoryPage.routeName);
  }

  void _handleMissionFailedNotification(Map<String, dynamic> data) {
    router.push(HistoryPage.routeName);
  }

  void _handleSupporterAssignedNotification(Map<String, dynamic> data) {
    router.push(ChallengerConfigPage.routeName);
  }

  void _handleSupporterDismissedNotification(Map<String, dynamic> data) {
    router.push(ChallengerConfigPage.routeName);
  }

  void _handleMissionAlarmNotification(Map<String, dynamic> data) {
    router.push(HomePage.routeName);
  }
}
