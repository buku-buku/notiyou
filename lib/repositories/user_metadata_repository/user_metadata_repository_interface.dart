import 'package:notiyou/models/registration_status.dart';

abstract class UserMetadataRepository {
  Future<void> setFCMToken(String token);
  Future<String?> getFCMToken();
  Future<void> setName(String name);
  Future<String?> getName();
  Future<Map<String, dynamic>> getUserMetadataByUserId(String userId);
  Future<UserRole> getRole(String userId);
  Future<void> updateRole(String userId, UserRole role);
}
