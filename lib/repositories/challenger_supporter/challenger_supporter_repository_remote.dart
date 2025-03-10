import 'package:notiyou/models/challenger_supporter_model.dart';
import 'package:notiyou/repositories/challenger_supporter/challenger_supporter_repository_interface.dart';
import 'package:notiyou/repositories/supabase_table_names_constants.dart';
import 'package:notiyou/services/challenger_supporter_exception.dart';
import 'package:notiyou/services/supabase_service.dart';

class ChallengerSupporterRepositoryRemote
    implements ChallengerSupporterRepository {
  ChallengerSupporterRepositoryRemote._internal();

  static final ChallengerSupporterRepositoryRemote _instance =
      ChallengerSupporterRepositoryRemote._internal();

  factory ChallengerSupporterRepositoryRemote() {
    return _instance;
  }

  static final supabaseClient = SupabaseService.client;

  @override
  Future<ChallengerSupporter> addChallengerSupporter(
      String challengerId, String? supporterId) async {
    final entity = await supabaseClient
        .from(SupabaseTableNames.challengerSupporter)
        .insert({
      'challenger_id': challengerId,
      'supporter_id': supporterId,
    }).select('''
      id,
      challenger_id,
      supporter_id
    ''').single();

    return ChallengerSupporter(
      id: entity['id'],
      challengerId: entity['challenger_id'],
      supporterId: entity['supporter_id'],
    );
  }

  @override
  Future<void> removeChallengerSupporter(String id) async {
    await supabaseClient
        .from(SupabaseTableNames.challengerSupporter)
        .delete()
        .eq('id', id);
  }

  @override
  Future<ChallengerSupporter> updateChallengerSupporter({
    required String challengerId,
    String? supporterId,
  }) async {
    final entity = await supabaseClient
        .from(SupabaseTableNames.challengerSupporter)
        .update({
          'challenger_id': challengerId,
          'supporter_id': supporterId,
        })
        .eq('challenger_id', challengerId)
        .select('''
      id,
      challenger_id,
      supporter_id
    ''')
        .single();

    return ChallengerSupporter(
      id: entity['id'],
      challengerId: entity['challenger_id'],
      supporterId: entity['supporter_id'],
    );
  }

  @override
  Future<ChallengerSupporter> getChallengerSupporterById(String id) async {
    final entity = await supabaseClient
        .from(SupabaseTableNames.challengerSupporter)
        .select('''
      id,
      challenger_id,
      supporter_id
    ''')
        .eq('id', id)
        .single();

    return ChallengerSupporter(
      id: entity['id'],
      challengerId: entity['challenger_id'],
      supporterId: entity['supporter_id'],
    );
  }

  @override
  Future<ChallengerSupporter> getChallengerSupporterByChallengerId(
      String challengerId) async {
    try {
      final entity = await supabaseClient
          .from(SupabaseTableNames.challengerSupporter)
          .select('''
        id,
        challenger_id,
        supporter_id
      ''')
          .eq('challenger_id', challengerId)
          .single();

      return ChallengerSupporter(
        id: entity['id'],
        challengerId: entity['challenger_id'],
        supporterId: entity['supporter_id'],
      );
    } catch (e) {
      throw ChallengerSupporterException('해당 코드의 도전자를 찾을 수 없습니다.');
    }
  }

  @override
  Future<ChallengerSupporter> getChallengerSupporterBySupporterId(
      String supporterId) async {
    final entity = await supabaseClient
        .from(SupabaseTableNames.challengerSupporter)
        .select('''
      id,
      challenger_id,
      supporter_id
    ''')
        .eq('supporter_id', supporterId)
        .single();

    return ChallengerSupporter(
      id: entity['id'],
      challengerId: entity['challenger_id'],
      supporterId: entity['supporter_id'],
    );
  }

  @override
  Future<ChallengerSupporter> dismissChallengerSupporterBySupporterId(
      String supporterId) async {
    final entity = await supabaseClient
        .from(SupabaseTableNames.challengerSupporter)
        .update({'supporter_id': null})
        .eq('supporter_id', supporterId)
        .select()
        .single();

    return ChallengerSupporter(
      id: entity['id'],
      challengerId: entity['challenger_id'],
    );
  }
}
