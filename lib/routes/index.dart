import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/core/routes/guards/route_guard.dart';
import 'package:notiyou/core/routes/route/go_route_with_guards.dart';
import 'package:notiyou/models/registration_status.dart';
import 'package:notiyou/routes/guards/auth_guard.dart';
import 'package:notiyou/routes/guards/role_guard.dart';
import 'package:notiyou/screens/challenger_config_page.dart';
import 'package:notiyou/screens/history_page.dart';
import 'package:notiyou/screens/home_page.dart';
import 'package:notiyou/screens/login_page.dart';
import 'package:notiyou/screens/signup_page.dart';
import 'package:notiyou/screens/splash_page.dart';
import 'package:notiyou/screens/supporter_config_page.dart';
import 'package:notiyou/screens/supporter_signup_page.dart';
import 'package:notiyou/services/auth/auth_service.dart';
import 'package:notiyou/services/user_metadata_service.dart';

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
  GoRouteWithGuards(
    path: SignupPage.routeName,
    builder: (context, state) => const SignupPage(),
    guards: [
      applyGuards(decorators: [
        (guard) => AuthGuard(guard),
      ])
    ],
  ),
  GoRouteWithGuards(
    path: SupporterSignupPage.routeName,
    builder: (context, state) => SupporterSignupPage(
      initialChallengerCode: state.uri.queryParameters['challengerId'],
    ),
    guards: [
      applyGuards(decorators: [
        (guard) => AuthGuard(guard),
      ])
    ],
  ),
  GoRouteWithGuards(
    path: ChallengerConfigPage.onboardingRouteName,
    builder: (context, state) => const ChallengerConfigPage(
      isFirstTime: true,
    ),
    guards: [
      applyGuards(decorators: [
        (guard) => AuthGuard(guard),
      ])
    ],
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
            } else if (index == 2) {
              final user = await AuthService.getUserSafe();
              final userRole = await UserMetadataService.getRole(user.id);
              if (context.mounted) {
                if (userRole == UserRole.challenger) {
                  context.go(ChallengerConfigPage.routeName);
                } else {
                  context.go(SupporterConfigPage.routeName);
                }
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
  GoRouteWithGuards(
    path: HomePage.routeName,
    builder: (context, state) => const HomePage(),
    guards: [
      applyGuards(decorators: [
        (guard) => AuthGuard(guard),
        (guard) => RoleGuard(guard, [UserRole.challenger, UserRole.supporter]),
      ])
    ],
  ),
  GoRouteWithGuards(
    path: HistoryPage.routeName,
    builder: (context, state) => const HistoryPage(),
    guards: [
      applyGuards(decorators: [
        (guard) => AuthGuard(guard),
        (guard) => RoleGuard(guard, [UserRole.challenger, UserRole.supporter]),
      ])
    ],
  ),
  GoRouteWithGuards(
    path: ChallengerConfigPage.routeName,
    builder: (context, state) => const ChallengerConfigPage(),
    guards: [
      applyGuards(decorators: [
        (guard) => AuthGuard(guard),
        (guard) => RoleGuard(guard, [UserRole.challenger]),
      ])
    ],
  ),
  GoRouteWithGuards(
    path: SupporterConfigPage.routeName,
    builder: (context, state) => const SupporterConfigPage(),
    guards: [
      applyGuards(decorators: [
        (guard) => AuthGuard(guard),
        (guard) => RoleGuard(guard, [UserRole.supporter]),
      ])
    ],
  ),
];

int _calculateSelectedIndex(BuildContext context) {
  final String location =
      GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();

  if (location == ChallengerConfigPage.routeName ||
      location == SupporterConfigPage.routeName) {
    return 2;
  }

  return bottomNavigationRoutes
      .indexWhere((route) => location.startsWith(route.path));
}
