import 'package:notiyou/services/notification/notification_event.dart';

abstract class NotificationHandler {
  void handleNotification(NotificationEvent event, Map<String, dynamic> data);
}
