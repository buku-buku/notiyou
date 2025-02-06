import 'package:flutter/material.dart';
import 'package:notiyou/models/mission_time_model.dart';

abstract interface class MissionTimeRepository {
  Future<void> init();
  Future<List<MissionTime?>> getMissionTimes();
  Future<MissionTime?> getMissionTime(int missionId);
  Future<MissionTime> setMissionTime(TimeOfDay time);
  Future<void> updateMissionTime(int missionId, TimeOfDay time);
  Future<void> removeMissionTime(int missionId);
  Future getMissionByUserId(String userId);
  Future<void> setMissionSupporter(String challengerId, String supporterId);
}
