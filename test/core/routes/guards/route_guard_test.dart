import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notiyou/core/routes/guards/route_guard.dart';

class MockRouteGuard extends Mock implements RouteGuard {}

class MockBuildContext extends Mock implements BuildContext {}

class MockGoRouterState extends Mock implements GoRouterState {}

void main() {
  group('BaseGuard Interface 테스트', () {
    test('BaseGuard는 항상 통과한다.', () async {
      // arrange
      final guard = BaseGuard();
      final context = MockBuildContext();
      final state = MockGoRouterState();
      const redirectPath = '/redirect';

      // act
      final result = await guard.canActivate(context, state, redirectPath);

      // assert
      expect(result, isNull);
    });
  });

  group('RouteGuardDecorator Interface 테스트', () {
    test('데코레이터 생성시 전달받은 가드가 호출되어야 한다.', () async {
      // arrange
      final mockGuard = MockRouteGuard();
      final decorator = RouteGuardDecoratorImpl(mockGuard);
      final context = MockBuildContext();
      final state = MockGoRouterState();
      const redirectPath = '/redirect';

      when(() => mockGuard.canActivate(context, state, redirectPath))
          .thenAnswer((_) async => redirectPath);

      // act
      final result = await decorator.canActivate(context, state, redirectPath);

      // assert
      expect(result, equals(redirectPath));
      verify(() => mockGuard.canActivate(context, state, redirectPath))
          .called(1);
    });
  });
}

class RouteGuardDecoratorImpl extends RouteGuardDecorator {
  RouteGuardDecoratorImpl(super.guard);

  @override
  Future<String?> canActivate(
      BuildContext? context, GoRouterState state, String? redirectPath) async {
    final result = await super.canActivate(context, state, redirectPath);
    if (result != null) {
      return result;
    }
    return null;
  }
}
