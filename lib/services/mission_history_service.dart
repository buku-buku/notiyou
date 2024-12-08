import 'package:notiyou/models/mission_history.dart';
import 'package:notiyou/fixtures/mission_history.dart';

class MissionHistoryService {
  static Future<List<MissionHistory>> getMissionHistoriesByUserId(
      String userId) async {
    return missionHistoriesFixture;
  }
}
