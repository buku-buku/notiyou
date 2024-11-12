import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_page.dart';
import '../screens/login_page.dart';
import '../screens/signup_page.dart';
import '../screens/config_page.dart';
import '../screens/history_page.dart';
import '../screens/splash_page.dart';

final routes = <RouteBase>[
  GoRoute(
    path: SplashPage.routeName,
    builder: (context, state) => const SplashPage(),
  ),
  GoRoute(
    path: LoginPage.routeName,
    builder: (context, state) => const LoginPage(),
  ),
  GoRoute(
    path: SignupPage.routeName,
    builder: (context, state) => const SignupPage(),
  ),
  GoRoute(
    path: ConfigPage.onboardingRouteName,
    builder: (context, state) => const ConfigPage(),
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
            context.go(bottomNavigationRoutes[index].path);
          },
        ),
      );
    },
    routes: bottomNavigationRoutes,
  ),
];

final List<GoRoute> bottomNavigationRoutes = [
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
    builder: (context, state) => const ConfigPage(),
  ),
];

int _calculateSelectedIndex(BuildContext context) {
  final String location =
      GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
  return bottomNavigationRoutes
      .indexWhere((route) => location.startsWith(route.path));
}
