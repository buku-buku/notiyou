import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract class RouteGuard {
  /// 가드 활성화 여부를 확인하는 메서드
  /// 통과 가능하면 null을 반환하고, 통과 불가능하면 이동할 경로를 반환
  Future<String?> canActivate(
      BuildContext? context, GoRouterState state, String? redirectPath);
}

class BaseGuard implements RouteGuard {
  @override
  Future<String?> canActivate(
      BuildContext? context, GoRouterState state, String? redirectPath) async {
    return null;
  }
}

abstract class RouteGuardDecorator implements RouteGuard {
  final RouteGuard _guard;

  RouteGuardDecorator(this._guard);

  @override
  Future<String?> canActivate(
      BuildContext? context, GoRouterState state, String? redirectPath) {
    return _guard.canActivate(context, state, redirectPath);
  }
}

RouteGuard applyGuards({
  required List<RouteGuardDecorator Function(RouteGuard)> decorators,
}) {
  RouteGuard guard = BaseGuard();

  for (final decorator in decorators) {
    guard = decorator(guard);
  }

  return guard;
}
