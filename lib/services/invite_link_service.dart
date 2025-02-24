import 'package:app_links/app_links.dart';
import 'package:notiyou/routes/router.dart';
import 'package:notiyou/screens/home_page.dart';
import 'package:notiyou/screens/login_page.dart';
import 'package:notiyou/screens/splash_page.dart';
import 'package:notiyou/screens/supporter_signup_page.dart';
import 'package:notiyou/services/auth/auth_service.dart';
import 'package:notiyou/services/challenger_code/challenger_code_service.dart';
import 'package:notiyou/services/challenger_code/challenger_code_service_interface.dart';
import 'package:notiyou/services/dotenv_service.dart';

enum InvitedUserStatus {
  guest,
  unregisteredUser,
  registeredUser,
}

class InviteLinkService {
  static final _appLinks = AppLinks();
  static final ChallengerCodeService _challengerCodeService =
      ChallengerCodeServiceImpl.instance;

  static Future<void> init() async {
    try {
      // 앱이 종료된 상태에서 링크로 열린 경우
      final initialUri = await _appLinks.getInitialAppLink();
      if (initialUri != null) {
        _handleLink(initialUri);
      }

      // 앱이 실행 중일 때 링크를 처리
      _appLinks.uriLinkStream.listen(
        (uri) {
          _handleLink(uri);
        },
        onError: (error) {
          _handleError('초대링크 스트림 에러', error);
        },
      );
    } catch (error) {
      _handleError('초대링크 초기화 에러', error);
    }
  }

  static Future<String> generateInviteLink(String userId) async {
    try {
      final challengerCode = await _challengerCodeService.generateCode(userId);
      final serviceWebDomain = DotEnvService.getValue('SERVICE_WEB_DOMAIN');
      return '$serviceWebDomain/invite/$challengerCode';
    } catch (e) {
      throw Exception('초대 링크 생성에 실패했습니다');
    }
  }

  static Future<void> _handleLink(Uri uri) async {
    try {
      String? challengerCode;
      if (uri.scheme.startsWith('kakao')) {
        final uriString = uri.toString();
        challengerCode = uriString.split('challenger_code=').last;
      } else if (uri.path.startsWith('/invite/')) {
        challengerCode = uri.pathSegments.last;
      } else {
        throw Exception('올바른 초대링크가 아닙니다');
      }

      final userStatus = await _checkUserStatus();
      switch (userStatus) {
        case InvitedUserStatus.guest:
          router.push(LoginPage.routeName, extra: challengerCode);
        case InvitedUserStatus.unregisteredUser:
          router.push(SupporterSignupPage.routeName, extra: challengerCode);
        case InvitedUserStatus.registeredUser:
          router.push(HomePage.routeName);
      }
    } catch (error) {
      _handleError('초대링크 처리 에러', error);
    }
  }

  static Future<InvitedUserStatus> _checkUserStatus() async {
    final user = await AuthService.getUser();

    if (user == null) {
      return InvitedUserStatus.guest;
    } else if (AuthService.isRegistrationCompleted(user)) {
      return InvitedUserStatus.registeredUser;
    } else {
      return InvitedUserStatus.unregisteredUser;
    }
  }

  static void _handleError(String message, dynamic error) {
    // TODO: 에러 로깅
    router.go(SplashPage.routeName);
  }
}
