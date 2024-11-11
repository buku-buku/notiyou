import 'package:notiyou/services/dotenv_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static late final SupabaseClient _client;
  static SupabaseClient get client => _client;

  static Future<void> init() async {
    final supabaseUrl = DotEnvService.getValue('SUPABASE_URL');
    final supabaseAnonKey = DotEnvService.getValue('SUPABASE_ANON_KEY');

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  @Deprecated('요청 테스트용으로 작성된 메서드로, 이후 기능 개발 시 삭제 예정')
  static Future<PostgrestList> test() async {
    return await _client.from('test').select('*');
  }
}
