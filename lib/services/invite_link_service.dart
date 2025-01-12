import 'package:notiyou/routes/router.dart';
import 'package:notiyou/screens/login_page.dart';
import 'package:uni_links/uni_links.dart';

class InviteLinkService {
  static Future<void> init() async {
    try {
      // 앱이 종료된 상태에서 링크로 열린 경우
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        _handleLink(initialUri);
      }

      // 앱이 실행 중일 때 링크를 처리
      uriLinkStream.listen(
        (Uri? uri) {
          if (uri != null) {
            _handleLink(uri);
          }
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
      if (uri.path.startsWith('/invite/')) {
        final challengerInviteCode = uri.pathSegments.last;
        router.push(LoginPage.routeName,
            extra: {'challengerCode': challengerInviteCode});
      } else {
        throw Exception('올바른 초대링크가 아닙니다');
      }
    } catch (error) {
      _handleError('초대링크 처리 에러', error);
    }
  }

  static void _handleError(String message, dynamic error) {
    // TODO: 에러 로깅
    try {
      router.go(LoginPage.routeName); // 또는 다른 적절한 fallback 라우트
    } catch (error) {
      throw Exception('리다이렉트 실패: $error');
    }
  }
}
