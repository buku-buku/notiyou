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
  alreadyUsed('이미 사용된 코드입니다'),
  creationFailed('코드 생성에 실패했습니다'),
  unknown('알 수 없는 오류');

  final String message;
  const ChallengerCodeExceptionType(this.message);
}
