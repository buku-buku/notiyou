import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:notiyou/services/challenger_code/challenger_code_exception.dart';
import 'package:notiyou/services/challenger_code/challenger_code_service_interface.dart';
import 'dart:math';

class ChallengerCodeServiceImpl implements ChallengerCodeService {
  ChallengerCodeServiceImpl._();
  static final ChallengerCodeServiceImpl instance =
      ChallengerCodeServiceImpl._();

  static const _codeLength = 18;
  static const _charset = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const _radix = 34;

  @override
  Future<String> generateCode(String userId) async {
    try {
      if (userId.isEmpty) {
        throw const ChallengerCodeException(
          message: '사용자 ID를 입력해주세요',
          type: ChallengerCodeExceptionType.creationFailed,
        );
      }

      final userIdBytes = utf8.encode(userId);
      final hash = sha256.convert(userIdBytes).bytes;

      BigInt combinedNumber = BigInt.from(0);
      for (var i = 0; i < 16; i++) {
        combinedNumber = combinedNumber << 8;
        combinedNumber += BigInt.from(hash[i]);
      }

      // 현재 시간 정보 추가 (마이크로초 단위까지)
      final now = DateTime.now().microsecondsSinceEpoch;
      combinedNumber += BigInt.from(now);

      // 추가 엔트로피
      final random = Random.secure();
      for (var i = 0; i < 4; i++) {
        combinedNumber = combinedNumber << 8;
        combinedNumber += BigInt.from(random.nextInt(256));
      }

      // 코드 생성 (역순으로 생성)
      final List<String> codeChars = List.filled(_codeLength, '');
      final radixBig = BigInt.from(_radix);

      for (var i = _codeLength - 1; i >= 0; i--) {
        final index = (combinedNumber % radixBig).toInt();
        final safeIndex = index % _charset.length;
        codeChars[i] = _charset[safeIndex];
        combinedNumber = combinedNumber ~/ radixBig;
      }

      return codeChars.join();
    } catch (e) {
      throw const ChallengerCodeException(
        message: '도전자 코드 생성에 실패했습니다',
        type: ChallengerCodeExceptionType.creationFailed,
      );
    }
  }

  @override
  Future<void> verifyCode(String code) async {
    try {
      if (code.isEmpty) {
        throw const ChallengerCodeException(
          message: '도전자 코드를 입력해주세요',
          type: ChallengerCodeExceptionType.empty,
        );
      }

      if (code.length != _codeLength) {
        throw const ChallengerCodeException(
          message: '도전자 코드는 18자리여야 합니다',
          type: ChallengerCodeExceptionType.invalid,
        );
      }

      if (!code.split('').every((char) => _charset.contains(char))) {
        throw const ChallengerCodeException(
          message: '올바르지 않은 도전자 코드 형식입니다',
          type: ChallengerCodeExceptionType.invalid,
        );
      }
    } catch (e) {
      if (e is ChallengerCodeException) rethrow;
      throw const ChallengerCodeException(
        message: '도전자 코드 검증에 실패했습니다',
        type: ChallengerCodeExceptionType.unknown,
      );
    }
  }

  @override
  Future<String> extractUserId(String code) async {
    try {
      await verifyCode(code);

      // 코드를 숫자로 변환
      final number = _codeToNumber(code);

      // 숫자를 16진수 문자열로 변환 (userId 해시값으로 사용)
      final hashHex = number.toRadixString(16).padLeft(8, '0');

      // 이 해시값을 userId로 사용
      return hashHex;
    } catch (e) {
      if (e is ChallengerCodeException) rethrow;
      throw const ChallengerCodeException(
        message: '사용자 ID 추출에 실패했습니다',
        type: ChallengerCodeExceptionType.unknown,
      );
    }
  }

  BigInt _codeToNumber(String code) {
    var number = BigInt.from(0);
    for (var i = code.length - 1; i >= 0; i--) {
      number = number * BigInt.from(_radix) + BigInt.from(_charset.indexOf(code[i]));
    }
    return number;
  }
}
