import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

import 'screens/config_page.dart';
import 'screens/history_page.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'screens/profile_page.dart';
import 'screens/search_page.dart';
import 'screens/signup_page.dart';
import 'screens/splash_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  KakaoSdk.init(
    nativeAppKey: 'fa103be733ea653613939bf1d46f4313',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}

final _router = GoRouter(
  initialLocation: SplashPage.routeName,
  routes: [
    GoRoute(
      path: SplashPage.routeName,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: HomePage.routeName,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: SearchPage.routeName,
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: ProfilePage.routeName,
      builder: (context, state) => const ProfilePage(),
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
      path: ConfigPage.routeName,
      builder: (context, state) => const ConfigPage(),
    ),
    GoRoute(
      path: HistoryPage.routeName,
      builder: (context, state) => const HistoryPage(),
    ),
  ],
);
