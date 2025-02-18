import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:notiyou/repositories/supabase_table_names_constants.dart';
import 'package:notiyou/repositories/user_metadata_repository/user_metadata_repository_interface.dart';
import 'package:notiyou/services/supabase_service.dart';

class UserMetadataRepositoryRemote implements UserMetadataRepository {
  static final UserMetadataRepositoryRemote _instance =
      UserMetadataRepositoryRemote._internal();

  UserMetadataRepositoryRemote._internal();

  factory UserMetadataRepositoryRemote() {
    return _instance;
  }

  static final supabaseClient = SupabaseService.client;

  @override
  Future<void> setFCMToken(String token) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('User not found');
    }

    final userMetadata = await supabaseClient
        .from(SupabaseTableNames.userMetadata)
        .select()
        .eq('id', userId);

    if (userMetadata.isEmpty) {
      await supabaseClient.from(SupabaseTableNames.userMetadata).insert({
        'id': userId,
        'fcm_token': token,
      });
    } else {
      await supabaseClient.from(SupabaseTableNames.userMetadata).update({
        'fcm_token': token,
      }).eq('id', userId);
    }
  }

  @override
  Future<String?> getFCMToken() async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      return null;
    }

    final userMetadata = await supabaseClient
        .from(SupabaseTableNames.userMetadata)
        .select()
        .eq('id', userId);

    if (userMetadata.isEmpty) {
      return null;
    }
    final data = userMetadata.first;
    return data['fcm_token'];
  }
}
