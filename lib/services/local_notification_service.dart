import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  static void Function(String?)? onNotificationTap;

  static int _notificationId = 0;

  static Future<void> init({
    void Function(String?)? onNotificationTapped,
  }) async {
    onNotificationTap = onNotificationTapped;

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
        if (onNotificationTap != null) {
          onNotificationTap!(details.payload);
        }
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

  static Future<int> scheduleNotification({
    int? id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
  }) async {
    final newId = id ?? _notificationId++;

    await _notifications.zonedSchedule(
      newId,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    return newId;
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<void> showNotification({
    int? id,
    String? title = '테스트 알림',
    String? body = '이것은 테스트 알림입니다.',
    String? payload,
  }) async {
    await _notifications.show(
      id ?? _notificationId++,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
