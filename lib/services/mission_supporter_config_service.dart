import 'package:notiyou/repositories/mission_time_repository/mission_time_repository_interface.dart';
import 'package:notiyou/repositories/mission_time_repository/mission_time_repository_local.dart';
import 'package:notiyou/repositories/mission_time_repository/mission_time_repository_remote.dart';
import 'package:notiyou/services/mission_supporter_exception.dart';

class MissionSupporterConfigService {
  static bool _isLocalMode = false;
  static MissionTimeRepository _missionTimeRepository =
      MissionTimeRepositoryRemote();

  static Future<void> init() async {
    await _missionTimeRepository.init();
  }

  static Future<void> saveMissionSupporter(
      String challengerId, String supporterId) async {
    if (_isLocalMode) {
      throw MissionSupporterException('오프라인 모드에서는 조력자 등록 기능을 사용할 수 없습니다.');
    }
    final mission =
        await _missionTimeRepository.getMissionByUserId(challengerId);
    if (mission == null) {
      throw MissionSupporterException('유효한 미션이 아닙니다.');
    }
    if (mission.supporterId != null) {
      throw MissionSupporterException('추가 조력자를 등록할 수 없는 미션입니다.');
    }
    await _missionTimeRepository.setMissionSupporter(challengerId, supporterId);
  }

  static switchToLocalRepository() {
    _isLocalMode = true;
    _missionTimeRepository = MissionTimeRepositoryLocal();
  }
}
