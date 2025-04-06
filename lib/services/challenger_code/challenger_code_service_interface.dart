abstract interface class ChallengerCodeService {
  Future<String> generateCode(String userId);
  Future<String> verifyCode(String code);
  Future<String> extractUserId(String code);
}
