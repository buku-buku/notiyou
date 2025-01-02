// 도전자 코드 검증 관련 에러 클래스
// TODO: 다른 파일에서 관리
class ChallengerCodeException implements Exception {
  final String message;
  final ChallengerCodeExceptionType type;

  const ChallengerCodeException({
    required this.message,
    required this.type,
  });
}

// 에러 타입 열거형
enum ChallengerCodeExceptionType {
  empty('코드를 입력해주세요'),
  invalid('유효하지 않은 코드입니다'),
  notFound('존재하지 않는 도전자 코드입니다'),
  expired('만료된 코드입니다'),
  alreadyUsed('이미 사용된 코드입니다');

  final String message;
  const ChallengerCodeExceptionType(this.message);
}
