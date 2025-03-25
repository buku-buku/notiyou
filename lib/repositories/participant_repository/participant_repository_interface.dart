import 'package:notiyou/entities/current_participant.dart';

abstract interface class ParticipantRepository {
  /// 현재 사용자의 Participant 정보를 가져옵니다.
  Future<CurrentParticipant> getCurrentParticipant();

  /// 특정 사용자의 Participant 정보를 가져옵니다.
  Future<CurrentParticipant> getParticipantById(String userId);
}
