import 'package:notiyou/services/supabase_service.dart';

class SupporterRepository {
  static Future<Map<String, dynamic>?> getSupporter(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('supporters')
          .select('*')
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }

  // 서포터 삭제
  static Future<bool> deleteSupporter(String userId) async {
    try {
      await SupabaseService.client
          .from('supporters')
          .update({'is_deleted': true}).eq('user_id', userId);
      return true;
    } catch (e) {
      return false;
    }
  }
}
