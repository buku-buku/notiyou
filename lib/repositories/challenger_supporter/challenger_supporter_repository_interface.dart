import 'package:notiyou/models/challenger_supporter_model.dart';

abstract interface class ChallengerSupporterRepository {
  Future<ChallengerSupporter> addChallengerSupporter(
      String challengerId, String? supporterId);
  Future<void> removeChallengerSupporter(String id);
  Future<ChallengerSupporter> updateChallengerSupporter(
      {required String challengerId, String? supporterId});
  Future<ChallengerSupporter> getChallengerSupporterById(String id);
  Future<ChallengerSupporter> getChallengerSupporterByChallengerId(
      String challengerId);
  Future<ChallengerSupporter> getChallengerSupporterBySupporterId(
      String supporterId);
  Future<ChallengerSupporter> dismissChallengerSupporterBySupporterId(
      String supporterId);
  Future<ChallengerSupporter> getChallengerSupporterByUserId(String userId);
}
