import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/routes/index.dart';
import 'package:notiyou/screens/home_page.dart';
import 'package:notiyou/screens/login_page.dart';
import 'package:notiyou/screens/splash_page.dart';
import 'package:notiyou/screens/supporter_signup_page.dart';
import 'package:notiyou/services/invite_deep_link_service.dart';

final router = GoRouter(
  initialLocation: SplashPage.routeName,
  redirect: (context, state) async {
    FlutterNativeSplash.remove();

    final inviteDeepLink = InviteDeepLinkService.pendingDeepLink;
    if (inviteDeepLink != null) {
      return _getRouteFromInviteDeepLink(inviteDeepLink);
    }

    return null;
  },
  routes: routes,
);

String? _getRouteFromInviteDeepLink(InviteDeepLinkInfo deepLink) {
  InviteDeepLinkService.clearPendingDeepLink();

  return switch (deepLink.userStatus) {
    InvitedUserStatus.guest =>
      '${LoginPage.routeName}?challengerId=${deepLink.challengerCode}',
    InvitedUserStatus.unregisteredUser =>
      '${SupporterSignupPage.routeName}?challengerId=${deepLink.challengerCode}',
    InvitedUserStatus.registeredUser => HomePage.routeName,
  };
}
