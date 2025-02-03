import 'package:flutter_test/flutter_test.dart';
import 'package:notiyou/services/challenger_code/challenger_code_exception.dart';
import 'package:notiyou/services/challenger_code/challenger_code_service.dart';
import 'package:notiyou/services/dotenv_service.dart';

void main() {
  late ChallengerCodeServiceImpl service;
  const testUserId = 'a0ce3149-4aac-4416-be09-1ca5424dd9d5';

  setUp(() async {
    await DotEnvService.init();
    service = ChallengerCodeServiceImpl.instance;
  });

  group('ChallengerCodeService', () {
    group('.generateCode()', () {
      test('유효한 userId로 암호화된 코드 생성', () async {
        final code = await service.generateCode(testUserId);

        expect(code, isNotEmpty);
        expect(code, isA<String>());
      });

      test('빈 userId로 코드 생성 시 예외 발생', () async {
        expect(
          () => service.generateCode(''),
          throwsA(
            isA<ChallengerCodeException>().having(
              (e) => e.type,
              'type',
              ChallengerCodeExceptionType.creationFailed,
            ),
          ),
        );
      });
    });

    group('.verifyCode()', () {
      test('유효한 코드 검증', () async {
        final code = await service.generateCode(testUserId);
        await expectLater(service.verifyCode(code), completes);
      });

      test('빈 코드 검증 시 예외 발생', () async {
        expect(
          () => service.verifyCode(''),
          throwsA(
            isA<ChallengerCodeException>().having(
              (e) => e.type,
              'type',
              ChallengerCodeExceptionType.empty,
            ),
          ),
        );
      });
    });

    group('extractUserId 메서드', () {
      test('생성된 코드에서 userId 추출', () async {
        final code = await service.generateCode(testUserId);
        final extractedUserId = await service.extractUserId(code);

        expect(extractedUserId, testUserId);
      });

      test('잘못된 코드로 userId 추출 시 예외 발생', () async {
        expect(
          () => service.extractUserId('INVALID_CODE'),
          throwsA(isA<ChallengerCodeException>()),
        );
      });

      test('빈 코드로 userId 추출 시 예외 발생', () async {
        expect(
          () => service.extractUserId(''),
          throwsA(
            isA<ChallengerCodeException>().having(
              (e) => e.type,
              'type',
              ChallengerCodeExceptionType.empty,
            ),
          ),
        );
      });
    });

    test('전체 플로우 테스트', () async {
      // 1. 코드 생성
      final code = await service.generateCode(testUserId);
      expect(code, isNotEmpty);

      // 2. 코드 검증
      await expectLater(service.verifyCode(code), completes);

      // 3. userId 추출
      final extractedUserId = await service.extractUserId(code);
      expect(extractedUserId, testUserId);
    });
  });
}
