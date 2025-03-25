import 'package:notiyou/entities/current_participant.dart';
import 'package:notiyou/repositories/participant_repository/participant_repository_interface.dart';
import 'package:notiyou/repositories/participant_repository/participant_repository_remote.dart';

class ParticipantService {
  final ParticipantRepository _repository;

  const ParticipantService(this._repository);

  /// todo(@datalater): Service 레이어가 Repository 구현체에 의존하지 않도록 나중에 수정해야 합니다.
  static final ParticipantService _instance = ParticipantService(
    ParticipantRepositoryRemote(),
  );

  factory ParticipantService.getInstance() {
    return _instance;
  }

  Future<CurrentParticipant> getCurrentParticipant() async {
    return await _repository.getCurrentParticipant();
  }

  Future<CurrentParticipant> getParticipantById(String userId) async {
    return await _repository.getParticipantById(userId);
  }
}
