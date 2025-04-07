import 'package:notiyou/repositories/notification_template_repository/notification_template_repository_interface.dart';
import 'package:notiyou/repositories/supabase_table_names_constants.dart';
import 'package:notiyou/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationTemplateRepositoryRemote
    implements NotificationTemplateRepository {
  String get defaultSuccessMessageTemplate => '미션을 성공했습니다!';
  String get defaultFailureMessageTemplate => '미션을 실패했습니다.';

  static final NotificationTemplateRepositoryRemote _instance =
      NotificationTemplateRepositoryRemote._internal();

  factory NotificationTemplateRepositoryRemote() {
    return _instance;
  }

  NotificationTemplateRepositoryRemote._internal();

  static final supabaseClient = SupabaseService.client;

  @override
  Future<void> init() async {}

  @override
  Future<String> getSuccessMessageTemplate() async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('User not found');
    }

    final missionMessage = await supabaseClient
        .from(SupabaseTableNames.missionMessages)
        .select('success_message')
        .eq('user_id', userId)
        .maybeSingle();

    return missionMessage?['success_message'] ?? defaultSuccessMessageTemplate;
  }

  @override
  Future<String> getFailureMessageTemplate() async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('User not found');
    }

    final missionMessage = await supabaseClient
        .from(SupabaseTableNames.missionMessages)
        .select('fail_message')
        .eq('user_id', userId)
        .maybeSingle();

    return missionMessage?['fail_message'] ?? defaultFailureMessageTemplate;
  }

  @override
  Future<bool> setSuccessMessageTemplate(String template) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('User not found');
    }

    try {
      await supabaseClient.from(SupabaseTableNames.missionMessages).upsert({
        'user_id': userId,
        'success_message': template,
      }, onConflict: 'user_id');
      return true;
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Future<bool> setFailureMessageTemplate(String template) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('User not found');
    }

    try {
      await supabaseClient.from(SupabaseTableNames.missionMessages).upsert({
        'user_id': userId,
        'fail_message': template,
      }, onConflict: 'user_id');
      return true;
    } catch (e) {
      throw Exception(e);
    }
  }
}
