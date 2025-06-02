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

  static Future<supabase.User?> signInWithApple(
      String idToken, String rawNonce) async {
    final authResponse = await SupabaseService.client.auth.signInWithIdToken(
      provider: supabase.OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
    return authResponse.user;
  }

  static Future<void> signOut() async {
    await SupabaseService.client.auth.signOut();
  }

  static Future<supabase.User?> getUser() async {
    return SupabaseService.client.auth.currentUser;
  }
}
