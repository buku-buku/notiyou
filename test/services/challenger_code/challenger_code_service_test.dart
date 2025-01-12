import 'package:flutter_test/flutter_test.dart';
import 'package:notiyou/services/challenger_code/challenger_code_exception.dart';
import 'package:notiyou/services/challenger_code/challenger_code_service.dart';

void main() {
  late ChallengerCodeServiceImpl service;

  setUp(() {
    service = ChallengerCodeServiceImpl.instance;
  });

  group('ChallengerCodeService', () {
    group('.generateCode()', () {
      test('유효한 userId로 18자리 코드 생성', () async {
        final code = await service.generateCode('test-user-id');

        expect(code.length, 18);
        expect(
          code.split('').every(
                (char) => '23456789ABCDEFGHJKLMNPQRSTUVWXYZ'.contains(char),
              ),
          true,
        );
      });

      test('같은 userId로도 다른 시간에는 다른 코드 생성', () async {
        final code1 = await service.generateCode('test-user-id');
        await Future.delayed(const Duration(milliseconds: 100));
        final code2 = await service.generateCode('test-user-id');

        expect(code1, isNot(equals(code2)));
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
        final code = await service.generateCode('test-user-id');
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

      test('잘못된 길이의 코드 검증 시 예외 발생', () async {
        expect(
          () => service.verifyCode('ABC'),
          throwsA(
            isA<ChallengerCodeException>().having(
              (e) => e.type,
              'type',
              ChallengerCodeExceptionType.invalid,
            ),
          ),
        );
      });

      test('잘못된 문자가 포함된 코드 검증 시 예외 발생', () async {
        expect(
          () => service.verifyCode('ABC1IO'),
          throwsA(
            isA<ChallengerCodeException>().having(
              (e) => e.type,
              'type',
              ChallengerCodeExceptionType.invalid,
            ),
          ),
        );
      });
    });

    group('extractUserId 메서드', () {
      test('생성된 코드에서 userId 해시값 추출', () async {
        final code = await service.generateCode('test-user-id');
        final extractedHash = await service.extractUserId(code);

        expect(extractedHash, isNotEmpty);
        expect(extractedHash.length, greaterThanOrEqualTo(8));
      });

      test('잘못된 코드로 userId 추출 시 예외 발생', () async {
        expect(
          () => service.extractUserId('INVALID'),
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
      final code = await service.generateCode('test-user-id');
      expect(code.length, 18);

      // 2. 코드 검증
      await expectLater(service.verifyCode(code), completes);

      // 3. userId 해시값 추출
      final extractedHash = await service.extractUserId(code);
      expect(extractedHash, isNotEmpty);
    });
  });
}
