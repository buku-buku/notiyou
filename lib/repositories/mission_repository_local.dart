import 'package:flutter/material.dart';
import 'package:notiyou/repositories/mission_repository_interface.dart';
import 'package:notiyou/repositories/mission_time_repository_interface.dart';
import 'package:notiyou/repositories/mission_time_repository_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/mission.dart';
import '../utils/time_utils.dart';

/// 미션 데이터를 관리하는 저장소입니다.
///
/// 해당 저장소에서는 미션을 조회하고, 수정하는 메서드만 제공됩니다.
///
/// 미션이 생성되는 것은 서버에서 수행될 예정입니다. 클라이언트상에서 생성되는 미션은
/// 인터넷 연결이 불안정한 환경을 대비한 캐싱 목적으로만 존재합니다.
///
/// ⚠️: 로컬의 데이터는 오늘의 데이터만 저장됩니다.
/// 오늘 이후의 모든 데이터는 앱 실행 시 삭제됩니다.

class MissionRepositoryLocal implements MissionRepository {
  SharedPreferences? _prefs;
  final String _missionStoreKey = 'mission';
  final MissionTimeRepository _missionTimeRepository =
      MissionTimeRepositoryLocal();

// 싱글턴 인스턴스
  static final MissionRepositoryLocal _instance =
      MissionRepositoryLocal._internal();

  // 팩토리 생성자
  factory MissionRepositoryLocal() {
    return _instance;
  }

  // private 생성자
  MissionRepositoryLocal._internal();

  Future<void> init() async {
    await _missionTimeRepository.init();
    _prefs ??= await SharedPreferences.getInstance();
  }

  // 미션 별 키 생성
  String _getMissionKey(int missionNumber) => 'mission$missionNumber';

  // 날짜별 키 생성.
  String _getKeyForDate(DateTime date) {
    return '${_missionStoreKey}_${TimeUtils.stringifyYearMonthDay(date)}';
  }

  /// Shared Preferences에 저장되어 있는 날짜별 키 목록
  /// ```dart
  /// final keys = MissionRepository._getDateKeys();
  /// print(keys); // ['mission_2024-11-04', 'mission_2024-11-03', ...]
  /// ```
  List<String> _getDateKeys() {
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
  DateTime _parseDateFromKey(String key) {
    return TimeUtils.parseDate(key.replaceFirst('${_missionStoreKey}_', ''));
  }

  /// 미션 데이터 저장
  /// TODO: 실제로 데이터가 생성되는 것은 서버에서 수행될 예정입니다.
  /// 이후 해당 메서드는 서버에서 데이터를 받아오는 것을 대비한 캐싱 목적으로만 존재합니다.
  Future<void> _setMissions(DateTime date, List<Mission> missions) async {
    final key = _getKeyForDate(date);
    if (_prefs == null) await init();

    final missionJsonList =
        missions.map((m) => jsonEncode(m.toJson())).toList();
    await _prefs!.setStringList(key, missionJsonList);
  }

  Future<void> _addMission(DateTime date, Mission mission) async {
    final missions = await findMissions(date);
    final updatedMissions = [...missions, mission];
    await _setMissions(date, updatedMissions);
  }

  Future<void> updateTodayMissionTime(
    int missionNumber,
    TimeOfDay time,
  ) async {
    throw UnimplementedError('updateTodayMissionTime is not implemented');
  }

  // 미션 데이터 수정
  Future<void> updateMission(Mission mission) async {
    throw UnimplementedError('updateMission is not implemented');
  }

  /// ? 이것까지 레포지토리에 위치시키는게 좋을지 고민이 되긴함..
  Future<List<Mission>> _createTodaysMissions(DateTime date) async {
    final [mission1Time, mission2Time] = await Future.wait([
      _missionTimeRepository.getMissionTime(1),
      _missionTimeRepository.getMissionTime(2),
    ]);

    return [
      if (mission1Time != null)
        Mission(
          id: _getMissionKey(1),
          missionNumber: 1,
          time: mission1Time,
          isCompleted: false,
          date: date,
        ),
      if (mission2Time != null)
        Mission(
          id: _getMissionKey(2),
          missionNumber: 2,
          time: mission2Time,
          isCompleted: false,
          date: date,
        ),
    ];
  }

  // 미션 데이터 불러오기
  Future<List<Mission>> findMissions(DateTime date,
      {bool createIfEmpty = false}) async {
    final key = _getKeyForDate(date);
    if (_prefs == null) await init();

    final missionJsonList = _prefs!.getStringList(key) ?? [];

    // 미션 데이터가 없으면 로컬에서 임의로 생성한다.
    if (missionJsonList.isEmpty && createIfEmpty) {
      final newMissions = await _createTodaysMissions(date);

      await _setMissions(date, newMissions);
      return newMissions;
    }

    return missionJsonList
        .map((json) => Mission.fromJson(jsonDecode(json)))
        .toList();
  }

  /// 현재는 오늘의 미션에 대한 찾기만 지원함.
  Future<Mission?> findMissionById(String id) async {
    final missions = await findMissions(DateTime.now());
    try {
      return missions.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  // 미션 번호로 미션 찾기
  Future<Mission?> _findMissionByMissionNumber(
      DateTime date, int missionNumber) async {
    final missions = await findMissions(date);
    try {
      return missions.firstWhere((m) => m.missionNumber == missionNumber);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> removeTodayMission(int missionNumber) async {
    final today = DateTime.now();
    final mission = await _findMissionByMissionNumber(today, missionNumber);
    if (mission != null) {
      await _removeMissionById(today, mission.id);
    }
  }

  Future<void> _removeMissionById(DateTime date, String id) async {
    final missions = await findMissions(date);
    final updatedMissions = missions.where((m) => m.id != id).toList();
    await _setMissions(date, updatedMissions);
  }
}
