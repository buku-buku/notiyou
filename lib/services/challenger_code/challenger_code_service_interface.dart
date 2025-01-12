abstract interface class ChallengerCodeService {
  Future<String> generateCode(String userId);
  Future<void> verifyCode(String code);
  Future<String> extractUserId(String code);
}
