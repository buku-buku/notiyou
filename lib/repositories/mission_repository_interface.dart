import 'package:flutter/material.dart';
import '../models/mission.dart';

abstract interface class MissionRepository {
  Future<void> init();

  Future<void> updateTodayMissionTime(
    int missionNumber,
    TimeOfDay time,
  );

  Future<void> updateMission(DateTime date, Mission mission);

  // TODO: findMissions에 날짜 범위로 조회 기능 추가
  Future<List<Mission>> findMissions(DateTime date,
      {bool createIfEmpty = false});

  // TODO: date 파라미터 삭제. 타임존에 따른 버그를 일으키기 쉬움
  Future<Mission?> findMissionById(DateTime date, String id);

  // TODO: 해당 메서드 삭제. 미션 번호로 찾는 것은 의미가 없음
  Future<Mission?> findMissionByMissionNumber(DateTime date, int missionNumber);

  // TODO: 해당 메서드 삭제. 미션 번호로 찾는 것은 의미가 없음. 미션을 굳이 클라이언트에서 지울 필요도 없음.
  Future<void> removeTodayMission(int missionNumber);

  // TODO: 해당 메서드 삭제. 미션을 클라이언트에서 지우려고 할 필요가 없음.
  Future<void> removeMissionById(DateTime date, String id);

  /// 특정 날짜의 데이터 삭제
  /// TODO: 해당 메서드 삭제. 미션을 클라이언트에서 지우려고 할 필요가 없음.
  Future<void> removeMissionsFrom(DateTime date);

  /// 특정 날짜 이전의 데이터 삭제
  /// TODO: 해당 메서드 삭제. 미션을 클라이언트에서 지우려고 할 필요가 없음.
  Future<void> removeMissionsBefore(DateTime date);

  // TODO: 해당 메서드 삭제. 미션을 클라이언트에서 지우려고 할 필요가 없음.
  Future<void> clearAllMissions();
}
