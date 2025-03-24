import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/core/routes/guards/route_guard.dart';
import 'package:notiyou/screens/login_page.dart';
import 'package:notiyou/services/auth/auth_service.dart';

class AuthGuard extends RouteGuardDecorator {
  AuthGuard(
    super.guard,
  );

  @override
  Future<String?> canActivate(
      BuildContext? context, GoRouterState state, String? redirectPath) async {
    final result = await super.canActivate(context, state, redirectPath);
    if (result != null) {
      return result;
    }

    final user = await AuthService.getUser();
    if (user == null) {
      return redirectPath ?? LoginPage.routeName;
    }

    return null;
  }
}
