import 'package:flutter/material.dart';
import 'package:notiyou/repositories/mission_time_repository_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notiyou/utils/time_utils.dart';

/// 미션 시간 데이터를 관리하는 저장소입니다.
///
///
/// 설정된 미션 시간은 서버에 기록되며, 서버에서 미션을 생성할때 사용됩니다.
///
/// 다만 인터넷 연결이 불안정한 환경을 대비하여, 로컬에도 미션 시간을 저장합니다.
/// 해당 값을 통해 로컬상에서 미션이 생성될 수 있습니다.
///
/// ⚠️ 현재 사용되지 않는 저장소입니다. 필요가 있기 전까지는 MissionTimeRepositoryRemote를 사용해주세요.
class MissionTimeRepositoryLocal implements MissionTimeRepository {
  SharedPreferences? _prefs;
  // 싱글턴 인스턴스
  static final MissionTimeRepositoryLocal _instance =
      MissionTimeRepositoryLocal._internal();

  // 팩토리 생성자
  factory MissionTimeRepositoryLocal() {
    return _instance;
  }

  // private 생성자
  MissionTimeRepositoryLocal._internal();

  @override
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  String _getMissionKey(int missionNumber) => 'mission$missionNumber';

  // 미션 시간 조회
  @override
  Future<TimeOfDay?> getMissionTime(int missionNumber) async {
    await init();
    final key = _getMissionKey(missionNumber);
    final timeStr = _prefs!.getString(key);

    if (timeStr == null) return null;

    return TimeUtils.parseTime(timeStr);
  }

  // 미션 시간 설정
  @override
  Future<void> setMissionTime(int missionNumber, TimeOfDay time) async {
    await init();
    final key = _getMissionKey(missionNumber);
    await _prefs!.setString(key, TimeUtils.stringifyTime(time));
  }

  // 미션 시간 초기화
  @override
  Future<void> clearMissionTime(int missionNumber) async {
    await init();
    final key = _getMissionKey(missionNumber);
    await _prefs!.remove(key);
  }

  @override
  Future getMissionByUserId(String userId) async {}

  @override
  Future<void> setMissionSupporter(
      String challengerId, String supporterId) async {}
}
