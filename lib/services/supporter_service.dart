import '../repositories/supporter_repository.dart';

class SupporterService {
  static Future<Map<String, dynamic>?> getSupporter(String userId) async {
    final supporter = await SupporterRepository.getSupporter(userId);
    return supporter;
  }
}
