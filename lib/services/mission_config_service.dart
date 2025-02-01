import 'package:flutter/material.dart';
import 'package:notiyou/repositories/mission_grace_period_repository_remote.dart';
import 'package:notiyou/repositories/mission_grace_period_repository_interface.dart';
import 'package:notiyou/repositories/mission_grace_period_repository_local.dart';
import 'package:notiyou/repositories/mission_history_repository_interface.dart';
import 'package:notiyou/repositories/mission_history_repository_local.dart';
import 'package:notiyou/repositories/mission_history_repository_remote.dart';
import 'package:notiyou/repositories/mission_time_repository_interface.dart';
import 'package:notiyou/repositories/mission_time_repository_local.dart';
import 'package:notiyou/repositories/mission_time_repository_remote.dart';
import 'package:notiyou/services/mission_alarm_service.dart';
import 'package:notiyou/services/mission_supporter_exception.dart';

class MissionConfigService {
  static bool _isLocalMode = false;
  static MissionTimeRepository _missionTimeRepository =
      MissionTimeRepositoryRemote();
  static final MissionSupporterRepository _missionSupporterRepository =
      MissionTimeRepositoryRemote();
  static MissionHistoryRepository _missionHistoryRepository =
      MissionHistoryRepositoryRemote();
  static MissionGracePeriodRepository _missionGracePeriodRepository =
      MissionGracePeriodRepositoryRemote();

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

  static Future<int> getGracePeriod() async {
    return await _missionGracePeriodRepository.getGracePeriod();
  }

  static Future<void> saveGracePeriod(int gracePeriod) async {
    await _missionGracePeriodRepository.setGracePeriod(gracePeriod);
  }

  static Future<void> saveMissionSupporter(
      String challengerId, String supporterId) async {
    if (_isLocalMode) {
      throw MissionSupporterException('오프라인 모드에서는 조력자 등록 기능을 사용할 수 없습니다.');
    }
    final mission =
        await _missionSupporterRepository.getMissionByUserId(challengerId);
    if (mission == null) {
      throw MissionSupporterException('유효한 미션이 아닙니다.');
    }
    if (mission.supporterId != null) {
      throw MissionSupporterException('추가 조력자를 등록할 수 없는 미션입니다.');
    }
    await _missionSupporterRepository.setMissionSupporter(
        challengerId, supporterId);
  }

  static switchToLocalRepository() {
    _isLocalMode = true;
    _missionTimeRepository = MissionTimeRepositoryLocal();
    _missionHistoryRepository = MissionHistoryRepositoryLocal();
    _missionGracePeriodRepository = MissionGracePeriodRepositoryLocal();
  }
}
