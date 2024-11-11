import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notiyou/repositories/mission_time_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class PushAlarmService {
  static final FlutterLocalNotificationsPlugin _pushAlarms =
      FlutterLocalNotificationsPlugin();

  static const String _pushAlarmSetupKey = 'push_alarm_setup';

  static Future<void> init() async {
    tz.initializeTimeZones();
    await _initializeDevicePushAlarmSettings();

    final prefs = await SharedPreferences.getInstance();
    final isAlreadySetup = prefs.getBool(_pushAlarmSetupKey) ?? false;

    if (!isAlreadySetup) {
      await _scheduleDevicePushAlarms();
      await prefs.setBool(_pushAlarmSetupKey, true);
    }
  }

  static Future<void> _initializeDevicePushAlarmSettings() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _pushAlarms.initialize(settings);

    // 포그라운드 알림 권한 요청
    await _pushAlarms
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _pushAlarms
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> _scheduleDevicePushAlarms() async {
    final firstMissionTime = MissionTimeRepository.getMissionTime(1);
    final secondMissionTime = MissionTimeRepository.getMissionTime(2);

    if (firstMissionTime != null) {
      await scheduleMissionPushAlarm(1, firstMissionTime);
    }
    if (secondMissionTime != null) {
      await scheduleMissionPushAlarm(2, secondMissionTime);
    }
  }

  static Future<void> scheduleMissionPushAlarm(
      int missionNumber, TimeOfDay missionTime) async {
    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      missionTime.hour,
      missionTime.minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await _pushAlarms.zonedSchedule(
      missionNumber,
      '미션 알림',
      '미션 시간입니다!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mission_alarm',
          'Mission Alarm',
          channelDescription: 'Mission time notification',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelMissionPushAlarm(int missionNumber) async {
    await _pushAlarms.cancel(missionNumber);
  }

  static Future<void> cancelAllMissionPushAlarms() async {
    await _pushAlarms.cancelAll();
  }

  static Future<void> updateMissionPushAlarm(
      int missionNumber, TimeOfDay? time) async {
    await cancelMissionPushAlarm(missionNumber);

    if (time != null) {
      await scheduleMissionPushAlarm(missionNumber, time);
    }
  }
}
