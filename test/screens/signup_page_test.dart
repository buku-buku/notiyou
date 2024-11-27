import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/screens/signup_page.dart';
import 'package:notiyou/screens/config_page.dart';
import 'package:notiyou/routes/index.dart';
import 'package:notiyou/repositories/mission_time_repository_remote.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SignupPage 테스트', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await MissionTimeRepositoryRemote.init();
    });

    testWidgets('완료 버튼을 누르면 온보딩 모드로 설정 페이지로 이동한다', (tester) async {
      final router = GoRouter(
        initialLocation: SignupPage.routeName,
        routes: routes,
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      await tester.tap(find.text('완료'));
      await tester.pumpAndSettle();

      expect(
        router.routeInformationProvider.value.uri.toString(),
        ConfigPage.onboardingRouteName,
      );
    });
  });
}
