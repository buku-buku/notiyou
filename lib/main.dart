import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_talk.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:notiyou/services/dotenv_service.dart';
import 'package:notiyou/services/supabase_service.dart';
import 'package:notiyou/routes/router.dart';
import 'package:notiyou/services/mission_config_service.dart';
import 'package:notiyou/services/mission_alarm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DotEnvService.init();
  await initializeDateFormatting('ko_KR', null);

  KakaoSdk.init(
    nativeAppKey: DotEnvService.getValue('KAKAO_NATIVE_APP_KEY'),
  );
  await SupabaseService.init();
  await MissionConfigService.init();
  await MissionAlarmService.init();
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
