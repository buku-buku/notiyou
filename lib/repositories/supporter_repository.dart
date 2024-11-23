import 'package:supabase_flutter/supabase_flutter.dart';

class SupporterRepository {
  final SupabaseClient _supabase;

  SupporterRepository({required SupabaseClient supabase})
      : _supabase = supabase;

  // 서포터 정보 조회
  Future<Map<String, dynamic>?> getSupporter(String userId) async {
    try {
      final response = await _supabase
          .from('supporters')
          .select()
          .eq('user_id', userId)
          .single();
      return response;
    } catch (e) {
      return null;
    }
  }

  // 서포터 상태 확인
  Future<String?> getSupporterStatus(String userId) async {
    try {
      final response = await _supabase
          .from('supporters')
          .select('status')
          .eq('user_id', userId)
          .single();
      return response['status'] as String?;
    } catch (e) {
      return null;
    }
  }

  // 새로운 서포터 생성
  Future<bool> createSupporter({
    required String userId,
    required String supporterId,
    String status = 'waiting', // 기본값은 'waiting'
  }) async {
    try {
      await _supabase.from('supporters').insert({
        'user_id': userId,
        'supporter_id': supporterId,
        'status': status,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  // 서포터 상태 업데이트
  Future<bool> updateSupporterStatus({
    required String userId,
    required String status,
  }) async {
    try {
      await _supabase
          .from('supporters')
          .update({'status': status}).eq('user_id', userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 서포터 삭제
  Future<bool> deleteSupporter(String userId) async {
    try {
      await _supabase.from('supporters').delete().eq('user_id', userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // 서포터 존재 여부 확인
  Future<bool> hasSupporter(String userId) async {
    try {
      await _supabase
          .from('supporters')
          .select('id')
          .eq('user_id', userId)
          .single();
      return true;
    } catch (e) {
      return false;
    }
  }
}
