import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/models/registration_status.dart';
import 'package:notiyou/screens/home_page.dart';
import 'package:notiyou/screens/supporter_signup_page.dart';
import 'package:notiyou/services/auth/auth_service.dart';

import 'package:notiyou/screens/signup_page.dart';

class LoginPage extends StatelessWidget {
  static const routeName = '/login';
  final String? initialChallengerCode;

  const LoginPage({
    super.key,
    this.initialChallengerCode,
  });

  Future<void> _handleKakaoLogin(BuildContext context) async {
    try {
      final user = await AuthService.loginWithKakao();
      if (user == null) {
        throw Exception('User not found');
      }

      final registrationStatus = AuthService.getRegistrationStatus(user);
      if (!context.mounted) {
        return;
      }

      if (registrationStatus.registeredRole != UserRole.none) {
        context.go(HomePage.routeName);
        return;
      }

      if (registrationStatus.registeredRole == UserRole.none) {
        if (initialChallengerCode != null) {
          context.go(SupporterSignupPage.routeName,
              extra: initialChallengerCode);
        } else {
          context.go(SignupPage.routeName);
        }
      }
    } catch (error) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('카카오 로그인 실패하였습니다. 다시 시도해주세요.'),
            content: Text(error.toString()),
          ),
        );
      }
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
