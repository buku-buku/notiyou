import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/models/registration_status.dart';
import 'package:notiyou/screens/home_page.dart';
import 'package:notiyou/screens/supporter_signup_page.dart';
import 'package:notiyou/services/auth/auth_service.dart';

import 'package:notiyou/screens/signup_page.dart';
import 'package:notiyou/services/user_metadata_service.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

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

      final userRole = await UserMetadataService.getRole(user.id);
      if (!context.mounted) {
        return;
      }

      if (userRole != UserRole.none) {
        context.go(HomePage.routeName);
        return;
      }

      if (userRole == UserRole.none) {
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

  Future<void> _handleAppleLogin(BuildContext context) async {
    try {
      final user = await AuthService.loginWithApple();
      print('user: $user');
      if (user == null) {
        throw Exception('User not found');
      }

      final userRole = await UserMetadataService.getRole(user.id);
      if (!context.mounted) {
        return;
      }

      if (userRole != UserRole.none) {
        context.go(HomePage.routeName);
        return;
      }

      if (userRole == UserRole.none) {
        if (initialChallengerCode != null) {
          context.go(SupporterSignupPage.routeName,
              extra: initialChallengerCode);
        } else {
          context.go(SignupPage.routeName);
        }
      }
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        return;
      }
    } catch (error) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Apple 로그인에 실패하였습니다. 다시 시도해주세요.'),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _handleKakaoLogin(context),
              child: const Text('카카오톡으로 시작하기'),
            ),
            const SizedBox(height: 8), // 버튼과 텍스트 사이 간격
            ElevatedButton(
              onPressed: () => _handleAppleLogin(context),
              child: const Text('Apple로 시작하기'),
            ),
            const SizedBox(height: 8),
            const Text(
              '선택한 서비스에 설정된 이름으로 가입됩니다.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
