import 'package:notiyou/entities/participant.dart';
import 'package:notiyou/repositories/participant_repository/participant_repository_interface.dart';

class ParticipantService {
  final ParticipantRepository _repository;

  const ParticipantService(this._repository);

  Future<Participant> getCurrentParticipant() async {
    return await _repository.getCurrentParticipant();
  }

  Future<Participant> getParticipantById(String userId) async {
    return await _repository.getParticipantById(userId);
  }
}
