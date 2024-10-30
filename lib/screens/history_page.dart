import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'config_page.dart';
import 'login_page.dart';
import 'home_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  static const String routeName = '/history';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: const Center(
        child: Text('캘린더 UI - 미션 완수 현황'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // 히스토리 페이지를 현재 선택된 페이지로 설정
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '히스토리',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: '로그아웃',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(HomePage.routeName);
              break;
            case 1:
              // 이미 히스토리 페이지에 있으므로 아무 작업도 하지 않음
              break;
            case 2:
              context.go(ConfigPage.routeName);
              break;
            case 3:
              context.go(LoginPage.routeName);
              break;
          }
        },
      ),
    );
  }
}
