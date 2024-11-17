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
}
