import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:notiyou/services/supabase_service.dart';

class SupabaseAuthService {
  static Future<supabase.User?> signInWithKakaoToken(String idToken) async {
    final authResponse = await SupabaseService.client.auth.signInWithIdToken(
      provider: supabase.OAuthProvider.kakao,
      idToken: idToken,
    );
    return authResponse.user;
  }

  static Future<void> signOut() async {
    await SupabaseService.client.auth.signOut();
  }

  static Future<supabase.User?> getUser() async {
    return SupabaseService.client.auth.currentUser;
  }

  static bool isRegistrationCompleted(supabase.User user) {
    final registrationStatus = getRegistrationStatus(user);
    return registrationStatus['invitation_code'] == true &&
        registrationStatus['mission_setting'] == true;
  }

  static Map<String, bool> getRegistrationStatus(supabase.User user) {
    if (user.userMetadata == null) {
      return {
        'invitation_code': false,
        'mission_setting': false,
      };
    }
    // * 초대코드 및 미션 설정까지 입력 받아야 회원가입이 완료되었다고 판단할 수 있음
    return {
      'invitation_code': user.userMetadata!['invitation_code'] != null,
      'mission_setting': user.userMetadata!['mission_setting'] != null,
    };
  }
}
