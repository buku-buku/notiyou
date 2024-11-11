import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/services/dotenv_service.dart';
import 'package:notiyou/services/supabase_service.dart';
import 'screens/login_page.dart';
import 'services/mission_service.dart';
import 'services/push_alarm_service.dart';
import 'routes/index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DotEnvService.init();
  await SupabaseService.init();
  await MissionService.init();
  await PushAlarmService.init();
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
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}
