import 'package:notiyou/models/mission.dart';
import 'package:notiyou/repositories/mission_history_repository_interface.dart';
import 'package:notiyou/repositories/mission_history_repository_local.dart';
import 'package:notiyou/repositories/mission_history_repository_remote.dart';

class MissionHistoryService {
  static MissionHistoryRepository _missionHistoryRepository =
      MissionHistoryRepositoryRemote();

  static Future<List<Mission>> getAllMissions() async {
    final missions = await _missionHistoryRepository.findAllMissions();

    final missionsInLocalTime =
        missions.map((mission) => mission.withLocalTimes()).toList();

    return missionsInLocalTime;
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

  // 오늘의 미션 데이터 가져오기
  static Future<List<Mission>> getTodaysMissions() async {
    final missions =
        await _missionHistoryRepository.findMissions(DateTime.now());

    // 저장된 미션 데이터 반환
    return missions;
  }

  static switchToLocalRepository() {
    _missionHistoryRepository = MissionHistoryRepositoryLocal();
  }
}
