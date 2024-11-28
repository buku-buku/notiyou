import '../repositories/supporter_repository.dart';

class SupporterService {
  static Future<Map<String, dynamic>?> getSupporter(String userId) async {
    final supporter = await SupporterRepository.getSupporter(userId);
    return supporter;
  }

  static Future<bool> deleteSupporter(String userId) async {
    final result = await SupporterRepository.deleteSupporter(userId);
    return result;
  }
}
