import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/mission.dart';
import '../utils/time_utils.dart';

class MissionRepository {
  static SharedPreferences? _prefs;
  static const String _missionStoreKey = 'mission';
  static const String _lastResetKey = 'last_reset_date';

  // SharedPreferences 초기화
  static Future<void> init() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    await checkAndResetDailyMissions();
  }

  // 미션 별 키 생성
  static String _getMissionKey(int missionNumber) => 'mission$missionNumber';

  // 날짜별 키 생성
  static String _getKeyForDate(DateTime date) {
    return '${_missionStoreKey}_${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // 자정 지났는지 확인하고 초기화
  static Future<void> checkAndResetDailyMissions() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastResetStr = _prefs?.getString(_lastResetKey);

    if (lastResetStr != null) {
      final lastReset = DateTime.parse(lastResetStr);

      if (today.compareTo(lastReset) != 0) {
        await removeMissionsFrom(lastReset);
      }
    }

    // 마지막 초기화 날짜 업데이트
    await _prefs?.setString(_lastResetKey, today.toIso8601String());
  }

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

  // 미션 데이터 저장
  static Future<void> setMissions(DateTime date, List<Mission> missions) async {
    final key = _getKeyForDate(date);
    if (_prefs == null) await init();

    final missionJsonList =
        missions.map((m) => jsonEncode(m.toJson())).toList();
    await _prefs!.setStringList(key, missionJsonList);
  }

  // 미션 데이터 수정
  static Future<void> updateMission(DateTime date, Mission mission) async {
    // mission id로 기존 미션 찾기
    final missions = await findMissions(date);
    final updatedMissions = missions.map((m) {
      if (m.id == mission.id) return mission;
      return m;
    }).toList();

    await setMissions(date, updatedMissions);
  }

  // 미션 데이터 불러오기
  static Future<List<Mission>> findMissions(DateTime date) async {
    final key = _getKeyForDate(date);
    if (_prefs == null) await init();

    final missionJsonList = _prefs!.getStringList(key) ?? [];
    return missionJsonList
        .map((json) => Mission.fromJson(jsonDecode(json)))
        .toList();
  }

  // 미션 아이디로 미션 찾기
  static Future<Mission?> findMissionById(DateTime date, String id) async {
    final missions = await findMissions(date);
    return missions.firstWhere((m) => m.id == id);
  }

  // 특정 키의 데이터 삭제
  static Future<void> removeMissionsFrom(DateTime date) async {
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

  // 디버깅용: 모든 히스토리 출력
  static void debugMissionHistory() {
    if (_prefs == null) return;

    print('\n=== 미션 히스토리 ===');
    final allKeys =
        _prefs!.getKeys().where((key) => key.startsWith(_missionStoreKey));
    for (final key in allKeys) {
      final missions = _prefs!.getStringList(key) ?? [];
      print('$key: ${missions.length} missions');
      for (final mission in missions) {
        print('  $mission');
      }
    }
    print('==================\n');
  }

  // 저장소의 모든 데이터 출력 (버깅용)
  static void debugStorageContent() {
    if (_prefs == null) {
      print('SharedPreferences가 초기화되지 않음');
      return;
    }

    print('\n=== 저장소 전체 데이터 ===');
    final keys = _prefs!.getKeys();
    for (final key in keys) {
      print('$key: ${_prefs!.get(key)}');
    }
    print('=======================\n');
  }
}
