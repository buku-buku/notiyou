import 'package:go_router/go_router.dart';
import '../screens/home_page.dart';
import '../screens/login_page.dart';
import '../screens/signup_page.dart';
import '../screens/config_page.dart';
import '../screens/history_page.dart';

final routes = <RouteBase>[
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
    builder: (context, state) {
      final isOnboarding = state.uri.queryParameters['isOnboarding'] == 'true';
      return ConfigPage(isOnboarding: isOnboarding);
    },
  ),
  GoRoute(
    path: HomePage.routeName,
    builder: (context, state) => const HomePage(),
  ),
  GoRoute(
    path: HistoryPage.routeName,
    builder: (context, state) => const HistoryPage(),
  ),
];
