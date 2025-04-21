import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notiyou/core/routes/guards/route_guard.dart';
import 'package:notiyou/models/registration_status.dart';
import 'package:notiyou/routes/guards/role_guard.dart';
import 'package:notiyou/screens/signup_page.dart';
import 'package:notiyou/services/auth/auth_service.dart';
import 'package:notiyou/services/user_metadata_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class MockRouteGuard extends Mock implements RouteGuard {}

class MockBuildContext extends Mock implements BuildContext {}

class MockGoRouterState extends Mock implements GoRouterState {}

class MockUser extends Mock implements supabase.User {}

void main() {
  late MockRouteGuard mockGuard;
  late RoleGuard roleGuard;
  late MockBuildContext context;
  late MockGoRouterState state;
  late MockUser mockUser;
  const redirectPath = '/redirect';

  setUpAll(() {
    registerFallbackValue(MockBuildContext());
    registerFallbackValue(MockGoRouterState());
  });

  setUp(() {
    mockGuard = MockRouteGuard();
    roleGuard = RoleGuard(mockGuard, [UserRole.challenger]);
    context = MockBuildContext();
    state = MockGoRouterState();
    mockUser = MockUser();

    when(() => mockUser.id).thenReturn('test-user-id');
  });

  group('RoleGuard', () {
    test('허용된 역할을 가진 사용자는 접근을 허용해야 한다', () async {
      // arrange
      when(() => mockGuard.canActivate(any(), any(), any()))
          .thenAnswer((_) async => null);

      AuthService.setUserForTesting(mockUser);
      UserMetadataService.setRoleForTesting(UserRole.challenger);

      // act
      final result = await roleGuard.canActivate(context, state, redirectPath);

      // assert
      expect(result, isNull);
      verify(() => mockGuard.canActivate(context, state, redirectPath))
          .called(1);

      AuthService.clearUserForTesting();
    });

    test('허용되지 않은 역할을 가진 사용자는 redirectPath로 리디렉션해야 한다', () async {
      // arrange
      when(() => mockGuard.canActivate(any(), any(), any()))
          .thenAnswer((_) async => null);

      AuthService.setUserForTesting(mockUser);
      UserMetadataService.setRoleForTesting(UserRole.supporter);

      // act
      final result = await roleGuard.canActivate(context, state, redirectPath);

      // assert
      expect(result, equals(redirectPath));
      verify(() => mockGuard.canActivate(context, state, redirectPath))
          .called(1);

      AuthService.clearUserForTesting();
    });

    test('redirectPath가 null이면 SignupPage.routeName으로 리디렉션해야 한다', () async {
      // arrange
      when(() => mockGuard.canActivate(any(), any(), null))
          .thenAnswer((_) async => null);

      AuthService.setUserForTesting(mockUser);
      UserMetadataService.setRoleForTesting(UserRole.supporter);

      // act
      final result = await roleGuard.canActivate(context, state, null);

      // assert
      expect(result, equals(SignupPage.routeName));
      verify(() => mockGuard.canActivate(context, state, null)).called(1);

      AuthService.clearUserForTesting();
    });

    test('부모 가드가 리디렉션을 반환하면 그 값을 그대로 반환해야 한다', () async {
      // arrange
      when(() => mockGuard.canActivate(any(), any(), any()))
          .thenAnswer((_) async => '/other-route');

      // act
      final result = await roleGuard.canActivate(context, state, redirectPath);

      // assert
      expect(result, equals('/other-route'));
      verify(() => mockGuard.canActivate(context, state, redirectPath))
          .called(1);
    });

    test('사용자가 없는 경우 redirectPath로 리디렉션해야 한다', () async {
      // arrange
      when(() => mockGuard.canActivate(any(), any(), any()))
          .thenAnswer((_) async => null);

      AuthService.setAlwaysReturnNullForTesting();

      // act
      final result = await roleGuard.canActivate(context, state, redirectPath);

      // assert
      expect(result, equals(redirectPath));
      verify(() => mockGuard.canActivate(context, state, redirectPath))
          .called(1);
    });
  });
}
