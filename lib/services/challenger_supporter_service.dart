import 'package:notiyou/models/challenger_supporter_model.dart';
import 'package:notiyou/repositories/challenger_supporter/challenger_supporter_repository_remote.dart';
import 'package:notiyou/services/auth/auth_service.dart';

class ChallengerSupporterService {
  static final _repository = ChallengerSupporterRepositoryRemote();

  static Future<String> _getAuthorizedUserId() async {
    final user = await AuthService.getUser();
    if (user == null) {
      throw Exception('Unauthorized');
    }
    return user.id;
  }

  static Future<ChallengerSupporter> getSupporter() async {
    final userId = await _getAuthorizedUserId();
    final challengerSupporter =
        await _repository.getChallengerSupporterByChallengerId(userId);
    return challengerSupporter;
  }

  static Future<ChallengerSupporter> registerSupporter(
      String targetChallengerId) async {
    final userId = await _getAuthorizedUserId();
    final challengerSupporter = await _repository.updateChallengerSupporter(
      challengerId: targetChallengerId,
      supporterId: userId,
    );
    return challengerSupporter;
  }

  static Future<ChallengerSupporter> dismissSupporter() async {
    final userId = await _getAuthorizedUserId();
    final result = await _repository.updateChallengerSupporter(
      challengerId: userId,
      supporterId: null,
    );
    return result;
  }
}
