import 'package:notiyou/models/registration_status.dart';
import 'package:notiyou/repositories/user_metadata_repository/user_metadata_repository_remote.dart';
import 'package:notiyou/services/auth/auth_service.dart';

class UserMetadataService {
  static final userMetadataRepository = UserMetadataRepositoryRemote();

  static Future<void> setRole(String userId, UserRole role) async {
    await userMetadataRepository.updateRole(userId, role);
  }

  static Future<UserRole> getRole(String userId) async {
    return await userMetadataRepository.getRole(userId);
  }

  static Future<bool> isRoleRegistrationCompleted() async {
    final userId = await AuthService.getUserId();
    final role = await getRole(userId);
    return role != UserRole.none;
  }
}
