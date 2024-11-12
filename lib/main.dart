import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

import 'package:notiyou/services/dotenv_service.dart';
import 'package:notiyou/services/supabase_service.dart';
import 'routes/router.dart';
import 'services/mission_service.dart';
import 'services/push_alarm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DotEnvService.init();

  KakaoSdk.init(
    nativeAppKey: 'fa103be733ea653613939bf1d46f4313',
  );
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
      routerConfig: router,
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
