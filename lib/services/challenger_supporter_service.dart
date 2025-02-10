import 'package:notiyou/models/challenger_supporter_model.dart';
import 'package:notiyou/repositories/challenger_supporter/challenger_supporter_repository_remote.dart';
import 'package:notiyou/services/auth/auth_service.dart';

class ChallengerSupporterService {
  static Future<ChallengerSupporter> getChallengerSupporter() async {
    final user = await AuthService.getUser();
    if (user == null) {
      throw Exception('Unauthorized');
    }
    final challengerSupporterRepository = ChallengerSupporterRepositoryRemote();
    final challengerSupporter = await challengerSupporterRepository
        .getChallengerSupporterByChallengerId(user.id);
    return challengerSupporter;
  }

  static Future<ChallengerSupporter> dissmissSupporter(String id) async {
    final user = await AuthService.getUser();
    if (user == null) {
      throw Exception('Unauthorized');
    }
    final challengerSupporterRepository = ChallengerSupporterRepositoryRemote();
    final result =
        await challengerSupporterRepository.updateChallengerSupporter(
      id,
      challengerId: user.id,
      supporterId: null,
    );
    return result;
  }
}
