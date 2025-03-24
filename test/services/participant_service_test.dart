import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notiyou/entities/current_participant.dart';
import 'package:notiyou/repositories/participant_repository/participant_repository_interface.dart';
import 'package:notiyou/services/participant_service.dart';

class MockParticipantRepository extends Mock implements ParticipantRepository {}

void main() {
  late ParticipantRepository mockRepository;
  late ParticipantService service;

  setUp(() {
    mockRepository = MockParticipantRepository();
    service = ParticipantService(mockRepository);
  });

  group('ParticipantService', () {
    test('getCurrentParticipant returns Participant from repository', () async {
      const expectedParticipant = CurrentParticipant(
        name: 'Test User',
        type: ParticipantType.challenger,
        partner: Partner(
          name: 'Test Partner',
          type: ParticipantType.supporter,
        ),
      );

      when(() => mockRepository.getCurrentParticipant())
          .thenAnswer((_) async => expectedParticipant);

      final result = await service.getCurrentParticipant();

      expect(result.name, equals(expectedParticipant.name));
      expect(result.partner?.name, equals(expectedParticipant.partner?.name));
      expect(result.partner?.type, equals(expectedParticipant.partner?.type));
      verify(() => mockRepository.getCurrentParticipant()).called(1);
    });
  });
}
