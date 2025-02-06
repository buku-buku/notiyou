import 'package:flutter/material.dart';
import 'package:notiyou/models/mission_time_model.dart';
import 'package:notiyou/repositories/mission_time_repository_interface.dart';
import 'package:notiyou/repositories/supabase_table_names_constants.dart';
import 'package:notiyou/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:notiyou/utils/time_utils.dart';

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

  @override
  Future<List<MissionTime>> getMissionTimes() async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('User not found');
    }

    final missionTimes = await supabaseClient
        .from(SupabaseTableNames.missionTime)
        .select(
            'id, created_at, updated_at, challenger_id, mission_at, supporter_id')
        .eq('challenger_id', userId)
        .order('mission_at', ascending: true);

    return missionTimes
        .map((entity) => MissionTime.fromJson(
              id: entity['id'],
              createdAt: entity['created_at'],
              updatedAt: entity['updated_at'],
              challengerId: entity['challenger_id'],
              missionAt: entity['mission_at'],
              supporterId: entity['supporter_id'],
            ))
        .toList();
  }

  @override
  Future<MissionTime?> getMissionTime(int missionId) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('User not found');
    }

    final mission = await supabaseClient
        .from(SupabaseTableNames.missionTime)
        .select(
            'id, created_at, updated_at, challenger_id, mission_at, supporter_id')
        .eq('challenger_id', userId)
        .eq('id', missionId);

    return mission.isNotEmpty
        ? MissionTime.fromJson(
            id: mission.first['id'],
            createdAt: mission.first['created_at'],
            updatedAt: mission.first['updated_at'],
            challengerId: mission.first['challenger_id'],
            missionAt: mission.first['mission_at'],
            supporterId: mission.first['supporter_id'],
          )
        : null;
  }

  // TODO: 조력자와 미션(도전자)를 매칭하는 방식 개편 필요
  @override
  Future getMissionByUserId(String challengerId) async {
    final mission = await supabaseClient
        .from('challenger_mission_time')
        .select('*')
        .eq('challenger_id', challengerId);

    return mission;
  }

  @override
  Future<void> setMissionSupporter(
      String challengerId, String supporterId) async {
    await supabaseClient.from('challenger_mission_time').update(
        {'supporter_id': supporterId}).eq('challenger_id', challengerId);
  }

  // 미션 시간 설정
  @override
  Future<MissionTime> createMissionTime(TimeOfDay time) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('User not found');
    }

    final mission = await supabaseClient
        .from(SupabaseTableNames.missionTime)
        .insert({
          'challenger_id': userId,
          'mission_at': TimeUtils.stringifyTime(time),
        })
        .select(
            'id, created_at, updated_at, challenger_id, mission_at, supporter_id')
        .single();

    return MissionTime.fromJson(
      id: mission['id'],
      createdAt: mission['created_at'],
      updatedAt: mission['updated_at'],
      challengerId: mission['challenger_id'],
      missionAt: mission['mission_at'],
      supporterId: mission['supporter_id'],
    );
  }

  @override
  Future<void> updateMissionTime(int missionId, TimeOfDay time) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('User not found');
    }
    await supabaseClient
        .from(SupabaseTableNames.missionTime)
        .update({'mission_at': TimeUtils.stringifyTime(time)})
        .eq('id', missionId)
        .eq('challenger_id', userId);
  }

  // 미션 시간 초기화
  @override
  Future<void> removeMissionTime(int missionId) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('User not found');
    }
    await supabaseClient
        .from(SupabaseTableNames.missionTime)
        .delete()
        .eq('challenger_id', userId)
        .eq('id', missionId);
  }
}
