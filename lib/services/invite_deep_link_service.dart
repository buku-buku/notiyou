import 'package:app_links/app_links.dart';
import 'package:notiyou/services/auth/auth_service.dart';
import 'package:notiyou/services/challenger_code/challenger_code_service.dart';
import 'package:notiyou/services/challenger_code/challenger_code_service_interface.dart';
import 'package:notiyou/services/dotenv_service.dart';
import 'package:notiyou/routes/router.dart';

enum InvitedUserStatus {
  guest,
  unregisteredUser,
  registeredUser,
}

class InviteDeepLinkInfo {
  final String challengerCode;
  final InvitedUserStatus userStatus;

  InviteDeepLinkInfo({
    required this.challengerCode,
    required this.userStatus,
  });
}

extension InviteDeepLinkInfoDebug on InviteDeepLinkInfo {
  String debugString() {
    return 'InviteDeepLinkInfo(challengerCode: $challengerCode, userStatus: $userStatus)';
  }
}

class InviteDeepLinkService {
  static final _appLinks = AppLinks();
  static final ChallengerCodeService _challengerCodeService =
      ChallengerCodeServiceImpl.instance;

  static InviteDeepLinkInfo? _pendingDeepLink;

  static InviteDeepLinkInfo? get pendingDeepLink => _pendingDeepLink;

  static void clearPendingDeepLink() {
    _pendingDeepLink = null;
  }

  static Future<void> init() async {
    try {
      await _handleInitialDeepLink();
      _listenToDeepLinks();
    } catch (error) {
      _resetToDefaultState(error);
    }
  }

  static Future<void> _handleInitialDeepLink() async {
    // 앱이 종료된 상태에서 링크로 열린 경우
    final initialUri = await _appLinks.getInitialAppLink();
    if (initialUri != null) {
      await _processDeepLink(initialUri);
    }
  }

  static void _listenToDeepLinks() {
    _appLinks.uriLinkStream.listen(
      (uri) async {
        await _processDeepLink(uri);
        routerRefreshNotifier.value = !routerRefreshNotifier.value;
      },
      onError: (error) => _resetToDefaultState(error),
    );
  }

  static Future<void> _processDeepLink(Uri uri) async {
    try {
      final challengerCode = _extractChallengerCode(uri);

      final userStatus = await _getUserStatus();

      _pendingDeepLink = InviteDeepLinkInfo(
        challengerCode: challengerCode,
        userStatus: userStatus,
      );
    } catch (error) {
      _resetToDefaultState(error);
    }
  }

  static String _extractChallengerCode(Uri uri) {
    if (uri.scheme.startsWith('kakao')) {
      return uri.toString().split('challenger_code=').last;
    }
    if (uri.path.startsWith('/invite/')) {
      return uri.pathSegments.last;
    }
    throw Exception('올바른 초대링크가 아닙니다');
  }

  static Future<InvitedUserStatus> _getUserStatus() async {
    final user = await AuthService.getUser();

    if (user == null) {
      return InvitedUserStatus.guest;
    }

    if (AuthService.isRegistrationCompleted(user)) {
      return InvitedUserStatus.registeredUser;
    }

    return InvitedUserStatus.unregisteredUser;
  }

  static Future<String> generateDeepLink(String userId) async {
    try {
      final challengerCode = await _challengerCodeService.generateCode(userId);
      final serviceWebDomain = DotEnvService.getValue('SERVICE_WEB_DOMAIN');
      return '$serviceWebDomain/invite/$challengerCode';
    } catch (e) {
      throw Exception('초대 링크 생성에 실패했습니다');
    }
  }

  static void _resetToDefaultState(dynamic error) {
    _pendingDeepLink = null;
  }
}
