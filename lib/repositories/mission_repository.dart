import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/mission.dart';

class MissionRepository {
  static SharedPreferences? _prefs;

  // SharedPreferences 초기화
  static Future<void> init() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  // 날짜별 키 생성
  static String getKeyForDate(DateTime date) {
    return 'mission_${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // 미션 데이터 저장
  static Future<void> saveMissions(String key, List<Mission> missions) async {
    if (_prefs == null) await init();

    final missionJsonList =
        missions.map((m) => jsonEncode(m.toJson())).toList();
    await _prefs!.setStringList(key, missionJsonList);
  }

  // 미션 데이터 불러오기
  static Future<List<Mission>> getMissions(String key) async {
    if (_prefs == null) await init();

    final missionJsonList = _prefs!.getStringList(key) ?? [];
    return missionJsonList
        .map((json) => Mission.fromJson(jsonDecode(json)))
        .toList();
  }

  // 특정 키의 데이터 삭제
  static Future<void> removeData(String key) async {
    if (_prefs == null) await init();

    await _prefs!.remove(key);
  }
}
