import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/screens/config_page.dart';
import 'package:notiyou/repositories/mission_time_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notiyou/routes/index.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await MissionTimeRepository.init();
  });

  group('ConfigPage 라우트 테스트', () {
    testWidgets(
        '설정 페이지를 온보딩 과정(ex. 회원가입)에서 최초로 진입한 경우, bottom navigation이 보이지 않는다',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: '${ConfigPage.routeName}?isOnboarding=true',
            routes: routes,
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsNothing);
    });

    testWidgets('설정 페이지를 온보딩으로 진입하지 않은 경우, bottom navigation이 보인다',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: GoRouter(
            initialLocation: ConfigPage.routeName,
            routes: routes,
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}
