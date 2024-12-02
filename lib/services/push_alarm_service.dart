import 'package:flutter/material.dart';
import 'package:notiyou/repositories/mission_time_repository_interface.dart';
import 'package:notiyou/repositories/mission_time_repository_remote.dart';
import 'package:notiyou/screens/home_page.dart';
import 'package:notiyou/services/auth/auth_service.dart';
import 'package:notiyou/services/local_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../routes/router.dart';

class PushAlarmService {
  static final MissionTimeRepository _missionTimeRepository =
      MissionTimeRepositoryRemote();

  static const String _pushAlarmSetupKey = 'push_alarm_setup';

  static Future<void> init() async {
    await LocalNotificationService.init(
      onNotificationTapped: (String? payload) {
        if (payload != null) {
          router.push(payload);
        }
      },
    );

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
    final firstMissionTime = await _missionTimeRepository.getMissionTime(1);
    final secondMissionTime = await _missionTimeRepository.getMissionTime(2);

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

    await LocalNotificationService.scheduleNotification(
      id: missionNumber,
      title: '미션 알림',
      body: '미션 시간입니다!',
      scheduledTime: scheduledTime,
      payload: HomePage.routeName,
    );
  }

  static Future<void> cancelMissionPushAlarm(int missionNumber) async {
    await LocalNotificationService.cancelNotification(missionNumber);
  }

  static Future<void> cancelAllMissionPushAlarms() async {
    await LocalNotificationService.cancelAllNotifications();
  }

  static Future<void> updateMissionPushAlarm(
      int missionNumber, TimeOfDay? time) async {
    await cancelMissionPushAlarm(missionNumber);

    if (time != null) {
      await scheduleMissionPushAlarm(missionNumber, time);
    }
  }
}
