import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_talk.dart' as kakao;

class KakaoAuthService {
  static final _kakaoUserApi = kakao.UserApi.instance;

  static Future<bool> isKakaoTalkInstalled() async {
    return await kakao.isKakaoTalkInstalled();
  }

  static Future<kakao.OAuthToken?> _loginWithKakaoTalk() async {
    try {
      return await _kakaoUserApi.loginWithKakaoTalk();
    } on PlatformException catch (error) {
      if (error.code == 'CANCELED') {
        return null;
      }
      return await _loginWithKakaoAccount();
    }
  }

  static Future<kakao.OAuthToken?> _loginWithKakaoAccount() async {
    try {
      return await _kakaoUserApi.loginWithKakaoAccount();
    } catch (error) {
      rethrow;
    }
  }

  static Future<kakao.OAuthToken?> login() async {
    return await isKakaoTalkInstalled()
        ? _loginWithKakaoTalk()
        : _loginWithKakaoAccount();
  }

  static Future<kakao.User?> getUser() async {
    return await _kakaoUserApi.me();
  }

  static void validateTokenForSupabaseLink(kakao.OAuthToken token) {
    final userIdToken = token.idToken;
    if (userIdToken == null) {
      throw Exception(
          '카카오 ID 토큰 발급에 실패하였습니다. 카카오의 OpenID Connect 활성화 여부 및 scope에 openid가 포함되었는지 확인하세요.');
    }
  }

  static Future<void> logout() async {
    if (await kakao.AuthApi.instance.hasToken()) {
      await _kakaoUserApi.logout();
    }
  }

  static Future<void> unregister() async {
    try {
      await _kakaoUserApi.unlink();
    } catch (error) {
      throw Exception(error);
    }
  }
}
