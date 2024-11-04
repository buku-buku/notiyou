import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/mission.dart';
import '../utils/time_utils.dart';
import './mission_time_repository.dart';

class MissionRepository {
  static SharedPreferences? _prefs;
  static const String _missionStoreKey = 'mission';

  // SharedPreferences 초기화
  static Future<void> init() async {
    await MissionTimeRepository.init();
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    await removeMissionsBefore(DateTime.now());
  }

  // 미션 별 키 생성
  static String _getMissionKey(int missionNumber) => 'mission$missionNumber';

  // 날짜별 키 생성.
  static String _getKeyForDate(DateTime date) {
    return '${_missionStoreKey}_${TimeUtils.stringifyYearMonthDay(date)}';
  }

  /// Shared Preferences에 저장되어 있는 날짜별 키 목록
  /// ```dart
  /// final keys = MissionRepository._getDateKeys();
  /// print(keys); // ['mission_2024-11-04', 'mission_2024-11-03', ...]
  /// ```
  static List<String> _getDateKeys() {
    return _prefs!
        .getKeys()
        .where((key) =>
            TimeUtils.isDateString(key) && key.startsWith(_missionStoreKey))
        .toList();
  }

  /// 날짜 키로부터 날짜 값 파싱
  /// ```dart
  /// final date = MissionRepository._parseDateFromKey('mission_2024-11-04');
  /// print(date); // DateTime(2024, 11, 4)
  /// ```
  static DateTime _parseDateFromKey(String key) {
    return TimeUtils.parseDate(key.replaceFirst('${_missionStoreKey}_', ''));
  }

  // 미션 데이터 저장
  static Future<void> _setMissions(
      DateTime date, List<Mission> missions) async {
    final key = _getKeyForDate(date);
    if (_prefs == null) await init();

    final missionJsonList =
        missions.map((m) => jsonEncode(m.toJson())).toList();
    await _prefs!.setStringList(key, missionJsonList);
  }

  static Future<void> _addMission(DateTime date, Mission mission) async {
    final missions = await findMissions(date);
    final updatedMissions = [...missions, mission];
    await _setMissions(date, updatedMissions);
  }

  static Future<void> updateTodayMissionTime(
    int missionNumber,
    TimeOfDay time,
  ) async {
    final today = DateTime.now();
    final mission = await findMissionByMissionNumber(today, missionNumber);
    if (mission != null) {
      await updateMission(today, mission.copyWith(time: time));
    } else {
      await _addMission(
          today,
          Mission(
            id: _getMissionKey(missionNumber),
            missionNumber: missionNumber,
            time: time,
            isCompleted: false,
            date: today,
          ));
    }
  }

  // 미션 데이터 수정
  static Future<void> updateMission(DateTime date, Mission mission) async {
    // mission id로 기존 미션 찾기
    final missions = await findMissions(date);
    final updatedMissions = missions.map((m) {
      if (m.id == mission.id) return mission;
      return m;
    }).toList();

    await _setMissions(date, updatedMissions);
  }

  /// ? 이것까지 레포지토리에 위치시키는게 좋을지 고민이 되긴함..
  static List<Mission> _createTodaysMissions(DateTime date) {
    return [
      if (MissionTimeRepository.getMissionTime(1) != null)
        Mission(
          id: _getMissionKey(1),
          missionNumber: 1,
          time: MissionTimeRepository.getMissionTime(1)!,
          isCompleted: false,
          date: date,
        ),
      if (MissionTimeRepository.getMissionTime(2) != null)
        Mission(
          id: _getMissionKey(2),
          missionNumber: 2,
          time: MissionTimeRepository.getMissionTime(2)!,
          isCompleted: false,
          date: date,
        ),
    ];
  }

  // 미션 데이터 불러오기
  static Future<List<Mission>> findMissions(DateTime date,
      {bool createIfEmpty = false}) async {
    final key = _getKeyForDate(date);
    if (_prefs == null) await init();

    final missionJsonList = _prefs!.getStringList(key) ?? [];

    // 미션 데이터가 없으면 로컬에서 임의로 생성한다.
    if (missionJsonList.isEmpty && createIfEmpty) {
      final newMissions = _createTodaysMissions(date);

      await _setMissions(date, newMissions);
      return newMissions;
    }

    return missionJsonList
        .map((json) => Mission.fromJson(jsonDecode(json)))
        .toList();
  }

  // 미션 아이디로 미션 찾기
  static Future<Mission?> findMissionById(DateTime date, String id) async {
    final missions = await findMissions(date);
    try {
      return missions.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  // 미션 번호로 미션 찾기
  static Future<Mission?> findMissionByMissionNumber(
      DateTime date, int missionNumber) async {
    final missions = await findMissions(date);
    try {
      return missions.firstWhere((m) => m.missionNumber == missionNumber);
    } catch (e) {
      return null;
    }
  }

  static Future<void> removeTodayMission(int missionNumber) async {
    final today = DateTime.now();
    final mission = await findMissionByMissionNumber(today, missionNumber);
    if (mission != null) {
      await removeMissionById(today, mission.id);
    }
  }

  static Future<void> removeMissionById(DateTime date, String id) async {
    final missions = await findMissions(date);
    final updatedMissions = missions.where((m) => m.id != id).toList();
    await _setMissions(date, updatedMissions);
  }

  /// 특정 날짜의 데이터 삭제
  static Future<void> removeMissionsFrom(DateTime date) async {
    final key = _getKeyForDate(date);
    if (_prefs == null) await init();

    await _prefs!.remove(key);
  }

  /// 특정 날짜 이전의 데이터 삭제
  static Future<void> removeMissionsBefore(DateTime date) async {
    if (_prefs == null) await init();

    final futures = _getDateKeys()
        .where((key) => _parseDateFromKey(key).isBefore(date))
        .map((key) => _prefs!.remove(key))
        .toList();
    await Future.wait(futures);
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
