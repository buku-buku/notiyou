import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/core/routes/route/go_route_with_guards.dart';
import 'package:notiyou/routes/index.dart';
import 'package:notiyou/screens/home_page.dart';
import 'package:notiyou/screens/login_page.dart';
import 'package:notiyou/screens/splash_page.dart';
import 'package:notiyou/screens/supporter_signup_page.dart';
import 'package:notiyou/services/invite_deep_link_service.dart';

final routerRefreshNotifier = ValueNotifier<bool>(false);

final router = GoRouter(
  initialLocation: SplashPage.routeName,
  refreshListenable: routerRefreshNotifier,
  redirect: (context, state) async {
    final inviteDeepLink = InviteDeepLinkService.pendingDeepLink;

    if (inviteDeepLink != null) {
      final routeName = _getRouteFromInviteDeepLink(inviteDeepLink);
      InviteDeepLinkService.clearPendingDeepLink();
      return routeName;
    }

    final guardRedirectPath =
        await _checkGuardRedirects(state.topRoute, context, state);
    if (guardRedirectPath != null) {
      return guardRedirectPath;
    }

    return null;
  },
  routes: routes,
);

Future<String?> _checkGuardRedirects(
    GoRoute? route, BuildContext context, GoRouterState state) async {
  if (route is GoRouteWithGuards) {
    final guards = route.guards;
    for (final guard in guards) {
      final canActivate = await guard.canActivate(context, state, null);
      if (canActivate != null) {
        return canActivate;
      }
    }
  }

  return null;
}

String? _getRouteFromInviteDeepLink(InviteDeepLinkInfo deepLink) {
  return switch (deepLink.userStatus) {
    InvitedUserStatus.guest =>
      '${LoginPage.routeName}?challengerId=${deepLink.challengerCode}',
    InvitedUserStatus.unregisteredUser =>
      '${SupporterSignupPage.routeName}?challengerId=${deepLink.challengerCode}',
    InvitedUserStatus.registeredUser => HomePage.routeName,
  };
}
