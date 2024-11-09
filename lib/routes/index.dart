import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_page.dart';
import '../screens/login_page.dart';
import '../screens/signup_page.dart';
import '../screens/config_page.dart';
import '../screens/history_page.dart';

int _calculateSelectedIndex(BuildContext context) {
  final String location =
      GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
  if (location.startsWith(HomePage.routeName)) return 0;
  if (location.startsWith(HistoryPage.routeName)) return 1;
  if (location.startsWith(ConfigPage.routeName)) return 2;
  return 0;
}

final routes = <RouteBase>[
  GoRoute(
    path: LoginPage.routeName,
    builder: (context, state) => const LoginPage(),
  ),
  GoRoute(
    path: SignupPage.routeName,
    builder: (context, state) => const SignupPage(),
  ),
  ShellRoute(
    builder: (context, state, child) {
      return Scaffold(
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _calculateSelectedIndex(context),
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: '히스토리'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
            BottomNavigationBarItem(icon: Icon(Icons.logout), label: '로그아웃'),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                context.go(HomePage.routeName);
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
    },
    routes: [
      GoRoute(
        path: HomePage.routeName,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: HistoryPage.routeName,
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: ConfigPage.routeName,
        builder: (context, state) {
          final isOnboarding =
              state.uri.queryParameters['isOnboarding'] == 'true';
          return ConfigPage(isOnboarding: isOnboarding);
        },
      ),
    ],
  ),
];
