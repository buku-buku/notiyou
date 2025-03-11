import 'package:go_router/go_router.dart';
import 'package:notiyou/routes/index.dart';
import 'package:notiyou/screens/home_page.dart';
import 'package:notiyou/screens/login_page.dart';
import 'package:notiyou/screens/splash_page.dart';
import 'package:notiyou/screens/supporter_signup_page.dart';
import 'package:notiyou/services/invite_deep_link_service.dart';
import 'package:flutter/foundation.dart';

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

    return null;
  },
  routes: routes,
);

String? _getRouteFromInviteDeepLink(InviteDeepLinkInfo deepLink) {
  return switch (deepLink.userStatus) {
    InvitedUserStatus.guest =>
      '${LoginPage.routeName}?challengerId=${deepLink.challengerCode}',
    InvitedUserStatus.unregisteredUser =>
      '${SupporterSignupPage.routeName}?challengerId=${deepLink.challengerCode}',
    InvitedUserStatus.registeredUser => HomePage.routeName,
  };
}
