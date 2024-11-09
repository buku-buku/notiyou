import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/login_page.dart';
import 'services/mission_service.dart';
import 'routes/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MissionService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: LoginPage.routeName,
        routes: routes,
      ),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
