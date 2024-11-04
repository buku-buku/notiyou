import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/time_utils.dart';

class MissionTimeRepository {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  static String _getMissionKey(int missionNumber) => 'mission$missionNumber';

  // 미션 시간 조회
  static TimeOfDay? getMissionTime(int missionNumber) {
    final key = _getMissionKey(missionNumber);
    final timeStr = _prefs!.getString(key);

    if (timeStr == null) return null;

    return TimeUtils.parseTime(timeStr);
  }

  // 미션 시간 설정
  static Future<void> setMissionTime(int missionNumber, TimeOfDay time) async {
    final key = _getMissionKey(missionNumber);
    await _prefs!.setString(key, TimeUtils.stringifyTime(time));
  }

  // 미션 시간 초기화
  static Future<void> clearMissionTime(int missionNumber) async {
    final key = _getMissionKey(missionNumber);
    await _prefs!.remove(key);
  }
}
