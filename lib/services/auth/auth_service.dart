// ignore_for_file: invalid_visibility_annotation

import 'package:kakao_flutter_sdk/kakao_flutter_sdk_talk.dart';
import 'package:meta/meta.dart';
import 'package:notiyou/repositories/user_metadata_repository/user_metadata_repository_remote.dart';
import 'package:notiyou/services/auth/kakao_auth_service.dart';
import 'package:notiyou/services/auth/supabase_auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

// TODO: 자체 User 객체 생성 및 관리 필요.
// TODO: 테스트 용이성을 위해 static class 제거 필요. 이를 위해선 어플리케이션 레이어에서 DI Container 사용 필요.
class AuthService {
  static final userMetadataRepository = UserMetadataRepositoryRemote();

  static Future<supabase.User?> loginWithKakao() async {
    // * 기존 로그인 상태 초기화
    if (await isLoggedIn()) {
      await logout();
    }

    final OAuthToken? token = await KakaoAuthService.login();

    if (token == null) {
      throw Exception('token == null, 카카오 로그인에 실패하였습니다.');
    }

    final kakaoUser = await KakaoAuthService.getUser();
    if (kakaoUser == null) {
      throw Exception('kakaoUser == null, 카카오 유저 정보를 가져오는데 실패하였습니다.');
    }

    final name = kakaoUser.kakaoAccount?.profile?.nickname;
    if (name == null) {
      throw Exception('name == null, 카카오 유저 정보에서 nickname을 가져오는데 실패하였습니다.');
    }

    KakaoAuthService.validateTokenForSupabaseLink(token);
    final user = await SupabaseAuthService.signInWithKakaoToken(token.idToken!);

    await userMetadataRepository.setName(name);

    return user;
  }

  static Future<void> logout() async {
    await KakaoAuthService.logout();
    await SupabaseAuthService.signOut();
  }

  static Future<bool> isLoggedIn() async {
    try {
      final user = await getUser();
      return user != null;
    } catch (e) {
      return false;
    }
  }

  // TODO: static class 제거 이후 메서드 제거
  @visibleForTesting
  static dynamic _testUser;
  // TODO: static class 제거 이후 메서드 제거
  @visibleForTesting
  static bool _alwaysReturnNull = false;

  // TODO: static class 제거 이후 메서드 제거
  @visibleForTesting
  static void setUserForTesting(dynamic user) {
    _testUser = user;
  }

  // TODO: static class 제거 이후 메서드 제거
  @visibleForTesting
  static void setAlwaysReturnNullForTesting() {
    _alwaysReturnNull = true;
  }

// TODO: static class 제거 이후 메서드 제거
  @visibleForTesting
  static void clearUserForTesting() {
    _testUser = null;
  }

  static Future<dynamic> getUser() async {
    // for testing
    // TODO: static class 제거 이후 제거
    if (_testUser != null) {
      return _testUser;
    }
    // for testing
    // TODO: static class 제거 이후 제거
    if (_alwaysReturnNull) {
      return null;
    }

    // 실제 구현 코드
    return await SupabaseAuthService.getUser();
  }

  static Future<supabase.User> getUserSafe() async {
    final user = await getUser();
    if (user == null) {
      throw AuthException('사용자 인증이 필요합니다.');
    }
    return user;
  }

  static Future<String> getUserId() async {
    final user = await getUser();
    if (user == null) {
      throw Exception('Unauthorized');
    }
    return user.id;
  }
}
