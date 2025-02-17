abstract class UserMetadataRepository {
  Future<void> setFCMToken(String token);
  Future<String?> getFCMToken();
}
