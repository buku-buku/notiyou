import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notiyou/core/routes/guards/route_guard.dart';
import 'package:notiyou/routes/guards/auth_guard.dart';
import 'package:notiyou/screens/login_page.dart';
import 'package:notiyou/services/auth/auth_service.dart';

class MockRouteGuard extends Mock implements RouteGuard {}

class MockBuildContext extends Mock implements BuildContext {}

class MockGoRouterState extends Mock implements GoRouterState {}

class MockUser extends Mock {}

void main() {
  late MockRouteGuard mockGuard;
  late AuthGuard authGuard;
  late MockBuildContext context;
  late MockGoRouterState state;
  const redirectPath = '/redirect';

  setUpAll(() {
    registerFallbackValue(MockBuildContext());
    registerFallbackValue(MockGoRouterState());
  });

  setUp(() {
    mockGuard = MockRouteGuard();
    authGuard = AuthGuard(mockGuard);
    context = MockBuildContext();
    state = MockGoRouterState();
  });

  group('AuthGuard', () {
    test('인증된 사용자가 있으면 접근을 허용해야 한다', () async {
      // arrange
      when(() => mockGuard.canActivate(any(), any(), any()))
          .thenAnswer((_) async => null);

      AuthService.setUserForTesting(MockUser());

      // act
      final result = await authGuard.canActivate(context, state, redirectPath);

      // assert
      expect(result, isNull);
      verify(() => mockGuard.canActivate(context, state, redirectPath))
          .called(1);

      AuthService.clearUserForTesting();
    });

    test('인증된 사용자가 없으면 redirectPath로 리디렉션해야 한다', () async {
      // arrange
      when(() => mockGuard.canActivate(any(), any(), any()))
          .thenAnswer((_) async => null);

      AuthService.setAlwaysReturnNullForTesting();

      // act
      final result = await authGuard.canActivate(context, state, redirectPath);

      // assert
      expect(result, equals(redirectPath));
      verify(() => mockGuard.canActivate(context, state, redirectPath))
          .called(1);
    });

    test('redirectPath가 null이면 LoginPage.routeName으로 리디렉션해야 한다', () async {
      // arrange
      when(() => mockGuard.canActivate(any(), any(), null))
          .thenAnswer((_) async => null);

      AuthService.setAlwaysReturnNullForTesting();

      // act
      final result = await authGuard.canActivate(context, state, null);

      // assert
      expect(result, equals(LoginPage.routeName));
      verify(() => mockGuard.canActivate(context, state, null)).called(1);
    });

    test('부모 가드가 리디렉션을 반환하면 그 값을 그대로 반환해야 한다', () async {
      // arrange
      when(() => mockGuard.canActivate(any(), any(), any()))
          .thenAnswer((_) async => '/other-route');

      // act
      final result = await authGuard.canActivate(context, state, redirectPath);

      // assert
      expect(result, equals('/other-route'));
      verify(() => mockGuard.canActivate(context, state, redirectPath))
          .called(1);
    });
  });
}
