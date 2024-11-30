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

  @override
  Future<void> init() async {
    await _missionTimeRepository.init();
    _prefs ??= await SharedPreferences.getInstance();
  }

  String _getKeyForDate(DateTime date) {
    return '${_missionStoreKey}_${TimeUtils.stringifyYearMonthDay(date)}';
  }

  /// 미션 데이터 저장
  /// 이후 해당 메서드는 서버에서 데이터를 받아오는 것을 대비한 캐싱 목적으로만 존재합니다.
  Future<void> _setMissions(DateTime date, List<Mission> missions) async {
    final key = _getKeyForDate(date);
    if (_prefs == null) await init();

    final missionJsonList =
        missions.map((m) => jsonEncode(m.toJson())).toList();
    await _prefs!.setStringList(key, missionJsonList);
  }

  @override
  Future<bool> hasTodayMission(int missionNumber) async {
    final missions = await findMissions(DateTime.now());
    return missions.any((e) => e.missionNumber == missionNumber);
  }

  @override
  Future<void> updateTodayMissionTime(
    int missionNumber,
    TimeOfDay time,
  ) async {
    throw UnimplementedError('updateTodayMissionTime is not implemented');
  }

  @override
  Future<void> updateMission(Mission mission) async {
    throw UnimplementedError('updateMission is not implemented');
  }

  @override
  Future<List<Mission>> findMissions(DateTime date) async {
    final key = _getKeyForDate(date);
    if (_prefs == null) await init();

    final missionJsonList = _prefs!.getStringList(key) ?? [];

    return missionJsonList
        .map((json) => Mission.fromJson(jsonDecode(json)))
        .toList();
  }

  /// ! 현재는 오늘의 미션에 대한 찾기만 지원함.
  @override
  Future<Mission?> findMissionById(String id) async {
    final missions = await findMissions(DateTime.now());
    try {
      return missions.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

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
