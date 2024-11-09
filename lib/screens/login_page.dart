import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_talk.dart';

import 'signup_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const String routeName = '/login';

  Future<OAuthToken?> _loginWithKakaoTalk() async {
    try {
      return await UserApi.instance.loginWithKakaoTalk();
    } on PlatformException catch (error) {
      if (error.code == 'CANCELED') {
        return null;
      }

      return await _loginWithKakaoAccount();
    }
  }

  Future<OAuthToken?> _loginWithKakaoAccount() async {
    try {
      return await UserApi.instance.loginWithKakaoAccount();
    } catch (error) {
      return null;
    }
  }

  Future<void> _handleKakaoLogin(BuildContext context) async {
    OAuthToken? token;

    if (await isKakaoTalkInstalled()) {
      token = await _loginWithKakaoTalk();
    } else {
      token = await _loginWithKakaoAccount();
    }

    if (token != null) {
      print(token.accessToken);
      context.go(SignupPage.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _handleKakaoLogin(context),
          child: const Text('카카오톡으로 시작하기'),
        ),
      ),
    );
  }
}
