import 'package:notiyou/entities/participant.dart';

abstract interface class ParticipantRepository {
  /// 현재 사용자의 Participant 정보를 가져옵니다.
  Future<Participant> getCurrentParticipant();

  /// 특정 사용자의 Participant 정보를 가져옵니다.
  Future<Participant> getParticipantById(String userId);
}
