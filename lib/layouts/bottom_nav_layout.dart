import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_page.dart';
import '../screens/config_page.dart';
import '../screens/history_page.dart';
import '../screens/login_page.dart';

// 아직 사용하지 않는 위젯
class BottomNavLayout extends StatelessWidget {
  final Widget child;

  const BottomNavLayout({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith(HomePage.routeName)) return 0;
    if (location.startsWith(ConfigPage.routeName)) return 1;
    if (location.startsWith(HistoryPage.routeName)) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '히스토리',
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
              context.go(ConfigPage.routeName);
              break;
            case 2:
              context.go(HistoryPage.routeName);
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
