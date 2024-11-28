import '../services/supabase_service.dart';

class SupporterRepository {
  static Future<Map<String, dynamic>?> getSupporter(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('supporters')
          .select('*')
          .eq('user_id', userId)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }

  // 서포터 삭제
  static Future<bool> deleteSupporter(String userId) async {
    try {
      await await SupabaseService.client
          .from('supporters')
          .delete()
          .eq('user_id', userId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
