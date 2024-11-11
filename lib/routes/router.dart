import 'package:go_router/go_router.dart';
import 'package:notiyou/routes/index.dart';
import '../screens/login_page.dart';

final router = GoRouter(
  initialLocation: LoginPage.routeName,
  routes: routes,
);
