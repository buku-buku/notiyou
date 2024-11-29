import 'package:flutter/material.dart';
import '../models/mission.dart';

abstract interface class MissionRepository {
  Future<void> init();
  Future<void> updateTodayMissionTime(
    int missionNumber,
    TimeOfDay time,
  );
  Future<void> updateMission(DateTime date, Mission mission);
  Future<List<Mission>> findMissions(DateTime date,
      {bool createIfEmpty = false});
  Future<Mission?> findMissionById(DateTime date, String id);
  Future<Mission?> findMissionByMissionNumber(DateTime date, int missionNumber);
  Future<void> removeTodayMission(int missionNumber);
  Future<void> removeMissionById(DateTime date, String id);

  /// 특정 날짜의 데이터 삭제
  Future<void> removeMissionsFrom(DateTime date);

  /// 특정 날짜 이전의 데이터 삭제
  Future<void> removeMissionsBefore(DateTime date);
  // 모든 미션 삭제
  Future<void> clearAllMissions();
}
