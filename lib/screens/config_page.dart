import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'home_page.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  static const String routeName = '/config';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Config')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: '미션시간 입력',
              ),
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: '미션시간2 입력',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 카카오톡 친구 목록 확인하기 기능 연결 예정
              },
              child: const Text('조력자 선택'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.go(HomePage.routeName);
              },
              child: const Text('설정 완료'),
            ),
          ],
        ),
      ),
    );
  }
}
