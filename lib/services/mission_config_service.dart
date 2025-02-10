import 'package:flutter/material.dart';
import 'package:notiyou/models/mission_time_model.dart';
import 'package:notiyou/repositories/mission_grace_period_repository/mission_grace_period_repository_remote.dart';
import 'package:notiyou/repositories/mission_grace_period_repository/mission_grace_period_repository_interface.dart';
import 'package:notiyou/repositories/mission_grace_period_repository/mission_grace_period_repository_local.dart';
import 'package:notiyou/repositories/mission_history_repository/mission_history_repository_interface.dart';
import 'package:notiyou/repositories/mission_history_repository/mission_history_repository_local.dart';
import 'package:notiyou/repositories/mission_history_repository/mission_history_repository_remote.dart';
import 'package:notiyou/repositories/mission_time_repository/mission_time_repository_interface.dart';
import 'package:notiyou/repositories/mission_time_repository/mission_time_repository_local.dart';
import 'package:notiyou/repositories/mission_time_repository/mission_time_repository_remote.dart';
import 'package:notiyou/services/mission_alarm_service.dart';

class MissionConfigService {
  static MissionTimeRepository _missionTimeRepository =
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

  static Future<void> saveMissionTime(
    TimeOfDay time,
    int? missionId,
  ) async {
    var missionIdToSave = missionId;
    if (missionId == null) {
      final mission = await _missionTimeRepository.createMissionTime(time);
      missionIdToSave = mission.id;
    } else {
      await _missionTimeRepository.updateMissionTime(missionId, time);
    }

    if (missionIdToSave == null) {
      throw Exception('missionIdToSave is null');
    }

    if (await _missionHistoryRepository.hasTodayMission(missionIdToSave)) {
      await _missionHistoryRepository.updateTodayMissionTime(
          missionIdToSave, time);
    } else {
      await _missionHistoryRepository.createTodayMission(missionIdToSave);
    }

    await MissionAlarmService.updateAlarm(missionIdToSave, time);
  }

  static Future<void> clearMissionTime({
    required int missionId,
  }) async {
    await _missionTimeRepository.removeMissionTime(missionId);
    await _missionHistoryRepository.removeTodayMission(missionId);
    await MissionAlarmService.cancelAlarm(missionId);
  }

  static Future<List<MissionTime?>> getMissionTimes() async {
    final times = await _missionTimeRepository.getMissionTimes();

    return times;
  }

  static Future<MissionTime?> getMissionTime(int missionId) async {
    final time = await _missionTimeRepository.getMissionTime(missionId);

    return time;
  }

  static Future<int> getGracePeriod() async {
    return await _missionGracePeriodRepository.getGracePeriod();
  }

  static Future<void> saveGracePeriod(int gracePeriod) async {
    await _missionGracePeriodRepository.setGracePeriod(gracePeriod);
  }

  static switchToLocalRepository() {
    _missionTimeRepository = MissionTimeRepositoryLocal();
    _missionHistoryRepository = MissionHistoryRepositoryLocal();
    _missionGracePeriodRepository = MissionGracePeriodRepositoryLocal();
  }
}
