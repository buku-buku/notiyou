import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/screens/challenger_config_page.dart';
import 'package:notiyou/screens/supporter_signup_page.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  static const String routeName = '/signup';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '당신의 역할을 선택해주세요',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            _RoleSelectionButton(
              title: '도전자',
              subtitle: '목표를 달성하고 싶은 분',
              onTap: () => context.go(ChallengerConfigPage.onboardingRouteName),
            ),
            const SizedBox(height: 20),
            _RoleSelectionButton(
              title: '조력자',
              subtitle: '도전자를 응원하고 싶은 분',
              onTap: () => context.go(SupporterSignupPage.routeName),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleSelectionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleSelectionButton({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
