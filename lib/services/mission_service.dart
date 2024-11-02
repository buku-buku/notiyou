import 'package:shared_preferences/shared_preferences.dart';

class MissionService {
  static const String _mission1TimeKey = 'mission1_time';
  static const String _mission2TimeKey = 'mission2_time';
  static const String _mission1CompletedKey = 'mission1_completed';
  static const String _mission2CompletedKey = 'mission2_completed';
  static SharedPreferences? _prefs;

  // SharedPreferences 초기화
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
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

  // 미션 완료 상태 토글
  static Future<bool> toggleMissionComplete(int missionNumber) async {
    if (_prefs == null) await init();

    final key =
        missionNumber == 1 ? _mission1CompletedKey : _mission2CompletedKey;
    final currentState = _prefs!.getBool(key) ?? false;
    final newState = !currentState;
    await _prefs!.setBool(key, newState);

    print('미션$missionNumber 완료 상태 변경: $newState');
    return newState;
  }

  // 미션 완료 상태 확인
  static bool isMissionCompleted(int missionNumber) {
    if (_prefs == null) return false;

    final key =
        missionNumber == 1 ? _mission1CompletedKey : _mission2CompletedKey;
    return _prefs!.getBool(key) ?? false;
  }

  // 오늘의 미션 초기화 (매일 자정에 호출 예정)
  static Future<void> resetDailyMissions() async {
    if (_prefs == null) await init();

    await _prefs!.remove(_mission1CompletedKey);
    await _prefs!.remove(_mission2CompletedKey);
    print('일일 미션 초기화 완료');
  }

  // 모든 미션 데이터 삭제 (설정 초기화용)
  static Future<void> clearAllMissionData() async {
    if (_prefs == null) await init();

    await _prefs!.remove(_mission1TimeKey);
    await _prefs!.remove(_mission2TimeKey);
    await _prefs!.remove(_mission1CompletedKey);
    await _prefs!.remove(_mission2CompletedKey);
    print('모든 미션 데이터 삭제 완료');
  }

  // 디버깅용: 현재 저장된 모든 미션 데이터 출력
  static void debugMissionData() {
    if (_prefs == null) return;

    print('\n=== 미션 데이터 현황 ===');
    print('미션1 시간: ${getMissionTime(1)}');
    print('미션2 시간: ${getMissionTime(2)}');
    print('미션1 완료여부: ${isMissionCompleted(1)}');
    print('미션2 완료여부: ${isMissionCompleted(2)}');
    print('=====================\n');
  }
}
