import 'package:go_router/go_router.dart';
import 'package:notiyou/routes/index.dart';
import 'package:notiyou/screens/splash_page.dart';

final router = GoRouter(
  initialLocation: SplashPage.routeName,
  routes: routes,
);
