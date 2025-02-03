import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'package:notiyou/services/challenger_code/challenger_code_exception.dart';
import 'package:notiyou/services/challenger_code/challenger_code_service_interface.dart';
import 'package:notiyou/services/dotenv_service.dart';

class ChallengerCodeServiceImpl implements ChallengerCodeService {
  ChallengerCodeServiceImpl._();
  static final ChallengerCodeServiceImpl instance =
      ChallengerCodeServiceImpl._();

  // 테스트용 고정 키
  static final _key =
      encrypt.Key.fromBase64(DotEnvService.getValue('CHALLENGER_CODE_KEY'));
  // 테스트용 고정 IV
  static final _iv =
      encrypt.IV.fromBase64(DotEnvService.getValue('CHALLENGER_CODE_IV'));

  @override
  Future<String> generateCode(String userId) async {
    try {
      if (userId.isEmpty) {
        throw const ChallengerCodeException(
          message: '사용자 ID를 입력해주세요',
          type: ChallengerCodeExceptionType.creationFailed,
        );
      }

      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      final encrypted = encrypter.encrypt(userId, iv: _iv);

      // URL 안전한 base64로 인코딩 ('+' -> '-', '/' -> '_', '=' 제거)
      return base64Url.encode(encrypted.bytes);
    } catch (e) {
      throw const ChallengerCodeException(
        message: '도전자 코드 생성에 실패했습니다',
        type: ChallengerCodeExceptionType.creationFailed,
      );
    }
  }

  @override
  Future<String> extractUserId(String code) async {
    try {
      if (code.isEmpty) {
        throw const ChallengerCodeException(
          message: '도전자 코드를 입력해주세요',
          type: ChallengerCodeExceptionType.empty,
        );
      }

      // AES 복호화 설정
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));

      // URL 안전한 base64 디코딩
      final bytes = base64Url.decode(code);

      // 복호화
      final decrypted = encrypter.decrypt(
        encrypt.Encrypted(bytes),
        iv: _iv,
      );

      return decrypted;
    } catch (e) {
      if (e is ChallengerCodeException) rethrow;
      throw const ChallengerCodeException(
        message: '사용자 ID 추출에 실패했습니다',
        type: ChallengerCodeExceptionType.unknown,
      );
    }
  }

  @override
  Future<void> verifyCode(String code) async {
    if (code.isEmpty) {
      throw const ChallengerCodeException(
        message: '도전자 코드를 입력해주세요',
        type: ChallengerCodeExceptionType.empty,
      );
    }
  }
}
