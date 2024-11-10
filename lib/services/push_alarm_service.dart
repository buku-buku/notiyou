import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notiyou/repositories/mission_time_repository.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class PushAlarmService {
  static final FlutterLocalNotificationsPlugin _pushAlarms =
      FlutterLocalNotificationsPlugin();

  static const String _pushAlarmSetupKey = 'push_alarm_setup';

  static Future<void> init() async {
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
    var pushStartDatetime = DateTime(
      now.year,
      now.month,
      now.day,
      missionTime.hour,
      missionTime.minute,
    );

    final zonedScheduledDate = tz.TZDateTime.from(pushStartDatetime, tz.local);
    if (zonedScheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      pushStartDatetime = pushStartDatetime.add(const Duration(days: 1));
    }

    await _pushAlarms.zonedSchedule(
      missionNumber, // 알림 ID
      '미션 알림', // 제목
      '미션 시간입니다!', // 내용
      tz.TZDateTime.from(pushStartDatetime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'notiyou_mission_channel', // 채널 ID
          '미션 알림', // 채널 이름
          channelDescription: '미션 시간 알림', // 채널 설명
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // 절전 모드에서도 알림 발생
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancelMissionPushAlarm(int missionNumber) async {
    await _pushAlarms.cancel(missionNumber);
  }

  // 개별 미션 알림 설정/해제
  static Future<void> updateMissionPushAlarm(
      int missionNumber, TimeOfDay? time) async {
    await cancelMissionPushAlarm(missionNumber);

    // 새로운 시간이 있는 경우에만 알림 설정
    if (time != null) {
      await scheduleMissionPushAlarm(missionNumber, time);
      print('미션 $missionNumber의 알림이 ${time.hour}:${time.minute}으로 업데이트되었습니다.');
    }
  }
}
