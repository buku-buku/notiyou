import 'package:notiyou/services/auth/auth_service.dart';

import '../repositories/supporter_repository.dart';

class SupporterService {
  static Future<Map<String, dynamic>?> getSupporter() async {
    final user = await AuthService.getUser();
    if (user != null) {
      return await SupporterRepository.getSupporter(user.id);
    }
    return null;
  }

  static Future<bool> deleteSupporter(String userId) async {
    final result = await SupporterRepository.deleteSupporter(userId);
    return result;
  }
}
