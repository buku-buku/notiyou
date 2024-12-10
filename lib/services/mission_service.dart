import 'package:flutter/material.dart';
import 'package:notiyou/repositories/mission_history_repository_interface.dart';
import 'package:notiyou/repositories/mission_history_repository_local.dart';
import 'package:notiyou/repositories/mission_history_repository_remote.dart';
import 'package:notiyou/repositories/mission_time_repository_interface.dart';
import 'package:notiyou/repositories/mission_time_repository_local.dart';
import 'package:notiyou/repositories/mission_time_repository_remote.dart';
import 'package:notiyou/services/mission_alarm_service.dart';
import 'package:notiyou/models/mission.dart';

class MissionService {
  static MissionTimeRepository _missionTimeRepository =
      MissionTimeRepositoryRemote();
  static MissionHistoryRepository _missionHistoryRepository =
      MissionHistoryRepositoryRemote();

  // SharedPreferences 초기화
  static Future<void> init() async {
    await _missionTimeRepository.init();
    await _missionHistoryRepository.init();
  }

  // 미션 시간 저장
  static Future<void> saveMissionTime(
    int missionNumber,
    TimeOfDay? time,
  ) async {
    if (time != null) {
      await _missionTimeRepository.setMissionTime(missionNumber, time);
      if (await _missionHistoryRepository.hasTodayMission(missionNumber)) {
        await _missionHistoryRepository.updateTodayMissionTime(
            missionNumber, time);
      } else {
        await _missionHistoryRepository.createTodayMission(missionNumber);
      }
    } else {
      await _missionTimeRepository.clearMissionTime(missionNumber);
      // 미션 시간 삭제시 오늘의 미션 삭제
      await _missionHistoryRepository.removeTodayMission(missionNumber);
    }

    await MissionAlarmService.updateAlarm(missionNumber, time);
  }

  // 미션 시간 불러오기
  static Future<TimeOfDay?> getMissionTime(int missionNumber) async {
    final time = await _missionTimeRepository.getMissionTime(missionNumber);

    return time;
  }

  // 미션 완료 상태 토글 및 히스토리 저장
  static Future<bool> toggleMissionComplete(String missionId) async {
    final mission = await _missionHistoryRepository.findMissionById(missionId);

    if (mission == null) {
      throw Exception('Mission not found');
    }

    final newIsCompleted = !mission.isCompleted;
    final updatedMission = mission.copyWith(
      isCompleted: newIsCompleted,
      completedAt: newIsCompleted ? DateTime.now() : null,
    );

    // 변경된 데이터 저장
    await _missionHistoryRepository.updateMission(updatedMission);

    // 변경된 미션의 새로운 상태 반환
    return updatedMission.isCompleted;
  }

  static Future<bool> hasTodayMissions() async {
    final missions =
        await _missionHistoryRepository.findMissions(DateTime.now());
    return missions.isNotEmpty;
  }

  // 오늘의 미션 데이터 가져오기
  static Future<List<Mission>> getTodaysMissions() async {
    final missions =
        await _missionHistoryRepository.findMissions(DateTime.now());
    print(missions);
    // 저장된 미션 데이터 반환
    return missions;
  }

  // 특정 날짜의 미션 히스토리 가져오기
  static Future<List<Mission>> getMissionHistory(DateTime date) async {
    return await _missionHistoryRepository.findMissions(date);
  }

  static switchToLocalRepository() {
    _missionTimeRepository = MissionTimeRepositoryLocal();
    _missionHistoryRepository = MissionHistoryRepositoryLocal();
  }
}
