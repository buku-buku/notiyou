import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'signup_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const String routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.go(SignupPage.routeName);
          },
          child: const Text('카카오톡으로 시작하기'),
        ),
      ),
    );
  }
}
