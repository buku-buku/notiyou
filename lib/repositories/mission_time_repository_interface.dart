import 'package:flutter/material.dart';

abstract interface class MissionTimeRepository {
  Future<void> init();
  Future<TimeOfDay?> getMissionTime(int missionNumber);
  Future<void> setMissionTime(int missionNumber, TimeOfDay time);
  Future<void> clearMissionTime(int missionNumber);
}

abstract interface class MissionSupporterRepository
    implements MissionTimeRepository {
  Future getMissionByUserId(String userId);
  Future<void> setMissionSupporter(String challengerId, String supporterId);
}
