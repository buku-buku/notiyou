import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'config_page.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  static const String routeName = '/signup';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: '초대코드 입력',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go(ConfigPage.routeName);
              },
              child: const Text('완료'),
            ),
          ],
        ),
      ),
    );
  }
}
