import 'package:shared_preferences/shared_preferences.dart';
import '../models/mission.dart';
import '../repositories/mission_repository.dart';

class MissionService {
  static const String _mission1TimeKey = 'mission1_time';
  static const String _mission2TimeKey = 'mission2_time';
  static SharedPreferences? _prefs;

  // SharedPreferences 초기화
  static Future<void> init() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
      print('SharedPreferences 초기화 완료');
      _checkAndResetDaily(); // 자정 지난 후 첫 실행시 초기화
    }
  }

  // 자정 지났는지 확인하고 초기화
  static Future<void> _checkAndResetDaily() async {
    final lastResetKey = 'last_reset_date';
    final today = DateTime.now();
    final lastResetStr = _prefs?.getString(lastResetKey);

    if (lastResetStr != null) {
      final lastReset = DateTime.parse(lastResetStr);
      if (today.day != lastReset.day ||
          today.month != lastReset.month ||
          today.year != lastReset.year) {
        // 날짜가 변경되었으면 초기화
        await resetDailyMissions();
      }
    }

    // 마지막 초기화 날짜 업데이트
    await _prefs?.setString(lastResetKey, today.toIso8601String());
  }

  // 미션 시간 저장
  static Future<void> saveMissionTime(int missionNumber, String? time) async {
    if (_prefs == null) await init();

    final key = missionNumber == 1 ? _mission1TimeKey : _mission2TimeKey;
    if (time != null) {
      await _prefs!.setString(key, time);
    } else {
      await _prefs!.remove(key);
    }
    print('미션$missionNumber 시간 저장: $time');
  }

  // 미션 시간 불러오기
  static String? getMissionTime(int missionNumber) {
    if (_prefs == null) return null;

    final key = missionNumber == 1 ? _mission1TimeKey : _mission2TimeKey;
    final time = _prefs!.getString(key);
    print('미션$missionNumber 시간 불러오기: $time');
    return time;
  }

  // 미션 완료 상태 토글 및 히스토리 저장
  static Future<bool> toggleMissionComplete(String missionId) async {
    if (_prefs == null) await init();

    final today = DateTime.now();

    // 현재 날짜의 미션 데이터 가져오기
    final missions = await MissionRepository.getMissions(today);

    // 해당 미션의 상태 변경
    final updatedMissions = missions.map((mission) {
      if (mission.id == missionId) {
        return Mission(
          id: mission.id,
          time: mission.time,
          isCompleted: !mission.isCompleted,
          completedAt: !mission.isCompleted ? DateTime.now() : null,
          date: today,
        );
      }
      return mission;
    }).toList();

    // 변경된 데이터 저장
    await MissionRepository.saveMissions(DateTime.now(), updatedMissions);

    // 변경된 미션의 새로운 상태 반환
    final targetMission = updatedMissions.firstWhere((m) => m.id == missionId);
    return targetMission.isCompleted;
  }

  // 오늘의 미션 데이터 가져오기
  static Future<List<Mission>> getTodaysMissions() async {
    if (_prefs == null) await init();

    final missions = await MissionRepository.getMissions(DateTime.now());

    if (missions.isEmpty) {
      // 해당 날짜의 첫 접속이면 미션 초기화
      final newMissions = [
        if (getMissionTime(1) != null)
          Mission(
            id: 'mission1',
            time: getMissionTime(1)!,
            isCompleted: false,
            date: DateTime.now(),
          ),
        if (getMissionTime(2) != null)
          Mission(
            id: 'mission2',
            time: getMissionTime(2)!,
            isCompleted: false,
            date: DateTime.now(),
          ),
      ];

      // 초기 미션 데이터 저장
      await MissionRepository.saveMissions(DateTime.now(), newMissions);
      return newMissions;
    }

    // 저장된 미션 데이터 반환
    return missions;
  }

  // 특정 날짜의 미션 히스토리 가져오기
  static Future<List<Mission>> getMissionHistory(DateTime date) async {
    if (_prefs == null) await init();

    return await MissionRepository.getMissions(date);
  }

  // 오늘의 미션 초기화 (매일 자정에 호출 예정)
  static Future<void> resetDailyMissions() async {
    if (_prefs == null) await init();

    await MissionRepository.removeData(DateTime.now());
    print('일일 미션 초기화 완료');
  }

  // 모든 미션 데이터 삭제 (설정 초기화용)
  static Future<void> clearAllMissionData() async {
    if (_prefs == null) await init();

    await MissionRepository.clearAllMissions();
    print('모든 미션 데이터 삭제 완료');
  }

  // 디버깅용: 모든 히스토리 출력
  static void debugMissionHistory() {
    if (_prefs == null) return;

    print('\n=== 미션 히스토리 ===');
    final allKeys =
        _prefs!.getKeys().where((key) => key.startsWith('mission_'));
    for (final key in allKeys) {
      final missions = _prefs!.getStringList(key) ?? [];
      print('$key: ${missions.length} missions');
      for (final mission in missions) {
        print('  $mission');
      }
    }
    print('==================\n');
  }

  // 저장소의 모든 데이터 출력 (버깅용)
  static void debugStorageContent() {
    if (_prefs == null) {
      print('SharedPreferences가 초기화되지 않음');
      return;
    }

    print('\n=== 저장소 전체 데이터 ===');
    final keys = _prefs!.getKeys();
    for (final key in keys) {
      print('$key: ${_prefs!.get(key)}');
    }
    print('=======================\n');
  }
}
