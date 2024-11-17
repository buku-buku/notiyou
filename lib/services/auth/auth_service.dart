import 'package:kakao_flutter_sdk/kakao_flutter_sdk_talk.dart';
import 'package:notiyou/services/auth/kakao_auth_service.dart';
import 'package:notiyou/services/auth/supabase_auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// TODO: 자체 User 객체 생성 및 관리 필요.
class AuthService {
  static Future<supabase.User?> loginWithKakao() async {
    // * 기존 로그인 상태 초기화
    if (await isLoggedIn()) {
      await logout();
    }

    OAuthToken? token = await KakaoAuthService.login();

    if (token == null) {
      throw Exception('카카오 로그인에 실패하였습니다.');
    }

    // TODO: 비즈앱 전환 후에는 추가항목이 아닌 최초 인증 시 선택항목으로 제공되어 불필요해질 예정.
    if (!await KakaoAuthService.isFriendsScopeAgreed()) {
      final tokenWithAdditionalScopes =
          await KakaoAuthService.logInWithAdditionalScopes();
      if (tokenWithAdditionalScopes == null) {
        throw Exception('카카오 추가 항목 동의에 실패하였습니다.');
      }
      token = tokenWithAdditionalScopes;
    }

    KakaoAuthService.validateTokenForSupabaseLink(token);
    return await SupabaseAuthService.signInWithKakaoToken(token.idToken!);
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

  static Future<supabase.User?> getUser() async {
    return await SupabaseAuthService.getUser();
  }

  static bool isRegistrationCompleted(supabase.User user) {
    return SupabaseAuthService.isRegistrationCompleted(user);
  }

// TODO: RegistrationStatus 객체 정의
  static Map<String, bool> getRegistrationStatus(supabase.User user) {
    return SupabaseAuthService.getRegistrationStatus(user);
  }
}
