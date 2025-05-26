import 'package:notiyou/repositories/supabase_table_names_constants.dart';
import 'package:notiyou/repositories/user_deletion_request_repository/user_deletion_request_repository_interface.dart';
import 'package:notiyou/services/supabase_service.dart';

class UserDeletionRequestRepositoryRemote
    implements UserDeletionRequestRepositoryInterface {
  static final UserDeletionRequestRepositoryRemote _instance =
      UserDeletionRequestRepositoryRemote._internal();

  UserDeletionRequestRepositoryRemote._internal();

  factory UserDeletionRequestRepositoryRemote() {
    return _instance;
  }

  static final supabaseClient = SupabaseService.client;

  @override
  Future<void> createUserDeletionRequest(String userId) async {
    await SupabaseService.client
        .from(SupabaseTableNames.userDeletionRequest)
        .insert({
      'user_id': userId,
    });
  }
}
