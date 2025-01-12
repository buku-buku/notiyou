import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notiyou/screens/signup_page.dart';
import 'package:notiyou/screens/challenger_config_page.dart';
import 'package:notiyou/screens/supporter_signup_page.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  group('SignupPage 테스트', () {
    late MockGoRouter mockRouter;

    setUp(() {
      mockRouter = MockGoRouter();
    });

    testWidgets('도전자 회원가입 버튼을 누르면 온보딩 모드로 설정 페이지로 이동한다', (tester) async {
      when(() => mockRouter.go(any())).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: InheritedGoRouter(
            goRouter: mockRouter,
            child: const SignupPage(),
          ),
        ),
      );

      await tester.tap(find.text('도전자'));
      await tester.pumpAndSettle();

      verify(() => mockRouter.go(ChallengerConfigPage.onboardingRouteName))
          .called(1);
    });

    testWidgets('조력자 회원가입 버튼을 누르면 조력자 회원가입 페이지로 이동한다', (tester) async {
      when(() => mockRouter.go(any())).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: InheritedGoRouter(
            goRouter: mockRouter,
            child: const SignupPage(),
          ),
        ),
      );

      await tester.tap(find.text('조력자'));
      await tester.pumpAndSettle();

      verify(() => mockRouter.go(SupporterSignupPage.routeName)).called(1);
    });
  });
}
