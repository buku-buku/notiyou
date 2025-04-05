import 'package:flutter/material.dart';
import 'package:notiyou/repositories/mission_time_repository/mission_time_repository_interface.dart';
import 'package:notiyou/repositories/mission_time_repository/mission_time_repository_remote.dart';
import 'package:notiyou/services/auth/auth_service.dart';
import 'package:notiyou/services/local_notification_service.dart';
import 'package:notiyou/services/notification/notification_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MissionAlarmService {
  static final MissionTimeRepository _missionTimeRepository =
      MissionTimeRepositoryRemote();

  static const String _pushAlarmSetupKey = 'push_alarm_setup';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isAlreadySetup = prefs.getBool(_pushAlarmSetupKey) ?? false;

    if (!isAlreadySetup) {
      await _scheduleDevicePushAlarms();
      await prefs.setBool(_pushAlarmSetupKey, true);
    }
  }

  // TODO: 로그인 및 회원가입을 모두 마친 후, 미션 시간을 설정한 후에 알림 설정을 하도록 수정
  static Future<void> _scheduleDevicePushAlarms() async {
    if (!await AuthService.isLoggedIn()) {
      return;
    }
    final missionTimes = await _missionTimeRepository.getMissionTimes();

    for (var missionTime in missionTimes) {
      if (missionTime == null) {
        continue;
      }

      scheduleAlarm(missionTime.id, missionTime.missionAt);
    }
  }

  static Future<void> scheduleAlarm(
      int missionId, TimeOfDay missionTime) async {
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

    await LocalNotificationService.scheduleNotification(
      id: missionId,
      title: '미션 알림',
      body: '미션 시간입니다!',
      scheduledTime: scheduledTime,
      notificationType: NotificationEvent.missionAlarm.value,
    );
  }

  static Future<void> cancelAlarm(int missionId) async {
    await LocalNotificationService.cancelNotification(missionId);
  }

  static Future<void> cancelAllAlarms() async {
    await LocalNotificationService.cancelAllNotifications();
  }

  static Future<void> updateAlarm(int missionId, TimeOfDay? time) async {
    await cancelAlarm(missionId);

    if (time != null) {
      await scheduleAlarm(missionId, time);
    }
  }
}
