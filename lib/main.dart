import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_talk.dart';
import 'package:notiyou/routes/router.dart';
import 'package:notiyou/services/dotenv_service.dart';
import 'package:notiyou/services/firebase/firebase_service.dart';
import 'package:notiyou/services/invite_deep_link_service.dart';
import 'package:notiyou/services/local_notification_service.dart';
import 'package:notiyou/services/mission_alarm_service.dart';
import 'package:notiyou/services/mission_config_service.dart';
import 'package:notiyou/services/supabase_service.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await DotEnvService.init();
  await initializeDateFormatting('ko_KR', null);

  KakaoSdk.init(
    nativeAppKey: DotEnvService.getValue('KAKAO_NATIVE_APP_KEY'),
  );
  await SupabaseService.init();
  await FirebaseService.init();
  runApp(const MyApp());
  await InviteDeepLinkService.init();
  await LocalNotificationService.init();
  await MissionConfigService.init();
  await MissionAlarmService.init();
  FlutterNativeSplash.remove();
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
