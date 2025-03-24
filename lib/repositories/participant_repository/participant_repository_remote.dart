import 'package:notiyou/entities/current_participant.dart';
import 'package:notiyou/repositories/participant_repository/participant_repository_interface.dart';
import 'package:notiyou/repositories/supabase_table_names_constants.dart';
import 'package:notiyou/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ParticipantRepositoryRemote implements ParticipantRepository {
  static final ParticipantRepositoryRemote _instance =
      ParticipantRepositoryRemote._internal();

  ParticipantRepositoryRemote._internal();

  factory ParticipantRepositoryRemote() {
    return _instance;
  }

  static final supabaseClient = SupabaseService.client;

  @override
  Future<CurrentParticipant> getCurrentParticipant() async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('User not found');
    }

    return getParticipantById(userId);
  }

  @override
  Future<CurrentParticipant> getParticipantById(String userId) async {
    final currentUserMetadata = await supabaseClient
        .from(SupabaseTableNames.userMetadata)
        .select()
        .eq('id', userId)
        .single();

    final challengerSupporter = await supabaseClient
        .from(SupabaseTableNames.challengerSupporter)
        .select('challenger_id, supporter_id')
        .or('challenger_id.eq.$userId,supporter_id.eq.$userId')
        .maybeSingle();

    final hasChallengerSupporter = challengerSupporter != null;
    final isUserChallenger = hasChallengerSupporter &&
        userId == challengerSupporter['challenger_id'];

    String? partnerId;
    if (hasChallengerSupporter) {
      partnerId = isUserChallenger
          ? challengerSupporter['supporter_id']
          : challengerSupporter['challenger_id'];
    }

    Partner? partner;
    final hasPartner = partnerId != null;
    if (hasPartner) {
      final partnerMetadata = await supabaseClient
          .from(SupabaseTableNames.userMetadata)
          .select()
          .eq('id', partnerId)
          .single();

      partner = Partner(
        type: isUserChallenger
            ? ParticipantType.supporter
            : ParticipantType.challenger,
        name: partnerMetadata['name'],
      );
    }

    return CurrentParticipant(
      name: currentUserMetadata['name'],
      type: isUserChallenger
          ? ParticipantType.challenger
          : ParticipantType.supporter,
      partner: partner,
    );
  }
}
