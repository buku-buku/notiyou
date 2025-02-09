import 'package:flutter/material.dart';
import 'package:notiyou/repositories/mission_history_repository_interface.dart';
import 'package:notiyou/repositories/mission_time_repository_interface.dart';
import 'package:notiyou/repositories/mission_time_repository_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:notiyou/models/mission.dart';
import 'package:notiyou/utils/time_utils.dart';

/// 미션 데이터를 관리하는 저장소입니다.
///
/// 해당 저장소에서는 미션을 조회하고, 수정하는 메서드만 제공됩니다.
///
/// 미션이 생성되는 것은 서버에서 수행될 예정입니다. 클라이언트상에서 생성되는 미션은
/// 인터넷 연결이 불안정한 환경을 대비한 캐싱 목적으로만 존재합니다.
///
/// ⚠️: 로컬의 데이터는 오늘의 데이터만 저장됩니다.
/// 오늘 이후의 모든 데이터는 앱 실행 시 삭제됩니다.
class MissionHistoryRepositoryLocal implements MissionHistoryRepository {
  SharedPreferences? _prefs;
  final String _missionStoreKey = 'mission';
  final MissionTimeRepository _missionTimeRepository =
      MissionTimeRepositoryLocal();

// 싱글턴 인스턴스
  static final MissionHistoryRepositoryLocal _instance =
      MissionHistoryRepositoryLocal._internal();

  // 팩토리 생성자
  factory MissionHistoryRepositoryLocal() {
    return _instance;
  }

  // private 생성자
  MissionHistoryRepositoryLocal._internal();

  @override
  Future<void> init() async {
    await _missionTimeRepository.init();
    _prefs ??= await SharedPreferences.getInstance();
  }

  String _getKeyForDate(DateTime date) {
    return '${_missionStoreKey}_${TimeUtils.stringifyYearMonthDay(date)}';
  }

  @override
  Future<void> createTodayMission(int missionId) async {
    throw UnimplementedError('createTodayMission is not implemented');
  }

  @override
  Future<bool> hasTodayMission(int missionId) async {
    final missions = await findMissions(DateTime.now());
    return missions.any((e) => e.id == missionId);
  }

  @override
  Future<void> updateTodayMissionTime(
    int missionId,
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
  Future<Mission?> findMissionById(int id) async {
    final missions = await findMissions(DateTime.now());
    try {
      return missions.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> removeTodayMission(int missionId) async {
    throw UnimplementedError('removeTodayMission is not implemented');
  }

  @override
  Future<List<Mission>> findAllMissions() async {
    throw UnimplementedError('findAllMissions is not implemented');
  }
}
