import '../models/mission_history.dart';
import '../fixtures/mission_history.dart';

class MissionHistoryService {
  static Future<List<MissionHistory>> getMissionHistoriesByUserId(
      String userId) async {
    return missionHistoriesFixture;
  }
}
