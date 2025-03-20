import 'package:notiyou/entities/participant.dart';
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
  Future<Participant> getCurrentParticipant() async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('User not found');
    }

    return getParticipantById(userId);
  }

  @override
  Future<Participant> getParticipantById(String userId) async {
    final userMetadata = await supabaseClient
        .from(SupabaseTableNames.userMetadata)
        .select()
        .eq('id', userId)
        .single();

    final challengerSupporter = await supabaseClient
        .from(SupabaseTableNames.challengerSupporter)
        .select('''
          challenger_id,
          supporter_id,
          challenger:user_metadata!challenger_supporter_challenger_metadata_fkey(name),
          supporter:user_metadata!challenger_supporter_supporter_metadata_fkey(name)
        ''')
        .or('challenger_id.eq.$userId,supporter_id.eq.$userId')
        .maybeSingle();

    final hasPartnerRelationship = challengerSupporter != null;
    final isUserChallenger = hasPartnerRelationship &&
        userId == challengerSupporter['challenger_id'];
    final hasSupporterPartner =
        hasPartnerRelationship && challengerSupporter['supporter_id'] != null;
    final hasChallengerPartner =
        hasPartnerRelationship && challengerSupporter['challenger_id'] != null;

    final hasNoPartner = !hasPartnerRelationship ||
        (isUserChallenger && !hasSupporterPartner) ||
        (!isUserChallenger && !hasChallengerPartner);

    if (hasNoPartner) {
      return Participant(
        name: userMetadata['name'],
        type: isUserChallenger
            ? ParticipantType.challenger
            : ParticipantType.supporter,
        partner: null,
      );
    }

    final partner = isUserChallenger
        ? Partner(
            type: ParticipantType.supporter,
            name: challengerSupporter['supporter']['name'],
          )
        : Partner(
            type: ParticipantType.challenger,
            name: challengerSupporter['challenger']['name'],
          );

    return Participant(
      name: userMetadata['name'],
      type: isUserChallenger
          ? ParticipantType.challenger
          : ParticipantType.supporter,
      partner: partner,
    );
  }
}
