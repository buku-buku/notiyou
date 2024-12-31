import 'package:flutter/material.dart';

class SupporterSignupPage extends StatelessWidget {
  const SupporterSignupPage({
    super.key,
    this.initialChallengerCode,
  });

  static const String routeName = '/signup/supporter';
  final String? initialChallengerCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('조력자 회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '도전자의 코드를 입력해주세요',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              '도전자의 응원과 격려를 위해 코드가 필요합니다',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: TextEditingController(text: initialChallengerCode),
              decoration: const InputDecoration(
                labelText: '도전자 코드',
                hintText: '도전자에게 받은 코드를 입력해주세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: 도전자 코드 유효성 검사
              },
              child: const Text('다음'),
            ),
          ],
        ),
      ),
    );
  }
}
