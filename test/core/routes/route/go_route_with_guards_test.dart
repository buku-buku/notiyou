import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notiyou/core/routes/guards/route_guard.dart';
import 'package:notiyou/core/routes/route/go_route_with_guards.dart';

class MockWidget extends Mock implements Widget {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}

class MockRouteGuard extends Mock implements RouteGuard {}

void main() {
  group('GoRouteWithGuards', () {
    late List<RouteGuard> guards;
    late MockWidget mockWidget;

    setUp(() {
      guards = [MockRouteGuard(), MockRouteGuard()];
      mockWidget = MockWidget();
    });

    test('생성자가 올바르게 동작해야 함', () {
      const path = '/test';
      const name = 'test';

      final route = GoRouteWithGuards(
        path: path,
        name: name,
        guards: guards,
        builder: (context, state) => mockWidget,
      );

      expect(route.path, path);
      expect(route.name, name);
      expect(route.guards, guards);
      expect(route.guards.length, 2);
    });

    test('guards 목록이 비어 있어도 작동해야 함', () {
      final route = GoRouteWithGuards(
        path: '/no-guards',
        guards: const [],
        builder: (context, state) => mockWidget,
      );

      expect(route.guards, isEmpty);
    });
  });
}
