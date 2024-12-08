import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_user.dart';
import 'package:notiyou/screens/splash_page.dart';

import 'package:notiyou/screens/config_page.dart';
import 'package:notiyou/screens/history_page.dart';
import 'package:notiyou/screens/home_page.dart';

class BottomNavLayout extends StatelessWidget {
  final Widget child;

  const BottomNavLayout({super.key, required this.child});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await UserApi.instance.logout();

      if (context.mounted) {
        context.go(SplashPage.routeName);
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그아웃 중 오류가 발생했습니다.'),
          ),
        );
      }
    }
  }

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
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('로그아웃'),
                  content: const Text('정말 로그아웃 하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _handleLogout(context);
                      },
                      child: const Text('로그아웃'),
                    ),
                  ],
                ),
              );
              break;
          }
        },
      ),
    );
  }
}
