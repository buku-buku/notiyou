import 'package:notiyou/models/registration_status.dart';
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

  static Future<void> setRole(UserRole role) async {
    final userMetadata =
        SupabaseService.client.auth.currentUser?.userMetadata ?? {};
    // TODO: Add error handling for updateUser operation
    await SupabaseService.client.auth.updateUser(
      supabase.UserAttributes(
        data: {
          ...userMetadata,
          'registered_role': role.name,
        },
      ),
    );
  }

  static bool isRegistrationCompleted(supabase.User user) {
    final registrationStatus = getRegistrationStatus(user);
    return registrationStatus.registeredRole != UserRole.none;
  }

  static RegistrationStatus getRegistrationStatus(supabase.User user) {
    if (user.userMetadata == null) {
      return RegistrationStatus(
        registeredRole: UserRole.none,
      );
    }

    return RegistrationStatus.fromString(
      user.userMetadata!['registered_role'],
    );
  }
}
