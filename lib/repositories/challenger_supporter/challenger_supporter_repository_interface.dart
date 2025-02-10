import 'package:notiyou/models/challenger_supporter_model.dart';

abstract interface class ChallengerSupporterRepository {
  Future<ChallengerSupporter> addChallengerSupporter(
      String challengerId, String? supporterId);
  Future<void> removeChallengerSupporter(String id);
  Future<ChallengerSupporter> updateChallengerSupporter(String id,
      {String? challengerId, String? supporterId});
  Future<ChallengerSupporter> getChallengerSupporterById(String id);
  Future<ChallengerSupporter> getChallengerSupporterByChallengerId(
      String challengerId);
  Future<ChallengerSupporter> getChallengerSupporterBySupporterId(
      String supporterId);
}
