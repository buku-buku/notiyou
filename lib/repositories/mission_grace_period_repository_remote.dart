import 'package:notiyou/repositories/mission_grace_period_repository_interface.dart';
import 'package:notiyou/repositories/supabase_table_names_constants.dart';
import 'package:notiyou/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MissionGracePeriodRepositoryRemote
    implements MissionGracePeriodRepository {
  static final MissionGracePeriodRepositoryRemote _instance =
      MissionGracePeriodRepositoryRemote._internal();

  factory MissionGracePeriodRepositoryRemote() {
    return _instance;
  }

  MissionGracePeriodRepositoryRemote._internal();

  static final supabaseClient = SupabaseService.client;

  @override
  Future<int> getGracePeriod() async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('User not found');
    }

    final gracePeriod = await supabaseClient
        .from(SupabaseTableNames.challengerGracePeriod)
        .select('grace_period')
        .eq('challenger_id', userId);

    return gracePeriod.isNotEmpty ? gracePeriod.first['grace_period'] : 0;
  }

  @override
  Future<void> setGracePeriod(int gracePeriod) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('User not found');
    }

    final hasGracePeriod = await supabaseClient
        .from(SupabaseTableNames.challengerGracePeriod)
        .select('id')
        .eq('challenger_id', userId);

    if (hasGracePeriod.isNotEmpty) {
      await supabaseClient
          .from(SupabaseTableNames.challengerGracePeriod)
          .update({'grace_period': gracePeriod}).eq('challenger_id', userId);
    } else {
      await supabaseClient
          .from('challenger_grace_period')
          .insert({'challenger_id': userId, 'grace_period': gracePeriod});
    }
  }
}
