import 'package:flutter/material.dart';
import 'package:notiyou/models/mission.dart';

abstract interface class MissionHistoryRepository {
  Future<void> init();

  Future<void> createTodayMission(int missionId);

  Future<bool> hasTodayMission(int missionId);

  Future<void> updateTodayMissionTime(
    int missionId,
    TimeOfDay time,
  );

  Future<void> updateMission(Mission mission);

  // TODO: findMissions에 날짜 범위로 조회 기능 추가
  Future<List<Mission>> findMissions(DateTime date);

  Future<Mission?> findMissionById(int missionId);

  Future<void> removeTodayMission(int missionId);

  Future<List<Mission>> findAllMissions();
}
