import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../repositories/mission_time_repository.dart';
import '../repositories/mission_repository.dart';

class MissionService {
  // SharedPreferences 초기화
  static Future<void> init() async {
    await MissionTimeRepository.init();
    await MissionRepository.init();
  }

  // 미션 시간 저장
  static Future<void> saveMissionTime(int missionNumber, TimeOfDay? time,
      {bool isUpdateTodayMission = true}) async {
    if (time != null) {
      await MissionTimeRepository.setMissionTime(missionNumber, time);
      if (isUpdateTodayMission) {
        await MissionRepository.updateTodayMissionTime(missionNumber, time);
      }
    } else {
      await MissionTimeRepository.clearMissionTime(missionNumber);
      if (isUpdateTodayMission) {
        await MissionRepository.removeTodayMission(missionNumber);
      }
    }
    print('미션$missionNumber 시간 저장: $time');
  }

  // 미션 시간 불러오기
  static TimeOfDay? getMissionTime(int missionNumber) {
    final time = MissionTimeRepository.getMissionTime(missionNumber);
    print('미션$missionNumber 시간 불러오기: $time');
    return time;
  }

  // 미션 완료 상태 토글 및 히스토리 저장
  static Future<bool> toggleMissionComplete(String missionId) async {
    final today = DateTime.now();

    final mission = await MissionRepository.findMissionById(today, missionId);

    if (mission == null) {
      throw Exception('Mission not found');
    }

    final newIsCompleted = !mission.isCompleted;
    final updatedMission = mission.copyWith(
      isCompleted: newIsCompleted,
      completedAt: newIsCompleted ? DateTime.now() : null,
    );

    // 변경된 데이터 저장
    await MissionRepository.updateMission(today, updatedMission);

    // 변경된 미션의 새로운 상태 반환
    return updatedMission.isCompleted;
  }

  static Future<bool> hasTodayMissions() async {
    final missions = await MissionRepository.findMissions(DateTime.now());
    return missions.isNotEmpty;
  }

  // 오늘의 미션 데이터 가져오기
  static Future<List<Mission>> getTodaysMissions() async {
    final missions = await MissionRepository.findMissions(DateTime.now(),
        createIfEmpty: true);

    // 저장된 미션 데이터 반환
    return missions;
  }

  // 특정 날짜의 미션 히스토리 가져오기
  static Future<List<Mission>> getMissionHistory(DateTime date) async {
    return await MissionRepository.findMissions(date);
  }

  // 모든 미션 데이터 삭제 (설정 초기화용)
  static Future<void> clearAllMissionData() async {
    await MissionRepository.clearAllMissions();
    print('모든 미션 데이터 삭제 완료');
  }

  // 디버깅용: 저장소 전체 데이터 출력
  static void debugStorageContent() {
    MissionRepository.debugStorageContent();
  }
}
