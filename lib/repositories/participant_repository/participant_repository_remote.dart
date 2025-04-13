import 'package:notiyou/entities/current_participant.dart';
import 'package:notiyou/repositories/challenger_supporter/challenger_supporter_repository_interface.dart';
import 'package:notiyou/repositories/challenger_supporter/challenger_supporter_repository_remote.dart';
import 'package:notiyou/repositories/participant_repository/participant_repository_interface.dart';
import 'package:notiyou/repositories/user_metadata_repository/user_metadata_repository_interface.dart';
import 'package:notiyou/repositories/user_metadata_repository/user_metadata_repository_remote.dart';
import 'package:notiyou/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ParticipantRepositoryRemote implements ParticipantRepository {
  static final ParticipantRepositoryRemote _instance =
      ParticipantRepositoryRemote._internal();

  final UserMetadataRepository _userMetadataRepository =
      UserMetadataRepositoryRemote();

  final ChallengerSupporterRepository _challengerSupporterRepository =
      ChallengerSupporterRepositoryRemote();

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
    final currentUserMetadata =
        await _userMetadataRepository.getUserMetadataByUserId(userId);

    final challengerSupporter = await _challengerSupporterRepository
        .getChallengerSupporterByUserId(userId);

    final isUserChallenger = userId == challengerSupporter.challengerId;

    final partnerId = isUserChallenger
        ? challengerSupporter.supporterId
        : challengerSupporter.challengerId;

    Partner? partner;

    final hasPartner = partnerId != null;
    if (hasPartner) {
      final partnerMetadata =
          await _userMetadataRepository.getUserMetadataByUserId(partnerId);

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
