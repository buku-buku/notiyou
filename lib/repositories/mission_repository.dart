import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/mission.dart';

class MissionRepository {
  static SharedPreferences? _prefs;
  static const String _missionStoreKey = 'mission';

  // SharedPreferences 초기화
  static Future<void> init() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  // 날짜별 키 생성
  static String _getKeyForDate(DateTime date) {
    return '${_missionStoreKey}_${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // 미션 데이터 저장
  static Future<void> saveMissions(
      DateTime date, List<Mission> missions) async {
    final key = _getKeyForDate(date);
    if (_prefs == null) await init();

    final missionJsonList =
        missions.map((m) => jsonEncode(m.toJson())).toList();
    await _prefs!.setStringList(key, missionJsonList);
  }

  // 미션 데이터 불러오기
  static Future<List<Mission>> getMissions(DateTime date) async {
    final key = _getKeyForDate(date);
    if (_prefs == null) await init();

    final missionJsonList = _prefs!.getStringList(key) ?? [];
    return missionJsonList
        .map((json) => Mission.fromJson(jsonDecode(json)))
        .toList();
  }

  // 특정 키의 데이터 삭제
  static Future<void> removeData(DateTime date) async {
    final key = _getKeyForDate(date);
    if (_prefs == null) await init();

    await _prefs!.remove(key);
  }

  // 모든 미션 삭제
  static Future<void> clearAllMissions() async {
    if (_prefs == null) await init();

    final futures = _prefs!
        .getKeys()
        .where((key) => key.startsWith(_missionStoreKey))
        .map((key) => _prefs!.remove(key))
        .toList();

    await Future.wait(futures);
  }
}
