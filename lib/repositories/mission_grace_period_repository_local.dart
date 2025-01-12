import 'package:notiyou/repositories/mission_grace_period_repository_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MissionGracePeriodRepositoryLocal
    implements MissionGracePeriodRepository {
  SharedPreferences? _prefs;

  static final MissionGracePeriodRepositoryLocal _instance =
      MissionGracePeriodRepositoryLocal._internal();

  factory MissionGracePeriodRepositoryLocal() {
    return _instance;
  }

  MissionGracePeriodRepositoryLocal._internal();

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<int> getGracePeriod() async {
    await init();
    const key = 'grace_period';
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError('SharedPreferences가 초기화되지 않았습니다');
    }
    final gracePeriod = prefs.getInt(key);
    return gracePeriod ?? 0;
  }

  @override
  Future<void> setGracePeriod(int gracePeriod) async {
    await init();
    const key = 'grace_period';
    await _prefs!.setInt(key, gracePeriod);
  }
}
