import 'package:flutter/material.dart';
import 'package:notiyou/models/mission.dart';

abstract interface class MissionRepository {
  Future<void> init();

  // TODO: missionId로 생성하도록 변경
  Future<void> createTodayMission(int missionNumber);

  Future<bool> hasTodayMission(int missionNumber);

// TODO: missionNumber가 아닌 id로 업데이트
  Future<void> updateTodayMissionTime(
    int missionNumber,
    TimeOfDay time,
  );

  Future<void> updateMission(Mission mission);

  // TODO: findMissions에 날짜 범위로 조회 기능 추가
  Future<List<Mission>> findMissions(DateTime date);

  Future<Mission?> findMissionById(String id);

  // TODO: removeMissionById를 제공하고 해당 메서드 삭제
  Future<void> removeTodayMission(int missionNumber);
}
