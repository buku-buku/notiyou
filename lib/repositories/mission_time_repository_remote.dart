import 'package:flutter/material.dart';
import 'package:notiyou/repositories/mission_time_repository_interface.dart';
import 'package:notiyou/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/time_utils.dart';

/// 미션 시간 데이터를 관리하는 저장소입니다.
///
/// 설정된 미션 시간은 서버에 기록되며, 서버에서 미션을 생성할때 사용됩니다.
///
class MissionTimeRepositoryRemote implements MissionTimeRepository {
  // 싱글턴 인스턴스
  static final MissionTimeRepositoryRemote _instance =
      MissionTimeRepositoryRemote._internal();

  // 팩토리 생성자
  factory MissionTimeRepositoryRemote() {
    return _instance;
  }

  // private 생성자
  MissionTimeRepositoryRemote._internal();

  static final supabaseClient = SupabaseService.client;

  @override
  Future<void> init() async {}

  // 미션 시간 조회
  @override
  Future<TimeOfDay?> getMissionTime(int missionNumber) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('User not found');
    }

    final mission = await supabaseClient
        .from('missions')
        .select('mission_at')
        .eq('user_id', userId)
        .eq('mission_number', missionNumber);

    return mission.isNotEmpty
        ? TimeUtils.parseTime(mission.first['mission_at'])
        : null;
  }

  // 미션 시간 설정
  @override
  Future<void> setMissionTime(int missionNumber, TimeOfDay time) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('User not found');
    }
    final hasMission = await supabaseClient
        .from('missions')
        .select('id')
        .eq('user_id', userId)
        .eq('mission_number', missionNumber);

    if (hasMission.isNotEmpty) {
      await supabaseClient
          .from('missions')
          .update({'mission_at': TimeUtils.stringifyTime(time)})
          .eq('user_id', userId)
          .eq('mission_number', missionNumber);
    } else {
      await supabaseClient.from('missions').insert({
        'user_id': userId,
        'mission_number': missionNumber,
        'mission_at': TimeUtils.stringifyTime(time),
      });
    }
  }

  // 미션 시간 초기화
  @override
  Future<void> clearMissionTime(int missionNumber) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('User not found');
    }
    await supabaseClient
        .from('missions')
        .delete()
        .eq('user_id', userId)
        .eq('mission_number', missionNumber);
  }
}
