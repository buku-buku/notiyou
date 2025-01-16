abstract interface class MissionGracePeriodRepository {
  Future<int> getGracePeriod();
  Future<void> setGracePeriod(int gracePeriod);
}
