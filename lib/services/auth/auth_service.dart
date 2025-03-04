import 'package:kakao_flutter_sdk/kakao_flutter_sdk_talk.dart';
import 'package:notiyou/models/registration_status.dart';
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
class AuthService {
  static Future<supabase.User?> loginWithKakao() async {
    // * 기존 로그인 상태 초기화
    if (await isLoggedIn()) {
      await logout();
    }

    final OAuthToken? token = await KakaoAuthService.login();

    if (token == null) {
      throw Exception('카카오 로그인에 실패하였습니다.');
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

  static Future<void> setRole(UserRole role) async {
    return SupabaseAuthService.setRole(role);
  }

  static Future<supabase.User?> getUser() async {
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

  static bool isRegistrationCompleted(supabase.User user) {
    return SupabaseAuthService.isRegistrationCompleted(user);
  }

  static RegistrationStatus getRegistrationStatus(supabase.User user) {
    return SupabaseAuthService.getRegistrationStatus(user);
  }
}
