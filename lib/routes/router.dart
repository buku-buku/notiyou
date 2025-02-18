import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:notiyou/routes/index.dart';
import 'package:notiyou/screens/splash_page.dart';
import 'package:notiyou/screens/home_page.dart';
import 'package:notiyou/screens/login_page.dart';
import 'package:notiyou/screens/signup_page.dart';
import 'package:notiyou/screens/supporter_signup_page.dart';
import 'package:notiyou/services/auth/auth_service.dart';
import 'package:notiyou/services/invite_deep_link_service.dart';

bool _isFirstNavigation = true;

final router = GoRouter(
  initialLocation: SplashPage.routeName,
  redirect: (context, state) async {
    FlutterNativeSplash.remove();

    final inviteDeepLink = InviteDeepLinkService.pendingDeepLink;
    if (inviteDeepLink != null) {
      return _handleInviteDeepLink(inviteDeepLink);
    }

    if (_isFirstNavigation) {
      _isFirstNavigation = false;
      return await _handleAuthState(state.uri.toString());
    }

    return null;
  },
  routes: routes,
);

String? _handleInviteDeepLink(InviteDeepLinkInfo deepLink) {
  InviteDeepLinkService.clearPendingDeepLink();

  return switch (deepLink.userStatus) {
    InvitedUserStatus.guest =>
      '${LoginPage.routeName}?challengerId=${deepLink.challengerId}',
    InvitedUserStatus.unregisteredUser =>
      '${SupporterSignupPage.routeName}?challengerId=${deepLink.challengerId}',
    InvitedUserStatus.registeredUser => HomePage.routeName,
  };
}

Future<String?> _handleAuthState(String currentLocation) async {
  final uri = Uri.parse(currentLocation);
  final queryParams = uri.queryParameters.isEmpty ? '' : '?${uri.query}';

  try {
    final user = await AuthService.getUser();
    if (user == null) {
      throw Exception('User not found');
    }

    final isRegistrationComplete = AuthService.isRegistrationCompleted(user);
    if (!isRegistrationComplete) {
      if (uri.path.startsWith(SupporterSignupPage.routeName)) {
        return currentLocation;
      }

      return '${SignupPage.routeName}$queryParams';
    }

    if (currentLocation == SplashPage.routeName ||
        currentLocation == LoginPage.routeName) {
      return '${HomePage.routeName}$queryParams';
    }
    return null;
  } catch (e) {
    return '${LoginPage.routeName}$queryParams';
  }
}
