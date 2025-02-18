import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/services/auth/auth_service.dart';
import 'package:notiyou/screens/home_page.dart';
import 'package:notiyou/screens/login_page.dart';
import 'package:notiyou/screens/signup_page.dart';
import 'package:notiyou/screens/challenger_config_page.dart';
import 'package:notiyou/screens/history_page.dart';
import 'package:notiyou/screens/splash_page.dart';
import 'package:notiyou/screens/supporter_signup_page.dart';

final routes = <RouteBase>[
  GoRoute(
    path: SplashPage.routeName,
    builder: (context, state) => const SplashPage(),
  ),
  GoRoute(
    path: LoginPage.routeName,
    builder: (context, state) => LoginPage(
      initialChallengerCode: state.uri.queryParameters['challengerId'],
    ),
  ),
  GoRoute(
    path: SignupPage.routeName,
    builder: (context, state) => const SignupPage(),
  ),
  GoRoute(
    path: SupporterSignupPage.routeName,
    builder: (context, state) => SupporterSignupPage(
      initialChallengerCode: state.uri.queryParameters['challengerId'],
    ),
  ),
  GoRoute(
    path: ChallengerConfigPage.onboardingRouteName,
    builder: (context, state) => const ChallengerConfigPage(
      isFirstTime: true,
    ),
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
          onTap: (index) async {
            if (index == 3) {
              await AuthService.logout();
              if (context.mounted) {
                context.go(LoginPage.routeName);
              }
            } else {
              context.go(bottomNavigationRoutes[index].path);
            }
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
    path: ChallengerConfigPage.routeName,
    builder: (context, state) => const ChallengerConfigPage(),
  ),
];

int _calculateSelectedIndex(BuildContext context) {
  final String location =
      GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();
  return bottomNavigationRoutes
      .indexWhere((route) => location.startsWith(route.path));
}
