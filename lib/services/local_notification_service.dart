import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notiyou/services/notification/notification_event.dart';
import 'package:notiyou/services/notification/notification_handler.dart';
import 'package:notiyou/services/notification/notification_handler_interface.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const String notificationChannelId = 'NotiYou - Mission Alarm ID';
const String notificationChannelName = 'NotiYou - Mission Alarm';
const String notificationChannelDescription = 'Mission time notification';

const notificationDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    notificationChannelId,
    notificationChannelName,
    channelDescription: notificationChannelDescription,
    importance: Importance.max,
    priority: Priority.high,
  ),
  iOS: DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  ),
);

const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
const iosSettings = DarwinInitializationSettings();
const settings = InitializationSettings(
  android: androidSettings,
  iOS: iosSettings,
);

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static final NotificationHandler _notificationHandler =
      NotificationHandlerImpl();

  static Future<void> init() async {
    await _initializeTimeZone();
    await _initializeSettings();
    await _requestPermissions();
  }

  static Future<void> _initializeTimeZone() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
  }

  static Future<void> _initializeSettings() async {
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        final event = NotificationEvent.getNotificationEvent(details.payload);
        _notificationHandler.handleNotification(event, {});
      },
    );
  }

  static Future<void> _requestPermissions() async {
    await _requestAndroidPermissions();
    await _requestIOSPermissions();
  }

  static Future<void> _requestAndroidPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> _requestIOSPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> scheduleNotificationInterval({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String notificationType,
    required int count,
  }) async {
    for (var i = 0; i < count; i++) {
      final time =
          tz.TZDateTime.from(scheduledTime.add(Duration(days: i)), tz.local);
      await _scheduleNotification(
        id: _createIdByDate(i, time),
        title: title,
        body: body,
        scheduledTime: time,
        notificationType: notificationType,
      );
    }
  }

  static Future<int> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String notificationType,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: notificationType,
    );

    return id;
  }

  static Future<void> cancelNotification(int id) async {
    final today = DateTime.now();
    final idToCancel = _createIdByDate(id, today);
    await _notifications.cancel(idToCancel);
  }

  static int _createIdByDate(int id, DateTime date) {
    return "$id${date.year}${date.month}${date.day}".hashCode;
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> showNotification({
    required int id,
    String? title = '테스트 알림',
    String? body = '이것은 테스트 알림입니다.',
    String? notificationType,
  }) async {
    await _notifications.show(
      _createIdByDate(id, DateTime.now()),
      title,
      body,
      notificationDetails,
      payload: notificationType,
    );
  }
}
