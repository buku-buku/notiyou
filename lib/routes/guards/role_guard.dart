import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/core/routes/guards/route_guard.dart';
import 'package:notiyou/models/registration_status.dart';
import 'package:notiyou/screens/login_page.dart';
import 'package:notiyou/services/auth/auth_service.dart';
import 'package:notiyou/services/user_metadata_service.dart';

class RoleGuard extends RouteGuardDecorator {
  final List<UserRole> allowedRoles;

  RoleGuard(super.guard, this.allowedRoles);

  @override
  Future<String?> canActivate(
      BuildContext? context, GoRouterState state, String? redirectPath) async {
    var result = await super.canActivate(context, state, redirectPath);
    if (result != null) {
      return result;
    }

    result = redirectPath ?? LoginPage.routeName;

    final user = await AuthService.getUser();
    if (user == null) {
      return result;
    }

    final userRole = await UserMetadataService.getRole(user.id);
    if (!allowedRoles.contains(userRole)) {
      return result;
    }

    return null;
  }
}
