import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'config_page.dart';
import 'history_page.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView(
        children: const [
          ListTile(
            title: Text('미션시간 1'),
            trailing: Checkbox(
              value: false,
              onChanged: null,
            ),
          ),
          ListTile(
            title: Text('미션시간 2'),
            trailing: Checkbox(
              value: false,
              onChanged: null,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
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
              // 이미 홈 페이지에 있으므로 아무 작업도 하지 않음
              break;
            case 1:
              context.go(HistoryPage.routeName);
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
