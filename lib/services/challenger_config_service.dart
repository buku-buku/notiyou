import 'package:notiyou/models/challenger_supporter_model.dart';
import 'package:notiyou/models/registration_status.dart';
import 'package:notiyou/repositories/challenger_supporter/challenger_supporter_repository_remote.dart';
import 'package:notiyou/services/auth/auth_service.dart';
import 'package:notiyou/exceptions/challenger_supporter_exception.dart';
import 'package:notiyou/services/user_metadata_service.dart';

class ChallengerConfigService {
  static final _repository = ChallengerSupporterRepositoryRemote();

  static Future<String> _getAuthorizedUserId() async {
    final user = await AuthService.getUserSafe();
    return user.id;
  }

  static Future<ChallengerSupporter> getChallenger() async {
    final userId = await _getAuthorizedUserId();
    final challenger =
        await _repository.getChallengerSupporterBySupporterId(userId);
    return challenger;
  }

  static Future<ChallengerSupporter> getSupporter() async {
    final userId = await _getAuthorizedUserId();
    final supporter =
        await _repository.getChallengerSupporterByChallengerId(userId);
    return supporter;
  }

  static Future<ChallengerSupporter> getSupporterByChallengerId(
      String challengerId) async {
    final challengerSupporter =
        await _repository.getChallengerSupporterByChallengerId(challengerId);
    return challengerSupporter;
  }

  static Future<ChallengerSupporter> registerSupporter(
      String targetChallengerId) async {
    final userId = await _getAuthorizedUserId();

    final challengerSupporter =
        await ChallengerConfigService.getSupporterByChallengerId(
            targetChallengerId);
    if (challengerSupporter.supporterId != null) {
      throw ChallengerSupporterException('이미 등록된 서포터가 있습니다.');
    }

    final updatedChallengerSupporter =
        await _repository.updateChallengerSupporter(
      challengerId: targetChallengerId,
      supporterId: userId,
    );
    return updatedChallengerSupporter;
  }

  static Future<ChallengerSupporter> dismissSupporter() async {
    final userId = await _getAuthorizedUserId();
    final challengerSupporterInfo =
        await _repository.getChallengerSupporterByChallengerId(userId);
    final supporterId = challengerSupporterInfo.supporterId;
    if (supporterId == null) {
      throw ChallengerSupporterException('서포터 정보가 없습니다.');
    }

    try {
      final result = await _repository.updateChallengerSupporter(
        challengerId: userId,
        supporterId: null,
      );
      await UserMetadataService.setRole(supporterId, UserRole.none);
      return result;
    } catch (e) {
      await _repository.updateChallengerSupporter(
        challengerId: userId,
        supporterId: supporterId,
      );
      await UserMetadataService.setRole(supporterId, UserRole.supporter);
      throw ChallengerSupporterException('서포터 해제 중 오류가 발생했습니다: $e');
    }
  }

  static Future<void> quitSupporter() async {
    try {
      final userId = await AuthService.getUserId();
      await UserMetadataService.setRole(userId, UserRole.none);
      try {
        await _repository.dismissChallengerSupporterBySupporterId(userId);
      } catch (e) {
        await UserMetadataService.setRole(userId, UserRole.supporter);
        throw ChallengerSupporterException('서포터 해제 중 오류가 발생했습니다: $e');
      }
    } catch (e) {
      throw ChallengerSupporterException('사용자 역할 변경 중 오류가 발생했습니다: $e');
    }
  }
}
