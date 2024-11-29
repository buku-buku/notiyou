import 'package:flutter/src/material/time.dart';
import 'package:notiyou/models/mission.dart';
import 'package:notiyou/repositories/mission_repository_interface.dart';

/// 미션 데이터를 관리하는 저장소입니다.
///
/// 해당 저장소에서는 미션을 조회하고, 수정하는 메서드만 제공됩니다.
///
/// 미션이 생성되는 것은 서버에서 수행될 예정입니다. 클라이언트상에서 생성되는 미션은
/// 인터넷 연결이 불안정한 환경을 대비한 캐싱 목적으로만 존재합니다.
///
/// ⚠️: 로컬의 데이터는 오늘의 데이터만 저장됩니다.
/// 오늘 이후의 모든 데이터는 앱 실행 시 삭제됩니다.

class MissionRepositoryRemote implements MissionRepository {
  @override
  Future<void> clearAllMissions() {
    // TODO: implement clearAllMissions
    throw UnimplementedError();
  }

  @override
  Future<Mission?> findMissionById(DateTime date, String id) {
    // TODO: implement findMissionById
    throw UnimplementedError();
  }

  @override
  Future<Mission?> findMissionByMissionNumber(
      DateTime date, int missionNumber) {
    // TODO: implement findMissionByMissionNumber
    throw UnimplementedError();
  }

  @override
  Future<List<Mission>> findMissions(DateTime date,
      {bool createIfEmpty = false}) {
    // TODO: implement findMissions
    throw UnimplementedError();
  }

  @override
  Future<void> init() {
    // TODO: implement init
    throw UnimplementedError();
  }

  @override
  Future<void> removeMissionById(DateTime date, String id) {
    // TODO: implement removeMissionById
    throw UnimplementedError();
  }

  @override
  Future<void> removeMissionsBefore(DateTime date) {
    // TODO: implement removeMissionsBefore
    throw UnimplementedError();
  }

  @override
  Future<void> removeMissionsFrom(DateTime date) {
    // TODO: implement removeMissionsFrom
    throw UnimplementedError();
  }

  @override
  Future<void> removeTodayMission(int missionNumber) {
    // TODO: implement removeTodayMission
    throw UnimplementedError();
  }

  @override
  Future<void> updateMission(DateTime date, Mission mission) {
    // TODO: implement updateMission
    throw UnimplementedError();
  }

  @override
  Future<void> updateTodayMissionTime(int missionNumber, TimeOfDay time) {
    // TODO: implement updateTodayMissionTime
    throw UnimplementedError();
  }
}
