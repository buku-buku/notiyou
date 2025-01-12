import 'package:app_links/app_links.dart';
import 'package:notiyou/routes/router.dart';
import 'package:notiyou/screens/home_page.dart';
import 'package:notiyou/screens/login_page.dart';

class InviteLinkService {
  static final _appLinks = AppLinks();

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

  static void _handleLink(Uri uri) {
    try {
      String parsedChallengerCode = '';
      if (uri.scheme.startsWith('kakao')) {
        final uriString = uri.toString();
        parsedChallengerCode = uriString.split('challenger_code=').last;
      } else if (uri.path.startsWith('/invite/')) {
        parsedChallengerCode = uri.pathSegments.last;
      } else {
        throw Exception('올바른 초대링크가 아닙니다');
      }

      router.push(LoginPage.routeName,
          extra: {'challengerCode': parsedChallengerCode});
    } catch (error) {
      _handleError('초대링크 처리 에러', error);
    }
  }

  static void _handleError(String message, dynamic error) {
    // TODO: 에러 로깅
    router.go(HomePage.routeName); // 또는 다른 적절한 fallback 라우트
  }
}
