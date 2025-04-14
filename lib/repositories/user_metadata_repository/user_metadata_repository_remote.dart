import 'package:notiyou/exceptions/repository_exception.dart';
import 'package:notiyou/models/registration_status.dart';
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

  @override
  Future<void> setName(String name) async {
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
        'name': name,
      });
    } else {
      await supabaseClient.from(SupabaseTableNames.userMetadata).update({
        'name': name,
      }).eq('id', userId);
    }
  }

  @override
  Future<String?> getName() async {
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
    return data['name'];
  }

  @override
  Future<Map<String, dynamic>> getUserMetadataByUserId(String userId) async {
    final userMetadata = await supabaseClient
        .from(SupabaseTableNames.userMetadata)
        .select()
        .eq('id', userId);

    if (userMetadata.isEmpty) {
      throw EntityNotFoundException(
        'User not found',
        details: 'No user found with ID: $userId',
      );
    }

    if (userMetadata.length > 1) {
      throw RepositoryException(
        'Multiple user metadata found for user ID: $userId',
      );
    }

    return userMetadata.first;
  }

  @override
  Future<UserRole> getRole(String userId) async {
    final result = await supabaseClient
        .from(SupabaseTableNames.userMetadata)
        .select('role')
        .eq('id', userId)
        .single();

    return UserRole.fromString(result['role']);
  }

  @override
  Future<void> updateRole(String userId, UserRole role) async {
    await supabaseClient.from(SupabaseTableNames.userMetadata).update({
      'role': role.name,
    }).eq('id', userId);
  }
}
