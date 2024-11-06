import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/time_utils.dart';

/// 미션 시간 데이터를 관리하는 저장소입니다.
///
/// 설정된 미션 시간은 서버에 기록되며, 서버에서 미션을 생성할때 사용됩니다.
///
/// 다만 인터넷 연결이 불안정한 환경을 대비하여, 로컬에도 미션 시간을 저장합니다.
/// 해당 값을 통해 로컬상에서 미션이 생성될 수 있습니다.
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
